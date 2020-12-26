# Linux yum 命令

yum（ Yellow dog Updater, Modified）是一个在 Fedora 和 RedHat 以及 SUSE 中的 Shell 前端软件包管理器。

基于 RPM 包管理，能够从指定的服务器自动下载 RPM 包并且安装，可以自动处理依赖性关系，并且一次安装所有依赖的软体包，无须繁琐地一次次下载、安装。

yum 提供了查找、安装、删除某一个、一组甚至全部软件包的命令，而且命令简洁而又好记。

### yum 语法

```
yum [options] [command] [package ...]
```

- **options：**可选，选项包括-h（帮助），-y（当安装过程提示选择全部为 "yes"），-q（不显示安装的过程）等等。
- **command：**要进行的操作。
- **package：**安装的包名。

------

## yum常用命令

- \1. 列出所有可更新的软件清单命令：yum check-update
- \2. 更新所有软件命令：yum update
- \3. 仅安装指定的软件命令：yum install <package_name>
- \4. 仅更新指定的软件命令：yum update <package_name>
- \5. 列出所有可安裝的软件清单命令：yum list
- \6. 删除软件包命令：yum remove <package_name>
- \7. 查找软件包命令：yum search <keyword>
- \8. 清除缓存命令:
  - yum clean packages: 清除缓存目录下的软件包
  - yum clean headers: 清除缓存目录下的 headers
  - yum clean oldheaders: 清除缓存目录下旧的 headers
  - yum clean, yum clean all (= yum clean packages; yum clean oldheaders) :清除缓存目录下的软件包及旧的 headers

### 实例 1

安装 pam-devel 

```
[root@www ~]# yum install pam-devel
Setting up Install Process
Parsing package install arguments
Resolving Dependencies  <==先检查软件的属性相依问题
--> Running transaction check
---> Package pam-devel.i386 0:0.99.6.2-4.el5 set to be updated
--> Processing Dependency: pam = 0.99.6.2-4.el5 for package: pam-devel
--> Running transaction check
---> Package pam.i386 0:0.99.6.2-4.el5 set to be updated
filelists.xml.gz          100% |=========================| 1.6 MB    00:05
filelists.xml.gz          100% |=========================| 138 kB    00:00
-> Finished Dependency Resolution
……(省略)
```

### 实例 2

移除  pam-devel

```
[root@www ~]# yum remove pam-devel
Setting up Remove Process
Resolving Dependencies  <==同样的，先解决属性相依的问题
--> Running transaction check
---> Package pam-devel.i386 0:0.99.6.2-4.el5 set to be erased
--> Finished Dependency Resolution

Dependencies Resolved

=============================================================================
 Package                 Arch       Version          Repository        Size
=============================================================================
Removing:
 pam-devel               i386       0.99.6.2-4.el5   installed         495 k

Transaction Summary
=============================================================================
Install      0 Package(s)
Update       0 Package(s)
Remove       1 Package(s)  <==还好，并没有属性相依的问题，单纯移除一个软件

Is this ok [y/N]: y
Downloading Packages:
Running rpm_check_debug
Running Transaction Test
Finished Transaction Test
Transaction Test Succeeded
Running Transaction
  Erasing   : pam-devel                    ######################### [1/1]

Removed: pam-devel.i386 0:0.99.6.2-4.el5
Complete!
```

### 实例 3

利用 yum 的功能，找出以 pam 为开头的软件名称有哪些？

```
[root@www ~]# yum list pam*
Installed Packages
pam.i386                  0.99.6.2-3.27.el5      installed
pam_ccreds.i386           3-5                    installed
pam_krb5.i386             2.2.14-1               installed
pam_passwdqc.i386         1.0.2-1.2.2            installed
pam_pkcs11.i386           0.5.3-23               installed
pam_smb.i386              1.1.7-7.2.1            installed
Available Packages <==底下则是『可升级』的或『未安装』的
pam.i386                  0.99.6.2-4.el5         base
pam-devel.i386            0.99.6.2-4.el5         base
pam_krb5.i386             2.2.14-10              base
```

------

## 国内 yum 源

网易（163）yum源是国内最好的yum源之一 ，无论是速度还是软件版本，都非常的不错。

将yum源设置为163 yum，可以提升软件包安装和更新的速度，同时避免一些常见软件版本无法找到。

### 安装步骤

首先备份/etc/yum.repos.d/CentOS-Base.repo

```
mv /etc/yum.repos.d/CentOS-Base.repo /etc/yum.repos.d/CentOS-Base.repo.backup
```

下载对应版本 repo 文件, 放入 /etc/yum.repos.d/ (操作前请做好相应备份)

- [CentOS5](http://mirrors.163.com/.help/CentOS5-Base-163.repo) ：http://mirrors.163.com/.help/CentOS5-Base-163.repo
- [CentOS6](http://mirrors.163.com/.help/CentOS6-Base-163.repo) ：http://mirrors.163.com/.help/CentOS6-Base-163.repo
- [CentOS7](http://mirrors.163.com/.help/CentOS7-Base-163.repo) ：http://mirrors.163.com/.help/CentOS7-Base-163.repo

```
wget http://mirrors.163.com/.help/CentOS6-Base-163.repo
mv CentOS6-Base-163.repo CentOS-Base.repo
```

运行以下命令生成缓存

```
yum clean all
yum makecache
```

除了网易之外，国内还有其他不错的 yum 源，比如中科大和搜狐。

中科大的 yum 源，安装方法查看：https://lug.ustc.edu.cn/wiki/mirrors/help/centos

sohu 的 yum 源安装方法查看: http://mirrors.sohu.com/help/centos.html

 [Linux vi/vim](https://www.runoob.com/linux/linux-vim.html) 

[Linux apt 命令](https://www.runoob.com/linux/linux-comm-apt.html) 

##      	    	    	        2  篇笔记   写笔记    

1. 

     li1121567428

    li1***567428@live.com

    50

   **配置本地Yum仓库**

   实现此案例需要按照如下步骤进行。

   步骤一：搭建一个本地Yum，将RHEL6光盘手动挂载到/media

   命令操作如下所示：

   ```
   [root@localhost ~]# mount /dev/cdrom /media/
   mount: block device /dev/sr0 is write-protected, mounting read-only
   [root@localhost ~]# mount | tail -1
   /dev/sr0 on /media type iso9660 (ro)
   ```

   步骤二：将本地设置为客户端，进行Yum验证

   Yum客户端需编辑配置文件，命令操作如下所示：

   ```
   [root@localhost ~]# cd /etc/yum.repos.d/         //必须在这个路径下
   [root@localhost yum.repos.d]# ls                  //此路径下事先有配置文件的模板
   rhel-source.repo
   
   [root@localhost yum.repos.d]# cp rhel-source.repo rhel6.repo //配置文件必须以.repo结尾
   [root@localhost yum.repos.d]# vim rhel6.repo
   [rhel-6]                                     //中括号里内容要求唯一，但不要出现特殊字符
   name=Red Hat Enterprise Linux 6           //此为描述信息，可以看情况填写
   baseurl=file:///media/                     //此项为yum软件仓库位置，指向光盘挂载点
   enabled=1                                   //此项为是否开启，1为开启, 0为不开启
   gpgcheck=1                                  //此项为是否检查签名，1为检测, 0为不检测
   gpgkey=file:///etc/pki/rpm-gpg/RPM-GPG-KEY-redhat-release  //签名认证信息的路径
   
   [root@localhost /]# yum repolist
   Loaded plugins: product-id, refresh-packagekit, security, subscription-manager
   This system is not registered to Red Hat Subscription Management. You can use subscription-manager to register.
   rhel-6                                            | 3.9 kB     00:00 ... 
   rhel-6/primary_db                                  | 3.1 MB     00:00 ... 
   repo id             repo name                                     status
   rhel-6              Red Hat Enterprise Linux 6                    3,690
   repolist: 3,690
   ```

   [li1121567428](javascript:;)  li1121567428 li1***567428@live.com3年前 (2017-07-01)

2. 

     荣书

    zrs***07@163.com

    42

   对于 Linux 软件安装时提示缺失库的，可以使用 yum 的 provides 参数查看 libstdc++.so.6 的库文件包含在那个安装包中只需要执行：

   ```
   yum provides libstdc++.so.6
   ```

   然后按查询到安装包包名，使用 **yum install** 安装即可。







###  yum 语法

1 安装
 yum install 全部安装
 yum install package1 安装指定的安装包package1
 yum groupinsall group1 安装程序组group1

2 更新和升级
 yum update 全部更新
 yum update package1 更新指定程序包package1
 yum check-update 检查可更新的程序
 yum upgrade package1 升级指定程序包package1
 yum groupupdate group1 升级程序组group1

3 查找和显示
 yum info package1 显示安装包信息package1
 yum list 显示所有已经安装和可以安装的程序包
 yum list package1 显示指定程序包安装情况package1
 yum groupinfo group1 显示程序组group1信息yum search string 根据关键字string查找安装包

4 删除程序
 yum remove &#124; erase package1 删除程序包package1
 yum groupremove group1 删除程序组group1
 yum deplist package1 查看程序package1依赖情况

5 清除缓存
 yum clean packages 清除缓存目录下的软件包
 yum clean headers 清除缓存目录下的 headers
 yum clean oldheaders 清除缓存目录下旧的 headers
 yum clean, yum clean all (= yum clean packages; yum clean oldheaders) 清除缓存目录下的软件包及旧的headers

比如，要安装游戏程序组，首先进行查找：
 ＃：yum grouplist
 可以发现，可安装的游戏程序包名字是”Games and Entertainment“，这样就可以进行安装：
 ＃：yum groupinstall "Games and Entertainment"
 所 有的游戏程序包就自动安装了。在这里Games and  Entertainment的名字必须用双引号选定，因为linux下面遇到空格会认为文件名结束了，因此必须告诉系统安装的程序包的名字是“Games and Entertainment”而不是“Games"。

此外，还可以修改配置文件/etc/yum.conf选择安装源。可见yum进行配置程序有多方便了吧。更多详细的选项和命令，当然只要在命令提示行下面:man yum

yum groupinstall "KDE (K Desktop Environment)"

yum install pirut k3b mikmod

yum groupinstall "Server Configuration Tools"

yum groupinstall "Sound and Video"

\#yum groupinstall "GNOME Desktop Environment"

yum groupinstall "Legacy Software Support"

yum groupinstall "Development Libraries"

yum groupinstall "Development Tools"

\#yum groupinstall "Windows File Server"

yum groupinstall "System Tools"

yum groupinstall "X Window System"

yum install php-gd
 yum install gd-devel
 yum groupinstall "Chinese Support"


 \#yum install samba-common //该执行会一起安装 samba-client
 \#yum install samba

yum install gcc
 yum install cpp
 yum install gcc-c++
 yum install ncurses
 yum install ncurses-devel
 yum install gd-devel php-gd
 yum install gd-devel
 yum install gcc
 yum install cpp
 yum install gcc-c++
 yum install ncurses
 yum install ncurses-devel
 yum install gd-devel php-gd
 yum install gd-devel
 yum install zlib-devel
 yum install freetype-devel freetype-demos freetype-utils
 yum install libpng-devel libpng10 libpng10-devel
 yum install libjpeg-devel
 yum install ImageMagick
 yum install php-gd
 yum install flex
 yum install ImageMagick-devel


 \#yum install system-config-bind     
 \#yum groupinstall "DNS Name Server"   //安裝 bind 及 bind-chroot 套件
 yum groupinstall "MySQL Database"'

yum clean all

\-----------------------------------------------------------------------------------------------------------

装了个fedora linux不能用中文输入是一件很棘手的事，连搜解决方案都没法搜。只能勉强用几个拼音碰碰运气，看Google能不能识别了。而我就遇见了这样的事。
 解决方案：
 yum install scim* -y

yum 命令详解：
  Redhat和Fedora的软件安装命令是rpm，但是用rpm安装软件最大的麻烦就是需要手动寻找安装该软件所需要的一系列依赖关系，超级  麻烦不说，要是软件不用了需要卸载的话由于卸载掉了某个依赖关系而导致其他的软件不能用是非常恼人的。令人高兴的是，Fedora终于推出了类似于  ubuntu中的apt的命令yum，令Fedora的软件安装变得简单容易。Yum 有以下特点：
 *可以同时配置多个资源库(Repository)
 *简洁的配置文件(/etc/yum.conf)
 *自动解决增加或删除rpm包时遇到的倚赖性问题
 *使用方便
 *保持与RPM数据库的一致性
 yum，是Yellow dog Updater Modified的简称，起初是由yellow dog这一发行版的开发者Terra  Soft研发，用python写成，那时还叫做yup(yellow dog  updater)，后经杜克大学的Linux@Duke开发团队进行改进，遂有此名。yum的宗旨是自动化地升级，安装/移除rpm包，收集rpm包的相关信息，检查依赖性并自动提示用户解决。yum的关键之处是要有可靠的repository，顾名思义，这是软件的仓库，它可以是http或ftp站点， 也可以是本地软件池，但必须包含rpm的header，  header包括了rpm包的各种信息，包括描述，功能，提供的文件，依赖性等.正是收集了这些 header并加以分析，才能自动化地完成余下的任务。
 1.yum的一切配置信息都储存在一个叫yum.conf的配置文件中，通常位于/etc目 录下，这是整个yum系统的重中之重，我在的F9中查看了这一文件，大家一起来看下：
 [hanlong@localhost F9常用文档]$ sudo more /etc/yum.conf
 [main]
 cachedir=/var/cache/yum
 keepcache=0
 debuglevel=2
 logfile=/var/log/yum.log
 exactarch=1
 obsoletes=1
 gpgcheck=1
 plugins=1
 metadata_expire=1800
 \# PUT YOUR REPOS HERE OR IN separate files named file.repo
 \# in /etc/yum.repos.d

下面简单的对这一文件作简要的说明：
 cachedir：yum缓存的目录，yum在此存储下载的rpm包和数据库，一般是/var/cache/yum。
 debuglevel：除错级别，0──10,默认是2
 logfile：yum的日志文件，默认是/var/log/yum.log。
 exactarch，有两个选项1和0,代表是否只升级和你安装软件包cpu体系一致的包，如果设为1，则如你安装了一个i386的rpm，则yum不会用686的包来升级。
 gpgchkeck= 有1和0两个选择，分别代表是否是否进行gpg校验，如果没有这一项，默认好像也是检查的。
 2.好了，接下来就是yum的使用了，首先用yum来升级软件，yum的操作大都须有超级用户的权限，当然可以用sudo。
 yum  update，这一步是必须的，yum会从服务器的header目录下载rpm的header，放在本地的缓存中，这可能会花费一定的时间，但比起yum  给我们带来方便，这些时间的花费又算的了什么呢？header下载完毕，yum会判断是否有可更新的软件包，如果有，它会询问你的意见，是否更新，还是说 y吧，把系统始终up to  date总是不错的，这时yum开始下载软件包并使用调用rpm安装，这可能要一定时间，取决于要更新软件的数目和网络状况，万一网络断了，也没关系，再 进行一次就可以了。升级完毕，以后每天只要使用yum check-update检查一下有无跟新，如果有，就用yum  update进行跟新，时刻保持系统为最新，堵住一切发现的漏洞。用yum update packagename 对某个单独包进行升级。
 现在简单的把yum软件升级的一些命令罗列一下：
 (更新：我在安装wine的时候是用rpm一个一个安装的，先安装以来关系，然后在安装wine的主包，但是刚刚在论坛上发现来一个好的帖子，就yum的本地安装。参数是-localinstall
 $yum localinstall wine-*
 这样的话，yum会自动安装所有的依赖关系，而不用rpm一个一个的安装了，省了好多工作。
 还有一个与他类似的参数：
 $yum localupdate wine-*
 如果有wine的新版本，而且你也下载到来本地，就可以这样本地更新wine了。)

1.列出所有可更新的软件清单
 命令：yum check-update

2.安装所有更新软件
 命令：yum update

3.仅安装指定的软件
 命令：yum install

4.仅更新指定的软件
 命令：yum update

5.列出所有可安裝的软件清单
 命令：yum list

3.使用yum安装和卸载软件，有个前提是yum安装的软件包都是rpm格式的。
 安装的命令是，yum install xxx，yum会查询数据库，有无这一软件包，如果有，则检查其依赖冲突关系，如果没有依赖冲突，那么最好，下载安装;如果有，则会给出提示，询问是否要同时安装依赖，或删除冲突的包，你可以自己作出判断
 删除的命令是，yum remove xxx，同安装一样，yum也会查询数据库，给出解决依赖关系的提示。
 1.用YUM安装软件包
 命令：yum install

2.用YUM删除软件包
 命令：yum remove

4.用yum查询想安装的软件
  我们常会碰到这样的情况，想要安装一个软件，只知道它和某方面有关，但又不能确切知道它的名字。这时yum的查询功能就起作用了。你可以用 yum  search keyword这样的命令来进行搜索，比如我们要则安装一个Instant Messenger，但又不知到底有哪些，这时不妨用 yum search  messenger这样的指令进行搜索，yum会搜索所有可用rpm的描述，列出所有描述中和messeger有关的rpm包，于是我们可能得到  gaim，kopete等等，并从中选择。
 有时我们还会碰到安装了一个包，但又不知道其用途，我们可以用yum info packagename这个指令来获取信息。
 1.使用YUM查找软件包
 命令：yum search
 2.列出所有可安装的软件包
 命令：yum list
 3.列出所有可更新的软件包
 命令：yum list updates
 4.列出所有已安装的软件包
 命令：yum list installed
 5.列出所有已安装但不在 Yum Repository 內的软件包
 命令：yum list extras
 6.列出所指定的软件包
 命令：yum list 7.使用YUM获取软件包信息
 命令：yum info 8.列出所有软件包的信息
 命令：yum info
 9.列出所有可更新的软件包信息
 命令：yum info updates
 10.列出所有已安裝的软件包信息
 命令：yum info installed
 11.列出所有已安裝但不在 Yum Repository 內的软件包信息
 命令：yum info extras
 12.列出软件包提供哪些文件
 命令：yum provides

5.清除YUM缓存
 yum  会把下载的软件包和header存储在cache中，而不会自动删除。如果我们觉得它们占用了磁盘空间，可以使用yum  clean指令进行清除，更精确的用法是yum clean headers清除header，yum clean  packages清除下载的rpm包，yum clean all 清除所有
 1.清除缓存目录(/var/cache/yum)下的软件包
 命令：yum clean packages

2.清除缓存目录(/var/cache/yum)下的 headers

命令：yum clean headers

3.清除缓存目录(/var/cache/yum)下旧的 headers

命令：yum clean oldheaders

4.清除缓存目录(/var/cache/yum)下的软件包及旧的headers

命令：yum clean, yum clean all (= yum clean packages; yum clean oldheaders)

以上所有命令参数的使用都可以用man来查看：
 1、安装图形版yumex：yum install yumex。
 2、安装额外的软件仓库：
 rpm.livna.org 的软件包仓库:
 rpm -ivh [http://livna-dl.reloumirrors.net](http://livna-dl.reloumirrors.net/) … ease-7-2.noarch.rpm

freshrpms.net 的软件包仓库:
 rpm –ivh http://ftp.freshrpms.net/pub/fre … 1.1-1.fc.noarch.rpm

3、安装最快源 yum install yum-fastestmirror

资源真的是非常丰富，从Centos到Ubuntu，ISO镜像、升级包，应有尽有，上交的兄弟们真是幸福，羡慕啊。不过还好，我们好歹也算是在教育网内，凑合着也可以沾点光，下载一些。
 网址为：ftp://ftp.sjtu.edu.cn/

相应的yum的repo为
 [updates]
 name=Fedora updates
 baseurl=ftp://ftp.sjtu.edu.cn/fedora/linux/updates/$releasever/$basearch/
 enabled=1
 gpgcheck=0
 [fedora]
 name=Fedora $releasever - $basearch
 baseurl=ftp://ftp.sjtu.edu.cn/fedora/linux/releases/$releasever/Everything/$basearch/os/
 enabled=1
 gpgcheck=1
 gpgkey=file:///etc/pki/rpm-gpg/RPM-GPG-KEY-fedora file:///etc/pki/rpm-gpg/RPM-GPG-KEY

如果在机器上安装了apt管理器，则相应的源为
 repomd ftp://ftp.sjtu.edu.cn/ fedora/linux/updates/$(VERSION)/$(ARCH)/

repomd ftp://ftp.sjtu.edu.cn/ fedora/linux/releases/$(VERSION)/Everything/$(ARCH)/os/

这与前面yum的源的格式上有一些差别，需要加以注意。
 下面介绍一下fedora 下安装 scim

1． 什么输入法适合我？
 fcitx和scim是目前比较好的输入法，  但是他们的特点不同，fcitx只能输入中文，而scim可以根据需要，利用不同的码表达到中英日…等等各种语言的输入问题。如果你只懂中文，或者只会输 入英文&中文，那么fcitx是一个不错的选择，因为它漂亮，小巧，实用。如果你还需要输入日文或者其他语言，那么你因该安装scim。通  过合理的配置，他能够让你像在windows里面一样，想输入什么语言就能输入什么语言，同一种语言想用什么输入法就用什么输入法。Scim的扩充性很  强，而且比较稳定，我就是选择的是scim.
 2． 安装一个新输入法前需要哪些准备？
 如果你选择fcitx或者scim，那么我建议你删除系统自带的中文输入法。方法如下：
 rpm –qa | grep iiimf | xargs rpm –e
 rpm –qa | grep Chinput| xargs rpm –e
 如果有哪一行提示rpm: no packages given for erase那表示本身你的系统里面没有该输入法，不用担心，继续往下看就行了。
 说 明：rpm –qa是列出所有安装的rpm包，grep iiimf是选择出其中名字含有iiimf的那些包，xargs rpm  –e的意思是把前面列出的这些包删除掉。Xargs的作用就是把前面通过 |  传过来的数据作为下面命令的参数。这就好比一个过滤器，首先是放着所有的安装包，然后grep以后，只留下了含有某些特定关键字的rpm包，然后通过  xargs和rpm  –e的组合运用，把剩下的这些含有某特定关键字的包删掉。这样就达到了删除该输入法及相关包的目的。下面的Chinput也是如此，在此不再重复。如果你还安装了其他输入法，比如你原来装的是fcitx，现在想装scim，那么你最好模仿上面的样子把fcitx删除，方法就是把iiimf的位置改成 fcitx就可以了。
 在安装新输入法之前，最好这样做一下，因为多种输入法同时存在一个系统中没有什么好处，你只可能去用一个，而且他们同时存在可能有的时候会出现问题，想想也知道，会互相竞争嘛。所以在此以后，你应该保证系统里面已经没有中文输入法了。通过类似以下方式验证：
 whereis fcitx
 whereis scim
 whereis miniChinput
 …





```
sudo yum-config-manager  --add-repo https://download.docker.com/linux/centos/docker-ce.repo
```