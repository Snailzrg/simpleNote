[toc]



# 一 Eclipse安装反编译插件JD-Eclipse

## 1、下载JD-Eclipse插件

进入JD官网http://jd.benow.ca/，下滑页面看到JD-Eclipse如下，**下载 Release jd-eclipse-site-1.0.0-RC2.zip**，大红箭头标着呢
（积分多任性？资源传送门在这：https://download.csdn.net/download/qq_31772441/10408138
纳闷了为什么不能设置 0 积分下载）
**(补上云链接 https://pan.baidu.com/s/1-QVb2GREu84JawcMy5QU9Q)**
![下载JD-Eclipse插件](https://img-blog.csdn.net/20180511211804494?watermark/2/text/aHR0cHM6Ly9ibG9nLmNzZG4ubmV0L3FxXzMxNzcyNDQx/font/5a6L5L2T/fontsize/400/fill/I0JBQkFCMA==/dissolve/70)

## 2、安装

官网上清晰地写了安装的过程，如上红框，勉强看懂来强行翻译一波：
Installation

1. Download and unzip the JD-Eclipse Update Site,//**下载文件**，然后…**不用解压！**（强行翻译，别、不用、不需要解压）（unzip 其实是解压的意思，小编试了不用解压也可以直接用，那就别、不用、不需要解压）
2. Launch Eclipse,//**运行Eclipse**
3. Click on “Help > Install New Software…”,//**点击Eclipse菜单栏Help > Install New Software…**
4. Click on button “Add…” to add an new repository,//**点击Add…**
5. Enter “JD-Eclipse Update Site” and select the local site directory,//**输入Name：JD-Eclipse Update Site；Location：选择刚才下载的那个jd-eclipse-site-1.0.0-RC2.zip的路径**
6. Check “Java Decompiler Eclipse Plug-in”,//**选中Java Decompiler Eclipse Plug-in**
7. Next, next, next… and restart Eclipse.//**Next,一路next，一路怼，最后Eclipse重启，搞定收工**（搞不定？**看下**）

------

## *搞不定？请看图文操作

Eclipse菜单栏Help > Install New Software…
![Install New Software](https://img-blog.csdn.net/20180511222119559?watermark/2/text/aHR0cHM6Ly9ibG9nLmNzZG4ubmV0L3FxXzMxNzcyNDQx/font/5a6L5L2T/fontsize/400/fill/I0JBQkFCMA==/dissolve/70)
**Name：**随意填写，**Location：**选择刚才下载的jd-eclipse-site-1.0.0-RC2.zip文件路径
![Location](https://img-blog.csdn.net/20180511222204159?watermark/2/text/aHR0cHM6Ly9ibG9nLmNzZG4ubmV0L3FxXzMxNzcyNDQx/font/5a6L5L2T/fontsize/400/fill/I0JBQkFCMA==/dissolve/70)
OK，一路next
![这里写图片描述](https://img-blog.csdn.net/20180511222226234?watermark/2/text/aHR0cHM6Ly9ibG9nLmNzZG4ubmV0L3FxXzMxNzcyNDQx/font/5a6L5L2T/fontsize/400/fill/I0JBQkFCMA==/dissolve/70)
![在这里插入图片描述](https://img-blog.csdnimg.cn/20200416100921811.png?x-oss-process=image/watermark,type_ZmFuZ3poZW5naGVpdGk,shadow_10,text_aHR0cHM6Ly9ibG9nLmNzZG4ubmV0L3FxXzMxNzcyNDQx,size_16,color_FFFFFF,t_70)
![这里写图片描述](https://img-blog.csdn.net/20180511222241585?watermark/2/text/aHR0cHM6Ly9ibG9nLmNzZG4ubmV0L3FxXzMxNzcyNDQx/font/5a6L5L2T/fontsize/400/fill/I0JBQkFCMA==/dissolve/70)
出现这个Warning，不用担心，OK即可。
![OK](https://img-blog.csdn.net/20180511211825845?watermark/2/text/aHR0cHM6Ly9ibG9nLmNzZG4ubmV0L3FxXzMxNzcyNDQx/font/5a6L5L2T/fontsize/400/fill/I0JBQkFCMA==/dissolve/70)
![这里写图片描述](https://img-blog.csdn.net/20180511222247645?watermark/2/text/aHR0cHM6Ly9ibG9nLmNzZG4ubmV0L3FxXzMxNzcyNDQx/font/5a6L5L2T/fontsize/400/fill/I0JBQkFCMA==/dissolve/70)
重启Eclipse，插件生效
![这里写图片描述](https://img-blog.csdn.net/20180511222254508?watermark/2/text/aHR0cHM6Ly9ibG9nLmNzZG4ubmV0L3FxXzMxNzcyNDQx/font/5a6L5L2T/fontsize/400/fill/I0JBQkFCMA==/dissolve/70)

##### Ecliplse重启后，class文件还是无法显示？

那来设置下Eclipse里某个不可描述的设置，**设置JD查看器为默认class文件查看器**
1、点击Eclipse菜单栏Window > Preference > General > Editors > File Associations
2、分别选中“.class”、“.class without source”，再选中下面JD Class File Viewer，再点击Default，设置其为默认
（注：如果没有发现相关选项，点击左上角“Add”添加即可）
![这里写图片描述](https://img-blog.csdn.net/2018051121183225?watermark/2/text/aHR0cHM6Ly9ibG9nLmNzZG4ubmV0L3FxXzMxNzcyNDQx/font/5a6L5L2T/fontsize/400/fill/I0JBQkFCMA==/dissolve/70)
![这里写图片描述](https://img-blog.csdn.net/20180511211841488?watermark/2/text/aHR0cHM6Ly9ibG9nLmNzZG4ubmV0L3FxXzMxNzcyNDQx/font/5a6L5L2T/fontsize/400/fill/I0JBQkFCMA==/dissolve/70)

另外：JD-Eclilpse的配置在这
![在这里插入图片描述](https://img-blog.csdnimg.cn/20200416104215984.jpg?x-oss-process=image/watermark,type_ZmFuZ3poZW5naGVpdGk,shadow_10,text_aHR0cHM6Ly9ibG9nLmNzZG4ubmV0L3FxXzMxNzcyNDQx,size_16,color_FFFFFF,t_70)

> 
>
> 搞定收工







# 二 待续

