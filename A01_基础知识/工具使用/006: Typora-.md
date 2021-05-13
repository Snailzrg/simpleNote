## 1 修改背景







## 2 设置图床

[图床工具](https://github.com/Molunerfinn/PicGo/releases)，就是自动把本地图片转换成链接的一款工具，网络上有很多图床工具，就目前使用种类而言，**PicGo** 算得上一款比较优秀的图床工具。

> 这边使用`PicGo+码云`来实现markdown图床，也可以使用Github，不过考虑网络问题选择码云。

- PicGo版本：

![img](https://img2020.cnblogs.com/blog/1972718/202003/1972718-20200323210552751-1313111323.png)

- 安装成功界面：

![image-20200323193807622](https://gitee.com/fakefake00/NoteImgs/raw/master/img/image-20200323194623130.png)

- 找到底下插件设置，使用码云需要另外安装插件，搜索gitee安装插件，有两个插件都可以用

> 注意：安装`gitee-uploader 1.1.2`插件，必须要先安装`node.js`才能安装插件

![image-20200323194553126](https://gitee.com/fakefake00/NoteImgs/raw/master/img/image-20200323194553126.png)

- 建立gitee码云图床库，就是在码云新建一个仓库，步骤：

![image-20200323195546145](https://gitee.com/fakefake00/NoteImgs/raw/master/img/image-20200323195546145.png)

- 接下来配置PicGO，安装Gitee插件成功，就会出现Gitee图床栏目：

```
url：https://getee.com
owner：写你的码云用户名
repo：仓库名称
token：填入码云的私人令牌
path：路径，一般写上img
message：可以不用写
```

![image-20200323195759180](https://gitee.com/fakefake00/NoteImgs/raw/master/img/image-20200323200847954.png)

- token获取：进入码云，点击进入设置页

![image-20200323200414766](https://gitee.com/fakefake00/NoteImgs/raw/master/img/image-20200323200414766.png)

- 找到左侧 **私人令牌** ，点击生成新令牌，描述随便填写，就勾选projects，提交，复制获取到的token

![image-20200323200633225](https://gitee.com/fakefake00/NoteImgs/raw/master/img/image-20200323195759180.png)

![image-20200323200847954](https://gitee.com/fakefake00/NoteImgs/raw/master/img/image-20200323200633225.png)

- 配置Typora，点击 文件，偏好设置，选择图像，设置PicGo二进制文件的路径：

![image-20200323201738802](https://gitee.com/fakefake00/NoteImgs/raw/master/img/image-20200323201738802.png)

- 配置成`上传图片`（.md文件先保存完，再插入进去的图片上传会失败）
- 测试其他图片存放位置的操做都没啥问题，唯独 `上传图片`
- `无特殊操作` 默认存放路径`C:\Users\用户\AppData\Roaming\Typora\typora-user-images`
- 手动去上传图片：选择 格式->图像->上传所有本地图片

![img](https://img2020.cnblogs.com/blog/1972718/202003/1972718-20200325124858815-145787238.png)

![image-20200323201738802](https://gitee.com/fakefake00/NoteImgs/raw/master/img/image-20200323201738802.png)![a140ebf9b938d6de50099fc5f38f81c3的副本](/Users/snailzhou/Desktop/a140ebf9b938d6de50099fc5f38f81c3的副本.jpg)

- Typora使用下面这个url跟PicGo连接的，所以PicGo的设置也要对应，默认一般就是。f35667ae0fbd1e564ead1b184d944db3

![img](https://gitee.com/fakefake00/NoteImgs/raw/master/img/image-20200323203807172-1584967114062.png)

![image-20200323204010678](https://gitee.com/fakefake00/NoteImgs/raw/master/img/image-20200323204010678.png)

- 不过PicGo的Server监听端口会经常变动（比如电脑重启后）,就需要修改不然Typora图片也会上传失败




# 二：设置目录显示