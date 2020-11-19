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