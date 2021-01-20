[toc]
# 虚拟机安装Linux

>- See https://www.cnblogs.com/hihtml5/p/8217062.html
>- 网络：https://blog.csdn.net/lei___2011/article/details/79210912

## 一：三种网络配置

### 1.1:Bridged（桥接模式）

桥接模式相当于虚拟机和主机在同一个真实网段，VMWare充当一个集线器功能（一根网线连到主机相连的路由器上），所以如果电脑换了内网，静态分配的ip要更改。图如下：

![img](https://images2018.cnblogs.com/blog/1208477/201804/1208477-20180419143437270-462551669.png)

### 1.2:  NAT（网络地址转换模式）

NAT模式和桥接模式一样可以上网，只不过，虚拟机会虚拟出一个内网，主机和虚拟机都在这个虚拟的局域网中。NAT中VMWare相当于交换机（产生一个局域网，在这个局域网中分别给主机和虚拟机分配ip地址）

**![img](https://images2018.cnblogs.com/blog/1208477/201804/1208477-20180419143720854-1271541753.png)**

#### 1.2.1: 步骤

- 1.设置VMVare的默认网关（相当于我们设置路由器）: 
  编辑->虚拟网络编辑器->更改设置->选中VM8>点击NAT设置，设置默认网关为192.168.182.2。

![img](https://images2018.cnblogs.com/blog/1208477/201804/1208477-20180419145040228-1331049611.png)![img](https://images2018.cnblogs.com/blog/1208477/201804/1208477-20180419145433514-976861705.png)

- 2.设置主机ip地址，点击VMnet8，设置ip地址为192.168.182.1，网关为上面设置的网关。

![img](https://images2018.cnblogs.com/blog/1208477/201804/1208477-20180419150244761-104929934.png)

![img](https://images2018.cnblogs.com/blog/1208477/201804/1208477-20180419145656726-751051047.png)

- 3.设置linux虚拟机上的网络配置，界面化同上。

#### 1.2.2:  IP配置

-  未安装系统

 ![img](https://img2020.cnblogs.com/blog/1208477/202012/1208477-20201218135525376-1790028470.png)

 

- 已安装系统

ifcfg-ens33原文件如下，此时为NAT模式下的DHCP

![img](https://img2020.cnblogs.com/blog/1208477/202010/1208477-20201025175946067-2099571204.png)

 改为静态IP：

如果是NAT要去虚拟网络编辑器中查看NAT设置中的网关IP

[![复制代码](https://common.cnblogs.com/images/copycode.gif)](javascript:void(0);)

```
cd  /etc/sysconfig/network-scripts/     //进入到网络适配器文件夹中
mv ifcfg-ethXXX ifcfg-eth0     //名字改为ifcfg-eth0
vi  ifcfg-eth0    //编辑文件

TYPE=Ethernet 
DEFROUTE=yes 
PEERDNS=yes 
PEERROUTES=yes 
IPV4_FAILURE_FATAL=no 
IPV6INIT=yes 
IPV6_AUTOCONF=yes
IPV6_DEFROUTE=yes 
IPV6_PEERDNS=yes 
IPV6_PEERROUTES=yes 
IPV6_FAILURE_FATAL=no 
NAME=eth0
#UUID（Universally Unique Identifier）是系统层面的全局唯一标识符号，Mac地址以及IP地址是网络层面的标识号；
#两台不同的Linux系统拥有相同的UUID并不影响系统的使用以及系统之间的通信；
#可以通过命令uuidgen ens33生成新的uuid
#和DEVICE一样也可以不写,DEVICE="ens33"可以不写，但一定不要写DEVICE="eth0"
UUID=ae0965e7-22b9-45aa-8ec9-3f0a20a85d11 

ONBOOT=yes  #开启自动启用网络连接,这个一定要改
IPADDR=192.168.182.3  #设置IP地址 
NETMASK=255.255.225.0  #设置子网掩码 
GATEWAY=192.168.182.2  #设置网关 
DNS1=61.147.37.1  #设置主DNS 
DNS2=8.8.8.8  #设置备DNS 
BOOTPROTO=static  #启用静态IP地址 ,默认为dhcp

:wq!  #保存退出 

service network restart  #重启网络，本文环境为centos7

ping www.baidu.com  #测试网络是否正常

ip addr  #查看IP地址
```

[![复制代码](https://common.cnblogs.com/images/copycode.gif)](javascript:void(0);)

改BOOTPROTO和NAME，新增IP网关DNS等配置

![img](https://img2020.cnblogs.com/blog/1208477/202010/1208477-20201025182720952-1754423781.png)

测试下OK

![img](https://images2018.cnblogs.com/blog/1208477/201804/1208477-20180419153003040-1182862366.png)

- failed to start lsb:bring up/down networking

ip addr查看mac地址（ link/ether后面的为mac地址），然后在ifcfg-eth0中配置

```
vi /etc/sysconfig/network-scripts/ifcfg-eth0  #修改配置文件

#添加如下配置，这里要写上你的MAC地址
HWADDR=00:0c:bd:05:4e:cc
```

然后关闭NetworkManager

```
systemctl stop NetworkManager
systemctl disable NetworkManager

#重启计算机（推荐）
#systemctl restart network.service
#service network restart
```

- ping通局域网但是ping不通外网

去掉配置NETWORK=yes即可，不知道为啥CentOS7.8加上去之后只能ping的通同一网段的，其他网段的和外网都ping不通。

- 下载ifconfig

ping通网络之后可以下载ifconfig命令

```
yum provides ifconfig    #查看哪个包提供了ifconfig命令,显示net-tools
yum install net-tools    #安装提供ifconfig的包
```

### 1.3: Host-Only（仅主机模式）

主机模式和NAT模式很相似，只不过不能上网，相当于VMware虚拟一个局域网，但是这个局域网没有连互联网。

![img](https://images2018.cnblogs.com/blog/1208477/201804/1208477-20180419144541754-1780033276.png)

参考[文章](https://www.linuxidc.com/Linux/2016-09/135521.htm)

虚拟机安装好后用xshell直接拖拽传递文件的话要执行以下命令

yum install lrzsz



## 二：CenterOS以centeros7为列

> iso下载：http://mirrors.163.com/  网易开源站

### 2.1 网路配置

![image-20210120103348060](https://gitee.com/snailzrg/snail_img/raw/master/picgo_snail_img/image-20210120103348060.png)

### 2.2 ：分区

![image-20210109210330759](https://gitee.com/snailzrg/snail_img/raw/master/picgo_snail_img/image-20210109210330759.png)



## 三： Ubuntu

> 以 Ubuntu18为列
>
> iso下载：http://mirrors.163.com/ubuntu-releases/16.04.7/

### 3.1：安装

> 第一次安装，先配置iso，用iso安装，一直默认～ 安装完后切换硬盘启动

![image-20210120112131645](https://gitee.com/snailzrg/snail_img/raw/master/picgo_snail_img/image-20210120112131645.png)

![image-20210120112337385](https://gitee.com/snailzrg/snail_img/raw/master/picgo_snail_img/image-20210120112337385.png)

### 3.2 ：安装Vm工具

>1、打开虚拟机，并点击要更改成全屏的那个ubuntu系统的电源，我的虚拟机名字就叫ubuntu，那么就点击【打开此虚拟机电源】
>
>2、等虚拟机打开之后，我们点击虚拟机软件上面工具栏中的【虚拟机(V)】，会展现出一个下拉菜单。
>
>3、在下拉菜单中，我们找到并使用鼠标左键单击【安装Vmware工具】，如果你这里是灰色的，那么可能是 因为你的虚拟机版本比较低！
>
>4、点击以上选项后，我们进入到系统里面，找到在桌面上出现的wmware tools的光盘！我们点击进入其中。
>
>5、在vmware tools虚拟光盘里面，我们双击【vmware.tar.gz】这个文件，注意我这里的是任意字符的意思哦，每个虚拟机的版本可能不一。
>
>6、复制这个【vmware****.tar.gz】文件，到【文件】--->【home】文件夹里面。
>
>7、然后按【Ctrl+Alt+T】调出命令界面，然后在里面输入【tar -zxvf v】后按【Tab】键，自动补全整个工具的名字。然后按enter执行。
>
>8、然后在终端里面 输入【cd V】，再按一次TAB键补全被解压后的那个工具目录名字。回车后进入到该工具解压后的目录里面！最后输入【sudo ./vmware-install.pl】执行即可安装成功，安装成功后，按【CTRL+Alt+enter】键就能给ubuntu全屏



