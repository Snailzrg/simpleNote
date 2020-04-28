# Stream sorted() 示例
原文链接：http://www.concretepage.com/java/jdk-8/java-8-stream-sorted-example 
国外对Java8一系列总结的不错， 翻译过来给大家共享 
这篇文章将会讲解Java 8 Stream sorted()示例， 我们能够以自然序或着用Comparator 接口定义的排序规则来排序一个流。Comparator 能用用lambada表达式来初始化， 我们还能够逆序一个已经排序的流。 
接下来我们将会使用java 8 的流式sorted排序List 、Map 、 Set 
1、sorted() 默认使用自然序排序， 其中的元素必须实现Comparable 接口 
2、sorted(Comparator<? super T> comparator) ：我们可以使用lambada 来创建一个Comparator 实例。可以按照升序或着降序来排序元素。 

A 下面代码以自然序排序一个list
```
    list.stream().sorted() 
```

B 自然序逆序元素，使用Comparator 提供的reverseOrder() 方法
```
    list.stream().sorted(Comparator.reverseOrder()) 
```
Comparator 来排序一个list
```
    list.stream().sorted(Comparator.comparing(Student::getAge)) 
```
把上面的元素逆序
```
list.stream().sorted(Comparator.comparing(Student::getAge).reversed())
```
