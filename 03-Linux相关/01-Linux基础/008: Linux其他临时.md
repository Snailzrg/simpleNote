[toc]
#一 iptables

## 1 iptables

# iptables

iptables规则链执行顺序

预备知识(转)： iptable有三种队列(表)规则，mangle queue， filter queue， nat queue。

1。The first is the mangle table which is responsible for the alteration of quality of service bits in the TCP header.
2。The second table is the filter queue which is responsible for packet filtering. 
     * Forward chain: Filters packets to servers protected by the firewall.
     * Input chain: Filters packets destined for the firewall.
     * Output chain: Filters packets originating from the firewall. 
3。The third table is the nat queue which is responsible for network address translation. It has two built-in chains; these are:
     * Pre-routing chain: NATs packets when the destination address of the packet needs to be changed.
     * Post-routing chain: NATs packets when the source address of the packet needs to be changed 

个人总结：
iptables执行规则时，是从从规则表中从上至下顺序执行的，如果没遇到匹配的规则，就一条一条往下执行，如果遇到匹配的规则后，那么就执行本规则，执行后根据本规则的动作(accept, reject, log等)，决定下一步执行的情况，后续执行一般有三种情况。
1。一种是继续执行当前规则队列内的下一条规则。比如执行过Filter队列内的LOG后，还会执行Filter队列内的下一条规则。
2。一种是中止当前规则队列的执行，转到下一条规则队列。比如从执行过accept后就中断Filter队列内其它规则，跳到nat队列规则去执行
3。一种是中止所有规则队列的执行。

--------------------其它相关知识补充(转过来的)-----------------------------

iptables 是采用规则堆栈的方式来进行过滤，当一个封包进入网卡，会先检查 Prerouting，然后检查目的 IP 判断是否需要转送出去，接着就会跳到 INPUT 或 Forward 进行过滤，如果封包需转送处理则检查 Postrouting，如果是来自本机封包，则检查 OUTPUT 以及 Postrouting。过程中如果符合某条规则将会进行处理，处理动作除了 ACCEPT、REJECT、DROP、REDIRECT 和 MASQUERADE 以外，还多出 LOG、ULOG、DNAT、SNAT、MIRROR、QUEUE、RETURN、TOS、TTL、MARK 等，其中某些处理动作不会中断过滤程序，某些处理动作则会中断同一规则炼的过滤，并依照前述流程继续进行下一个规则炼的过滤（注意：这一点与 ipchains 不同），一直到堆栈中的规则检查完毕为止。透过这种机制所带来的好处是，我们可以进行复杂、多重的封包过滤，简单的说，iptables 可以进行纵横交错式的过滤（tables）而非炼状过滤（chains）。


　ACCEPT 将封包放行，进行完此处理动作后，将不再比对其它规则，直接跳往下一个规则炼（nat:postrouting）。 
　REJECT 拦阻该封包，并传送封包通知对方，可以传送的封包有几个选择：ICMP port-unreachable、ICMP echo-reply 或是 tcp-reset（这个封包会要求对方关闭联机），进行完此处理动作后，将不再比对其它规则，直接 中断过滤程序。 范例如下： 
iptables -A FORWARD -p TCP --dport 22 -j REJECT --reject-with tcp-reset 
　DROP 丢弃封包不予处理，进行完此处理动作后，将不再比对其它规则，直接中断过滤程序。 
　REDIRECT 将封包重新导向到另一个端口（PNAT），进行完此处理动作后，将 会继续比对其它规则。 这个功能可以用来实作通透式 porxy 或用来保护 web 服务器。例如：iptables -t nat -A PREROUTING -p tcp --dport 80 -j REDIRECT --to-ports 8080 
　MASQUERADE 改写封包来源 IP 为防火墙 NIC IP，可以指定 port 对应的范围，进行完此处理动作后，直接跳往下一个规则炼（mangle:postrouting）。这个功能与 SNAT 略有不同，当进行 IP 伪装时，不需指定要伪装成哪个 IP，IP 会从网卡直接读取，当使用拨接连线时，IP 通常是由 ISP 公司的 DHCP 服务器指派的，这个时候 MASQUERADE 特别有用。范例如下：　 
　iptables -t nat -A POSTROUTING -p TCP -j MASQUERADE --to-ports 1024-31000
LOG 将封包相关讯息纪录在 /var/log 中，详细位置请查阅 /etc/syslog.conf 组态档，进行完此处理动作后，将会继续比对其它规则。例如： 
　　iptables -A INPUT -p tcp -j LOG --log-prefix "INPUT packets"
SNAT 改写封包来源 IP 为某特定 IP 或 IP 范围，可以指定 port 对应的范围，进行完此处理动作后，将直接跳往下一个规则炼（mangle:postrouting）。范例如下： 
　　iptables -t nat -A POSTROUTING -p tcp-o eth0 -j SNAT --to-source 194.236.50.155-194.236.50.160:1024-32000
DNAT 改写封包目的地 IP 为某特定 IP 或 IP 范围，可以指定 port 对应的范围，进行完此处理动作后，将会直接跳往下一个规则炼（filter:input 或 filter:forward）。范例如下： 
　　iptables -t nat -A PREROUTING -p tcp -d 15.45.23.67 --dport 80 -j DNAT --to-destination 192.168.1.1-192.168.1.10:80-100
MIRROR 镜射封包，也就是将来源 IP 与目的地 IP 对调后，将封包送回，进行完此处理动作后，将会中断过滤程序。 
QUEUE 中断过滤程序，将封包放入队列，交给其它程序处理。透过自行开发的处理程序，可以进行其它应用，例如：计算联机费用.......等。 
RETURN 结束在目前规则炼中的过滤程序，返回主规则炼继续过滤，如果把自订规则炼看成是一个子程序，那么这个动作，就相当于提早结束子程序并返回到主程序中。 
MARK 将封包标上某个代号，以便提供作为后续过滤的条件判断依据，进行完此处理动作后，将会继续比对其它规则。范例如下： 
　　iptables -t mangle -A PREROUTING -p tcp --dport 22 -j MARK --set-mark 2

http://www.cnblogs.com/foundation/archive/2007/08/18/860911.html



## 2 sed

# sed

sed

a\ 在当前行下面插入文本。
i\ 在当前行上面插入文本。
c\ 把选定的行改为新的文本。
d 删除，删除选择的行。
D 删除模板块的第一行。
s 替换指定字符
h 拷贝模板块的内容到内存中的缓冲区。
H 追加模板块的内容到内存中的缓冲区。
g 获得内存缓冲区的内容，并替代当前模板块中的文本。
G 获得内存缓冲区的内容，并追加到当前模板块文本的后面。
l 列表不能打印字符的清单。
n 读取下一个输入行，用下一个命令处理新的行而不是用第一个命令。
N 追加下一个输入行到模板块后面并在二者间嵌入一个新行，改变当前行号码。
p 打印模板块的行。
P(大写) 打印模板块的第一行。
q 退出Sed。
b lable 分支到脚本中带有标记的地方，如果分支不存在则分支到脚本的末尾。
r file 从file中读行。
t label if分支，从最后一行开始，条件一旦满足或者T，t命令，将导致分支到带有标号的命令处，或者到脚本的末尾。
T label 错误分支，从最后一行开始，一旦发生错误或者T，t命令，将导致分支到带有标号的命令处，或者到脚本的末尾。
w file 写并追加模板块到file末尾。  
W file 写并追加模板块的第一行到file末尾。  
! 表示后面的命令对所有没有被选定的行发生作用。  
= 打印当前行号码。  

# 把注释扩展到下一个换行符以前。



...................................源字符集...........................................................
^ 匹配行开始，如：/^sed/匹配所有以sed开头的行。
$ 匹配行结束，如：/sed$/匹配所有以sed结尾的行。
. 匹配一个非换行符的任意字符，如：/s.d/匹配s后接一个任意字符，最后是d。

* 匹配0个或多个字符，如：/*sed/匹配所有模板是一个或多个空格后紧跟sed的行。
  [] 匹配一个指定范围内的字符，如/[ss]ed/匹配sed和Sed。  
  [^] 匹配一个不在指定范围内的字符，如：/[^A-RT-Z]ed/匹配不包含A-R和T-Z的一个字母开头，紧跟ed的行。
  \(..\) 匹配子串，保存匹配的字符，如s/\(love\)able/\1rs，loveable被替换成lovers。
  & 保存搜索字符用来替换其他字符，如s/love/**&**/，love这成**love**。
  \< 匹配单词的开始，如:/\<love/匹配包含以love开头的单词的行。
  \> 匹配单词的结束，如/love\>/匹配包含以love结尾的单词的行。
  x\{m\} 重复字符x，m次，如：/0\{5\}/匹配包含5个0的行。
  x\{m,\} 重复字符x，至少m次，如：/0\{5,\}/匹配至少有5个0的行。
  x\{m,n\} 重复字符x，至少m次，不多于n次，如：/0\{5,10\}/匹配5~10个0的行。


.........................替换文本中的字符串：...................
sed 's/book/books/' file
-n选项和p命令一起使用表示只打印那些发生替换的行：
sed -n 's/test/TEST/p' file
直接编辑文件选项-i，会匹配file文件中每一行的第一个book替换为books：

3使用后缀 /g 标记会替换每一行中的所有匹配：
sed 's/book/books/g' file



## 3 trap

# trap

Linux Trap 
	trap命令用于指定在接收到信号后将要采取的动作，常见的用途是在脚本程序被中断时完成清理工作。
当shell接收到sigspec指定的信号时，arg参数（命令）将会被读取，并被执行。
	例如：trap "exit 1" HUP INT PIPE QUIT TERM  表示当shell收到HUP INT PIPE QUIT TERM这几个命令时，
当前执行的程序会读取参数“exit 1”，并将它作为命令执行。

如果arg参数缺省或者为“-”，每个接收到的sigspec信号都将会被重置为它们进入shell时的值；

如果arg是空字符串每一个由sigspec指定的信号都会被shell和它所调用的命令忽略；

如果有-p选项而没有提供arg参数则会打印所有与sigspec指定信号相关联的的trap命令；

如果没有提供任何参数或者仅有-p选项，trap命令将会打印与每一个信号有关联的命令的列表；

-l选项的作用是让shell打印一个命令名称和其相对应的编号的列表。


信号是一种进程间通信机制，它给应用程序提供一种异步的软件中断，
使应用程序有机会接受其他程序活终端发送的命令(即信号)。应用程序收到信号后，
有三种处理方式：忽略，默认，或捕捉。进程收到一个信号后，会检查对该信号的处理机制。
如果是SIG_IGN，就忽略该信号；如果是SIG_DFT，则会采用系统默认的处理动作，
通常是终止进程或忽略该信号；如果给该信号指定了一个处理函数(捕捉)，则会中断当前进程正在执行的任务，
转而去执行该信号的处理函数，返回后再继续执行被中断的任务。

在有些情况下，我们不希望自己的shell脚本在运行时刻被中断，
比如说我们写得shell脚本设为某一用户的默认shell，使这一用户进入系统后只能作某一项工作，如数据库备份， 
我们可不希望用户使用Ctrl c之类便进入到shell状态，做我们不希望做的事情。这便用到了信号处理。
以下是一些你可能会遇到的，要在程序中使用的更常见的信号：



## 4 other

# other

top
前五行是系统整体的统计信息。
第一行是任务队列信息，同uptime 命令的执行结果。其内容如下：
01:06:48 当前时间
up 1:22 系统运行时间，格式为时:分
1 user 当前登录用户数
load average: 0.06, 0.60, 0.48 系统负载，即任务队列的平均长度。
三个数值分别为1 分钟、5 分钟、15 分钟前到现在的平均值。
第二、三行为进程和CPU 的信息。当有多个CPU 时，这些内容可能会超过两行。内容如下：
Tasks: 29 total 进程总数
1 running 正在运行的进程数
28 sleeping 睡眠的进程数
0 stopped 停止的进程数
0 zombie 僵尸进程数
Cpu(s): 0.3% us 用户空间占用CPU 百分比
1.0% sy 内核空间占用CPU 百分比
0.0% ni 用户进程空间内改变过优先级的进程占用CPU 百分比
98.7% id 空闲CPU 百分比
0.0% wa 等待输入输出的CPU 时间百分比
0.0% hi
0.0% si
最后两行为内存信息。内容如下：
Mem: 191272k total 物理内存总量
173656k used 使用的物理内存总量
17616k free 空闲内存总量
22052k buffers 用作内核缓存的内存量
Swap: 192772k total 交换区总量
0k used 使用的交换区总量
192772k free 空闲交换区总量
123988k cached 缓冲的交换区总量。
内存中的内容被换出到交换区，而后又被换入到内存，但使用过的交换区尚未被覆盖，
该数值即为这些内容已存在于内存中的交换区的大小。
相应的内存再次被换出时可不必再对交换区写入。
进程信息区
统计信息区域的下方显示了各个进程的详细信息。首先来认识一下各列的含义。
序号列名含义
a PID 进程id
b PPID 父进程id
c RUSER Real user name
d UID 进程所有者的用户id
e USER 进程所有者的用户名
f GROUP 进程所有者的组名
g TTY 启动进程的终端名。不是从终端启动的进程则显示为?
h PR 优先级
i NI nice 值。负值表示高优先级，正值表示低优先级
j P 最后使用的CPU，仅在多CPU 环境下有意义
k %CPU 上次更新到现在的CPU 时间占用百分比
l TIME 进程使用的CPU 时间总计，单位秒
m TIME+ 进程使用的CPU 时间总计，单位1/100 秒
n %MEM 进程使用的物理内存百分比
o VIRT 进程使用的虚拟内存总量，单位kb。VIRT=SWAP+RES
p SWAP 进程使用的虚拟内存中，被换出的大小，单位kb。
q RES 进程使用的、未被换出的物理内存大小，单位kb。RES=CODE+DATA
r CODE 可执行代码占用的物理内存大小，单位kb
s DATA 可执行代码以外的部分(数据段+栈)占用的物理内存大小，单位kb
t SHR 共享内存大小，单位kb
u nFLT 页面错误次数
v nDRT 最后一次写入到现在，被修改过的页面数。
w S 进程状态。
D=不可中断的睡眠状态
R=运行
S=睡眠
T=跟踪/停止
Z=僵尸进程
x COMMAND 命令名/命令行
y WCHAN 若该进程在睡眠，则显示睡眠中的系统函数名
z Flags 任务标志，参考sched.h
##################################
iptables
内建三个表：nat mangle 和filter
filter 预设规则表，有INPUT、FORWARD 和OUTPUT 三个规则链
INPUT 进入
FORWARD 转发
OUTPUT 出去
ACCEPT 将封包放行
REJECT 拦阻该封包
DROP 丢弃封包不予处理
-A 在所选择的链(INPUT 等)末添加一条或更多规则
-D 删除一条
-E 修改
-p tcp、udp、icmp 0 相当于所有all !取反
-P 设置缺省策略(与所有链都不匹配强制使用此策略)
-s IP/掩码(IP/24) 主机名、网络名和清楚的IP 地址!取反
-j 目标跳转，立即决定包的命运的专用内建目标
-i 进入的（网络）接口[名称] eth0
-o 输出接口[名称]
-m 模块
--sport 源端口
--dport 目标端口
#配置文件
vi /etc/sysconfig/iptables
#将防火墙中的规则条目清除掉
iptables -F
#注意:iptables -P INPUT ACCEPT
#导入防火墙规则
iptables-restore <规则文件
#保存防火墙设置
/etc/init.d/iptables save
#重启防火墙服务
/etc/init.d/iptables restart
#查看规则
iptables -L -n
iptables -L -n --line-numbers
#从某个规则链中删除一条规则
iptables -D INPUT --dport 80 -j DROP
iptables -D INPUT 8
#取代现行规则
iptables -R INPUT 8 -s 192.168.0.1 -j DROP
#插入一条规则
iptables -I INPUT 8 --dport 80 -j ACCEPT
#查看转发
iptables -t nat -nL
#在内核里打开ip 转发功能
echo 1 > /proc/sys/net/ipv4/ip_forward
##################################
#允许本地回环
iptables -A INPUT -s 127.0.0.1 -p tcp -j ACCEPT
#允许已建立的或相关连的通行
iptables -A INPUT -m state --state ESTABLISHED,RELATED -j ACCEPT
#开放对外访问
iptables -P OUTPUT ACCEPT
#指定某端口针对IP 开放
iptables -A INPUT -s 192.168.10.37 -p tcp --dport 22 -j ACCEPT
#允许的IP 或IP 段访问
iptables -A INPUT -s 192.168.10.37 -p tcp -j ACCEPT
#开放对外开放端口
iptables -A INPUT -p tcp --dport 80 -j ACCEPT
#关闭入口
iptables -P INPUT DROP
#关闭转发
iptables -P FORWARD DROP
##################################
iptables 规则文件
 Generated by iptables-save v1.2.11 on Fri Feb 9 12:10:37 2007
*filter
:INPUT DROP [637:58967]
:FORWARD DROP [0:0]


Wall  用于向用户发送消息 向所有终端广播。。