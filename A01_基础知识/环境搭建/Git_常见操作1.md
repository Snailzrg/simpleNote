[toc]

# Git 常见操作

>参考资源：
>
>

## 一：简易的命令行入门教程:

### 1.1: Git 全局设置:

```
git config --global user.name "snailzrg"
git config --global user.email "snailzrg@163.com"
```

### 1.2: 创建 git 仓库:

```
mkdir snail_back
cd snail_back
git init
touch README.md
git add README.md
git commit -m "first commit"
git remote add origin https://gitee.com/snailzrg/snail_back.git
git push -u origin master
```

### 1.3: 已有仓库?

```
cd existing_git_repo
git remote add origin https://gitee.com/snailzrg/snail_back.git
git push -u origin master
```



## 