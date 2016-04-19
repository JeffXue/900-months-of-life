---
title: tomcat7安装配置详细说明
tags:
  - tomcat7
date: 2016-04-18 20:06:21
categories: 运维
---

# 安装
Tomcat不需要安装，直接解压到对应的目录即可，需提前解压安装JDK1.7，并配置环境变量
```
tar xvzf apache-tomcat-7.0.68.tar.gz -C /usr/local

mv /usr/local/apache-tomcat-7.0.68 /usr/local/tomcat
```

# 配置
## 配置JAVA_HOME
启动的时候，启动脚本会加载setenv.sh，以下为catalina.sh截取代码
(同样会自动加载setclasspath.sh)
```
if [ -r "$CATALINA_BASE/bin/setenv.sh" ]; then
     . "$CATALINA_BASE/bin/setenv.sh"
elif [ -r "$CATALINA_HOME/bin/setenv.sh" ]; then
     . "$CATALINA_HOME/bin/setenv.sh"
fi
```

/usr/local/tomcat/bin/setenv.sh
```
JAVA_HOME=/usr/local/jdk1.7.0_79
```

## 修改catalina.out输出路径
默认情况下catalina.out会输出到tomcat的logs目录下，可自行修改其输出路径
/usr/local/tomcat/bin/catalina.sh
```
if [ -z "$CATALINA_OUT" ] ; then
  CATALINA_OUT="$CATALINA_BASE"/logs/catalina.out
fi
```

## 配置JVM
catalina.sh
```
JAVA_OPTS="$JAVA_OPTS -Xms512m -Xmx3072m -Xss1024K -XX:PermSize=128m -XX:MaxPermSize=512m"

```
- -Xms Java Heap初始值
- -Xmx Java Heap最大值
- -Xmn Java Heap Young区大小
- -Xss 每个线程的stack大小
- -XX:PermSize 永久保区域初始大小
- -XX:MaxPermSize 永久保存区初始最大值
- -XX:NewSize 设置JVM堆的新生代的默认大小
- -XX:MaxNewSize 设置JVM堆的新生代的最大大小

## 自定义变量
可以在catalina.sh/setenv.sh中自行定义变量，如定义一个外网IP地址用于配置Djava.rmi.server.hostname
```
PUBLIC_IP=`/sbin/ifconfig  | grep 'inet addr:'| grep -v '127.0.0.1' | cut -d: -f2 | awk '{ print $1}' |grep -v ^10.`
```

## 配置jmxremote
官方monitoring说明：https://tomcat.apache.org/tomcat-7.0-doc/monitoring.html
catalina.sh
```
JAVA_OPTS="$JAVA_OPTS -Djava.rmi.server.hostname=$PUBLIC_IP -Dcom.sun.management.jmxremote -Dcom.sun.management.jmxremote.port=8999 -Dcom.sun.management.jmxremote.ssl=false -Dcom.sun.management.jmxremote.authenticate=true -Dcom.sun.management.jmxremote.password.file=../conf/jmxremote.password -Dcom.sun.management.jmxremote.access.file=../conf/jmxremote.access -Dfile.encoding=UTF-8"
```
- -Dcom.sun.management.jmxremote  启动JMX远程监控
- -Dcom.sun.management.jmxremote.port=8999 使用的端口8999
- -Dcom.sun.management.jmxremote.ssl=false 不使用ssl
- -Dcom.sun.management.jmxremote.authenticate=true 远程连接需要密码认证
- -Dcom.sun.management.jmxremote.password.file=../conf/jmxremote.password 指定jmx账号文件
- -Dcom.sun.management.jmxremote.access.file=../conf/jmxremote.password 指定jmx账号授权文件

在conf目录下新建jmxremote.password和jmxremote.access文件
```
touch /usr/local/tomcat/conf/jmxremote.password
touch /usr/local/tomcat/conf/jmxremote.access

```

jmxremote.access添加以下内容：
```
monitorRole readonly 
controlRole readwrite
```

jmxremote.password添加以下内容：
```
monitorRole tomcat
controlRole tomcat
```
Tip：The password file should be read-only and only accessible by the operating system user Tomcat is running as


## 配置server.xml
```
<?xml version='1.0' encoding='utf-8'?>

<Server port="8005" shutdown="SHUTDOWN">

  <Listener className="org.apache.catalina.core.AprLifecycleListener" SSLEngine="on" />
  <Listener className="org.apache.catalina.core.JasperListener" />
  <Listener className="org.apache.catalina.core.JreMemoryLeakPreventionListener" />
  <Listener className="org.apache.catalina.mbeans.GlobalResourcesLifecycleListener" />
  <Listener className="org.apache.catalina.core.ThreadLocalLeakPreventionListener" />

  <GlobalNamingResources>
    <Resource name="UserDatabase" auth="Container"
              type="org.apache.catalina.UserDatabase"
              description="User database that can be updated and saved"
              factory="org.apache.catalina.users.MemoryUserDatabaseFactory"
              pathname="conf/tomcat-users.xml" />
  </GlobalNamingResources>

  <Service name="Catalina">

    <!-- 启用线程池 -->
    <Executor name="tomcatThreadPool" namePrefix="catalina-exec-"
        maxThreads="150"
        minSpareThreads="4" 
        maxIdleTime="30"/>

    <!-- 配置Connector -->
    <!-- protocol支持三种模式bio，nio，apr，对应配置为：
            org.apache.coyote.http11.Http11Protocol
            org.apache.coyote.http11.Http11NioProtocol
            org.apache.coyote.http11.Http11AprProtocol
        需安装tomcat-native才能支持apr模式，具体见tomcat-natvie编译安装
    -->
 
    <Connector executor="tomcatThreadPool"
               port="8080" protocol="org.apache.coyote.http11.Http11AprProtocol"
               connectionTimeout="20000"
               enableLookups="false"
               disableUploadTimeout="true"
               URIEncoding="UTF-8" />

    <Engine name="Catalina" defaultHost="localhost">

      <Realm className="org.apache.catalina.realm.LockOutRealm">

        <Realm className="org.apache.catalina.realm.UserDatabaseRealm"
               resourceName="UserDatabase"/>
      </Realm>
    
      <!-- 配置对应的appBase目录 --> 
      <Host name="localhost"  appBase="webapps"
            unpackWARs="true" autoDeploy="true">

        <!-- 配置日志输出 --> 
        <Valve className="org.apache.catalina.valves.AccessLogValve" directory="logs"
               prefix="localhost_access_log." suffix=".txt"
               pattern="%h %l %u %t &quot;%r&quot; %s %b" />

      </Host>
    </Engine>
  </Service>
</Server>
```

## 配置logging.properties
根据实际情况修改输出日志路径
```
1catalina.org.apache.juli.FileHandler.level = FINE
1catalina.org.apache.juli.FileHandler.directory = ${catalina.base}/logs
1catalina.org.apache.juli.FileHandler.prefix = catalina.

2localhost.org.apache.juli.FileHandler.level = FINE
2localhost.org.apache.juli.FileHandler.directory = ${catalina.base}/logs
2localhost.org.apache.juli.FileHandler.prefix = localhost.

3manager.org.apache.juli.FileHandler.level = FINE
3manager.org.apache.juli.FileHandler.directory = ${catalina.base}/logs
3manager.org.apache.juli.FileHandler.prefix = manager.

4host-manager.org.apache.juli.FileHandler.level = FINE
4host-manager.org.apache.juli.FileHandler.directory = ${catalina.base}/logs
4host-manager.org.apache.juli.FileHandler.prefix = host-manager.

```

## 配置tomcat-user.xml
tomcat默认的webapps下有管理后台，需要配置用户才能查看运行状态和管理应用
```
<?xml version='1.0' encoding='utf-8'?>
<role rolename="manager-gui"/>
<user username="tomcat" password="tomcat" roles="manager-gui"/>
</tomcat-users>

```


# 启动
```
/usr/local/tomcat/bin/startup.sh
```

# 停止
```
/usr/local/tomcat/bin/shutdown.sh
```
