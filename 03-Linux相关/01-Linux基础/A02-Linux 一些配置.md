[toc]
# 一，配置 
## 1， CenterOS7配置
### 1.1， 基础配置 
netstat -anlpt | grep 22
yum instatll net-tools –y    ----安装netstat工具

所以我们需要重新安装即可
yum reinstall openssh-server

云服务器 ECS Linux CentOS 7 下重启服务通过service 操作报错：
Redirecting to /bin/systemctl restart sshd.service
查资料发现，在ESC下重启服务是通过systemctl 操作： 
例：1、启动sshd服务：
systemctl start sshd.service
2.、重启 sshd 服务：
systemctl restart sshd.service
3、 设置服务开启自启：
systemctl enable sshd.service 

首先使用ip add命令查看系统当前IP地址，可以看到当前IP地址是10.0.0.3
查看之后你就会发现ens33是没有inet属性的，然而不存在这个属性是不可以连接虚拟机的。 
  vi/etc/sysconf ig/network-scripts/ifcfg/ens33





##  163yum

1`wget -O /etc/yum.repos.d/CentOS-Base.repo.163  http://mirrors.163.com/.help/CentOS7-Base-163.repo

2`mv /etc/yum.repos.d/CentOS-Base.repo /etc/yum.repos.d/CentOS-Base.repo.backup`

3 mv /etc/yum.repos.d/CentOS-Base.repo.163  /etc/yum.repos.d/CentOS-Base.repo

4 yum clean all & yum makecache



### [修改CentOS默认yum源为国内yum镜像源](https://blog.csdn.net/xiaojin21cen/article/details/84726193?utm_medium=distribute.pc_relevant.none-task-blog-BlogCommendFromBaidu-1.nonecase&depth_1-utm_source=distribute.pc_relevant.none-task-blog-BlogCommendFromBaidu-1.nonecase)
- 拉阿里云镜像   `wget -O /etc/yum.repos.d/CentOS-Base.repo.aliyun  http://mirrors.aliyun.com/repo/Centos-7.repo`
	
- 备份原镜像  `mv /etc/yum.repos.d/CentOS-Base.repo /etc/yum.repos.d/CentOS-Base.repo.backup`

- 使用阿里云  `mv /etc/yum.repos.d/CentOS-Base.repo.aliyun  /etc/yum.repos.d/CentOS-Base.repo`

- 运行yum makecache生成缓存   `yum clean all & yum makecache`

rpm -qa | grep yum  <!-- 是否安装yum  yum repolist all -->



> 如果 Linux中提示-bash: wget: command not found的解决方法 没有安装下载器

- yum install wget -y       centeros

- apt-get install -y wget   Ubuntu/Debian



#### CenterOS7 开放端口

```
最近在docker下搭建MySQL和Redis环境，远程linux主机内部网络都走通了，但是就是外网
无法连接远程服务器的MySQL和Redis。经过一番查找和学习，终于找到了问题，不仅远程服
务器上docker要做好内部和外部端口的映射，关键还要把对外开放的端口添加到防火墙中。
123
```

内容介绍的逻辑是：本篇文章先记录Centos7下查看防火墙状态和网络状态命令；下一篇将介绍通过docker搭建MySQL和Redis环境并接通外网可以访问。

命令集合：

```
（1）查看对外开放的端口状态
查询已开放的端口 netstat -anp
查询指定端口是否已开 firewall-cmd --query-port=666/tcp
提示 yes，表示开启；no表示未开启。
1234
```

![这里写图片描述](https://img-blog.csdn.net/20180825092851369?watermark/2/text/aHR0cHM6Ly9ibG9nLmNzZG4ubmV0L3JlYWxqaA==/font/5a6L5L2T/fontsize/400/fill/I0JBQkFCMA==/dissolve/70)

```
（2）查看防火墙状态
查看防火墙状态 systemctl status firewalld
开启防火墙 systemctl start firewalld  
关闭防火墙 systemctl stop firewalld
开启防火墙 service firewalld start 
若遇到无法开启
先用：systemctl unmask firewalld.service 
然后：systemctl start firewalld.service
12345678
```

![这里写图片描述](https://img-blog.csdn.net/20180825093357657?watermark/2/text/aHR0cHM6Ly9ibG9nLmNzZG4ubmV0L3JlYWxqaA==/font/5a6L5L2T/fontsize/400/fill/I0JBQkFCMA==/dissolve/70)

```
（3）对外开发端口
查看想开的端口是否已开：
firewall-cmd --query-port=6379/tcp
123
```

![这里写图片描述](https://img-blog.csdn.net/20180825093826266?watermark/2/text/aHR0cHM6Ly9ibG9nLmNzZG4ubmV0L3JlYWxqaA==/font/5a6L5L2T/fontsize/400/fill/I0JBQkFCMA==/dissolve/70)

```
添加指定需要开放的端口：
firewall-cmd --add-port=123/tcp --permanent
重载入添加的端口：
firewall-cmd --reload
查询指定端口是否开启成功：
firewall-cmd --query-port=123/tcp
123456
```

![这里写图片描述](https://img-blog.csdn.net/20180825094232356?watermark/2/text/aHR0cHM6Ly9ibG9nLmNzZG4ubmV0L3JlYWxqaA==/font/5a6L5L2T/fontsize/400/fill/I0JBQkFCMA==/dissolve/70)

```
移除指定端口：
firewall-cmd --permanent --remove-port=123/tcp
12
```

![这里写图片描述](https://img-blog.csdn.net/20180825094634124?watermark/2/text/aHR0cHM6Ly9ibG9nLmNzZG4ubmV0L3JlYWxqaA==/font/5a6L5L2T/fontsize/400/fill/I0JBQkFCMA==/dissolve/70)

```
安装iptables-services ：
yum install iptables-services 
进入下面目录进行修改：
/etc/sysconfig/iptables
1234
```

![这里写图片描述](https://img-blog.csdn.net/20180825095256477?watermark/2/text/aHR0cHM6Ly9ibG9nLmNzZG4ubmV0L3JlYWxqaA==/font/5a6L5L2T/fontsize/400/fill/I0JBQkFCMA==/dissolve/70)
![这里写图片描述](https://img-blog.csdn.net/20180825095304371?watermark/2/text/aHR0cHM6Ly9ibG9nLmNzZG4ubmV0L3JlYWxqaA==/font/5a6L5L2T/fontsize/400/fill/I0JBQkFCMA==/dissolve/70)