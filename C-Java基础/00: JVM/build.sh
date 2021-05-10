export LANG=C
## BootStrapJdk 安装
export ALT_BOOTDIR=/home/snailzrg/data/jdkbuild/bootstrap_jdk/jdk1.7.0_80

## 允许自动下载依赖
export ALLOW_DOWNLOADS=true

## 并行编译的线程数，设置成cpu的核心数即可
export HOTSPOT_BUILD_JOBS=2
export ALT_PARALLEL_COMPILE_JOBS=2

## 比较本次版本和上次版本的差异 这对于我们没有什么意义
## 必须设置成false 否则 make sanity 检查会报错 缺少先前版本jdk的映射错误
## 如果已经设置dev或者 DEV_ONLY=true，这个不显示设置也可
export SKIP_COMPARE_IMAGES=true

## 使用预编译头文件 不加这个编译会慢一些
export USE_PRECOMPILED_HEADER=true

## 要编译的内容
export BUILD_LANGTOOLS=true
#export BUILD_JAXP=false
#export BUILD_JAXWS=false
#export BUILD_CORBA=false
export BUILD_HOTSPOT=true 
export BUILD_JDK=true

## 要编译的版本
#export SKIP_DEBUG_BUILD=false
#export SKIP_FASTDEBUG_BUILD=true
#export DEBUG_NAME=debug

## 把它设置成false可以避开javaws和浏览器java插件之间的部分的build
BUILD_DEPLOY=false

##把它设置成false就不会出现build安装包。因为安装包里会出现一些奇怪的依赖
## 但是即使不build它自己也已经能得到完整的jdk映像，
BUILD_INSTALL=false


## ubutun编译jdk7报错check_os_version
SUPPORTED_OS_VERSION=2.4% 2.5% 2.6% 3% 4% 5%
DISABLE_HOTSPOT_OS_VERSION_CHECK=ok

## 编译结构所存放的路径
export ALT_OUTPITDIR=/home/snailzrg/data/jdkbuild/jdk8u-dev/build

## 这两个环境变量也需要去掉 
unset JAVA_HOME
unset CLASSPATH

##
#export PATH=/home/snailzrg/data/jdkbuild/bootstrap_jdk/jdk1.7.0_80/bin:$PATH 


make 2>&1 |tee $ALT_OUTPITDIR/build.log





# export ANT_HOME=/home/snailzrg/data/soft/apache-ant-1.9.15
# export JAVA_HOME=/home/snailzrg/data/jdkbuild/bootstrap_jdk/jdk1.7.0_80
# export PATH=$JAVA_HOME/bin:$PATH:$ANT_HOME/bin
# export CLASSPATH=.:$JAVA_HOME/lib/dt.jar:$JAVA_HOME/lib/tools.jar
