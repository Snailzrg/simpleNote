# 关于java中Pattern和Matcher区别于联系
本文章转自: http://blog.csdn.net/cclovett/article/details/12448843
结论：Pattern与Matcher一起合作.Matcher类提供了对正则表达式的分组支持,以及对正则表达式的多次匹配支持. 单独用Pattern只能使用Pattern.matcher(String regex,CharSequence input)一种最基础最简单的匹配。
Java正则表达式通过java.util.regex包下的Pattern类与Matcher类实现(建议在阅读本文时,打开Java API文档,当介绍到哪个方法时,查看java API中的方法说明,效果会更佳).
Pattern类用于创建一个正则表达式,也可以说创建一个匹配模式,它的构造方法是私有的,不可以直接创建,但可以通过 Pattern.complie(String regex) 简单工厂方法创建一个正则表达式, 
Java代码示例:

