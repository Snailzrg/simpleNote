# Linux基础知识
  来自CSDN总结 比自己总结的到位
## [Linux目录结构](https://blog.csdn.net/beyondlee2011/article/details/85341516)
  ```
  /
   ├── bin      #用户二进制可执行命令  例如 mkdir（创建目录）、cat（查看文件）、find（查找文件）等。
   ├── boot     #存放内核文件和系统引导程序
   ├── data     #挂载目录，数据存储，虚拟机硬盘大多挂载在这个区 
   ├── dev      #设备文件存放的目录，因为linux中一切皆文件
   ├── etc 		#yum/rpm安装的软件配置文件所在的目录。  一般配置文件启动文件放置此处
   ├── home     #用户home,如root,新建用户会在此建同名目录
   ├── lib 
   ├── lib64 
   ├── lost+found 
   ├── media	 #用于挂载可移动设备的临时目录
   ├── mnt 
   ├── opt   	 #该目录是可选的，一般是给第三方厂家开发的程序的安装目录。现在一般不用了。
   ├── proc 
   ├── root
   ├── sbin      #只供系统管理员二进制可行性命令 如：iptables（防护墙）、ifconfig（查看网卡信息）、init（设置启动级别）
   ├── selinux 
   ├── srv 
   ├── sys 		#与/proc一样，存放系统运行过程中的信息文件
   ├── tmp      #临时文件存放的地方，目录的权限为1777，所有用户对这个目录都有可读可写可执行的权限，所以其他人也可以删除你的文件。(可以当作windows的回收站来用，不用的东西先放这里)
   ├── upload 
   ├── usr 		#安装除操作系统本身外的一些应用程序或组件的目录，一般可以认为是linux系统上安装的应用程序默认都安装在此目录中
   └── var
  ```
## 特殊文件说明
###  网卡配置文件
文件位置为：/etc/sysconfig/network-scripts/ifcfg-eth0，该文件控制网卡的配置信息，网卡的配置文件统一放在network-scripts中，eth1表示第二块网卡，依次累加。
```
[root@lixin usr]# cat /etc/sysconfig/network-scripts/ifcfg-eth0 
DEVICE=eth0                  #设备名称
TYPE=Ethernet                        #设备类型为Ethernet
ONBOOT=yes                                  #开机启动
NM_CONTROLLED=yes            
BOOTPROTO=none               #IP获取方式
IPADDR=10.0.0.8                             #IP地址
NETMASK=255.255.255.0        #网络掩码
DNS2=4.4.4.4                                #备用DNS地址
GATEWAY=10.0.0.2                            #网关地址
DNS1=10.0.0.2                        #主用DNS地址
[root@lixin usr]#
```
特殊字段说明：
    NM_CONTROLLED表示是否启用NetworkManager管理，NetworkManager是一个图形管理工具，没有装图形界面该选项可以改为no。
    BOOTPROTO 表示获取IP的方式，动态获取（dhcp），静态配置（static），无（none）。
### DNS解析配置文件
```
[root@yg-zhangdy /]# more /etc/resolv.conf
; generated by /usr/sbin/dhclient-script
search ygsoft.com
nameserver 10.0.0.1
nameserver 10.0.0.2
```

...... 待续


## [Linux 用户管理](https://blog.csdn.net/beyondlee2011/article/details/85341819)



## [Linux 目录结构]










