# new_note
https://www.jianshu.com/p/24193e9ad62f


通过官网下载最新版的 node 之后，nvm 也默认安装了。
一. node 多版本管理
在开发中，有时候对 node 的版本有要求，有时候需要切换到指定的 node 版本来重现问题等。遇到这种需求的时候，我们需要能够灵活的切换node版本。 这里我们使用nvm工具来管理多版本node。
1. nvm install v4.8.7
nvm 详细安装步骤
curl -o- https://raw.githubusercontent.com/creationix/nvm/v0.33.8/install.sh | bash

如果nvm -v报错：command not found
安装指南给出了解决办法：

ls -al | grep zsh → .zshrc
touch .zsh_profile
在里面追加一行 source ~/.zshrc

2. nvm ls 查看已经安装的版本

default nvm 默认使用的版本
node和stable 当前安装的node的最新的稳定版本
iojs iojs的最新稳定版本
lts/* node lts 系列最新的稳定版本
lts/argon,lts/boron,lts/carbon分别指lts的三个大的版本的最新版本


3. nvm use lts/boron 用别名或版本号来切换版本
4. nvm alias default v8.10.0 指定默认版本号
通过nvm使用node开发项目时需要保证版本统一性，某些模块安装时会根据不同的node版本进行编译，切换node版本会导致该模块不可用.
二. 使用nrm来切换npm源
1. npm install -g nrm
2. nrm ls：列出可用的源
3. nrm use taobao：通过 nrm use指令来切换不同的源
4. nrm add 别名 源地址：添加源

作者：McDu
链接：https://www.jianshu.com/p/24193e9ad62f
来源：简书
简书著作权归作者所有，任何形式的转载都请联系作者获得授权并注明出处。