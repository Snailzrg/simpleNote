##  -1 VScode使用技巧

### 查看所有快捷键

> ctrl k + ctrl s = 打开快捷键一览表。
>
> 在这里面、你可以查看、搜索、修改快捷键。
>
> 专门记述快捷键的官方文档：
>
> [https://code.visualstudio.com/shortcuts/keyboard-shortcuts-windows.pdf](https://link.zhihu.com/?target=https%3A//code.visualstudio.com/shortcuts/keyboard-shortcuts-windows.pdf)
>
> VS Code里面按下F1、输入shortcuts、回车，就会自动跳转到这个文档，这个方法可以查看这个文档的实时更新。
>
> 

### 设置中文

> 1.打开“vscode” ，按快捷键“Ctrl+Shift+P”。
>
> 2.在顶部搜索框中输入“configure language”，按回车键。
>
> 3.“vscode”里面就会打开一个语言配置文件，将“en-us”修改成“zh-cn”，按“Ctrl+S”保存设置，重启“vscode”就...



### 常见快捷键

```
多重光标同时编辑:Alt按住不动点击鼠标.
选中光标所在的单词:Ctrl+D.  (Ctrl+Shift+L选中文中所有出现该词的地方)
快速切换上下行语句:Alt+Up   (Up:上方向键,在ST中为Ctrl+Shift+方向键)
快速定位到定义的地方:F12
快速预览变量定义:Alt+F12 (这两个功能用过VS的都知道 :)  而且C#语言支持当前字段/函数被引用的信息,在editor.referenceInfos可以设置)
快速复制当前行到上一行或下一行: Shift+Alt+Up/Down
查找/切换匹配括号: Ctrl+Shift+]
快速/取消注释: Ctrl+/
快速分屏编辑: Ctrl+\

```

### 设置代码段

1. 按快捷键Ctrl+Shift+P打开命令输入 snippet : (也可以点击文件=>首选项=>用户代码片段)



![img](https://user-gold-cdn.xitu.io/2019/8/17/16c9eaedaf86327a?imageView2/0/w/1280/h/960/format/webp/ignore-error/1)



1. 选择选项后会出现一个语言列表用以选择给哪种语言创建代码段，



![img](https://user-gold-cdn.xitu.io/2019/8/17/16c9eb6666073783?imageView2/0/w/1280/h/960/format/webp/ignore-error/1)



#### 参数解释

```
prefix      :这个参数是使用代码段的快捷入口,比如这里的log在使用时输入log会有智能感知.
body        :这个是代码段的主体.需要设置的代码放在这里,字符串间换行的话使用\r\n换行符隔开.注意如果值里包含特殊字符需要进行转义. 多行语句的以,隔开
$1          :这个为光标的所在位置.
$2          :使用这个参数后会光标的下一位置将会另起一行,按tab键可进行快速切换,还可以有$3,$4,$5.....
description :代码段描述,在使用智能感知时的描述
```





# -2  VSCode插件整理

一、安装插件

前端统一开发工具：VSCode插件整理。

首先，如果你不知道怎么安装编辑器插件，那么请记住这个图标：

![在这里插入图片描述](https://user-gold-cdn.xitu.io/2020/4/10/1716491f81658a26?imageView2/0/w/1280/h/960/format/webp/ignore-error/1)

二、插件推荐



1.（必备）Auto Close Tag:自动添加HTML/XML关闭标签 [code.visualstudio.com/updates/v1_…](https://code.visualstudio.com/updates/v1_16#_html-close-tags) 这个插件是必备的，提高开发效率的东西，无论用js框架，html作为前端是必须要写的。

![在这里插入图片描述](https://user-gold-cdn.xitu.io/2020/4/10/1716491f81a65cd1?imageView2/0/w/1280/h/960/format/webp/ignore-error/1)



2.（必备）Auto Rename Tag: 自动重命名配对的标签 [marketplace.visualstudio.com/items?itemN…](https://marketplace.visualstudio.com/items?itemName=formulahendry.auto-rename-tag)

![在这里插入图片描述](https://user-gold-cdn.xitu.io/2020/4/10/1716491f824eaaff?imageView2/0/w/1280/h/960/format/webp/ignore-error/1)



3.（必备）Beautify:格式化js,json,css,cass,html [marketplace.visualstudio.com/items?itemN…](https://marketplace.visualstudio.com/items?itemName=HookyQR.beautify)

![在这里插入图片描述](https://user-gold-cdn.xitu.io/2020/4/10/1716491f825662e0?imageView2/0/w/1280/h/960/format/webp/ignore-error/1)



4.（必备）Bracket Pair ColorZer:颜色识别匹配括号 [marketplace.visualstudio.com/items?itemN…](https://marketplace.visualstudio.com/items?itemName=CoenraadS.bracket-pair-colorizer)

![在这里插入图片描述](https://user-gold-cdn.xitu.io/2020/4/10/1716491f83b90118?imageView2/0/w/1280/h/960/format/webp/ignore-error/1)



5.（必备）CSS Peek：调试css样式的必备插件 [marketplace.visualstudio.com/items?itemN…](https://marketplace.visualstudio.com/items?itemName=pranaygp.vscode-css-peek) 鼠标放在类名，id上的时候，显示出此类型下的css样式，并可以直接跳转到css文件

![在这里插入图片描述](https://user-gold-cdn.xitu.io/2020/4/10/1716491f874f2b7f?imageView2/0/w/1280/h/960/format/webp/ignore-error/1)


## 