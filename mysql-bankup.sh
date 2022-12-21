#用户名
username=root
#密码
password=Yunlv123@
#将要备份的数据库
database_name=yunlv_report
#保存备份文件最多个数
count=30
#备份保存路径
backup_path=/opt/mysql_backup/yunlv_report
#日期
date_time=$(date +%Y-%m-%d-%H-%M)
#如果文件夹不存在则创建
if [ ! -d $backup_path ]; then
  mkdir -p $backup_path
fi
#开始备份
mysqldump -u $username -p$password $database_name >$backup_path/$database_name-table-$date_time.sql
mysqldump -u $username -p$password --routines --no-create-info --no-data --no-create-db --skip-opt --skip-triggers $database_name >$backup_path/$database_name-process-$date_time.sql
#开始压缩
cd $backup_path
tar -zcvf $database_name-$date_time.tar.gz $database_name-table-$date_time.sql $database_name-process-$date_time.sql
#删除源文件
rm -rf $backup_path/$database_name-table-$date_time.sql
rm -rf $backup_path/$database_name-process-$date_time.sql
#更新备份日志
echo "create $backup_path/$database_name-$date_time.tar.gz" >>$backup_path/dump.log
#找出需要删除的备份
delfile=$(ls -l -crt $backup_path/*.tar.gz | awk '{print $9 }' | head -1)
#判断现在的备份数量是否大于阈值
#解决fi报错问题https://www.cnblogs.com/zjiacun/p/8066841.html
#：set ff=unix
number=$(ls -l -crt $backup_path/*.tar.gz | awk '{print $9 }' | wc -l)
if [ $number -gt $count ]; then
  #删除最早生成的备份，只保留count数量的备份
  rm $delfile
  #更新删除文件日志
  echo "delete $delfile" >>$backup_path/dump.log
fi
