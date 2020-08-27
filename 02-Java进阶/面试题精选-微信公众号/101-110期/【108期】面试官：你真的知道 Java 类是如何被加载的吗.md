## 【108期】面试官：你真的知道 Java 类是如何被加载的吗？

## 一：前言

最近给一个非Java方向的朋友讲了下双亲委派模型，朋友让我写篇文章深度研究下JVM的ClassLoader，我确实也好久没写JVM相关的文章了，有点手痒痒，涂了皮炎平也抑制不住。

我在向朋友解释的时候是这么说的：双亲委派模型中，ClassLoader在加载类的时候，会先交由它的父ClassLoader加载，只有当父ClassLoader加载失败的情况下，才会尝试自己去加载。这样可以实现部分类的复用，又可以实现部分类的隔离，因为不同ClassLoader加载的类是互相隔离的。

不过贸然的向别人解释双亲委派模型是不妥的，如果在不了解JVM的类加载机制的情况下，又如何能很好的理解“不同ClassLoader加载的类是互相隔离的”这句话呢？所以为了理解双亲委派，最好的方式，就是先了解下ClassLoader的加载流程。

## 二：Java 类是如何被加载的

### 2.1：何时加载类

我们首先要清楚的是，Java类何时会被加载？

《深入理解Java虚拟机》给出的答案是：

> - 遇到new、getstatic、putstatic 等指令时。
> - 对类进行反射调用的时候。
> - 初始化某个类的子类的时候。
> - 虚拟机启动时会先加载设置的程序主类。
> - 使用JDK 1.7 的动态语言支持的时候。

其实要我说，最通俗易懂的答案就是：当运行过程中需要这个类的时候。

那么我们不妨就从如何加载类开始说起。

### 2.2：怎么加载类

利用ClassLoader加载类很简单，直接调用ClassLoder的loadClass（）方法即可，我相信大家都会，但是还是要举个栗子：

```
public class Test {
    public static void main(String[] args) throws ClassNotFoundException {
        Test.class.getClassLoader().loadClass("com.wangxiandeng.test.Dog");
    }
}
```

上面这段代码便实现了让ClassLoader去加载 “com.wangxiandeng.test.Dog” 这个类，是不是 so easy。但是JDK 提供的 API 只是冰山一角，看似很简单的一个调用，其实隐藏了非常多的细节，我这个人吧，最喜欢做的就是去揭开 API 的封装，一探究竟。

### 2.3：JVM 是怎么加载类的

JVM 默认用于加载用户程序的ClassLoader为AppClassLoader，不过无论是什么ClassLoader，它的根父类都是java.lang.ClassLoader。在上面那个例子中，loadClass（）方法最终会调用到ClassLoader.definClass1（）中，这是一个 Native 方法。

```
static native Class<?> defineClass1(ClassLoader loader, String name, byte[] b, int off, int len,
                                        ProtectionDomain pd, String source); 
```

看到 Native 方法莫心慌，不要急，打开OpenJDK源码，我等继续走马观花便是！

definClass1（）对应的 JNI 方法为 Java_java_lang_ClassLoader_defineClass1（）

```
JNIEXPORT jclass JNICALL
Java_java_lang_ClassLoader_defineClass1(JNIEnv *env,
                                        jclass cls,
                                        jobject loader,
                                        jstring name,
                                        jbyteArray data,
                                        jint offset,
                                        jint length,
                                        jobject pd,
                                        jstring source)
{
    ......
    result = JVM_DefineClassWithSource(env, utfName, loader, body, length, pd, utfSource);
    ......
    return result;
}
```

Java_java_lang_ClassLoader_defineClass1 主要是调用了JVM_DefineClassWithSource（）加载类，跟着源码往下走，会发现最终调用的是 jvm.cpp 中的 jvm_define_class_common（）方法。

```
static jclass jvm_define_class_common(JNIEnv *env, const char *name,
                                      jobject loader, const jbyte *buf,
                                      jsize len, jobject pd, const char *source,
                                      TRAPS) {
  ......
  ClassFileStream st((u1*)buf, len, source, ClassFileStream::verify);
  Handle class_loader (THREAD, JNIHandles::resolve(loader));
  if (UsePerfData) {
    is_lock_held_by_thread(class_loader,
                           ClassLoader::sync_JVMDefineClassLockFreeCounter(),
                           THREAD);
  }
  Handle protection_domain (THREAD, JNIHandles::resolve(pd));
  Klass* k = SystemDictionary::resolve_from_stream(class_name,
                                                   class_loader,
                                                   protection_domain,
                                                   &st,
                                                   CHECK_NULL);
  ......

  return (jclass) JNIHandles::make_local(env, k->java_mirror());
}
```

上面这段逻辑主要就是利用 ClassFileStream 将要加载的class文件转成文件流，然后调用SystemDictionary::resolve_from_stream（），生成 Class 在 JVM 中的代表：Klass。

对于Klass，大家可能不太熟悉，但是在这里必须得了解下。说白了，它就是JVM 用来定义一个Java Class 的数据结构。不过Klass只是一个基类，Java Class 真正的数据结构定义在 InstanceKlass中。

```
class InstanceKlass: public Klass {

 protected:

  Annotations*    _annotations;
  ......
  ConstantPool* _constants;
  ......
  Array<jushort>* _inner_classes;
  ......
  Array<Method*>* _methods;
  Array<Method*>* _default_methods;
  ......
  Array<u2>*      _fields;
}
```

可见 InstanceKlass 中记录了一个 Java 类的所有属性，包括注解、方法、字段、内部类、常量池等信息。这些信息本来被记录在Class文件中，所以说，InstanceKlass就是一个Java Class 文件被加载到内存后的形式。

再回到上面的类加载流程中，这里调用了 SystemDictionary::resolve_from_stream（），将 Class 文件加载成内存中的 Klass。

resolve_from_stream（） 便是重中之重！主要逻辑有下面几步：

1：判断是否允许并行加载类，并根据判断结果进行加锁。

```
bool DoObjectLock = true;
if (is_parallelCapable(class_loader)) {
  DoObjectLock = false;
}
ClassLoaderData* loader_data = register_loader(class_loader, CHECK_NULL);
Handle lockObject = compute_loader_lock_object(class_loader, THREAD);
check_loader_lock_contention(lockObject, THREAD);
ObjectLocker ol(lockObject, THREAD, DoObjectLock);
```

如果允许并行加载，则不会对ClassLoader进行加锁，只对SystemDictionary加锁。否则，便会利用 ObjectLocker 对ClassLoader 加锁，保证同一个ClassLoader在同一时刻只能加载一个类。ObjectLocker 会在其构造函数中获取锁，并在析构函数中释放锁。

允许并行加载的好处便是精细化了锁粒度，这样可以在同一时刻加载多个Class文件。

2：解析文件流，生成 InstanceKlass。

```
InstanceKlass* k = NULL;

k = KlassFactory::create_from_stream(st,
                                         class_name,
                                         loader_data,
                                         protection_domain,
                                         NULL, // host_klass
                                         NULL, // cp_patches
                                         CHECK_NULL);
```

3：利用SystemDictionary注册生成的 Klass。

SystemDictionary 是用来帮助保存 ClassLoader 加载过的类信息的。准确点说，SystemDictionary并不是一个容器，真正用来保存类信息的容器是 Dictionary，每个ClassLoaderData 中都保存着一个私有的 Dictionary，而 SystemDictionary 只是一个拥有很多静态方法的工具类而已。

我们来看看注册的代码：

```
if (is_parallelCapable(class_loader)) {
  InstanceKlass* defined_k = find_or_define_instance_class(h_name, class_loader, k, THREAD);
  if (!HAS_PENDING_EXCEPTION && defined_k != k) {
    // If a parallel capable class loader already defined this class, register 'k' for cleanup.
    assert(defined_k != NULL, "Should have a klass if there's no exception");
    loader_data->add_to_deallocate_list(k);
    k = defined_k;
  }
} else {
  define_instance_class(k, THREAD);
}
```

如果允许并行加载，那么前面就不会对ClassLoader加锁，所以在同一时刻，可能对同一Class文件加载了多次。但是同一Class在同一ClassLoader中必须保持唯一性，所以这里会先利用 SystemDictionary 查询 ClassLoader 是否已经加载过相同 Class。

如果已经加载过，那么就将当前线程刚刚加载的InstanceKlass加入待回收列表，并将 InstanceKlass* k 重新指向利用SystemDictionary查询到的 InstanceKlass。
如果没有查询到，那么就将刚刚加载的 InstanceKlass 注册到 ClassLoader的 Dictionary 中 中。
虽然并行加载不会锁住ClassLoader，但是会在注册 InstanceKlass 时对 SystemDictionary 加锁，所以不需要担心InstanceKlass 在注册时的并发操作。

如果禁止了并行加载，那么直接利用SystemDictionary将 InstanceKlass 注册到 ClassLoader的 Dictionary 中即可。

resolve_from_stream（）的主要流程就是上面三步，很明显，最重要的是第二步，从文件流生成InstanceKlass。

生成InstanceKlass 调用的是 KlassFactory::create_from_stream（）方法，它的主要逻辑就是下面这段代码。

```
ClassFileParser parser(stream,
                       name,
                       loader_data,
                       protection_domain,
                       host_klass,
                       cp_patches,
                       ClassFileParser::BROADCAST, // publicity level
                       CHECK_NULL);

InstanceKlass* result = parser.create_instance_klass(old_stream != stream, CHECK_NULL);
```

原来 ClassFileParser 才是真正的主角啊！它才是将Class文件升华成InstanceKlass的幕后大佬！更多面试题，欢迎关注公众号 Java面试题精选

### 2.4：不得不说的ClassFileParser

ClassFileParser 加载Class文件的入口便是 create_instance_klass（）。顾名思义，用来创建InstanceKlass的。

create_instance_klass（）主要就干了两件事：

(1)：为 InstanceKlass 分配内存

```
InstanceKlass* const ik =
    InstanceKlass::allocate_instance_klass(*this, CHECK_NULL);
```

(2)：分析Class文件，填充 InstanceKlass 内存区域

fill_instance_klass(ik, changed_by_loadhook, CHECK_NULL);
我们先来说道说道第一件事，为 InstanceKlass 分配内存。

内存分配代码如下：

```
const int size = InstanceKlass::size(parser.vtable_size(),
                                       parser.itable_size(),
                                       nonstatic_oop_map_size(parser.total_oop_map_count()),
                                       parser.is_interface(),
                                       parser.is_anonymous(),
                                       should_store_fingerprint(parser.is_anonymous()));
ClassLoaderData* loader_data = parser.loader_data();
InstanceKlass* ik;
ik = new (loader_data, size, THREAD) InstanceKlass(parser, InstanceKlass::_misc_kind_other);
```

这里首先计算了InstanceKlass在内存中的大小，要知道，这个大小在Class 文件编译后就被确定了。

然后便 new 了一个新的 InstanceKlass 对象。这里并不是简单的在堆上分配内存，要注意的是Klass 对 new 操作符进行了重载：

```
void* Klass::operator new(size_t size, ClassLoaderData* loader_data, size_t word_size, TRAPS) throw() {
  return Metaspace::allocate(loader_data, word_size, MetaspaceObj::ClassType, THREAD);
}
```

分配 InstanceKlass 的时候调用了 Metaspace::allocate（）：

```
                             MetaspaceObj::Type type, TRAPS) {
  ......
  MetadataType mdtype = (type == MetaspaceObj::ClassType) ? ClassType : NonClassType;
  ......
  MetaWord* result = loader_data->metaspace_non_null()->allocate(word_size, mdtype);
  ......
  return result;
}
```

由此可见，InstanceKlass 是分配在 ClassLoader的 Metaspace（元空间） 的方法区中。从 JDK8 开始，HotSpot 就没有了永久代，类都分配在 Metaspace 中。Metaspace 和永久代不一样，采用的是 Native Memory，永久代由于受限于 MaxPermSize，所以当内存不够时会内存溢出。

分配完 InstanceKlass 内存后，便要着手第二件事，分析Class文件，填充 InstanceKlass 内存区域。

ClassFileParser 在构造的时候就会开始分析Class文件，所以fill_instance_klass（）中只需要填充即可。填充结束后，还会调用 java_lang_Class::create_mirror（）创建 InstanceKlass 在Java 层的 Class 对象。

```
void ClassFileParser::fill_instance_klass(InstanceKlass* ik, bool changed_by_loadhook, TRAPS) {
  .....
  ik->set_class_loader_data(_loader_data);
  ik->set_nonstatic_field_size(_field_info->nonstatic_field_size);
  ik->set_has_nonstatic_fields(_field_info->has_nonstatic_fields);
  ik->set_static_oop_field_count(_fac->count[STATIC_OOP]);
  ik->set_name(_class_name);
  ......

  java_lang_Class::create_mirror(ik,
                                 Handle(THREAD, _loader_data->class_loader()),
                                 module_handle,
                                 _protection_domain,
                                 CHECK);
}
```

到这儿，Class文件已经完成了华丽的转身，由冷冰冰的二进制文件，变成了内存中充满生命力的InstanceKlass。更多面试题，欢迎关注公众号 Java面试题精选

## 三：再谈双亲委派

如果你耐心的看完了上面的源码分析，你一定对 “不同ClassLoader加载的类是互相隔离的” 这句话的理解又上了一个台阶。

我们总结下：每个ClassLoader都有一个 Dictionary 用来保存它所加载的InstanceKlass信息。并且，每个 ClassLoader 通过锁，保证了对于同一个Class，它只会注册一份 InstanceKlass 到自己的 Dictionary 。

正式由于上面这些原因，如果所有的 ClassLoader 都由自己去加载 Class 文件，就会导致对于同一个Class文件，存在多份InstanceKlass，所以即使是同一个Class文件，不同InstanceKlasss 衍生出来的实例类型也是不一样的。

举个栗子，我们自定义一个 ClassLoader，用来打破双亲委派模型：

```
public class CustomClassloader extends URLClassLoader {

    public CustomClassloader(URL[] urls) {
        super(urls);
    }

    @Override
    protected Class<?> loadClass(String name, boolean resolve) throws ClassNotFoundException {
        if (name.startsWith("com.wangxiandeng")) {
            return findClass(name);
        }
        return super.loadClass(name, resolve);
    }
}
```

再尝试加载Studen类，并实例化：

```
public class Test {

    public static void main(String[] args) throws Exception {
        URL url[] = new URL[1];
        url[0] = Thread.currentThread().getContextClassLoader().getResource("");

        CustomClassloader customClassloader = new CustomClassloader(url);
        Class clazz = customClassloader.loadClass("com.wangxiandeng.Student");

        Student student = (Student) clazz.newInstance();
    }
}
```

运行后便会抛出类型强转异常：

```
Exception in thread "main" java.lang.ClassCastException:
      com.wangxiandeng.Student cannot be cast to com.wangxiandeng.Student
```

为什么呢？

因为实例化的Student对象所属的 InstanceKlass 是由CustomClassLoader加载生成的，而我们要强转的类型Student.Class 对应的 InstanceKlass 是由系统默认的ClassLoader生成的，所以本质上它们就是两个毫无关联的InstanceKlass，当然不能强转。

有同学问到：为什么“强转的类型Student.Class 对应的 InstanceKlass 是由系统默认的ClassLoader生成的”？

其实很简单，我们反编译下字节码：

```
  public static void main(java.lang.String[]) throws java.lang.Exception;
    descriptor: ([Ljava/lang/String;)V
    flags: ACC_PUBLIC, ACC_STATIC
    Code:
      stack=4, locals=5, args_size=1
         0: iconst_1
         1: anewarray     #2                  // class java/net/URL
         4: astore_1
         5: aload_1
         6: iconst_0
         7: invokestatic  #3                  // Method java/lang/Thread.currentThread:()Ljava/lang/Thread;
        10: invokevirtual #4                  // Method java/lang/Thread.getContextClassLoader:()Ljava/lang/ClassLoader;
        13: ldc           #5                  // String
        15: invokevirtual #6                  // Method java/lang/ClassLoader.getResource:(Ljava/lang/String;)Ljava/net/URL;
        18: aastore
        19: new           #7                  // class com/wangxiandeng/classloader/CustomClassloader
        22: dup
        23: aload_1
        24: invokespecial #8                  // Method com/wangxiandeng/classloader/CustomClassloader."<init>":([Ljava/net/URL;)V
        27: astore_2
        28: aload_2
        29: ldc           #9                  // String com.wangxiandeng.Student
        31: invokevirtual #10                 // Method com/wangxiandeng/classloader/CustomClassloader.loadClass:(Ljava/lang/String;)Ljava/lang/Class;
        34: astore_3
        35: aload_3
        36: invokevirtual #11                 // Method java/lang/Class.newInstance:()Ljava/lang/Object;
        39: checkcast     #12                 // class com/wangxiandeng/Student
        42: astore        4
        44: return
```

可以看到在利用加载的Class初始化实例后，调用了 checkcast 进行类型转化，checkcast 后的操作数 #12 即为Student这个类在常量池中的索引：`#12 = Class #52 // com/wangxiandeng/Student`

下面我们可以看看 checkcast 在HotSpot中的实现。

HotSpot 目前有三种字节码执行引擎，目前采用的是模板解释器，早期的HotSpot采用的是字节码解释器。模板解释器对于指令的执行都是用汇编写的，而字节码解释器采用的C++进行的翻译，为了看起来比较舒服，我们就不看汇编了，直接看字节码解释器就行了。如果你的汇编功底很好，当然也可以直接看模板解释器。

废话不多说，我们来看看字节码解释器对于checkcast的实现，代码在 bytecodeInterpreter.cpp 中

```
CASE(_checkcast):
    if (STACK_OBJECT(-1) != NULL) {
      VERIFY_OOP(STACK_OBJECT(-1));
      // 拿到 checkcast 指令后的操作数，本例子中即 Student.Class 在常量池中的索引：#12
      u2 index = Bytes::get_Java_u2(pc+1);

      // 如果常量池还没有解析，先进行解析，即将常量池中的符号引用替换成直接引用，
      //此时就会触发Student.Class 的加载
      if (METHOD->constants()->tag_at(index).is_unresolved_klass()) {
        CALL_VM(InterpreterRuntime::quicken_io_cc(THREAD), handle_exception);
      }
      // 获取上一步系统加载的Student.Class 对应的 InstanceKlass
      Klass* klassOf = (Klass*) METHOD->constants()->resolved_klass_at(index);
      // 获取要强转的对象的实际类型，即我们自己手动加载的Student.Class 对应的 InstanceKlass
      Klass* objKlass = STACK_OBJECT(-1)->klass(); // ebx

      // 现在就比较简单了，直接看看上面的两个InstanceKlass指针内容是否相同
      // 不同的情况下则判断是否存在继承关系
      if (objKlass != klassOf && !objKlass->is_subtype_of(klassOf)) {
        // Decrement counter at checkcast.
        BI_PROFILE_SUBTYPECHECK_FAILED(objKlass);
        ResourceMark rm(THREAD);
        char* message = SharedRuntime::generate_class_cast_message(
          objKlass, klassOf);
        VM_JAVA_ERROR(vmSymbols::java_lang_ClassCastException(), message, note_classCheck_trap);
      }
      // Profile checkcast with null_seen and receiver.
      BI_PROFILE_UPDATE_CHECKCAST(/*null_seen=*/false, objKlass);
    } else {
      // Profile checkcast with null_seen and receiver.
      BI_PROFILE_UPDATE_CHECKCAST(/*null_seen=*/true, NULL);
    }
```

通过对上面代码的分析，我相信大家已经理解了 “强转的类型Student.Class 对应的 InstanceKlass 是由系统默认的ClassLoader生成的” 这句话了。

双亲委派的好处是尽量保证了同一个Class文件只会生成一个InstanceKlass，但是某些情况，我们就不得不去打破双亲委派了，比如我们想实现Class隔离的时候。

回复下箫陌同学的问题：

```
// 如果常量池还没有解析，先进行解析，即将常量池中的符号引用替换成直接引用，
//此时就会触发Student.Class 的加载
if (METHOD->constants()->tag_at(index).is_unresolved_klass()) {
CALL_VM(InterpreterRuntime::quicken_io_cc(THREAD), handle_exception);
}
```

请问，为何这里会重新加载Student.Class？jvm是不是有自己的class加载链路，然后系统循着链路去查找class是否已经被加载？那该怎么把自定义的CustomClassloader 加到这个查询链路中去呢？

第一种方法：设置启动参数 java -Djava.system.class.loader

第二种方法：利用Thread.setContextClassLoder

这里就有点技巧了，看下代码：

```
public class Test {

    public static void main(String[] args) throws Exception {
        URL url[] = new URL[1];
        url[0] = Thread.currentThread().getContextClassLoader().getResource("");
        final CustomClassloader customClassloader = new CustomClassloader(url);
        Thread.currentThread().setContextClassLoader(customClassloader);
        Class clazz = customClassloader.loadClass("com.wangxiandeng.ClassTest");
        Object object = clazz.newInstance();
        Method method = clazz.getDeclaredMethod("test");
        method.invoke(object);
    }
}
public class ClassTest {

    public void test() throws Exception{
        Class clazz = Thread.currentThread().getContextClassLoader().loadClass("com.wangxiandeng.Student");
        Student student = (Student) clazz.newInstance();
        System.out.print(student.getClass().getClassLoader());

    }
}
```

要注意的是在设置线程的ClassLoader后，并不是直接调用 new ClassTest().test()。为什么呢？因为直接强引用的话，会在解析Test.Class的常量池时，利用系统默认的ClassLoader加载了ClassTest，从而又触发了ClassTest.Class的解析。为了避免这种情况的发生，这里利用CustomClassLoader去加载ClassTest.Class，再利用反射机制调用test（），此时在解析ClassTest.Class的常量池时，就会利用CustomClassLoader去加载Class常量池项，也就不会发生异常了。

## 四：总结

写完这篇文章，手也不痒了，甚爽！这篇文章从双亲委派讲到了Class文件的加载，最后又绕回到双亲委派，看似有点绕，其实只有理解了Class的加载机制，才能更好的理解类似双亲委派这样的机制，否则只死记硬背一些空洞的理论，是无法起到由内而外的理解的。

*来源：https://yq.aliyun.com/articles/710407*