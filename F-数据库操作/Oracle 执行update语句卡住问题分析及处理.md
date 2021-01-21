# Oracle 执行update语句卡住问题分析及处理

笔者在开发一个管理系统时遇到一个 问题：在 debug调试的时候，执行一条update语句是卡住不动了，也没有异常抛出，其他的操作都可以。用plsql执行程序中的update语句也是卡住。

## 原因

这种只有update无法执行其他语句可以执行的其实是因为记录锁导致的，在oracle中，执行了update或者insert语句后，都会要求commit，如果不commit却强制关闭连接，oracle就会将这条提交的记录锁住。由于我的java程序中加了事务，之前debug到一半的时候我强制把工程终止了，这样就导致没有执行事务提交，所以oracle将代码中update那一条的记录锁了。

## 解决

（一）部分解锁

1、查询锁表记录

```sql
select object_name, machine, s.sid, s.serial#
  from v$locked_object l, dba_objects o, v$session s
 where l.object_id　 = 　o.object_id
   and l.session_id = s.sid
   and object_name = 'BASE_ROOM_FRAME_CELL_BOX';--BASE_ROOM_FRAME_CELL_BOX 是表名
```

object_name：表名

machine：操作者（电脑名称）

s.sid：sessionid

s.serial#：暂时不知

2、关闭连接（删除）

```sql
ALTER system KILL session 'SID,serial#'
```

（二）全部解锁

```sql
--1、查看数据库锁,诊断锁的来源及类型：
SELECT OBJECT_ID, SESSION_ID, LOCKED_MODE FROM V$LOCKED_OBJECT;

--2、找出数据库的serial#,以备杀死：
SELECT T2.USERNAME, T2.SID, T2.SERIAL#, T2.LOGON_TIME
  FROM V$LOCKED_OBJECT T1, V$SESSION T2
 WHERE T1.SESSION_ID = T2.SID
 ORDER BY T2.LOGON_TIME;

--3、杀死该session 
  alter system kill session 'sid,serial#' ps: sid ,serial# --为步骤2中查出来的值
```

如果需要关闭的较多可以用

```sql
select 'alter system kill session ''' || s.sid || ',' || s.serial# || ''';'
  from v$locked_object l, dba_objects o, v$session s
 where l.object_id　 = 　o.object_id
   and l.session_id = s.sid
   and object_name = 'BASE_ROOM_FRAME_CELL_BOX';--BASE_ROOM_FRAME_CELL_BOX 表名
```

把查询结果复制出来直接执行几好了，

## 番外

oracle层面杀会话

select object_name,machine,s.sid,s.serial# from v$locked_object l,dba_objects o,v$session s where l.object_id=o.object_id and l.session_id=s.sid;（查询被锁对象）

alter system kill session '5,55'; (其中5,55分别是上面查询出的sid,serial#）

操作系统层面杀进程（linux）

select spid, osuser, s.program from v$session s,v$process p where s.paddr=p.addr and s.sid=5; (5是上面的sid)

kill -9 55555(55555是刚查询出的spid)

操作系统层面杀进程（win）

SQL>host orakill 实例名 55555；(555是刚查询出的spid)