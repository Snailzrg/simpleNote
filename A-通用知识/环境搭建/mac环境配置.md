

## 1:mac配置多版本jdk

> 说明：Mac系统的环境变量，加载顺序为：
> /etc/profile   /etc/paths.   ~/.bash_profile    ~/.bash_login   ~/.profile ~/.bashrc

- 查看

>snailzhou@SnaildeMacBook-Pro ~ % /usr/libexec/java_home -V
>Matching Java Virtual Machines (2):
>    11.0.10, x86_64:    "Java SE 11.0.10"       /Library/Java/JavaVirtualMachines/jdk-11.0.10.jdk/Contents/Home
>    1.8.0_211, x86_64:  "Java SE 8"     /Library/Java/JavaVirtualMachines/jdk1.8.0_211.jdk/Contents/Home
>
>/Library/Java/JavaVirtualMachines/jdk-11.0.10.jdk/Contents/Home
>snailzhou@SnaildeMacBook-Pro ~ % 



### 以下两个方式任选其一[推荐上面这种下面那种不行]

-  >1.打开终端vim ~/.bash_profile  //编辑文件，加入以下内容
   >
   >\# 设置 jdk1.8
   >
   >export JAVA_8_HOME='$(/usr/libexec/java_home -v 1.8)'
   >
   >\# 设置 jdk11
   >
   >export JAVA_11_HOME='$(/usr/libexec/java_home -v 11)'
   >
   >\# 默认 jdk 使用1.8版本
   >
   >JAVA_HOME=$JAVA_8_HOME
   >
   >PATH=$JAVA_HOME/bin:$PATH
   >
   >CLASSPATH=.:$JAVA_HOME/lib/dt.jar:$JAVA_HOME/lib/tools.jar
   >
   >export JAVA_HOME PATH CLASSPATH
   >
   >2.source ~/.bash_profile //使bash_profile 生效
   >
   >3.配置/etc/profile文件信息
   >
   >1. sudo vim /etc/profile
   >2. source /etc/profile
   >3. 在profile文件加入
   >4. alias jdk11="export JAVA_HOME=$JAVA_11_HOME"
   >5. alias jdk8="export JAVA_HOME=$JAVA_8_HOME"

- > ```
  > $ vim ~/.bash_profile
  > 
  > #添加下面的代码
  > export JAVA_8_HOME="$(/usr/libexec/java_home -v 1.8)"
  > export JAVA_11_HOME="$(/usr/libexec/java_home -v 11)"
  > alias jdk8='export JAVA_HOME=$JAVA_8_HOME'
  > alias jdk11='export JAVA_HOME=$JAVA_11_HOME'
  > export JAVA_HOME=$JAVA_8_HOME
  > 
  > #保存退出
  > #激活环境变量
  > $ source ~/.bash_profile
  > ```





.bash_profile

>\##########环境变量配置#########
>
>
>
>\#<设置jdk1.8/ 11>
>
>\#export JAVA_8_HOME='$(/usr/libexec/java_home -v 1.8)'
>
>\#export JAVA_11_HOME='$(/usr/libexec/java_home -v 11)'
>
>
>
>\#alias jdk8='export JAVA_HOME=$JAVA_8_HOME'
>
>\#alias jdk11='export JAVA_HOME=$JAVA_11_HOME'
>
>\#export JAVA_HOME=$JAVA_8_HOME
>
>
>
>\#CLASSPATH="$JAVA_HOME/lib/dt.jar:$JAVA_HOME/lib/tools.jar"
>
>\#PATH=$JAVA_HOME/bin:$PATH
>
>
>
>\#MAVEN_HOME=/Users/snailzhou/softData/maven/apache-maven-3.6.1
>
>\## CLASSPATH="$JAVA_HOME/lib/dt.jar:$JAVA_HOME/lib/tools.jar"
>
>\#GRADLE_HOME=/Users/snailzhou/softData/gradle/gradle-6.1
>
>\#PATH="$JAVA_HOME/bin:$PATH":$MAVEN_HOME/bin:$GRADLE_HOME/bin
>
>\#GOPATH=/Users/snailzhou/softData/goHome
>
>
>
>
>
>
>
>
>
>
>
>
>
>\##########################环境变量配置###############################################
>
>export JAVA8HOME=/Library/Java/JavaVirtualMachines/jdk1.8.0_211.jdk/Contents/Home
>
>export JAVA11HOME=/Library/Java/JavaVirtualMachines/jdk-11.0.10.jdk/Contents/Home
>
>export JAVA_HOME=$JAVA8HOME
>
>
>
>alias jdk8='export JAVA_HOME=$JAVA8HOME'
>
>alias jdk11='export JAVA_HOME=$JAVA11HOME'
>
>
>
>CLASSPATH="$JAVA_HOME/lib/dt.jar:$JAVA_HOME/lib/tools.jar"
>
>
>
>\## maven ##
>
>MAVEN_HOME=/Users/snailzhou/softData/maven/apache-maven-3.6.1
>
>\## gradle ##
>
>GRADLE_HOME=/Users/snailzhou/softData/gradle/gradle-6.1
>
>\## gopath ##
>
>GOPATH=/Users/snailzhou/softData/goHome
>
>
>
>PATH="$JAVA_HOME/bin:$PATH":$MAVEN_HOME/bin:$GRADLE_HOME/bin
>
>
>
>
>
>export GRADLE_HOME
>
>export PATH
>
>export CLASSPATH
>
>export MAVEN_HOME
>
>export GOPATH
>
>
>
>
>
>\#mysql
>
>export PATH=$PATH:/usr/local/mysql/bin
>
>export PATH=$PATH:/usr/local/mysql/support-files
>
>
>
>\#mangodb
>
>export PATH=${PATH}:/usr/local/MongoDB/bin
>
>
>
>
>
>\##groovy
>
>export PATH=$PATH:/Users/snailzhou/softData/groovy/groovy-3.0.7/bin
>
>".bash_profile" 66L, 1735C
>
>