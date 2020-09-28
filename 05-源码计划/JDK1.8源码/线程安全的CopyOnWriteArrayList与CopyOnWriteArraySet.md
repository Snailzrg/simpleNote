## sJDK1.8源码分析：线程安全的CopyOnWriteArrayList与CopyOnWriteArraySet

服务端开发 [Java知音](javascript:void(0);) *今天*

![img](https://mmbiz.qpic.cn/mmbiz_gif/eQPyBffYbucGRda0rcJFUcQBDSTWOLQwIxh0BtyOOiaibYXRzCjz4ID20aW2ZLKn18KekUCib3d8yLVtfH1tmljUQ/640?wx_fmt=gif&tp=webp&wxfrom=5&wx_lazy=1)

*作者：\*服务端开发**

blog.csdn.net/u010013573/article/details/87463023

### 概述

ArrayList不是线程安全的，所以如果需要保证ArrayList在多线程环境下的线程安全，即保证读的线程可见性和写的数据一致性，可以使用synchronized或者ReentrantLock对ArrayList的读写进行同步，或者使用Collections.syncrhonizedList来将ArrayList包装成SynchronizedList。

由于以上方法对读写都需要加锁，一定程度上影响了读写操作的并发性能和吞吐量，不过如果读写操作的频率不确定，即读写都可能非常频繁，则就不得不使用以上方法来保证ArrayList的线程安全性。

如果存在以读为主，写非常少，基本不存在写操作，如添加元素，删除元素等，则可以考虑使用CopyOnWriteArrayList。这是一个线程安全版本的ArrayList，由命名可以知道，CopyOnWriteArrayList在写操作的时候，包括添加，删除元素等，会新建一个列表，然后将当前列表拷贝拷贝到这个新列表，最后使用这个新列表替换旧列表。

### CopyOnWriteArrayList

CopyOnWriteArrayList底层也是使用一个数组来存放数据的，在读写方法，读操作是不加锁的，写操作需要使用一个ReentrantLock来加锁，从而对多个写线程进行同步，同时底层数组也是使用volatile修饰的，则保证了读写线程之间的可见性。除此之外，CopyOnWriteArrayList的迭代器不是fail-fast的，即写操作不会影响迭代器的数据遍历。

```
// get不加锁，set加锁新建一个array替换原来的；
// 迭代器保存array的快照，不是fail-fast；
// subList与主类共享array，读写均需加锁，写不新建一个array替换原来的，而是通过加锁来包装线程安全
public class CopyOnWriteArrayList<E>
    implements List<E>, RandomAccess, Cloneable, java.io.Serializable {
    private static final long serialVersionUID = 8673264195747942595L;

    // 写操作加锁
    /** The lock protecting all mutators */
    final transient ReentrantLock lock = new ReentrantLock();

    // volatile，保证线程之间的可见性
    /** The array, accessed only via getArray/setArray. */
    private transient volatile Object[] array;
    
    ...
    
}
```

#### 读操作

以下以get操作为例，分析以下读操作：读操作是直接从内部存放数据的数组读取数据的，不需要加锁。

```
public E get(int index) {
    return get(getArray(), index);
}

final Object[] getArray() {
    return array;
}

private E get(Object[] a, int index) {
    return (E) a[index];
}
```

### 迭代器

ArrayList的迭代器是fail-fast的，即如果一个线程在通过ArrayList的迭代器遍历列表数据时，如果其他线程修改了该列表，则该迭代器线程会抛ConcurrentModifyException的异常。而CopyOnWriteArrayList的迭代器是不受其他线程并发修改的影响的。

CopyOnWriteArrayList在返回一个迭代器的时候，会基于创建这个迭代器的时候，内部数组所拥有的数据，创建一个该内部数组当前的快照，然后迭代器遍历的是该快照，而不是内部的数组。所以这种实现方式也存在一定的数据延迟性，即对其他线程并行添加的数据不可见。不过CopyOnWriteArrayList是基于写操作很少或者基本没有的场景的，所以这种实现方法在这种假设下可行。

因为迭代器遍历的是内部数组的快照副本，故与ArrayList的迭代器不同的是，CopyOnWriteArrayList的迭代器是不支持写操作的，如添加，删除数据等。

```
public Iterator<E> iterator() {
    return new COWIterator<E>(getArray(), 0);
}

// 迭代器会创建一个底层array的快照，故主类的修改不影响该快照
static final class COWIterator<E> implements ListIterator<E> {

    // 内部数组快照
    /** Snapshot of the array */
    private final Object[] snapshot;
    
    ...

    private COWIterator(Object[] elements, int initialCursor) {
        cursor = initialCursor;
        snapshot = elements;
    }

    @SuppressWarnings("unchecked")
    public E next() {
        if (! hasNext())
            throw new NoSuchElementException();
            
        // 访问快照
        return (E) snapshot[cursor++];
    }

    ...

    // 不支持写操作
    public void remove() {
        throw new UnsupportedOperationException();
    }
    
    ...
    
}
```

#### 写操作

写操作是需要通过ReentrantLock这个互斥锁来进行加锁的，然后会创建一个新的数组来替换原来的数组。由于写操作很少，所以对于添加元素，新数组大小递增1，这个与ArrayList的每次扩容为原来的1.5倍是不一样的。对于删除元素，新数组大小递减1。如下为add方法的实现：

```
public boolean add(E e) {
    final ReentrantLock lock = this.lock;
    // 加互斥锁
    lock.lock();
    try {
        Object[] elements = getArray();
        int len = elements.length;
        // 新数组大小比原来数组多一个
        Object[] newElements = Arrays.copyOf(elements, len + 1);
        // 在新数组末尾添加该元素
        newElements[len] = e;
        // 新数组替换旧数组
        setArray(newElements);
        return true;
    } finally {
        lock.unlock();
    }
}
```

#### 子列表COWSubList

CopyOnWriteArrayList的子列表与COWSubList与ArrayList的子列表一样，内部使用的也是父列表的数组，主要是通过传递父列表引用给COWSubList，在COWSubList内部的读写操作是通过父列表来完成的，其中读写操作均需要使用lock加锁。

CopyOnWriteArrayList的subList返回子数组：

```
public List<E> subList(int fromIndex, int toIndex) {
    final ReentrantLock lock = this.lock;
    lock.lock();
    try {
        Object[] elements = getArray();
        int len = elements.length;
        if (fromIndex < 0 || toIndex > len || fromIndex > toIndex)
            throw new IndexOutOfBoundsException();
        // 传递this，即父列表引用，给COWSubList
        return new COWSubList<E>(this, fromIndex, toIndex);
    } finally {
        lock.unlock();
    }
}
```

COWSubList的定义如下：读写操作均需要使用父列表的lock加锁：

```
private static class COWSubList<E>
    extends AbstractList<E>
    implements RandomAccess
{
    // l为父列表引用
    private final CopyOnWriteArrayList<E> l;
    private final int offset;
    private int size;
    private Object[] expectedArray;

    // only call this holding l's lock
    COWSubList(CopyOnWriteArrayList<E> list,
               int fromIndex, int toIndex) {
        l = list;
        expectedArray = l.getArray();
        offset = fromIndex;
        size = toIndex - fromIndex;
    }

    ...
    
    // 读取
    public E get(int index) {
        final ReentrantLock lock = l.lock;
        lock.lock();
        try {
            rangeCheck(index);
            checkForComodification();
            return l.get(index+offset);
        } finally {
            lock.unlock();
        }
    }

    // 添加元素
    public void add(int index, E element) {
        final ReentrantLock lock = l.lock;
        lock.lock();
        try {
            checkForComodification();
            if (index < 0 || index > size)
                throw new IndexOutOfBoundsException();
            // l为父列表引用
            l.add(index+offset, element);
            expectedArray = l.getArray();
            size++;
        } finally {
            lock.unlock();
        }
    }

    ...
}
```

### CopyOnWriteArraySet

CopyOnWriteArraySet是基于CopyOnWriteArrayList实现的一个Set集合，内部不包含重复元素，也是线程安全的。

CopyOnWriteArraySet的定义如下：内部包含一个CopyOnWriteArrayList引用，而不是继承于CopyOnWriteArrayList来实现。

```
public class CopyOnWriteArraySet<E> extends AbstractSet<E>
        implements java.io.Serializable {
    private static final long serialVersionUID = 5457747651344034263L;

    private final CopyOnWriteArrayList<E> al;

    /**
     * Creates an empty set.
     */
    public CopyOnWriteArraySet() {
        al = new CopyOnWriteArrayList<E>();
    }
```

CopyOnWriteArraySet的核心实现为add添加元素时，避免元素重复，同时需要考虑多线程同时添加的问题。主要是基于CopyOnWriteArrayList的addIfAbsent实现：

```
public boolean add(E e) {
    return al.addIfAbsent(e);
}
```

CopyOnWriteArrayList的addIfAbsent实现如下：主要通过加锁成功之后，再次获取底层数组来判断是否需要添加，因为加锁成功后，只有当前线程可以访问这个底层数组，同时由于数组为volatile的，故可以保证多线程的可见性。

```
public boolean addIfAbsent(E e) {
    Object[] snapshot = getArray();
    // 此处可能两个线程同时调用indexOf(e, snapshot, 0, snapshot.length)，存在并发问题，
    // 故在addIfAbsent(e, snapshot)里面需要处理这种并发问题
    return indexOf(e, snapshot, 0, snapshot.length) >= 0 ? false :
        addIfAbsent(e, snapshot);
}

/**
 * A version of addIfAbsent using the strong hint that given
 * recent snapshot does not contain e.
 */
private boolean addIfAbsent(E e, Object[] snapshot) {
    final ReentrantLock lock = this.lock;
    lock.lock();
    try {
        // 获取锁的情况下，再次获取一次底层array，避免两个线程同时修改，前一线程添加了，
        // 后一线程重复添加，故需要获取前一线程操作的结果
        Object[] current = getArray();
        int len = current.length;
        // 如果快照和array不是同一个了，说明其他线程并发修改过了
        if (snapshot != current) {
            // Optimize for lost race to another addXXX operation
            int common = Math.min(snapshot.length, len);
            for (int i = 0; i < common; i++)
                // 其他线程添加过了e，即通过set在原来数组的某个位置替换添加的，则该线程直接返回了，此时已经存在了
                if (current[i] != snapshot[i] && eq(e, current[i]))
                    return false;
            // 如果在数组末尾添加过了，则直接返回，此时已经存在了
            if (indexOf(e, current, common, len) >= 0)
                    return false;
        }
        // copy当前数组，添加元素并将这个心数组替换底层的array
        Object[] newElements = Arrays.copyOf(current, len + 1);
        newElements[len] = e;
        setArray(newElements);
        return true;
    } finally {
        lock.unlock();
    }
}
```

