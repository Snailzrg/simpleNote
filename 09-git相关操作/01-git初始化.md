from ：[](https://blog.csdn.net/heimu24/article/details/81171422)


三、上传本地文件到github上
一、基础知识补充
1、git init #把这个目录变成Git可以管理的仓库

2、git add README.md #本地README.md文件添加到远程仓库

3、git add . #不但可以跟单一文件，还可以跟通配符，更可以跟目录。一个点就把当前目录下所有未追踪的文件全部add了，注意空格

4、git commit -m “注释” #把文件提交到仓库

5、git remote add origin git@github.com:heimu24/blog-backup.git #本地关联远程仓库

6、git push -u origin master #把本地库的所有内容推送到远程库上（第一次需要加-u，后面就不用加了）
————————————————
版权声明：本文为CSDN博主「heimu24」的原创文章，遵循CC 4.0 BY-SA版权协议，转载请附上原文出处链接及本声明。
原文链接：https://blog.csdn.net/heimu24/java/article/details/81171422