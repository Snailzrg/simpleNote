# Linux基础命令
- [Linux命令大全](https://man.linuxde.net/)


## 常用



## 文件相关
+ cd
```
路径操作指令
. ：表示当前目录
.. ：表示上一级目录
```
+ pwd
```
显示当前目录路径
```
+ ls
 ```
显示当前文件夹(路径)中的文件
ll ： ls -l 的别名，有些 linux 中没有这个命令
```
+ mkdir
```
创建目录
mkdir -p 目录 ：父级目录不存在时创建父级目录
```
+ tail
```
显示文件最后的内容
tail -n 10 log ：显示log文件最后10行内容
tail -f log ：追踪log文件内容，默认会显示最后10行
tail -f -n 100 log ：追踪log文件内容，并显示最后100行内容
```
+ less
 ```
按照命令窗口大小友好显示文件内容
q ：退出 less 命令显示内容
```
+ rm (慎用)
```
删除命令
rm -f ./log ： 删除当前目录中log文件
rm -rf ./dir ： 递归删除当前目录中的dir文件夹
```
+ mv
```
移动文件/重命名
mv ./log ../ ： 将当前log文件移动上一级文件夹中去
mv log logRename ：将当前log文件重命名为logRename
```
+ cp
```
复制命令
cp -r hello ../ ： 将hello文件夹复制到上一级目录
```

## 权限 chmod
- 赋权
```
1 ： r ，读权限
2 ： w ，写权限
4 ： x ，可执行权限
```
- linux 权限
```
| 文件 | 属主 | 属组 | 其他用户 |
| 类型 | 权限 | 权限 | 权限 |
|  d  | rwx  | rwx  | rwx |  d：表示文件夹
```

- eg：
```
chomd +x eg.sh ：赋予 eg.sh 文件所有用户可执行权限
chmod 777 eg.sh ：赋予 eg.sh 文件所有用户所用权限
chown ---> 修改文件/文件夹属组和属主
chown -R mysql:mysql database
```

## 网络相关
- ps
 ```
 非常强大的命令
```

## 防火墙相关
###  centos6
+ 检查防火墙状态
```
service iptables status 
#iptables: Firewall is not running. 防火墙未启用
 ```
+ 防火墙启停
```
service iptables stop
service iptables start
service iptables restart
```
+ 添加防火墙规则（这里只介绍修改文件的方式添加规则）

```
#修改/etc/sysconfig/iptables文件
# 文件内容开始-> 
# Firewall configuration written by system-config-firewall
# Manual customization of this file is not recommended. 
*filter 
:INPUT ACCEPT [0:0] 
:FORWARD ACCEPT [0:0] 
:OUTPUT ACCEPT [0:0] 
-A INPUT -m state --state ESTABLISHED,RELATED -j ACCEPT 
-A INPUT -p icmp -j ACCEPT 
-A INPUT -i lo -j ACCEPT 
-A INPUT -m state --state NEW -m tcp -p tcp --dport 22 -j ACCEPT 
# 添加的规则 8080 代表服务运行的端口，27027是数据库运行端口，需要根据具体配置进行修改/添加 
-A INPUT -m state --state NEW -m tcp -p tcp --dport 8080 -j ACCEPT 
-A INPUT -m state --state NEW -m tcp -p tcp --dport 27027 -j ACCEPT 
-A INPUT -j REJECT --reject-with icmp-host-prohibited -A FORWARD 
-j REJECT --reject-with icmp-host-prohibited COMMIT # 
<-文件内容结束 #修改文件后需要重启防火墙 service iptables restart

```
###  centos7
+ 防火墙操作
 ```
systemctl stop firewalld.service #停止 
systemctl disable firewalld.service #禁止开机启动 
systemctl restart iptables.service #开启 
systemctl enable iptables.service #开机启动
```
+ 使用 firewall-cmd 添加规则
 ```
#其中9200代表添加的端口，tcp代表协议，本项目配置tcp协议即可
 firewall-cmd --zone=public --add-port=9200/tcp --permanent 
 systemctl restart iptables.service
 ```
+ 修改配置文件形式添加规则， /etc/firewalld/zones/public.xml
 ``` 
<?xml version="1.0" encoding="utf-8"?> 
<zone>
 <short>Public</short>
  <description>For use in public areas. You do not trust the other computers on networks to not harm your computer. Only selected incoming connections are accepted. </description> 
  <!--service节点：配置服务名称-->
   <service name="ssh"/>
   <service name="dhcpv6-client"/> 
	<!--port节点：配置端口/协议--> 
	<port protocol="tcp" port="9200"/>
	 <!--rule节点：强大的规则配置文件, 这个不赘述，自行了解，一般用不到，除非要限制某些ip地址-->
	   <rule family="ipv4">
			<source address="192.168.1.10"/> 
			<port protocol="tcp" port="3306"/>
			<accept/> 
	   </rule> 
</zone> 
```

## SSH





## 定时任务