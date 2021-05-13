[toc]

# Redis

### Redis 本地工具连接

https://blog.csdn.net/yanwanwan/article/details/102540834

## 一:  安装 (非docker方式)

###  1.1 安装及单机配置

- 1 安装

```
wget http://download.redis.io/releases/redis-4.0.1.tar.gz
tar -zxvf redis-4.0.0.tar.gz
cd /data/redis/redis-4.0.1
编译 make [编译需要c环境 yum install gcc-c++]
安装 make install PREFIX=/usr/local/redis [安装的目录]

```

- 2 安装完成后会发现 /usr/local/redis/bin 下面会多了几个可执行文件
  - redis-server   redis 服务端
  - redis-cli　　　　redis 命令行客户端
  - redis-benchmark  redis 性能测试工具
  - redis-check-aof 　AOF文件修复工具
  - redis-check-dump  RDB文件修复工具
  - redis-sentinel 　  Sentinel 服务端

- 3 运行

  -  /usr/local/redis/bin/redis-cli shutdown   或者   kill -9   (关闭)
  - ./redis-server.  /root/data/redis/config/redis-conf   (启动服务)
  - /usr/local/redis/bin/redis-cli -h   127.0.0.1  -p 6379 （启动客户端连接）

  

- 简单修改 redis.conf

  >把protected-mode yes改为protected-mode no（在没有密码的情况下，关闭保护模式）
  >
  >注释掉bind 127.0.0.1   （取消绑定本地地址）
  >
  >把daemonize no改为daemonize yes  （是否为进程守护，关闭ssh窗口后即是否在后台继续运行

#### 1.1.1 设置密码

- 通过命令
  - config set requirepass 123456
- 修改配置文件
  - requirepass snail6380

#### 1.1.2 设置日志

- 修改配置文件
  - ->logfile ""   => logfile "/root/data/redis/log/redis-6380.log"

###  1.2 主从模式

#### 1.2.1 开启方式

（1）配置文件

在从服务器的配置文件中加入：slaveof <masterip> <masterport>

（2）启动命令

redis-server启动命令后加入 --slaveof <masterip> <masterport>

（3）客户端命令

Redis服务器启动后，直接通过客户端执行命令：slaveof <masterip> <masterport>，则该Redis实例成为从节点。



### 1.3  哨兵模式





## 二: docker安装

> docker目录中



## 三: 持久化

















