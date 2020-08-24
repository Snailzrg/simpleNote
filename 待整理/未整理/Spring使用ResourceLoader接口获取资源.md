# 1. Spring使用ResourceLoader接口获取资源
url：---> https://blog.csdn.net/u010086122/article/details/81607167
 -------> https://blog.csdn.net/u010086122/article/details/81607127
  
A    什么是资源？我们已知Spring中有很多xml配置文件，同时还可能自建各种properties资源文件，还有可能进行网络交互，首发各种文件、二进制流等。粗略可分为：URL资源、File资源、ClassPath相关资源、服务器相关资源（JBoss AS 5.x上的VFS资源）。Spring把这些文件、二进制流统称为资源。程序对这些资源的访问，就叫做资源访问。
 
B    J2SE中，有些处理资源文件的标准API，例如InputStream等文件IO和java.net.URL。但因为并非专门为Web服务设计，所以对于Spring服务，这些工具类显得比较底层。若直接使用这些方法，需要编写比较多的额外代码，例如前期文件存在判断、相对路径变绝对路径等。

C   处理资源文件步骤都很类似（打开资源、读取资源、关闭资源），所以若抽象出一个统一的接口来对这些底层资源进行统一访问，用起来就十分方便。对不同的底层资源都实现同一个接口，重写方法时再实现不同的处理。 这个接口就是Spring提供的Resource接口。


**--> . Resource接口 **
Spring的Resource接口继承InputStreamSource。
     public interface Resource extends InputStreamSource {}


● getInputStream：定位并打开资源，返回资源对应的输入流。每次调用都会返回新的输入流，调用者在使用完毕后必须关闭该资源。 
       public interface InputStreamSource {
    InputStream getInputStream() throws IOException;
}

Spring提供了很多内置Resource实现：
![](_v_images/1553241553_22371.png)
***Resource 里面的其它方法**
    ● exists：返回Resource所指向的底层资源是否存在 
    ● isReadable：返回当前Resource代表的底层资源是否可读 
    ● isOpen：返回Resource资源文件是否已经打开，如果返回true，则只能被读取一次然后关闭以避免内存泄漏；常见的Resource实现一般返回false 
    ● getURL：如果当前Resource代表的底层资源能由java.util.URL代表，则返回该URL，否则抛出IO异常 
    ● getURI：如果当前Resource代表的底层资源能由java.util.URI代表，则返回该URI，否则抛出IO异常 
    ● getFile：如果当前Resource代表的底层资源能由java.io.File代表，则返回该File，否则抛出IO异常 
    ● contentLength：返回当前Resource代表的底层文件资源的长度，一般是值代表的文件资源的长度。 
    ● lastModified：返回当前Resource代表的底层资源的最后修改时间。 
    ● createRelative：用于创建相对于当前Resource代表的底层资源的资源，比如当前Resource代表文件资源“d:/test/”则createRelative（“test.txt”）将返回表文件资源“d:/test/test.txt”Resource资源。 
    ● getFilename：返回当前Resource代表的底层文件资源的文件路径，比如File资源“file://d:/test.txt”将返回“d:/test.txt”，而URL资源http://www.javass.cn将返回“”，因为只返回文件路径。 
● getDescription：返回当前Resource代表的底层资源的描述符，通常就是资源的全路径（实际文件名或实际URL地址）。 



