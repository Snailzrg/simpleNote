[toc]



# Node









# NPM

>使用npm命令时，如果直接从国外的仓库下载依赖，下载速度很慢，甚至会下载不下来，我们可以更换npm的仓库源，提高下载速度。
>
>此处以淘宝镜像为例，如果公司有本地仓库，将地址修改为公司仓库地址即可

## 修改npm的源 安装cnpm

- 使用cnpm命令代替npm

```
// 安装cnpm命令,不会改变npm的源
npm install -g cnpm --registry=https://registry.npm.taobao.org

//使用
cnpm install
```

- 设置npm的源，可以设置多个源，但是只有一个是生效的

```
//设置淘宝源
npm config set registry https://registry.npm.taobao.org

//设置公司的源
npm config set registry http://xxxx.xx.xx.x

//查看源，可以看到设置过的所有的源
npm config get registry
https://registry.npmjs.org/
```

-  修改npm配置文件

```
//编辑 ~/.npmrc 加入下面内容
registry = https://registry.npm.taobao.org
```







#  安装多版本node管理