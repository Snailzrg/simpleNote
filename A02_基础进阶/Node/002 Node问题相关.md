# 问题相关-node





### 1.1  node_modules中出现.staging文件夹

当我们执行 `npm i` 之后，`node_modules` 里面出现了一个叫 `.staging` 的文件夹，这表明我们的依赖还没有下载完成，当依赖彻底下载完之后,`.staging`的文件夹会自动消失。

### 1.2  更改npm全局模块和cache默认安装位置

![image-20210218213621550](https://gitee.com/snailzrg/snail_img/raw/master/picgo_snail_img/image-20210218213621550.png)


2、启动CMD依次执行以下两条命令
npm config set prefix "XXX\nodejs\node_global"
npm config set cache "XXX\nodejs\node_cache"


3、设置环境变量：
NODE_PATH = XXX\Node\nodejs
PATH = %NODE_PATH%\;%NODE_PATH%\node_modules;%NODE_PATH%\node_global;


4、重启系统或重启explorer.exe，使环境变量生效。


5、安装模块试试上面的设置是否生效

npm install express -g // -g意思是安装到global目录下，也就是上面设置的XXX\nodejs\node_globalc