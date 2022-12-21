#!/bin/bash
#source /etc/profile
# Auth：Liucx
# Please change these parameters according to your real env.
# 请把JAVA_HOME改成你自己的环境路径.
# 如果需要修改启动所需的配置文件修改 -Dspring.profiles.active=dev 指定环境.
# set Java Home: Remember that dolphin only supports JDK8!
JAVA_HOME=/opt/jdk
#JAVA_HOME=/usr/local/java/jdk1.8.0_11
# application directory
cd `dirname $0`
APP_HOME=`pwd`
APP_NAME="gateway-report"
# JAR_PATH=${APP_HOME}/lib/$APP_NAME.jar
JAR_PATH=${APP_HOME}/lib/gateway-report.jar
JAR_HOME_TOW=${APP_NAME:2}
JAR_HOME=${JAR_HOME_TOW%%.*}
LOG_FILE=${APP_HOME}/logs
LOG_GC_PATH=$LOG_FILE/gclog.log
HEAP_DUMP_PATH=$LOG_FILE/HeapDump.hprof
CONFIG_PATH=${APP_HOME}/conf/
PORT=18080

echo "=============================================="
echo "========   欢迎使用科澜脚本启动jar    ========"
echo "========   生成的日志在本目录下       ========"
echo "========   日志是$APP_NAME.log         ========"
echo "=============================================="

# APP_NAME=`pwd |awk -F"/" '{print $NF}'`
# Java JVM lunch parameters
if [ x"$JAVA_MEM_OPTS" == x ];then
  JAVA_MEM_OPTS="-server -Xms1g -Xmx1g -Dfile.encoding=utf-8 -Dspring.config.location=$CONFIG_PATH -Dlog.path=$LOG_FILE -XX:+PrintGCDetails -XX:+HeapDumpOnOutOfMemoryError -Xloggc:$LOG_GC_PATH -XX:HeapDumpPath=$HEAP_DUMP_PATH "
fi
# waiting timeout for starting, in seconds
START_WAIT_TIMEOUT=30
psid=0
#/usr/java/jdk1.8.0_211/bin/jps -l | grep test
checkpid() {
  javaps=`$JAVA_HOME/bin/jps -l | grep "$APP_NAME"`
  if [ -n "$javaps" ]; then
   psid=`echo $javaps | awk '{print $1}'`
  else
   psid=0
  fi
}
start() {
  checkpid
  if [ $psid -ne 0 ]; then
   echo "================================"
   echo "warn: $APP_NAME already started! (pid=$psid)"
   echo "================================"
  else
   echo -n "Starting $APP_NAME ..."
   #-Dspring.profiles.active=dev 指定环境
   nohup $JAVA_HOME/bin/java -jar $JAVA_MEM_OPTS ${JAR_PATH} --server.port=$PORT >${APP_NAME}.log 2>&1 &  
   sleep 5
   checkpid
   echo ">>>>>>>>>(pid=$psid) [OK]"
   if [ $psid -ne 0 ]; then
     echo "(pid=$psid) [OK]"
   else
     echo "[Failed]"
   fi
  fi
}
stop() {
  sleep 2
  checkpid
  if [ $psid -ne 0 ]; then
   echo -n "Stopping $APP_NAME ...(pid=$psid) "
   #kill -9 $psid
   kill -9 $psid
   if [ $? -eq 0 ]; then
     echo "[OK]"
   else
     echo "[Failed]"
   fi
#   checkpid
#   if [ $psid -ne 0 ]; then
#     stop
#   fi
  else
   echo "================================"
   echo "warn: $APP_NAME is not running"
   echo "================================"
  fi
}
status() {
  checkpid
  if [ $psid -ne 0 ]; then
   echo "$APP_NAME is running! (pid=$psid)"
  else
   echo "$APP_NAME is not running"
  fi
}
info() {
  echo "System Information:"
  echo "****************************"
  echo `head -n 1 /etc/issue`
  echo `uname -a`
  echo
  echo "JAVA_HOME=$JAVA_HOME"
  echo `$JAVA_HOME/bin/java -version`
  echo
  echo "APP_HOME=$APP_HOME"
  echo "APP_NAME=$APP_NAME"
  echo "****************************"
}
case "$1" in
  'start')
   start
   ;;
  'stop')
   stop
   ;;
  'restart')
   stop
   echo "You restart the application ..."
   start #
   ;;
  'status')
   status
   ;;
  'info')
   info
   ;;
 *)
   echo "启动方式: $0 {start|stop|restart|status|info}"
   exit 1
esac
