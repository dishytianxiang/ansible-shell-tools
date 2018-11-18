#### 新增拷贝文件到远程主机目录脚本
- 脚本执行示例：bash transfer_file.sh -h hadoop -f transfer_hosts -t gz  -src "xxx.gz" -dest "/dirxxx"
- 验证脚本参数，任何参数不满足就退出执行，参数如下：
 * -f: ansible config file 
 * -h: group name of ansible operating hosts
 * -t: file compress type
 * -src: local file path
 * -dest: dir path  of target hosts 

- 验证ansible
 * 检查本机是否安装ansible，没有安装就退出执行

- 创建远程文件夹，解压gz文件到远程文件夹
 * ansible file 模块执行创建文件夹模块
 * ansible unarchive模块执行远程解压文件操作

- 将PYTHONPATH和CLASSPATH加入到远程主机/etc/profile文件中
 * 方法：
   - PYTHONPATH和CLASSPATH放入到/etc/profile中export
   - 使用ansible lineinfile模块来匹配PYTHONPATH和CLASSPATH，替换/etc/profile原来的PYTHONPATH和CLASSPATH
