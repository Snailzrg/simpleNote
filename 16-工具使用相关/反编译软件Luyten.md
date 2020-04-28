# 反编译软件Luyten安装详细步骤
----> https://blog.csdn.net/liu1508214140/article/details/82799538
在网上查到Luyten可以反编译jdk1.8的java代码，试用一下，完美运行，特此记录

1，下载源码，解压
地址：https://github.com/deathmarine/Luyten
解压后，进入可以看到

2， 编译打包
用cmd命令行进入解压后的Luyten-master文件夹下，执行mvn package
 （前提：电脑端已经安装了maven，可以运行mvn命令）

等待大概两分钟后，就可以看到安装完成（期间会下载大量的jar包
 在Luyten-master文件夹，会看到多了一个target文件夹，打开它

3，使用
双击luyten-0.5.3.exe，快乐的使用吧。

4，如果失败，就直接下载我的吧
https://download.csdn.net/download/liu1508214140/10698084
