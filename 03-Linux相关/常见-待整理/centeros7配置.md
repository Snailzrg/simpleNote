# centeros7配置

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
查看之后你就会发现ens33是没有inet属性的，然而不存在这个属性是不可以连接虚拟机的。 vi/etc/sysconf ig/network-scripts/ifcfg/ens33


