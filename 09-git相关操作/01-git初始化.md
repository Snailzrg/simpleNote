from ：[](https://blog.csdn.net/heimu24/article/details/81171422)

一、基础知识补充
1、git init #把这个目录变成Git可以管理的仓库
2、git add README.md #本地README.md文件添加到远程仓库
3、git add . #不但可以跟单一文件，还可以跟通配符，更可以跟目录。一个点就把当前目录下所有未追踪的文件全部add了，注意空格
4、git commit -m “注释” #把文件提交到仓库
5、git remote add origin git@github.com:heimu24/blog-backup.git #本地关联远程仓库
6、git push -u origin master #把本地库的所有内容推送到远程库上（第一次需要加-u，后面就不用加了）


-------
查看本地仓库关联的远程仓库信息 命令：git remote show origin !
![-已关联-](01-git初始化_files/1.jpg)
![-未关联-](01-git初始化_files/2.jpg)

2、第二步
如果项目未关联过其他远程仓库执行  git remote add origin https://gitee.com/*****/xj_job.git
如果项目一关联过其他远程分支执行 git remote set-url origin https://gitee.com/*****/xj_job.git

3、第三步

关联本地分关联远程仓库分支执行 
git branch --set-upstream-to=origin/master(远程分支) master(本地分支)--allow-unrelated-histories
关联成功后，拉去远程仓库分支执行 git pull --allow-unrelated-histories 
推送本地分支到远程分支  git push





 ---  一般公司常见git 操作 从dev 迁出新功能分支 完事合并到master dev
 步骤

 1 创建本地新分支 'dev-01'
 git branch dev-01

 2 查看分支，创建成功
 $ git branch -a

 3 检查一下仓库名称
 查看当前配置有哪些远程仓库：$ git remote
 （在克隆完某个项目后，（进到该项目文件夹中），至少可以看到一个名为 origin 的远程库，Git 默认使用这个名字来标识你所克隆的原始仓库）

 4 本地分支推上去，远程会自动生成同名新分支（dev-01）
 $ git push origin dev-01

 5 将当前分支与远程某分支关联
 $ git branch --set-upstream-to=origin/dev-01

 6 查看关联情况
 $ git branch -vv

 7 最后把本地代码推上去
 $ git add .
 $ git commit -m 'your commit info'
 $ git push origin dev-01


 总结：dev-01就是从dev分支创建的新分支


 ------   合并dev 代码到master -------

将dev分支上的代码合并到master分支
发表于 2020-03-29  |  分类于 后端  |  没有评论
1、切换到master分支
​ git checkout master

2、拉取最新代码
​ git pull

3、合并代码
​ git merge dev

4、查看状态（可查看合并的文件数，即commit数量）
​ git status

5、将合并后的代码提交到远程master上面
​ git push









# git 将A分支的特定提交合并到B分支
