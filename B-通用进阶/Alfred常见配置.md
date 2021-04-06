# 一：Alfred配置

> 快捷键 option+空格 
>
> command+空格==>自带的

## 大纲

| 名称          | 作用               | 类别     | 出处                                                         | 修改日期   |
| :------------ | :----------------- | :------- | :----------------------------------------------------------- | :--------- |
| Github        | 更便捷地使用Github | 开发编程 | [Github](https://link.jianshu.com?t=https://github.com/gharlan/alfred-github-workflow) | 2017-01-28 |
| Github Search | Github搜索         | 开发编程 | [Github](https://link.jianshu.com?t=https://github.com/pawelgrzybek/Github-Search) | 2017-01-28 |
| Stackoverflow | Stackoverflow搜索  | 开发编程 | [Github](https://link.jianshu.com?t=https://github.com/deanishe/alfred-stackoverflow) | 2017-01-28 |
| Dash          | 离线API            | 开发编程 | [Dash官网](https://link.jianshu.com?t=https://kapeli.com/dash) | 2017-01-27 |
| Hash          | 哈希工具           | 开发编程 | [Github](https://link.jianshu.com?t=https://github.com/BigLuck/alfred2-hash) | 2017-01-27 |
| Maven         | maven库搜索        | 开发编程 | [Github](https://link.jianshu.com?t=https://github.com/yisiqi/alfred2-workflow-maven) | 2017-01-27 |
| Copy Path     | 复制路径           | 工具     | [Github](https://link.jianshu.com?t=https://github.com/hzlzh/Alfred-Workflows) | 2017-01-27 |
| Shorten URL   | 缩短URL            | 工具     | [Github](https://link.jianshu.com?t=https://github.com/hzlzh/Alfred-Workflows) | 2017-01-28 |
| 扇贝词典      | 英语               | 工具     | [Github](https://link.jianshu.com?t=https://github.com/henter/Shanbay-Alfred2) | 2017-01-28 |
| Switch DNS    | 切换DNS设置        | 工具     | [Github](https://link.jianshu.com?t=https://github.com/dangoakachan/switchdns) | 2017-01-30 |

## 资源

- [Alfred官网](https://link.jianshu.com?t=http://www.alfredforum.com/forum/3-share-your-workflows)
- [知乎hzlzh大神维护的插件大全](https://link.jianshu.com?t=http://alfredworkflow.com)
- [Packal](https://link.jianshu.com?t=http://www.packal.org)

## 一：自定义搜索

##### 1.1文件检索

`find ***`  : 定位文件
 `open ***`  : 定位并且打开文件
 `in ***`  : 在文件中检索
 ...文件操作还有更多强大的功能，比如拷贝. 移动文件...

##### 1.2系统自带功能

在设置 -> Features 中有许多功能；
 `睡眠` `锁屏`  `重启`  `关机` `退出所有程序`...等

1.3**还有好多其他功能可以在Features中去探索，重点说一下自定义快捷搜索**
 在features中有个web search 选项，默认情况下输入非关键字的语句会用google搜索；这里也可以自己配置一些其他的检索方式；
 经常用github搜索开源库，一般你要先打开浏览器，到github主页，然后搜索，如果使用alfed配置一下，结果就是你可以在任何场景下 `option + 空格` 呼出alfed，输入`gh afn`，回车后就看到了，全自动化；`gh`是我自定义的搜索关键字
 具体如何设置，用一张图说明

![image-20210322211731299](https://gitee.com/snailzrg/snail_img/raw/master/picgo_snail_img/image-20210322211731299.png)

##### 1.4强大的workflow

workflow是alfred最强大的功能；有了workflow，alfred就像个中心调度器，成为一切的交通枢纽；
 ** 自定义一般的工作流**
 以打开xcode的来说，目前来说操作流程是：`option + 空格` -> 键入xcode -> 回车；如果使用workflow的工作流还能进一步简化流程；

1. 在alfed设置界面，选择workflow区，点击右下角的`+`添加自定义工作流，
2. 依次选择Templates -> Files And Apps  -> Launch file group from hotkey; 通过热键(快捷键打开某些文件或者启动app)；
3. 弹出框可以随意填写，create后看到如图





# 二 常用插件下载

## 2.1驼峰命名

> https://github.com/xudaolong/CodeVar/releases

## 2.2 有道翻译

> https://github.com/wensonsmith/YoudaoTranslate/releases

## 2.3 stackoverflow

> https://github.com/deanishe/alfred-stackexchange/releases



## 2.4 常见搜索

百度：`https://www.baidu.com/s?ie=utf-8&f=8&wd={query}`

简书：`http://www.jianshu.com/search?utf8=%E2%9C%93&q={query}`

淘宝：`http://s.taobao.com/search?oe=utf-8&f=8&q={query}`

京东：`https://search.jd.com/Search?keyword={query}&enc=utf-8&wq={query}`

微信文章：`http://weixin.sogou.com/weixin?type=2&query={query}`

stackoverflow：`http://www.stackoverflow.com/search?q={query}`

github：`https://github.com/search?utf8=%E2%9C%93&q={query}`

maven：`http://mvnrepository.com/search?q={query}`

Android API Search：`https://developer.android.com/reference/classes.html#q={query}`

