# 阿里云轻量 Debian 10.5 自用脚本
```
bash <(curl -Ls https://raw.githubusercontent.com/Waitung/script/main/aliyunlite-debian10.5/menu.sh)
```

---

执行后会在本地生成`usr/local/bin/menu`文件，和`~/sh`目录下存放脚本，方便之后本地执行  
如果不需要执行以下命令删除，安装前不会有其他残留
```
rm -f usr/local/bin/menu
rm -rf ~/sh
```