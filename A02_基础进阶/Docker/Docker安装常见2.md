## 安装配置Nginx

> docker run --name snail_nginx -p 80:80 -v  /Users/snailzhou/softData/dockerDatas/ngnix/nginx/nginx.conf:/etc/nginx/nginx.conf -v  /Users/snailzhou/softData/dockerDatas/ngnix/logs/log:/var/log/nginx -v   /Users/snailzhou/softData/dockerDatas/ngnix/www:/www  -v  /Users/snailzhou/softData/dockerDatas/ngnix/nginx/conf.d/default.conf:/etc/nginx/conf.d/default.conf -d nginx



/Users/snailzhou/softData/dockerDatas/ngnix/logs