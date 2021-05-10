###  git 简单初始化

Git 全局设置:

```
git config --global user.name "snailzrg"
git config --global user.email "snailzrg@163.com"
```

创建 git 仓库:

```
mkdir snail-resources
cd snail-resources
git init
touch README.md
git add README.md
git commit -m "first commit"
git remote add origin git@gitee.com:snailzrg/snail-resources.git
git remote add origin git@github.com:Snailzrg/SpringAllGradle.git
git push -u origin master 
```

已有仓库?

```
cd existing_git_repo
git remote add origin git@gitee.com:snailzrg/snail-resources.git
git push -u origin master
```

##  本地仓库与远程仓库的关联

> 查看本地仓库关联的远程仓库信息 命令：git remote show origin 
- 已关联

  ```
   remote origin
    Fetch URL: https://github.com/Snailzrg/simpleNote.git
    Push  URL: https://github.com/Snailzrg/simpleNote.git
    HEAD branch: master
    Remote branches:
      dev        tracked
      dev_hotfix tracked
      master     tracked
  ```


- 未关联

  ```
  fatal: Not a git repository (or any of the parent directories): .git
  ```

  2、第二步
  如果项目未关联过其他远程仓库执行  git remote add origin https://gitee.com/*****/xj_job.git
  如果项目一关联过其他远程分支执行 git remote set-url origin https://gitee.com/*****/xj_job.git

关联本地分关联远程仓库分支执行 
git branch --set-upstream-to=origin/master(远程分支) master(本地分支)--allow-unrelated-histories
关联成功后，拉去远程仓库分支执行 git pull --allow-unrelated-histories 
推送本地分支到远程分支  git push



##  合并dev到master

```
将dev分支上的代码合并到master分支
1、切换到master分支
 git checkout master

2、拉取最新代码
 git pull

3、合并代码
 git merge dev

4、查看状态（可查看合并的文件数，即commit数量）
 git status

5、将合并后的代码提交到远程master上面
 git push

merge 的变量实际上 commit 而不是分支，只不过 merge 结果就会自动更新到当前分支上而已
```



 ## git修改已commit的注释信息

  - git commit --amend

  然后按照vim 类似命令修改 message




 ##  生成SHH

 >1. 生成ssh公私钥： ssh-keygen -t rsa -C  snailzrg@163.com
 >2. 将公钥添加到远端库ssh管理处
 >3. **将k'nown_host 中与gitlib相关的数据删掉就可以了**



 ##  从dev 迁出新功能分支 完事合并到master dev 步骤

```
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
```





## 使用git reflog 命令来查看历史提交记录并使用提交记录恢复已经被删除掉的分支

> https://blog.csdn.net/ouyang_peng/article/details/84061662

# 一、问题描述

昨天下午有个同事急急忙忙跑我座位上，要我帮忙，说他刚刚因为手误，将他本地的某个project的某个branch分支删除了，并且也将Gitlab上面的远程分支也删除了。他本来是想发起merge request的，但是后面他眼神不好以为已经merged过了，就直接删了Gitlab上的远程分支并且将他本地的这个分支也直接删除了。

现在他跑过来问我有没有办法恢复，不然他这一天的工作就白费了。

看他急急忙忙不知所措的样子，我直接调侃他说恢复不了。要他以后小心点删除branch，不要眼神不好。后面才慢慢地然后使用了git reflog 查找了他所有的分支提交记录等，然后找到对应的git commit的sha1码，然后恢复过来了。他说居然还有这种操作，666！我去，这是常规操作好吗？

> 所以 如何恢复本地和远程仓库都已经删除掉的分支呢？？下面我来演示一下。

# 二、复现问题

现在我准备找一个测试的demo git 工程来进行演练一下，如何恢复以及被删除的分支。

## 1、创建一个git仓库并且提交一个文件

![在这里插入图片描述](https://img-blog.csdnimg.cn/20181114093726824.png?x-oss-process=image/watermark,type_ZmFuZ3poZW5naGVpdGk,shadow_10,text_aHR0cHM6Ly9ibG9nLmNzZG4ubmV0L3FxNDQ2MjgyNDEy,size_16,color_FFFFFF,t_70)

```
DH207891+OuyangPeng@DH207891 MINGW32 /f/git test
$ git init
Initialized empty Git repository in F:/git test/.git/

DH207891+OuyangPeng@DH207891 MINGW32 /f/git test (master)
$ vim test.txt

DH207891+OuyangPeng@DH207891 MINGW32 /f/git test (master)
$ cat test.txt
11111111111111111111111111111111

DH207891+OuyangPeng@DH207891 MINGW32 /f/git test (master)
$ git add .
warning: LF will be replaced by CRLF in test.txt.
The file will have its original line endings in your working directory.

DH207891+OuyangPeng@DH207891 MINGW32 /f/git test (master)
$ git commit -m "first commit"
[master (root-commit) 363a197] first commit
 1 file changed, 1 insertion(+)
 create mode 100644 test.txt

DH207891+OuyangPeng@DH207891 MINGW32 /f/git test (master)
$ git branch
* master

DH207891+OuyangPeng@DH207891 MINGW32 /f/git test (master)
$

1234567891011121314151617181920212223242526272829
```

## 2、再次编辑test.txt文件并且提交

![在这里插入图片描述](https://img-blog.csdnimg.cn/20181114093944520.png?x-oss-process=image/watermark,type_ZmFuZ3poZW5naGVpdGk,shadow_10,text_aHR0cHM6Ly9ibG9nLmNzZG4ubmV0L3FxNDQ2MjgyNDEy,size_16,color_FFFFFF,t_70)

## 3、切换分支并再次编辑test.txt文件并且提交

创建并切换到 feature/test1分支
![在这里插入图片描述](https://img-blog.csdnimg.cn/20181114094401453.png?x-oss-process=image/watermark,type_ZmFuZ3poZW5naGVpdGk,shadow_10,text_aHR0cHM6Ly9ibG9nLmNzZG4ubmV0L3FxNDQ2MjgyNDEy,size_16,color_FFFFFF,t_70)

在feature/test1分支上继续编辑test.txt文件并且提交
![在这里插入图片描述](https://img-blog.csdnimg.cn/201811140945099.png?x-oss-process=image/watermark,type_ZmFuZ3poZW5naGVpdGk,shadow_10,text_aHR0cHM6Ly9ibG9nLmNzZG4ubmV0L3FxNDQ2MjgyNDEy,size_16,color_FFFFFF,t_70)

```
DH207891+OuyangPeng@DH207891 MINGW32 /f/git test (master)
$ git checkout -b feature/test1
Switched to a new branch 'feature/test1'

DH207891+OuyangPeng@DH207891 MINGW32 /f/git test (feature/test1)
$ git branch
* feature/test1
  master

DH207891+OuyangPeng@DH207891 MINGW32 /f/git test (feature/test1)
$ git log
commit 77dfdffc87bde49a6361bbdf36a9b01a20c10a3b
Author: ouyangpeng <ouyangpeng@oaserver.dw.gdbbk.com>
Date:   Wed Nov 14 09:38:44 2018 +0800

    second commit

commit 363a197ffb4236ec9d6ee5b7631ae326eae958f4
Author: ouyangpeng <ouyangpeng@oaserver.dw.gdbbk.com>
Date:   Wed Nov 14 09:36:32 2018 +0800

    first commit

DH207891+OuyangPeng@DH207891 MINGW32 /f/git test (feature/test1)
$ vim test.txt

DH207891+OuyangPeng@DH207891 MINGW32 /f/git test (feature/test1)
$ cat test.txt
11111111111111111111111111111111


22222222222222222222222222222222


33333333333333333333333333333333

DH207891+OuyangPeng@DH207891 MINGW32 /f/git test (feature/test1)
$ git add test.txt
warning: LF will be replaced by CRLF in test.txt.
The file will have its original line endings in your working directory.

DH207891+OuyangPeng@DH207891 MINGW32 /f/git test (feature/test1)
$ git commit -m "third commit"
[feature/test1 dab39f4] third commit
 1 file changed, 3 insertions(+)

DH207891+OuyangPeng@DH207891 MINGW32 /f/git test (feature/test1)
$ git log
commit dab39f4808f6553e57a0551f44044919a31dc76b
Author: ouyangpeng <ouyangpeng@oaserver.dw.gdbbk.com>
Date:   Wed Nov 14 09:42:17 2018 +0800

    third commit

commit 77dfdffc87bde49a6361bbdf36a9b01a20c10a3b
Author: ouyangpeng <ouyangpeng@oaserver.dw.gdbbk.com>
Date:   Wed Nov 14 09:38:44 2018 +0800

    second commit

commit 363a197ffb4236ec9d6ee5b7631ae326eae958f4
Author: ouyangpeng <ouyangpeng@oaserver.dw.gdbbk.com>
Date:   Wed Nov 14 09:36:32 2018 +0800

    first commit

DH207891+OuyangPeng@DH207891 MINGW32 /f/git test (feature/test1)
$

123456789101112131415161718192021222324252627282930313233343536373839404142434445464748495051525354555657585960616263646566676869
```

现在我们有两个分支了，一个 feature/test1分支，一个 master分支。 feature/test1分支比master分支多了一次提交记录。

![在这里插入图片描述](https://img-blog.csdnimg.cn/20181114094645494.png?x-oss-process=image/watermark,type_ZmFuZ3poZW5naGVpdGk,shadow_10,text_aHR0cHM6Ly9ibG9nLmNzZG4ubmV0L3FxNDQ2MjgyNDEy,size_16,color_FFFFFF,t_70)

## 4、删除删除 feature/test1 分支

现在我们模拟刚才那位同事之间删除了 feature/test1 分支。我们先checkout到master分支，然后删除 feature/test1 分支
![在这里插入图片描述](https://img-blog.csdnimg.cn/20181114094940346.png?x-oss-process=image/watermark,type_ZmFuZ3poZW5naGVpdGk,shadow_10,text_aHR0cHM6Ly9ibG9nLmNzZG4ubmV0L3FxNDQ2MjgyNDEy,size_16,color_FFFFFF,t_70)

feature/test1分支因为没有合并到master分支，就被删除了。所以此时master分支没有feature/test1分支上做的新的修改记录。
![在这里插入图片描述](https://img-blog.csdnimg.cn/20181114095117506.png?x-oss-process=image/watermark,type_ZmFuZ3poZW5naGVpdGk,shadow_10,text_aHR0cHM6Ly9ibG9nLmNzZG4ubmV0L3FxNDQ2MjgyNDEy,size_16,color_FFFFFF,t_70)

```
DH207891+OuyangPeng@DH207891 MINGW32 /f/git test (feature/test1)
$ git checkout master
Switched to branch 'master'

DH207891+OuyangPeng@DH207891 MINGW32 /f/git test (master)
$ git branch
  feature/test1
* master

DH207891+OuyangPeng@DH207891 MINGW32 /f/git test (master)
$ git branch -d feature/test1
error: The branch 'feature/test1' is not fully merged.
If you are sure you want to delete it, run 'git branch -D feature/test1'.

DH207891+OuyangPeng@DH207891 MINGW32 /f/git test (master)
$ git branch
  feature/test1
* master

DH207891+OuyangPeng@DH207891 MINGW32 /f/git test (master)
$ git branch -D feature/test1
Deleted branch feature/test1 (was dab39f4).

DH207891+OuyangPeng@DH207891 MINGW32 /f/git test (master)
$ git branch
* master

DH207891+OuyangPeng@DH207891 MINGW32 /f/git test (master)
$ git log
commit 77dfdffc87bde49a6361bbdf36a9b01a20c10a3b
Author: ouyangpeng <ouyangpeng@oaserver.dw.gdbbk.com>
Date:   Wed Nov 14 09:38:44 2018 +0800

    second commit

commit 363a197ffb4236ec9d6ee5b7631ae326eae958f4
Author: ouyangpeng <ouyangpeng@oaserver.dw.gdbbk.com>
Date:   Wed Nov 14 09:36:32 2018 +0800

    first commit


123456789101112131415161718192021222324252627282930313233343536373839404142
```

# 三、恢复feature/test1分支

如何恢复feature/test1分支呢？？

## 3.1 找到feature/test1分支的最后一次提交记录

我们使用 git reflog 来看下git的提交记录，可以发现 dab39f4这次提交记录描述是 third commit 。

> 区别：如果在回退以后又想再次回到之前的版本，**git reflog** 可以查看所有分支的所有操作记录（包括commit和reset的操作），**包括已经被删除的commit记录**，**git log**则不能察看已经删除了的commit记录

![在这里插入图片描述](https://img-blog.csdnimg.cn/20181114095422936.png?x-oss-process=image/watermark,type_ZmFuZ3poZW5naGVpdGk,shadow_10,text_aHR0cHM6Ly9ibG9nLmNzZG4ubmV0L3FxNDQ2MjgyNDEy,size_16,color_FFFFFF,t_70)

```
DH207891+OuyangPeng@DH207891 MINGW32 /f/git test (master)
$ git branch
* master

DH207891+OuyangPeng@DH207891 MINGW32 /f/git test (master)
$ git log
commit 77dfdffc87bde49a6361bbdf36a9b01a20c10a3b
Author: ouyangpeng <ouyangpeng@oaserver.dw.gdbbk.com>
Date:   Wed Nov 14 09:38:44 2018 +0800

    second commit

commit 363a197ffb4236ec9d6ee5b7631ae326eae958f4
Author: ouyangpeng <ouyangpeng@oaserver.dw.gdbbk.com>
Date:   Wed Nov 14 09:36:32 2018 +0800

    first commit

DH207891+OuyangPeng@DH207891 MINGW32 /f/git test (master)
$ git reflog
77dfdff HEAD@{0}: checkout: moving from feature/test1 to master
dab39f4 HEAD@{1}: commit: third commit
77dfdff HEAD@{2}: checkout: moving from master to feature/test1
77dfdff HEAD@{3}: commit: second commit
363a197 HEAD@{4}: commit (initial): first commit


123456789101112131415161718192021222324252627
```

我们再来看看之前的截图，在feature/test1分支第三次提交的值为 dab39f4808f6553e57a0551f44044919a31dc76b
![img](https://img-blog.csdnimg.cn/201811140945099.png?x-oss-process=image/watermark,type_ZmFuZ3poZW5naGVpdGk,shadow_10,text_aHR0cHM6Ly9ibG9nLmNzZG4ubmV0L3FxNDQ2MjgyNDEy,size_16,color_FFFFFF,t_70)

dab39f4 和 dab39f4808f6553e57a0551f44044919a31dc76b 不就是提交记录的简写和完整的写法，一模一样。

因此我们找到了这次提交的SHA1校验和，因此我们就可以恢复feature/test1分支了。

## 3.2 根据feature/test1分支的最后一次提交记录来恢复feature/test1分支

![在这里插入图片描述](https://img-blog.csdnimg.cn/20181114100223325.png?x-oss-process=image/watermark,type_ZmFuZ3poZW5naGVpdGk,shadow_10,text_aHR0cHM6Ly9ibG9nLmNzZG4ubmV0L3FxNDQ2MjgyNDEy,size_16,color_FFFFFF,t_70)

```
DH207891+OuyangPeng@DH207891 MINGW32 /f/git test (master)
$ git reflog
77dfdff HEAD@{0}: checkout: moving from feature/test1 to master
dab39f4 HEAD@{1}: commit: third commit
77dfdff HEAD@{2}: checkout: moving from master to feature/test1
77dfdff HEAD@{3}: commit: second commit
363a197 HEAD@{4}: commit (initial): first commit

DH207891+OuyangPeng@DH207891 MINGW32 /f/git test (master)
$ git branch
* master

DH207891+OuyangPeng@DH207891 MINGW32 /f/git test (master)
$ git checkout -b feature/test1 dab39f4
Switched to a new branch 'feature/test1'

DH207891+OuyangPeng@DH207891 MINGW32 /f/git test (feature/test1)
$ git branch
* feature/test1
  master

DH207891+OuyangPeng@DH207891 MINGW32 /f/git test (feature/test1)
$ git log
commit dab39f4808f6553e57a0551f44044919a31dc76b
Author: ouyangpeng <ouyangpeng@oaserver.dw.gdbbk.com>
Date:   Wed Nov 14 09:42:17 2018 +0800

    third commit

commit 77dfdffc87bde49a6361bbdf36a9b01a20c10a3b
Author: ouyangpeng <ouyangpeng@oaserver.dw.gdbbk.com>
Date:   Wed Nov 14 09:38:44 2018 +0800

    second commit

commit 363a197ffb4236ec9d6ee5b7631ae326eae958f4
Author: ouyangpeng <ouyangpeng@oaserver.dw.gdbbk.com>
Date:   Wed Nov 14 09:36:32 2018 +0800

    first commit

DH207891+OuyangPeng@DH207891 MINGW32 /f/git test (feature/test1)
$

1234567891011121314151617181920212223242526272829303132333435363738394041424344
```

我们可以看到，我们恢复了 feature/test1分支，并且feature/test1分支之前的提交记录都完整的还原回来了，和原来一样，比master分支多了一次提交记录。如下所示：
![在这里插入图片描述](https://img-blog.csdnimg.cn/20181114100641227.png?x-oss-process=image/watermark,type_ZmFuZ3poZW5naGVpdGk,shadow_10,text_aHR0cHM6Ly9ibG9nLmNzZG4ubmV0L3FxNDQ2MjgyNDEy,size_16,color_FFFFFF,t_70)

## 3.3 在Gitlab上根据commit SHA直接新建branch来恢复被删除的分支

当然也可以在Gitlab上根据commit SHA直接新建branch来恢复被删除的分支，操作如下所示：

![在这里插入图片描述](https://img-blog.csdnimg.cn/20181114104312392.png?x-oss-process=image/watermark,type_ZmFuZ3poZW5naGVpdGk,shadow_10,text_aHR0cHM6Ly9ibG9nLmNzZG4ubmV0L3FxNDQ2MjgyNDEy,size_16,color_FFFFFF,t_70)

选择【Create from】，然后输入刚才查找到的commit SHA

![在这里插入图片描述](https://img-blog.csdnimg.cn/20181114104424553.png?x-oss-process=image/watermark,type_ZmFuZ3poZW5naGVpdGk,shadow_10,text_aHR0cHM6Ly9ibG9nLmNzZG4ubmV0L3FxNDQ2MjgyNDEy,size_16,color_FFFFFF,t_70)

然后点击回车
![在这里插入图片描述](https://img-blog.csdnimg.cn/20181114104449400.png?x-oss-process=image/watermark,type_ZmFuZ3poZW5naGVpdGk,shadow_10,text_aHR0cHM6Ly9ibG9nLmNzZG4ubmV0L3FxNDQ2MjgyNDEy,size_16,color_FFFFFF,t_70)

接着在【Branch name】写上分支名即可恢复了。

# 四、git reflog 简介

官方介绍地址 https://git-scm.com/docs/git-reflog

![在这里插入图片描述](https://img-blog.csdnimg.cn/2018111410135510.png?x-oss-process=image/watermark,type_ZmFuZ3poZW5naGVpdGk,shadow_10,text_aHR0cHM6Ly9ibG9nLmNzZG4ubmV0L3FxNDQ2MjgyNDEy,size_16,color_FFFFFF,t_70)

![在这里插入图片描述](https://img-blog.csdnimg.cn/20181114102535810.png?x-oss-process=image/watermark,type_ZmFuZ3poZW5naGVpdGk,shadow_10,text_aHR0cHM6Ly9ibG9nLmNzZG4ubmV0L3FxNDQ2MjgyNDEy,size_16,color_FFFFFF,t_70)

具体的操作以及选项可以去上面的官网查看具体的用法，下面我就将刚才我们使用的git reflog 稍微讲下即可。

## 4.1 查看历史版本记录

命令：git reflog
作用：查看提交版本历史记录
执行命令后如图：
![在这里插入图片描述](https://img-blog.csdnimg.cn/20181114102112910.png)

```
DH207891+OuyangPeng@DH207891 MINGW32 /f/git test (feature/test1)
$ git reflog
dab39f4 HEAD@{0}: checkout: moving from master to feature/test1
77dfdff HEAD@{1}: checkout: moving from feature/test1 to master
dab39f4 HEAD@{2}: commit: third commit
77dfdff HEAD@{3}: checkout: moving from master to feature/test1
77dfdff HEAD@{4}: commit: second commit
363a197 HEAD@{5}: commit (initial): first commit
12345678
```

从图中可以看到，执行git reflog 命令后，显示出来了很多行记录。

> 每行记录都由版本号（commit id SHA），HEAD值和操作描述三部分组成。版本号在第一列，HEAD值在第二列，操作描述信息在第三列。

- 版本号
  在之前都有提到，标识着每一次提交、合并等操作时的版本，相当于唯一标识
- HEAD值
  同样用来标识版本，但是不同于版本号的是，Head值是相对的。
  当HEAD值为HEAD时，表示为提交的最新版本；HEAD^ 表示为最新版本的上一个版本；HEAD^^表示为最新版本的上上个版本；HEAD~100表示为最新版本的往上第100个版本。

> HEAD值越小，表示版本越新，越大表示版本生成时间越久。

在上面图中，我们发现HEAD值的展示形式为HEAD@{0}、HEAD@{1}、HEAD@{2}…同样HEAD值的数字越小，表示版本越新，数字越大表示版本越旧。

- 操作描述
  记录了本次是哪种操作，以及操作时编写的描述信息。

## 4.2 查看历史版本记录–指定显示条数

同时，与git log相同的是，git reflog也提供了控制显示条数的选项：
命令：git reflog -n
执行命令后如图：
![在这里插入图片描述](https://img-blog.csdnimg.cn/20181114102218113.png?x-oss-process=image/watermark,type_ZmFuZ3poZW5naGVpdGk,shadow_10,text_aHR0cHM6Ly9ibG9nLmNzZG4ubmV0L3FxNDQ2MjgyNDEy,size_16,color_FFFFFF,t_70)

```
DH207891+OuyangPeng@DH207891 MINGW32 /f/git test (feature/test1)
$ git reflog -3
dab39f4 HEAD@{0}: checkout: moving from master to feature/test1
77dfdff HEAD@{1}: checkout: moving from feature/test1 to master
dab39f4 HEAD@{2}: commit: third commit

DH207891+OuyangPeng@DH207891 MINGW32 /f/git test (feature/test1)
$

123456789
```

如图所示，这里设置显示条数为3条，执行命令后，显示的条数为指定的条数3条。

![在这里插入图片描述](https://img-blog.csdnimg.cn/20181114102331783.png?x-oss-process=image/watermark,type_ZmFuZ3poZW5naGVpdGk,shadow_10,text_aHR0cHM6Ly9ibG9nLmNzZG4ubmV0L3FxNDQ2MjgyNDEy,size_16,color_FFFFFF,t_70)

```
DH207891+OuyangPeng@DH207891 MINGW32 /f/git test (feature/test1)
$ git reflog -6
dab39f4 HEAD@{0}: checkout: moving from master to feature/test1
77dfdff HEAD@{1}: checkout: moving from feature/test1 to master
dab39f4 HEAD@{2}: commit: third commit
77dfdff HEAD@{3}: checkout: moving from master to feature/test1
77dfdff HEAD@{4}: commit: second commit
363a197 HEAD@{5}: commit (initial): first commit

123456789
```

如图所示，这里设置显示条数为6条，执行命令后，显示的条数为指定的条数6条。

Cloning into 'hutool'...
The authenticity of host 'gitee.com (180.97.125.228)' can't be established.
ECDSA key fingerprint is SHA256:FQGC9Kn/eye1W8icdBgrQp+KkGYoFgbVr17bmjey0Wc.
Are you sure you want to continue connecting (yes/no)? yes

















###   https://blog.csdn.net/u012145252/article/details/80628451

git 拉取报错    2:30	Error merging: refusing to merge unrelated histories



