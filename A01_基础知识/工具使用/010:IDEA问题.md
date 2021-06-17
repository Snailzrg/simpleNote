[toc]

## IDEA 导入Maven不识别问题

当在idea中导入maven项目时，不能自动识别pom文件
解决方法： 
- 1.右键pom.xml文件，选择” add as maven project”,即可自动导入pom所依赖的jar包
- 另外刷新Maven配置的方法为：
- 1）右键单击项目；
- 2）在弹出菜单中选择Maven->Reimport菜单项。

此时，IDEA将通过网络自动下载相关依赖，并存放在Maven的本地仓库中。另外，可以将Maven的刷新设置为自动，配置方法为：
- （1）单击File|Setting菜单项，打开Settings选项卡；
- （2）在左侧的目录树中，展开Maven节点；
- （3）勾选Import Maven projects automatically选择项。


## IDEA 调试时对象的字段显示不全问题
idea 调试对象字段显示不全问题
在调试HashMap时，发现IDEA中调试面板的对象字段显示不全。 经过一番摸索，发现IDEA对集合类型的变量做了特别处理。
如下图，取消勾选该选项，即会展示集合对象的所有字段。
![](Idea遇到问题_files/1.jpg)
还有另外一个操作，就是在变量面板，选中一个变量 -> 右键 -> 'View as" -> 切换不同的类型查看效果（一般为Object即可


 ## 配置LOMBACK
- [SEE](https://blog.csdn.net/qq_41441210/article/details/79891093)



## IDEA debug
[see](https://www.cnblogs.com/chiangchou/p/idea-debug.html)
右键断点 输入条件



## IDEA2019 插件太慢





- 选中inherited members，可查看父类的所有方法 

  > idea中 打开Inherited members  ctrl+f12

- 查看继承树

  - 右键xxx.class，弹出了下拉菜单选中为 browse type hirearchy 选项
  - 右键 show diagrams

