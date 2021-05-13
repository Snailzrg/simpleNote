```
yum install -y pcre pcre-devel
```

## 2 安装要求的环境

下面的环境需要视自己的系统情况而定，没有的环境安装以下就好。

**1.需要安装gcc环境**

```
# yum install gcc-c++
```

**2.第三方的开发包**

**1 PERE**

PCRE(Perl Compatible Regular Expressions)是一个Perl库，包括 perl 兼容的正则表达式库。

nginx的http模块使用pcre来解析正则表达式，所以需要在linux上安装pcre库。

**注：pcre-devel是使用pcre开发的一个二次开发库。nginx****也需要此库**。

```
# yum install -y pcre pcre-devel
```

**2 zlib**

zlib库提供了很多种压缩和解压缩的方式，nginx使用zlib对http包的内容进行gzip，所以需要在linux上安装zlib库。

```
# yum install -y zlib zlib-devel
```

**3 openssl**

OpenSSL 是一个强大的安全套接字层密码库，囊括主要的密码算法、常用的密钥和证书封装管理功能及SSL协议，

并提供丰富的应用程序供测试或其它目的使用。

nginx不仅支持http协议，还支持https（即在ssl协议上传输http），所以需要在linux安装openssl库。

```
# yum -y install pcre  pcre-devel zlib  zlib-devel openssl openssl-devel
```

## 3 nginx安装过程

**1 把nginx源码包上传到linux系统上**

![img](https://gitee.com/snailzrg/snail_img/raw/master/picgo_snail_img/1320077-20180528213653887-1061022351.png)

**2 解压到/usr/local下面**

```
# tar -xvf nginx-1.14.0.tar.gz -C /usr/local
```

**3 使用cofigure命令创建一个makeFile文件**

**执行下面的命令的时候，一定要进入到nginx-1.14.0目录里面去。**

