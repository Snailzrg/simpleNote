# 手把手教你用 FastDFS 构建分布式文件管理系统

说起分布式文件管理系统，大家可能很容易想到 HDFS、GFS 等系统，前者是 Hadoop 的一部分，后者则是 Google 提供的分布式文件管理系统。除了这些之外，国内淘宝和腾讯也有自己的分布式文件管理系统，都叫 TFS（`Taobao File System` 和 `Tencent File System`）。

相对于上面提到的这些分布式文件管理系统而言，FastDFS 可能离我们 Java 工程师更近一些，因为文件上传这个功能太常见了，而想要搭建独立的分布式文件管理系统，FastDFS+Nginx 组合无疑是最佳方案。因此，松哥今天就来和大家简单聊一聊这个问题。

如果小伙伴们还不懂在传统的开发环境下如何进行文件上传，可以参考松哥之前发的文件上传教程：

- [Spring Boot + Vue，手把手教你做文件上传](https://mp.weixin.qq.com/s/OMgoUfH8lk8hDfuqWXGWTA)

## 1.什么是 FastDFS

### 1.1 FastDFS 简介

FastDFS 由淘宝的余庆大佬在 2008 年开源的一款轻量级分布式文件管理系统，FastDFS 用 C 语言实现，支持 Linux、FreeBSD、MacOS 等类 UNIX 系统。FastDFS 类似 google FS，属于应用级文件系统，不是通用的文件系统，只能通过专有 API 访问，目前提供了 C 和 Java SDK ，以及 PHP 扩展 SDK。

这款开源软件从发布至今，历经数十年，这款开源软件的生命力依然旺盛，在业界依然备受推崇，当然这也得益于作者一直在不断完善该软件。

FastDFS 专为互联网应用量身定做，解决大容量文件存储问题，追求高性能和高扩展性，它可以看做是基于文件的 key/value 存储系统，key 为文件 ID，value 为文件内容，因此称作分布式文件存储服务更为合适。

### 1.2 为什么需要 FastDFS

传统的企业级开发对于高并发要求不是很高，而且数据量可能也不大，在这样的环境下文件管理可能非常 Easy。

但是互联网应用访问量大、数据量大，在互联网应用中，我们必须考虑解决文件大容量存储和高性能访问的问题，而 FastDFS 就特别适合干这件事情，常见的图片存储、视频存储、文档存储等等我们都可以采用 FastDFS 来做。

### 1.3 FastDFS 架构

作为一款分布式文件管理系统，FastDFS 主要包括四个方面的功能：

- 文件存储
- 文件同步
- 文件上传
- 文件下载

这个方面的功能，基本上就能搞定我们常见的文件管理需求了。

下面这是一张来自 FastDFS 官网的系统架构图：



![img](https://user-gold-cdn.xitu.io/2020/3/1/170943e7c10bdabc?imageView2/0/w/1280/h/960/format/webp/ignore-error/1)



从上面这张图中我们可以看到，FastDFS 架构包括 Tracker 和 Storage 两部分，看名字大概就能知道，Tracker 用来追踪文件，相当于是文件的一个索引，而 Storage 则用来保存文件。

我们上传文件的文件最终保存在 Storage 上，文件的元数据信息保存在 Tracker 上，通过 Tracker 可以实现对 Storage 的负载均衡。

Storage 一般会搭建成集群，一个 Storage Cluster 可以由多个组构成，不同的组之间不进行通信，一个组又相当于一个小的集群，组由多个 Storage Server 组成，组内的 Storage Server 会通过连接进行文件同步来保证高可用。

## 2.FastDFS 安装

介绍完 FastDFS 之后，相信小伙伴已经摩拳擦掌跃跃欲试了，接下来我们就来看下 FastDFS 的安装。

我这里为了测试方便，就不开启多台虚拟机了，Tracker 和 Storage 我将安装在同一台服务器上。

图片上传我们一般使用 FastDFS，图片上传成功之后，接下来的图片访问我们一般采用 Nginx，所以这里的安装我将从三个方面来介绍：

- Tracker 安装
- Storage 安装
- Nginx 安装

### 2.1 Tracker 安装

安装，我们首先需要准备一个环境两个库以及一个安装包。

**1.一个环境**

先来看一个环境，由于 FastDFS 采用 C 语言开发，所以在安装之前，如果没有 gcc 环境，需要先安装，安装命令如下：

```
yum install gcc-c++

```

**2.两个库**

再来看两个库，由于 FastDFS 依赖 libevent 库，安装命令如下：

```
yum -y install libevent

```

另一个库是 libfastcommon，这是 FastDFS 官方提供的，它包含了 FastDFS 运行所需要的一些基础库。

libfastcommon 下载地址：[github.com/happyfish10…](https://github.com/happyfish100/libfastcommon/archive/V1.0.43.tar.gz)

> 考虑到 GitHub 访问较慢，松哥已经把安装文件下载好了，放在百度网盘上，小伙伴们可以在松哥公众号后台回复 fastdfs 获取下载链接。

将下载好的 libfastcommon 拷贝至 /usr/local/ 目录下，然后依次执行如下命令：

```
cd /usr/local
tar -zxvf V1.0.43.tar.gz
cd libfastcommon-1.0.43/
./make.sh
./make.sh install

```

**3.一个安装包**

接下来我们下载 Tracker，注意，由于 Tracker 和 Storage 是相同的安装包，所以下载一次即可（2.2 小节中不用再次下载）。

安装文件可以从 FastDFS 的 GitHub 仓库上下载，下载地址：[github.com/happyfish10…](https://github.com/happyfish100/fastdfs/archive/V6.06.tar.gz)

> 考虑到 GitHub 访问较慢，松哥已经把安装文件下载好了，放在百度网盘上，小伙伴们可以在松哥公众号后台回复 fastdfs 获取下载链接。

下载成功后，将下载文件拷贝到 /usr/local 目录下，然后依次执行如下命令安装：

```
cd /usr/local
tar -zxvf V6.06.tar.gz
cd fastdfs-6.06/
./make.sh
./make.sh install

```

安装成功后，执行如下命令，将安装目录内 conf 目录下的配置文件拷贝到 /etc/fdfs 目录下：

```
cd conf/
cp ./* /etc/fdfs/

```

**4.配置**

接下来进入 /etc/fdfs/ 目录下进行配置：

打开 tracker.conf 文件：

```
vi tracker.conf

```

修改如下配置：



![img](https://user-gold-cdn.xitu.io/2020/3/1/170943e7c19d8e73?imageView2/0/w/1280/h/960/format/webp/ignore-error/1)



默认端口是 22122，可以根据实际需求修改，我这里就不改了。然后下面配置一下元数据的保存目录（注意目录要存在）。

**5.启动**

接下来执行如下命令启动 Tracker：

```
/usr/bin/fdfs_trackerd /etc/fdfs/tracker.conf start

```

如此之后，我们的 Tracker 就算安装成功了。

### 2.2 Storage 安装

简单起见，这里我们搭建一个 Storage 实例即可。Storage 安装也需要 libevent 和 libfastcommon，这两个库的安装参考上文，这里我不在细说。

Storage 本身的安装，也和 Tracker 一致，执行命令也都一样，因为我这里将 Tracker 和 Storage 安装在同一台服务器上，所以不用再执行安装命令了（相当于安装 Tracker 时已经安装了 Storage 了）。

唯一要做的，就是进入到 /etc/fdfs 目录下，配置 Storage：

```
vi storage.conf

```



![img](https://user-gold-cdn.xitu.io/2020/3/1/170943e7c3a22159?imageView2/0/w/1280/h/960/format/webp/ignore-error/1)



这里一共配置三个地方，分别是 base_path、store_path0 以及 tracker_server ，tracker_server 模板有两个地址，我们这里只有一个，配置完成后，记得注释掉另外一个不用的。

配置完成后，执行如下命令启动 Storage：

```
/usr/bin/fdfs_storaged /etc/fdfs/storage.conf start

```

这两个启动完成后，现在就可以做文件的上传了，但是一般如果是图片文件，我们还需要提供一个图片的访问功能，目前来说最佳方案当然是 Nginx 了，所以我们这里连同 Nginx 一起配置好，再来做测试。

### 2.3 Nginx 安装

Nginx 可以算是 FastDFS 的重要搭档。

Nginx 的安装分为两个步骤：

- 安装 Nginx
- 首先在 Storage 下安装 fastdfs-nginx-module

第一步简单，松哥之前专门写过一篇文章扫盲 Nginx，所以 Nginx 安装大家直接参考这里：[Nginx 极简入门教程！](https://mp.weixin.qq.com/s/ZN07_3ImmyRU0NQaqzcazQ)

接下来看第二步。

首先下载 fastdfs-nginx-module，下载地址：[github.com/happyfish10…](https://github.com/happyfish100/fastdfs-nginx-module/archive/V1.22.tar.gz)

> 考虑到 GitHub 访问较慢，松哥已经把安装文件下载好了，放在百度网盘上，小伙伴们可以在松哥公众号后台回复 fastdfs 获取下载链接。

下载完成后，将下载的文件拷贝到 /usr/local 目录下。然后进入 /usr/local 目录，分别执行如下命令：

```
cd /usr/local
tar -zxvf V1.22.tar.gz

```

然后将 `/usr/local/fastdfs-nginx-module-1.22/src/mod_fastdfs.conf` 文件拷贝到 `/etc/fdfs/` 目录下，并修改该文件的内容：

```
vi /etc/fdfs/mod_fastdfs.conf

```



![img](https://user-gold-cdn.xitu.io/2020/3/1/170943e7c1cc17f1?imageView2/0/w/1280/h/960/format/webp/ignore-error/1)



接下来，回到第一步下载的 nginx 安装文件的解压目录中，执行如下命令，重新配置编译安装：

```
./configure --add-module=/usr/local/fastdfs-nginx-module-1.22/src
make
make install

```

安装完成后，修改 nginx 的配置文件，如下：

```
vi /usr/local/nginx/conf/nginx.conf

```



![img](https://user-gold-cdn.xitu.io/2020/3/1/170943e7c3d52ed0?imageView2/0/w/1280/h/960/format/webp/ignore-error/1)



在这里配置 nginx 请求转发。

配置完成后，启动 nginx，看到如下日志，表示 nginx 启动成功：

```
ngx_http_fastdfs_set pid=9908

```

**疑问：fastdfs-nginx-module 有啥用**

看了整个安装过程之后，很多小伙伴有疑问，到头来还是 nginx 本身直接找到了图片文件目录，fastdfs-nginx-module 到底有啥用？

前面我们说过，Storage 由很多组构成，每个组又是一个小的集群，在每一个组里边，数据会进行同步，但是如果数据还没同步，这个时候就有请求发来了，该怎么办？此时fastdfs-nginx-module 会帮助我们直接从源 Storage 上获取文件。

安装成功了。

## 3.Java 客户端调用

安装成功后，接下来我们就用 Java 客户端来测试一下文件上传下载。

首先我们来创建一个普通的 Maven 工程，添加如下依赖：

```
<dependency>
    <groupId>net.oschina.zcx7878</groupId>
    <artifactId>fastdfs-client-java</artifactId>
    <version>1.27.0.0</version>
</dependency>

```

然后，在项目的 resources 目录下添加 FastDFS 的配置文件 fastdfs-client.properties，内容如下：

```
fastdfs.connect_timeout_in_seconds = 5
fastdfs.network_timeout_in_seconds = 30
fastdfs.charset = UTF-8
fastdfs.http_anti_steal_token = false
fastdfs.http_secret_key = FastDFS1234567890
fastdfs.http_tracker_http_port = 80
fastdfs.tracker_servers = 192.168.91.128:22122
fastdfs.connection_pool.enabled = true
fastdfs.connection_pool.max_count_per_entry = 500
fastdfs.connection_pool.max_idle_time = 3600
fastdfs.connection_pool.max_wait_time_in_ms = 1000

```

这里的配置基本上都能见名知义，我就不挨个解释了。这里先配置下 fastdfs.tracker_servers，这是 Tracker 的地址，根据实际情况配置即可。

fastdfs.http_secret_key 配置这里先不用管它，后面我会跟大家解释。

### 3.1 文件上传

配置完成后，先来看文件上传，代码如下：

```
@Test
void testUpload() {
    try {
        ClientGlobal.initByProperties("fastdfs-client.properties");
        TrackerClient tracker = new TrackerClient();
        TrackerServer trackerServer = tracker.getConnection();
        StorageServer storageServer = null;
        StorageClient1 client = new StorageClient1(trackerServer, storageServer);
        NameValuePair nvp[] = null;
        //上传到文件系统
        String fileId = client.upload_file1("C:\\Users\\javaboy\\Pictures\\picpick\\1.png", "png",
                nvp);
        logger.info(fileId);
    } catch (Exception e) {
        e.printStackTrace();
    }
}

```

这里，首先加载配置文件，然后构造一个 TrackerClient 对象，接着再根据这个对象获取到一个 TrackerServer，然后创建一个 StorageClient1 实例。NameValuePair 中保存的是文件的元数据信息，如果有的话，就以 key/value 的方式来设置，如果没有的话，直接给一个 null 即可。

最后，调用 client 的 upload_file1 方法上传文件，第一个参数是文件路径，第二个参数是文件的扩展名，第三个参数就是文件的元数据信息，这个方法的返回值，就是上传文件的访问路径。执行该方法，打印日志如下：

```
2020-02-29 17:46:03.017  INFO 6184 --- [           main] o.j.fastdfs.FastdfsApplicationTests      : group1/M00/00/00/wKhbgF5aMteAWy0gAAJkI7-2yGk361.png

```

group1/M00/00/00/wKhbgF5aMteAWy0gAAJkI7-2yGk361.png 就是文件的路径，此时，在浏览器中输入 http://192.168.91.128/group1/M00/00/00/wKhbgF5aMteAWy0gAAJkI7-2yGk361.png 就可以看到上传的图片了。

### 3.2 文件下载

```
@Test
void testDownload() {
    try {
        ClientGlobal.initByProperties("fastdfs-client.properties");
        TrackerClient tracker = new TrackerClient();
        TrackerServer trackerServer = tracker.getConnection();
        StorageServer storageServer = null;
        StorageClient1 client = new StorageClient1(trackerServer, storageServer);
        byte[] bytes = client.download_file1("group1/M00/00/00/wKhbgF5aMteAWy0gAAJkI7-2yGk361.png");
        FileOutputStream fos = new FileOutputStream(new File("C:\\Users\\javaboy\\Pictures\\picpick\\666.png"));
        fos.write(bytes);
        fos.close();
    } catch (Exception e) {
        e.printStackTrace();
    }
}

```

这段代码就很好理解了，直接调用 download_file1 方法获取到一个 byte 数组，然后通过 IO 流写出到本地文件即可。

## 4.安全问题

现在，任何人都可以访问我们服务器上传文件，这肯定是不行的，这个问题好解决，加一个上传时候的令牌即可。

首先我们在服务端开启令牌校验：

```
vi /etc/fdfs/http.conf

```



![img](https://user-gold-cdn.xitu.io/2020/3/1/170943e7c49d5579?imageView2/0/w/1280/h/960/format/webp/ignore-error/1)



配置完成后，记得重启服务端：

```
./nginx -s stop
./nginx

```

接下来，在前端准备一个获取令牌的方法，如下：

```
@Test
public void getToken() throws Exception {
    int ts = (int) Instant.now().getEpochSecond();
    String token = ProtoCommon.getToken("M00/00/00/wKhbgF5aMteAWy0gAAJkI7-2yGk361.png", ts, "FastDFS1234567890");
    StringBuilder sb = new StringBuilder();
    sb.append("?token=").append(token);
    sb.append("&ts=").append(ts);
    System.out.println(sb.toString());
}

```

这里，我们主要是根据 ProtoCommon.getToken 方法来获取令牌，注意这个方法的第一个参数是你要访问的文件 id，**注意，这个地址里边不包含 group，千万别搞错了；**第二个参数是时间戳，第三个参数是密钥，密钥要和服务端的配置一致。

将生成的字符串拼接，追加到访问路径后面，如：`http://192.168.91.128/group1/M00/00/00/wKhbgF5aMteAWy0gAAJkI7-2yGk361.png?token=7e329cc50307000283a3ad3592bb6d32&ts=1582975854`。**此时访问路径里边如果没有令牌，会访问失败。**

好了，大功告成！下次和大家讲我如何在 Spring Boot 中玩这个