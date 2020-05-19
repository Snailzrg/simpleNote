# openOffice安装
最近由于项目需要，要在公司服务器上安装Openoffice，网上搜了一些资料后成功安装，现分享给大家。
1、首先先下载好需要的rpm包：Apache_OpenOffice_4.0.0_Linux_x86-64_install-rpm_zh-CN.tar.gz
或直接命令下载：wget http://heanet.dl.sourceforge.NET/project/openofficeorg.mirror/4.0.0/binaries/zh-CN/Apache_OpenOffice_4.0.0_Linux_x86-64_install-rpm_zh-CN.tar.gz
放到服务器的目录下（我放到了opt下）
2、将下载的openoffice解压（我直接解压到opt目录）：tar -zxvf Apache_OpenOffice_4.0.0_Linux_x86-64_install-rpm_zh-CN.tar.gz
3、解压后生成文件夹zh-CN 进到RPMS目录下，直接yum localinstall *.rpm
4、再装RPMS/desktop-integration目录下的openoffice4.0-redhat-menus-4.0-9702.noarch.rpm：yum localinstall openoffice4.0-redhat-menus-4.0-9702.noarch.rpm
5、安装完成直接启动Openoffice服务：
临时启动   /opt/openoffice4/program/soffice -headless -accept="socket,host=127.0.0.1,port=8100;urp;" -nofirststartwizard

一直后台启动 nohup  /opt/openoffice4/program/soffice -headless -accept="socket,host=127.0.0.1,port=8100;urp;" -nofirststartwizard &
6、查看服务是否启动（端口8100是否被soffice占用）：netstat -lnp |grep 8100
显示结果：tcp        0      0 127.0.0.1:8100              0.0.0.0:*                   LISTEN      19501/soffice.bin
大功告成！！！




program/ ./soffice -headless -accept="socket,host=127.0.0.1,port=8100;urp;" -nofirststartwizard

copy 字体文件（中文不显示问题）
将字体拷贝到linux系统下 /usr/share/fonts
依次执行以下命令
mkfontscale (yum install mkfontscale)
mkfontdir 
fc-cache
重新启动 soffice