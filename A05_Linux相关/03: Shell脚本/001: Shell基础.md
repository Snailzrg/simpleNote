# Shell基础



## 一：执行方式

- 1、工作目录执行 【./test.sh】

- 2、绝对路径执行 【/home/tan/scripts/test``.sh】

- 3、sh执行 【sh test.sh / bash test.sh 】

- 4、shell环境执行 【.test.sh】指的是在当前的shell环境中执行，可以使用 . 接脚本 或 source 接脚本

  > 比如在脚本a中执行脚本b 可以 用第四点

  ## 二 ：调试

  > sh -x strangescript  这将执行该脚本并显示所有变量的值。  【**sh -x zkServer.sh**】
  >
  > sh -n your_script     　　这将返回所有语法错误。

