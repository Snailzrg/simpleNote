# 记录一次oracle问题

 报错  org.hibernate.exception.SQLGrammarException: could not execute query错误解决笔记
参考 ：https://blog.csdn.net/maskice/article/details/49227755
           https://blog.csdn.net/paullinjie/article/details/81176477
           https://q.cnblogs.com/q/97492
           https://www.cnblogs.com/jzbml/p/5991918.html

note ：一般看大小写敏感问题 ；oracle 支持“”

```
Caused by: 
	at org.springframework.orm.hibernate3.SessionFactoryUtils.convertHibernateAccessException(SessionFactoryUtils.java:630)
	at org.springframework.orm.hibernate3.HibernateAccessor.convertHibernateAccessException(HibernateAccessor.java:412)
	at org.springframework.orm.hibernate3.HibernateTemplate.doExecute(HibernateTemplate.java:424)
	at org.springframework.orm.hibernate3.HibernateTemplate.execute(HibernateTemplate.java:339)
	at com.ygsoft.ecp.service.dataaccess.impl.ECPDataaccessTemplate.findBySQL(ECPDataaccessTemplate.java:906)
	... 36 more
Caused by: org.hibernate.exception.SQLGrammarException: could not execute query
	at org.hibernate.exception.SQLStateConverter.convert(SQLStateConverter.java:67)
	at org.hibernate.exception.JDBCExceptionHelper.convert(JDBCExceptionHelper.java:43)
	at org.hibernate.loader.Loader.doList(Loader.java:2438)
	at org.hibernate.loader.Loader.listIgnoreQueryCache(Loader.java:2326)
	at org.hibernate.loader.Loader.list(Loader.java:2321)
	at org.hibernate.loader.custom.CustomLoader.list(CustomLoader.java:289)
	at org.hibernate.impl.SessionImpl.listCustomQuery(SessionImpl.java:1695)
	at org.hibernate.impl.AbstractSessionImpl.list(AbstractSessionImpl.java:142)
	at org.hibernate.impl.SQLQueryImpl.list(SQLQueryImpl.java:152)
	at com.ygsoft.ecp.service.dataaccess.impl.ECPDataaccessTemplate.transResult(ECPDataaccessTemplate.java:2023)
	at com.ygsoft.ecp.service.dataaccess.impl.ECPDataaccessTemplate.access$3(ECPDataaccessTemplate.java:2021)
	at com.ygsoft.ecp.service.dataaccess.impl.ECPDataaccessTemplate$20.doInHibernate(ECPDataaccessTemplate.java:921)
	at org.springframework.orm.hibernate3.HibernateTemplate.doExecute(HibernateTemplate.java:419)
	... 38 more
Caused by: java.sql.SQLSyntaxErrorException: ORA-00942: 表或视图不存在
```
	

测试环境上时不时报错  本地没问题  
