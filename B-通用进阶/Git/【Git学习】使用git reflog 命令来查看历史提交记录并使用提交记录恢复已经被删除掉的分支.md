# 【Git学习】使用git reflog 命令来查看历史提交记录并使用提交记录恢复已经被删除掉的分支
from CDSN：https://blog.csdn.net/ouyang_peng/article/details/84061662

一、问题描述
昨天下午有个同事急急忙忙跑我座位上，要我帮忙，说他刚刚因为手误，将他本地的某个project的某个branch分支删除了，并且也将Gitlab上面的远程分支也删除了。他本来是想发起merge request的，但是后面他眼神不好以为已经merged过了，就直接删了Gitlab上的远程分支并且将他本地的这个分支也直接删除了。

现在他跑过来问我有没有办法恢复，不然他这一天的工作就白费了。

看他急急忙忙不知所措的样子，我直接调侃他说恢复不了。要他以后小心点删除branch，不要眼神不好。后面才慢慢地然后使用了git reflog 查找了他所有的分支提交记录等，然后找到对应的git commit的sha1码，然后恢复过来了。他说居然还有这种操作，666！我去，这是常规操作好吗？

所以 如何恢复本地和远程仓库都已经删除掉的分支呢？？下面我来演示一下。

二、复现问题
现在我准备找一个测试的demo git 工程来进行演练一下，如何恢复以及被删除的分支。

1、创建一个git仓库并且提交一个文件
![](【Git学习】使用git reflog 命令来查看历史提交记录并使用提交记录恢复已经被删除掉的分支_files/1.png)
 
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
    ```
**2、再次编辑test.txt文件并且提交**
    ![](_v_images/1542270839_4796.png)
**3、切换分支并再次编辑test.txt文件并且提交创建并切换到 feature/test1分支**
    ![](_v_images/1542270872_7982.png)
    在feature/test1分支上继续编辑test.txt文件并且提交
    ![](_v_images/1542270905_30504.png)

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
```

现在我们有两个分支了，一个 feature/test1分支，一个 master分支。 feature/test1分支比master分支多了一次提交记录。
![](_v_images/1542270982_12854.png)

**4、删除删除 feature/test1 分支**
现在我们模拟刚才那位同事之间删除了 feature/test1 分支。我们先checkout到master分支，然后删除 feature/test1 分支
![](_v_images/1542271046_18255.png)

feature/test1分支因为没有合并到master分支，就被删除了。所以此时master分支没有feature/test1分支上做的新的修改记录。
![](_v_images/1542271077_18350.png)

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
```

三、恢复feature/test1分支
如何恢复feature/test1分支呢？？

3.1 找到feature/test1分支的最后一次提交记录
我们使用 git reflog 来看下git的提交记录，可以发现 dab39f4这次提交记录描述是 third commit 。
    *区别：如果在回退以后又想再次回到之前的版本，git reflog 可以查看所有分支的所有操作记录（包括commit和reset的操作），包括已经被删除的commit记录，git log则不能察看已经删除了的commit记录*

