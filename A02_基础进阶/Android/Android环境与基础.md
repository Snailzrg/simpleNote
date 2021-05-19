[toc]

# Android基础

> [see](https://developer.android.google.cn/training/basics/firstapp/creating-project)
>
> 配置gradle jdk...

## 一: AndroidStudio环境配置

> see https://blog.csdn.net/qq_41976613/article/details/91432304
>
> 注意⚠️：路径不要有空格与中文  eg:D:\software\android



### 1:1 配置中出现的问题

- `Android Studio出现:Cause: unable to find valid certification path to requested target`

  > 从英文字面意思来看:找不到可用证书。就是Android Studio没有获得使用网络的权，无法访问https://bintray.com/bintray/jcenter
  >
  > https://blog.csdn.net/qq_17827627/article/details/99404177

- NDK Resolution Outcome: Project settings: Gradle model version=5.4.1, NDK ve

  > 显示你的NDK找不到，打开File->Project Structure->SDK Location 在Android NDK location一栏点击下载，下载完成后clean project再build project就可以了



## 二: 混合打包Cordova

> 