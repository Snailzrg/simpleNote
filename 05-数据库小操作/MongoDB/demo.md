1：给数据库中所有数据 新增·一个字段
db.user.update({},{$set:{description:'' }},false,true)；

2：创建索引 -- Key 值为你要创建的索引字段，1 为指定按升序创建索引，如果你想按降序来创建索引指定为 -1 即可。
db.collection.createIndex(keys, options) createIndex() 方法中你也可以设置使用多个字段创建索引（关系型数据库中称作复合索引）。 db.col.createIndex({"title":1,"description":-1})

3：Mongo的模糊查询 //db.org.find({"orgName":/湖南农业大学/})===>select * from org where orgName like ‘湖南农业大学’
4：Mongo内嵌文档的属性名查找