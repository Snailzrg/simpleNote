[toc]
# CenterOS

## 一: 常见配置

### 1.1 基础配置

> netstat -anlpt | grep 22
> yum instatll net-tools –y    ----安装netstat工具

> 所以我们需要重新安装即可
> yum reinstall openssh-server

云服务器 ECS Linux CentOS 7 下重启服务通过service 操作报错：
Redirecting to /bin/systemctl restart sshd.service
查资料发现，在ESC下重启服务是通过systemctl 操作： 

> 例：1、启动sshd服务：
> systemctl start sshd.service
> 2.、重启 sshd 服务：
> systemctl restart sshd.service
> 3、 设置服务开启自启：
> systemctl enable sshd.service 

首先使用ip add命令查看系统当前IP地址，可以看到当前IP地址是10.0.0.3
查看之后你就会发现ens33是没有inet属性的，然而不存在这个属性是不可以连接虚拟机的。 
  vi/etc/sysconf ig/network-scripts/ifcfg/ens33

### 1.2 替换国内yum源

rpm -qa | grep yum  <!-- 是否安装yum  yum repolist all -->

> 如果 Linux中提示-bash: wget: command not found的解决方法 没有安装下载器

| Ubuntu/Debian           | centeros            |
| ----------------------- | ------------------- |
| apt-get install -y wget | yum install wget -y |

- 网易163源

> 1 `wget -O /etc/yum.repos.d/CentOS-Base.repo.163  http://mirrors.163.com/.help/CentOS7-Base-163.repo

> 2 mv /etc/yum.repos.d/CentOS-Base.repo /etc/yum.repos.d/CentOS-Base.repo.backup

> 3  mv /etc/yum.repos.d/CentOS-Base.repo.163  /etc/yum.repos.d/CentOS-Base.repo

> 4  yum clean all & yum makecache

- 阿里源

> 1 拉阿里云镜像   `wget -O /etc/yum.repos.d/CentOS-Base.repo.aliyun  http://mirrors.aliyun.com/repo/Centos-7.repo`

> 2 备份原镜像    `mv /etc/yum.repos.d/CentOS-Base.repo /etc/yum.repos.d/CentOS-Base.repo.backup`

> 3 使用阿里云    `mv /etc/yum.repos.d/CentOS-Base.repo.aliyun  /etc/yum.repos.d/CentOS-Base.repo`

> 4 运行yum makecache生成缓存   `yum clean all & yum makecache`

### 1.3 开放端口

- #### 1.3.1 查看对外开放的端口状态

  > 查询已开放的端口 netstat -anp
  > 查询指定端口是否已开 firewall-cmd --query-port=666/tcp
  > 提示 yes，表示开启；no表示未开启。

- #### 1.3.2 查看防火墙状态

  |      操作      |                 CenterOS7                 |        CenterOS6         |
  | :------------: | :---------------------------------------: | :----------------------: |
  | 查看防火墙状态 | systemctl status firewalld（active 开启） | service iptables status  |
  |   开启防火墙   |         systemctl start firewalld         |  service iptables start  |
  |   关闭防火墙   |         systemctl stop firewalld          |  service iptables stop   |
  |   重启防火墙   |        systemctl restart firewalld        | service iptables restart |

   若遇到无法开启

  > 先用：systemctl unmask firewalld.service 
  > 然后：systemctl start firewalld.service

- #### 1.3.3 查看对外端口是否开启：

  > firewall-cmd --query-port=6379/tcp       yes开/no关



- #### 1.3.4 开放指定端口

  > 添加指定需要开放的端口：
  > firewall-cmd --add-port=123/tcp --permanent
  > 重载入添加的端口：
  > firewall-cmd --reload
  > 查询指定端口是否开启成功：
  > firewall-cmd --query-port=123/tcp

- #### 1.3.5 移除指定端口：
  > firewall-cmd --permanent --remove-port=123/tcp     success/failed
  >
  > firewall-cmd --reload //重载
  >
  > firewall-cmd --query-port=123/tcp。 //查



- #### 1.3.6 CenterOS6 操作开放端口

  修改/etc/sysconfig/iptables文件

 > 文件内容开始-> 
 > Firewall configuration written by system-config-firewall
 > Manual customization of this file is not recommended. 
 > *filter 
 > :INPUT ACCEPT [0:0] 
 > :FORWARD ACCEPT [0:0] 
 > :OUTPUT ACCEPT [0:0] 
 > -A INPUT -m state --state ESTABLISHED,RELATED -j ACCEPT 
 > -A INPUT -p icmp -j ACCEPT 
 > -A INPUT -i lo -j ACCEPT 
 > -A INPUT -m state --state NEW -m tcp -p tcp --dport 22 -j ACCEPT 

添加的规则 8080 代表服务运行的端口，27027是数据库运行端口，需要根据具体配置进行修改/添加 

 > -A INPUT -m state --state NEW -m tcp -p tcp --dport 8080 -j ACCEPT 
 > -A INPUT -m state --state NEW -m tcp -p tcp --dport 27027 -j ACCEPT 
 > -A INPUT -j REJECT --reject-with icmp-host-prohibited -A FORWARD 
 > -j REJECT --reject-with icmp-host-prohibited COMMIT # 
 > <-文件内容结束 #修改文件后需要重启防火墙 service iptables restart

- #### 1.3.7 CenterOS7 修改配置文件形式添加规则 [firewall-cmd 二者选一]

/etc/firewalld/zones/public.xml

 > <?xml version="1.0" encoding="utf-8"?> 
 > <zone>
 >  <short>Public</short>
 >   <description>For use in public areas. You do not trust the other computers on networks to not harm your computer. Only selected incoming connections are accepted. </description> 
 >   <!--service节点：配置服务名称-->
 >    <service name="ssh"/>
 >    <service name="dhcpv6-client"/> 
 > 	<!--port节点：配置端口/协议--> 
 > 	<port protocol="tcp" port="9200"/>
 > 	 <!--rule节点：强大的规则配置文件, 这个不赘述，自行了解，一般用不到，除非要限制某些ip地址-->
 > 	   <rule family="ipv4">
 > 			<source address="192.168.1.10"/> 
 > 			<port protocol="tcp" port="3306"/>
 > 			<accept/> 
 > 	   </rule> 
 > </zone> 



### 1.4 安装iptables-services

>yum install iptables-services 
>进入下面目录进行修改：
>/etc/sysconfig/iptables

## 二：yum

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

| 功能       | 命令                                                         | 结果 |
| ---------- | ------------------------------------------------------------ | ---- |
| 安装       | yum install 全部安装<br /> yum install package1 安装指定的安装包package1<br/> yum groupinsall group1 安装程序组group1 |      |
| 更新和升级 | yum update 全部更新<br/> yum update package1 更新指定程序包package1<br/> yum check-update 检查可更新的程序<br/> yum upgrade package1 升级指定程序包package1<br/> yum groupupdate group1 升级程序组group1 |      |
| 查找与显示 | yum info package1 显示安装包信息package1<br/> yum list 显示所有已经安装和可以安装的程序包<br/> yum list package1 显示指定程序包安装情况package1<br/> yum groupinfo group1 显示程序组group1信息yum search string 根据关键字string查找安装包 |      |
| 删除程序   | yum remove &#124; erase package1 删除程序包package1<br/> yum groupremove group1     删除程序组group1 <br/> yum deplist package1      查看程序package1依赖情况 |      |
| 清除缓存   | yum clean packages 清除缓存目录下的软件包<br/> yum clean headers 清除缓存目录下的 headers<br/> yum clean oldheaders 清除缓存目录下旧的 headers<br/> yum clean, yum clean all (= yum clean packages; yum clean oldheaders) 清除缓存目录下的软件包及旧的headers |      |

比如，要安装游戏程序组，首先进行查找：
 ＃：yum grouplist
 可以发现，可安装的游戏程序包名字是”Games and Entertainment“，这样就可以进行安装：
 ＃：yum groupinstall "Games and Entertainment"
 所 有的游戏程序包就自动安装了。在这里Games and  Entertainment的名字必须用双引号选定，因为linux下面遇到空格会认为文件名结束了，因此必须告诉系统安装的程序包的名字是“Games and Entertainment”而不是“Games"。

> 此外，还可以修改配置文件/etc/yum.conf选择安装源。可见yum进行配置程序有多方便了吧。更多详细的选项和命令，当然只要在命令提示行下面:man yum
>

## 三：一些问题

### 3.1 虚拟机中无法获取ip

> 接下来查看ens33网卡的配置：vi /etc/sysconfig/network-scripts/ifcfg-ens33

![image-20210120153011257](https://gitee.com/snailzrg/snail_img/raw/master/picgo_snail_img/image-20210120153011257.png)

> 检查虚拟机网络配置 重启即可

![image-20210120153645503](https://gitee.com/snailzrg/snail_img/raw/master/picgo_snail_img/image-20210120153645503.png)





