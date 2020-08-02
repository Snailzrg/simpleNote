# JDK8新特性：使用Optional避免null导致的NullPointerException
cdsn ：https://blog.csdn.net/aitangyong/article/details/54564100

空指针异常是导致Java应用程序失败的最常见原因。以前，为了解决空指针异常，Google公司著名的Guava项目引入了Optional类，Guava通过使用检查空值的方式来防止代码污染，它鼓励程序员写更干净的代码。受到Google Guava的启发，Optional类已经成为Java 8类库的一部分。Optional实际上是个容器：它可以保存类型T的值，或者仅仅保存null。Optional提供很多有用的方法，这样我们就不用显式进行空值检测。


Optional.of()或者Optional.ofNullable()：创建Optional对象，差别在于of不允许参数是null，而ofNullable则无限制。

// 参数不能是null
Optional<Integer> optional1 = Optional.of(1);
 
// 参数可以是null
Optional<Integer> optional2 = Optional.ofNullable(null);
 
// 参数可以是非null
Optional<Integer> optional3 = Optional.ofNullable(2);

Optional.empty()：所有null包装成的Optional对象：
Optional<Integer> optional1 = Optional.ofNullable(null);
Optional<Integer> optional2 = Optional.ofNullable(null);
System.out.println(optional1 == optional2);// true
System.out.println(optional1 == Optional.<Integer>empty());// true
 
Object o1 = Optional.<Integer>empty();
Object o2 = Optional.<String>empty();
System.out.println(o1 == o2);// true

isPresent()：判断值是否存在
Optional<Integer> optional1 = Optional.ofNullable(1);
Optional<Integer> optional2 = Optional.ofNullable(null);
 
// isPresent判断值是否存在
System.out.println(optional1.isPresent() == true);
System.out.println(optional2.isPresent() == false);


ifPresent(Consumer consumer)：如果option对象保存的值不是null，则调用consumer对象，否则不调用
Optional<Integer> optional1 = Optional.ofNullable(1);
Optional<Integer> optional2 = Optional.ofNullable(null);
 
// 如果不是null,调用Consumer
optional1.ifPresent(new Consumer<Integer>() {
	@Override
	public void accept(Integer t) {
		System.out.println("value is " + t);
	}
});
 
// null,不调用Consumer
optional2.ifPresent(new Consumer<Integer>() {
	@Override
	public void accept(Integer t) {
		System.out.println("value is " + t);
	}
});


orElse(value)：如果optional对象保存的值不是null，则返回原来的值，否则返回value
Optional<Integer> optional1 = Optional.ofNullable(1);
Optional<Integer> optional2 = Optional.ofNullable(null);
 
// orElse
System.out.println(optional1.orElse(1000) == 1);// true
System.out.println(optional2.orElse(1000) == 1000);// true


orElseGet(Supplier supplier)：功能与orElse一样，只不过orElseGet参数是一个对象
    Optional<Integer> optional1 = Optional.ofNullable(1);
    Optional<Integer> optional2 = Optional.ofNullable(null);
     
    System.out.println(optional1.orElseGet(() -> {
    	return 1000;
    }) == 1);//true
     
    System.out.println(optional2.orElseGet(() -> {
    	return 1000;
    }) == 1000);//true


orElseThrow()：值不存在则抛出异常，存在则什么不做，有点类似Guava的Precoditions
    Optional<Integer> optional1 = Optional.ofNullable(1);
    Optional<Integer> optional2 = Optional.ofNullable(null);
     
    optional1.orElseThrow(()->{throw new IllegalStateException();});
     
    try
    {
    	// 抛出异常
    	optional2.orElseThrow(()->{throw new IllegalStateException();});
    }
    catch(IllegalStateException e )
    {
    	e.printStackTrace();
    }


filter(Predicate)：判断Optional对象中保存的值是否满足Predicate，并返回新的Optional。
    Optional<Integer> optional1 = Optional.ofNullable(1);
    Optional<Integer> optional2 = Optional.ofNullable(null);
     
    Optional<Integer> filter1 = optional1.filter((a) -> a == null);
    Optional<Integer> filter2 = optional1.filter((a) -> a == 1);
    Optional<Integer> filter3 = optional2.filter((a) -> a == null);
    System.out.println(filter1.isPresent());// false
    System.out.println(filter2.isPresent());// true
    System.out.println(filter2.get().intValue() == 1);// true
    System.out.println(filter3.isPresent());// false

    map(Function)：对Optional中保存的值进行函数运算，并返回新的Optional(可以是任何类型)
    Optional<Integer> optional1 = Optional.ofNullable(1);
    Optional<Integer> optional2 = Optional.ofNullable(null);
     
    Optional<String> str1Optional = optional1.map((a) -> "key" + a);
    Optional<String> str2Optional = optional2.map((a) -> "key" + a);
     
    System.out.println(str1Optional.get());// key1
    System.out.println(str2Optional.isPresent());// false


flatMap()：功能与map()相似，差别请看如下代码。flatMap方法与map方法类似，区别在于mapping函数的返回值不同。map方法的mapping函数返回值可以是任何类型T，而flatMap方法的mapping函数必须是Optional。
            Optional<Integer> optional1 = Optional.ofNullable(1);
      
        Optional<Optional<String>> str1Optional = optional1.map((a) -> {
        	return Optional.<String>of("key" + a);
        });
         
        Optional<String> str2Optional = optional1.flatMap((a) -> {
        	return Optional.<String>of("key" + a);
        });
         
        System.out.println(str1Optional.get().get());// key1
        System.out.println(str2Optional.get());// key
        --------------------- 
作者：aitangyong 
来源：CSDN 
原文：https://blog.csdn.net/aitangyong/article/details/54564100 
版权声明：本文为博主原创文章，转载请附上博文链接！