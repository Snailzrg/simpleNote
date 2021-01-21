## 【110期】面试官：Redis分布式锁如何解决锁超时问题？

wangzaiplus [Java面试题精选](javascript:void(0);) *6月15日*

**点击上方“Java面试题精选”，关注公众号**

**面试刷图，查缺补漏**

**>>号外：****往期面试题，10篇为一个单位归置到本公众号菜单栏->面试题，有需要的欢迎翻阅**

***\*阶段汇总集合：\*******\*[++小Flag实现，一百期面试题汇总++](http://mp.weixin.qq.com/s?__biz=MzIyNDU2ODA4OQ==&mid=2247484532&idx=1&sn=1c243934507d79db4f76de8ed0e5727f&chksm=e80db202df7a3b14fe7077b0fe5ec4de4088ce96a2cde16cbac21214956bd6f2e8f51193ee2b&scene=21#wechat_redirect)\****

## 一、前言

关于redis分布式锁, 查了很多资料, 发现很多只是实现了最基础的功能, 但是, 并没有解决当锁已超时而业务逻辑还未执行完的问题, 这样会导致: A线程超时时间设为10s(为了解决死锁问题), 但代码执行时间可能需要30s, 然后redis服务端10s后将锁删除, 此时, B线程恰好申请锁, redis服务端不存在该锁, 可以申请, 也执行了代码, 那么问题来了, A、B线程都同时获取到锁并执行业务逻辑, 这与分布式锁最基本的性质相违背: 在任意一个时刻, 只有一个客户端持有锁, 即独享

为了解决这个问题, 本文将用完整的代码和测试用例进行验证, 希望能给小伙伴带来一点帮助

## 二、准备工作

压测工具jmeter

> https://pan.baidu.com/share/init?surl=NN0c0tDYQjBTTPA-WTT3yg
> 提取码: 8f2a

redis-desktop-manager客户端

> https://pan.baidu.com/share/init?surl=NoJtZZZOXsk45aQYtveWbQ
> 提取码: 9bhf

postman

> https://pan.baidu.com/share/init?surl=28sGJk4zxoOknAd-47hE7w
> 提取码: vfu7

也可以直接官网下载, 我这边都整理到网盘了

需要postman是因为我还没找到jmeter多开窗口的办法, 哈哈

## 三、说明

1、springmvc项目

2、maven依赖

```
        <!--redis-->
        <dependency>
            <groupId>org.springframework.data</groupId>
            <artifactId>spring-data-redis</artifactId>
            <version>1.6.5.RELEASE</version>
        </dependency>
        <dependency>
            <groupId>redis.clients</groupId>
            <artifactId>jedis</artifactId>
            <version>2.7.3</version>
        </dependency>
```

3、核心类

- 分布式锁工具类: DistributedLock
- 测试接口类: PcInformationServiceImpl
- 锁延时守护线程类: PostponeTask

## 四、实现思路

先测试在不开启锁延时线程的情况下, A线程超时时间设为10s, 执行业务逻辑时间设为30s, 10s后, 调用接口, 查看是否能够获取到锁, 如果获取到, 说明存在线程安全性问题

同上, 在加锁的同时, 开启锁延时线程, 调用接口, 查看是否能够获取到锁, 如果获取不到, 说明延时成功, 安全性问题解决

## 五、实现

### 1、版本01代码

#### 1)、DistributedLock

```
package com.cn.pinliang.common.util;

import com.cn.pinliang.common.thread.PostponeTask;
import com.google.common.collect.Lists;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.data.redis.core.RedisCallback;
import org.springframework.data.redis.core.RedisTemplate;
import org.springframework.stereotype.Component;
import redis.clients.jedis.Jedis;

import java.io.Serializable;
import java.util.Collections;

@Component
public class DistributedLock {

    @Autowired
    private RedisTemplate<Serializable, Object> redisTemplate;

    private static final Long RELEASE_SUCCESS = 1L;

    private static final String LOCK_SUCCESS = "OK";
    private static final String SET_IF_NOT_EXIST = "NX";
    private static final String SET_WITH_EXPIRE_TIME = "EX";
    // 解锁脚本(lua)
    private static final String RELEASE_LOCK_SCRIPT = "if redis.call('get', KEYS[1]) == ARGV[1] then return redis.call('del', KEYS[1]) else return 0 end";

    /**
     * 分布式锁
     * @param key
     * @param value
     * @param expireTime 单位: 秒
     * @return
     */
    public boolean lock(String key, String value, long expireTime) {
        return redisTemplate.execute((RedisCallback<Boolean>) redisConnection -> {
            Jedis jedis = (Jedis) redisConnection.getNativeConnection();
            String result = jedis.set(key, value, SET_IF_NOT_EXIST, SET_WITH_EXPIRE_TIME, expireTime);
            if (LOCK_SUCCESS.equals(result)) {
                return Boolean.TRUE;
            }
            return Boolean.FALSE;
        });
    }

    /**
     * 解锁
     * @param key
     * @param value
     * @return
     */
    public Boolean unLock(String key, String value) {
        return redisTemplate.execute((RedisCallback<Boolean>) redisConnection -> {
            Jedis jedis = (Jedis) redisConnection.getNativeConnection();
            Object result = jedis.eval(RELEASE_LOCK_SCRIPT, Collections.singletonList(key), Collections.singletonList(value));
            if (RELEASE_SUCCESS.equals(result)) {
                return Boolean.TRUE;
            }
            return Boolean.FALSE;
        });
    }

}
```

说明: 就2个方法, 加锁解锁, 加锁使用jedis setnx方法, 解锁执行lua脚本, 都是原子性操作

#### 2)、PcInformationServiceImpl

```
    public JsonResult add() throws Exception {
        String key = "add_information_lock";
        String value = RandomUtil.produceStringAndNumber(10);
        long expireTime = 10L;

        boolean lock = distributedLock.lock(key, value, expireTime);
        String threadName = Thread.currentThread().getName();
        if (lock) {
            System.out.println(threadName + " 获得锁...............................");
            Thread.sleep(30000);
            distributedLock.unLock(key, value);
            System.out.println(threadName + " 解锁了...............................");
        } else {
            System.out.println(threadName + " 未获取到锁...............................");
            return JsonResult.fail("未获取到锁");
        }

        return JsonResult.succeed();
    }
```

说明: 测试类很简单, value随机生成, 保证唯一, 不会在超时情况下解锁其他客户端持有的锁

#### 3)、打开redis-desktop-manager客户端, 刷新缓存, 可以看到, 此时是没有add_information_lock的key的

![img](https://mmbiz.qpic.cn/mmbiz/8KKrHK5ic6XDYtFdFOKmywXEZibICmNEkZvCiaCPPeiaKAlKbUialjsMrVDv8dgxlLKFIG9ASUicNsepApOBQa7RCN0w/640?wx_fmt=other&tp=webp&wxfrom=5&wx_lazy=1&wx_co=1)

#### 4)、启动jmeter, 调用接口测试

设置5个线程同时访问, 在10s的超时时间内查看redis, add_information_lock存在, 多次调接口, 只有一个线程能够获取到锁

往期100篇回顾：[一百期面试题汇总](http://mp.weixin.qq.com/s?__biz=MzIyNDU2ODA4OQ==&mid=2247484532&idx=1&sn=1c243934507d79db4f76de8ed0e5727f&chksm=e80db202df7a3b14fe7077b0fe5ec4de4088ce96a2cde16cbac21214956bd6f2e8f51193ee2b&scene=21#wechat_redirect)

redis

![img](https://mmbiz.qpic.cn/mmbiz/8KKrHK5ic6XDYtFdFOKmywXEZibICmNEkZibszSrIQUa2T9LuxUv4rRBfuyTbR9s8MBefN3LtnoZX47OSayys7yGA/640?wx_fmt=other&tp=webp&wxfrom=5&wx_lazy=1&wx_co=1)

1-4个请求, 都未获取到锁

![img](https://mmbiz.qpic.cn/mmbiz/8KKrHK5ic6XDYtFdFOKmywXEZibICmNEkZITHAZaGtDeI66WqcZgcTiboSRfkTXYyYr8xqWDiagwSeD1k66HSWAkvg/640?wx_fmt=other&tp=webp&wxfrom=5&wx_lazy=1&wx_co=1)

第5个请求, 获取到锁

![img](https://mmbiz.qpic.cn/mmbiz/8KKrHK5ic6XDYtFdFOKmywXEZibICmNEkZx7mM6fkdk3qN4EOUq4akjRJHLo2w6G2UgAFuJ9pEdcUqw9SEz6aFfw/640?wx_fmt=other&tp=webp&wxfrom=5&wx_lazy=1&wx_co=1)

OK, 目前为止, 一切正常, 接下来测试10s之后, A仍在执行业务逻辑, 看别的线程是否能获取到锁

![img](https://mmbiz.qpic.cn/mmbiz/8KKrHK5ic6XDYtFdFOKmywXEZibICmNEkZ6Xjo9OYll3PGyQyr4jwtO4ynHb2U0ZVY4lQyibMJnpbiaMBkt4rEVW6Q/640?wx_fmt=other&tp=webp&wxfrom=5&wx_lazy=1&wx_co=1)可以看到, 操作成功, 说明A和B同时执行了这段本应该独享的代码, 需要优化。

往期100篇回顾：[一百期面试题汇总](http://mp.weixin.qq.com/s?__biz=MzIyNDU2ODA4OQ==&mid=2247484532&idx=1&sn=1c243934507d79db4f76de8ed0e5727f&chksm=e80db202df7a3b14fe7077b0fe5ec4de4088ce96a2cde16cbac21214956bd6f2e8f51193ee2b&scene=21#wechat_redirect)

### 2、版本02代码

#### 1)、DistributedLock

```
package com.cn.pinliang.common.util;

import com.cn.pinliang.common.thread.PostponeTask;
import com.google.common.collect.Lists;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.data.redis.core.RedisCallback;
import org.springframework.data.redis.core.RedisTemplate;
import org.springframework.stereotype.Component;
import redis.clients.jedis.Jedis;

import java.io.Serializable;
import java.util.Collections;

@Component
public class DistributedLock {

    @Autowired
    private RedisTemplate<Serializable, Object> redisTemplate;

    private static final Long RELEASE_SUCCESS = 1L;
    private static final Long POSTPONE_SUCCESS = 1L;

    private static final String LOCK_SUCCESS = "OK";
    private static final String SET_IF_NOT_EXIST = "NX";
    private static final String SET_WITH_EXPIRE_TIME = "EX";
    // 解锁脚本(lua)
    private static final String RELEASE_LOCK_SCRIPT = "if redis.call('get', KEYS[1]) == ARGV[1] then return redis.call('del', KEYS[1]) else return 0 end";
    // 延时脚本
    private static final String POSTPONE_LOCK_SCRIPT = "if redis.call('get', KEYS[1]) == ARGV[1] then return redis.call('expire', KEYS[1], ARGV[2]) else return '0' end";

    /**
     * 分布式锁
     * @param key
     * @param value
     * @param expireTime 单位: 秒
     * @return
     */
    public boolean lock(String key, String value, long expireTime) {
        // 加锁
        Boolean locked = redisTemplate.execute((RedisCallback<Boolean>) redisConnection -> {
            Jedis jedis = (Jedis) redisConnection.getNativeConnection();
            String result = jedis.set(key, value, SET_IF_NOT_EXIST, SET_WITH_EXPIRE_TIME, expireTime);
            if (LOCK_SUCCESS.equals(result)) {
                return Boolean.TRUE;
            }
            return Boolean.FALSE;
        });

        if (locked) {
            // 加锁成功, 启动一个延时线程, 防止业务逻辑未执行完毕就因锁超时而使锁释放
            PostponeTask postponeTask = new PostponeTask(key, value, expireTime, this);
            Thread thread = new Thread(postponeTask);
            thread.setDaemon(Boolean.TRUE);
            thread.start();
        }

        return locked;
    }

    /**
     * 解锁
     * @param key
     * @param value
     * @return
     */
    public Boolean unLock(String key, String value) {
        return redisTemplate.execute((RedisCallback<Boolean>) redisConnection -> {
            Jedis jedis = (Jedis) redisConnection.getNativeConnection();
            Object result = jedis.eval(RELEASE_LOCK_SCRIPT, Collections.singletonList(key), Collections.singletonList(value));
            if (RELEASE_SUCCESS.equals(result)) {
                return Boolean.TRUE;
            }
            return Boolean.FALSE;
        });
    }

    /**
     * 锁延时
     * @param key
     * @param value
     * @param expireTime
     * @return
     */
    public Boolean postpone(String key, String value, long expireTime) {
        return redisTemplate.execute((RedisCallback<Boolean>) redisConnection -> {
            Jedis jedis = (Jedis) redisConnection.getNativeConnection();
            Object result = jedis.eval(POSTPONE_LOCK_SCRIPT, Lists.newArrayList(key), Lists.newArrayList(value, String.valueOf(expireTime)));
            if (POSTPONE_SUCCESS.equals(result)) {
                return Boolean.TRUE;
            }
            return Boolean.FALSE;
        });
    }

}
```

说明: 新增了锁延时方法, lua脚本, 自行脑补相关语法

#### 2)、PcInformationServiceImpl不需要改动

#### 3)、PostponeTask

```
package com.cn.pinliang.common.thread;

import com.cn.pinliang.common.util.DistributedLock;

public class PostponeTask implements Runnable {

    private String key;
    private String value;
    private long expireTime;
    private boolean isRunning;
    private DistributedLock distributedLock;

    public PostponeTask() {
    }

    public PostponeTask(String key, String value, long expireTime, DistributedLock distributedLock) {
        this.key = key;
        this.value = value;
        this.expireTime = expireTime;
        this.isRunning = Boolean.TRUE;
        this.distributedLock = distributedLock;
    }

    @Override
    public void run() {
        long waitTime = expireTime * 1000 * 2 / 3;// 线程等待多长时间后执行
        while (isRunning) {
            try {
                Thread.sleep(waitTime);
                if (distributedLock.postpone(key, value, expireTime)) {
                    System.out.println("延时成功...........................................................");
                } else {
                    this.stop();
                }
            } catch (Exception e) {
                e.printStackTrace();
            }
        }
    }

    private void stop() {
        this.isRunning = Boolean.FALSE;
    }

}
```

说明: 调用lock同时, 立即开启PostponeTask线程, 线程等待超时时间的2/3时间后, 开始执行锁延时代码, 如果延时成功, add_information_lock这个key会一直存在于redis服务端, 直到业务逻辑执行完毕, 因此在此过程中, 其他线程无法获取到锁, 也即保证了线程安全性

下面是测试结果

10s后, 查看redis服务端, add_information_lock仍存在, 说明延时成功

![img](https://mmbiz.qpic.cn/mmbiz/8KKrHK5ic6XDYtFdFOKmywXEZibICmNEkZzuWbMsicxoqn8gVSG2qicWuRn8avQPNhEuYz2djv9t5Qn1k28yL1HSEQ/640?wx_fmt=other&tp=webp&wxfrom=5&wx_lazy=1&wx_co=1)

此时用postman再次请求, 发现获取不到锁

![img](https://mmbiz.qpic.cn/mmbiz/8KKrHK5ic6XDYtFdFOKmywXEZibICmNEkZkFMc9UibkIXXKAW9k713Z8YiafGVngXQS8iclHbueic3mmRxWzNaU7ahyg/640?wx_fmt=other&tp=webp&wxfrom=5&wx_lazy=1&wx_co=1)

看一下控制台打印

![img](https://mmbiz.qpic.cn/mmbiz/8KKrHK5ic6XDYtFdFOKmywXEZibICmNEkZBYmXAtSXoruWYstS9AKhZXSu66lUn26EecGDu22dCq6cuxqJcibvbxQ/640?wx_fmt=other&tp=webp&wxfrom=5&wx_lazy=1&wx_co=1)

![img](https://mmbiz.qpic.cn/mmbiz/8KKrHK5ic6XDYtFdFOKmywXEZibICmNEkZcde96BY88Yf85HsZY3CNz3HkKcsV88okDGiaSFEczKSvErNrQGgegNQ/640?wx_fmt=other&tp=webp&wxfrom=5&wx_lazy=1&wx_co=1)

A线程在19:09:11获取到锁, 在10 * 2 / 3 = 6s后进行延时, 成功, 保证了业务逻辑未执行完毕的情况下不会释放锁

A线程执行完毕, 锁释放, 其他线程又可以竞争锁

OK, 目前为止, 解决了锁超时而业务逻辑仍在执行的锁冲突问题, 还很简陋, 而最严谨的方式还是使用官方的 Redlock 算法实现, 其中 Java 包推荐使用 redisson, 思路差不多其实, 都是在快要超时时续期, 以保证业务逻辑未执行完毕不会有其他客户端持有锁

也可以看看redisson相关内容：[Redisson是如何实现分布式锁的？](http://mp.weixin.qq.com/s?__biz=MzI4Njc5NjM1NQ==&mid=2247493252&idx=2&sn=5530b330af0e0bcb56f9cc8bd7d0a25d&chksm=ebd5d9a8dca250be07d54c37110fcc2549cb31968557910a77485747d9cb9ee842a2f05c25dc&scene=21#wechat_redirect)

*来源：www.jianshu.com/p/39b3570d3b56*