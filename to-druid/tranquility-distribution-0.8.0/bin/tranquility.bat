@REM tranquility-distribution launcher script
@REM
@REM Environment:
@REM JAVA_HOME - location of a JDK home dir (optional if java on path)
@REM CFG_OPTS  - JVM options (optional)
@REM Configuration:
@REM TRANQUILITY_DISTRIBUTION_config.txt found in the TRANQUILITY_DISTRIBUTION_HOME.
@setlocal enabledelayedexpansion

@echo off

if "%TRANQUILITY_DISTRIBUTION_HOME%"=="" set "TRANQUILITY_DISTRIBUTION_HOME=%~dp0\\.."

set "APP_LIB_DIR=%TRANQUILITY_DISTRIBUTION_HOME%\lib\"

rem Detect if we were double clicked, although theoretically A user could
rem manually run cmd /c
for %%x in (!cmdcmdline!) do if %%~x==/c set DOUBLECLICKED=1

rem FIRST we load the config file of extra options.
set "CFG_FILE=%TRANQUILITY_DISTRIBUTION_HOME%\TRANQUILITY_DISTRIBUTION_config.txt"
set CFG_OPTS=
if exist %CFG_FILE% (
  FOR /F "tokens=* eol=# usebackq delims=" %%i IN ("%CFG_FILE%") DO (
    set DO_NOT_REUSE_ME=%%i
    rem ZOMG (Part #2) WE use !! here to delay the expansion of
    rem CFG_OPTS, otherwise it remains "" for this loop.
    set CFG_OPTS=!CFG_OPTS! !DO_NOT_REUSE_ME!
  )
)

rem We use the value of the JAVACMD environment variable if defined
set _JAVACMD=%JAVACMD%

if "%_JAVACMD%"=="" (
  if not "%JAVA_HOME%"=="" (
    if exist "%JAVA_HOME%\bin\java.exe" set "_JAVACMD=%JAVA_HOME%\bin\java.exe"
  )
)

if "%_JAVACMD%"=="" set _JAVACMD=java

rem Detect if this java is ok to use.
for /F %%j in ('"%_JAVACMD%" -version  2^>^&1') do (
  if %%~j==java set JAVAINSTALLED=1
  if %%~j==openjdk set JAVAINSTALLED=1
)

rem BAT has no logical or, so we do it OLD SCHOOL! Oppan Redmond Style
set JAVAOK=true
if not defined JAVAINSTALLED set JAVAOK=false

if "%JAVAOK%"=="false" (
  echo.
  echo A Java JDK is not installed or can't be found.
  if not "%JAVA_HOME%"=="" (
    echo JAVA_HOME = "%JAVA_HOME%"
  )
  echo.
  echo Please go to
  echo   http://www.oracle.com/technetwork/java/javase/downloads/index.html
  echo and download a valid Java JDK and install before running tranquility-distribution.
  echo.
  echo If you think this message is in error, please check
  echo your environment variables to see if "java.exe" and "javac.exe" are
  echo available via JAVA_HOME or PATH.
  echo.
  if defined DOUBLECLICKED pause
  exit /B 1
)


rem We use the value of the JAVA_OPTS environment variable if defined, rather than the config.
set _JAVA_OPTS=%JAVA_OPTS%
if "!_JAVA_OPTS!"=="" set _JAVA_OPTS=!CFG_OPTS!

rem We keep in _JAVA_PARAMS all -J-prefixed and -D-prefixed arguments
rem "-J" is stripped, "-D" is left as is, and everything is appended to JAVA_OPTS
set _JAVA_PARAMS=
set _APP_ARGS=

:param_loop
call set _PARAM1=%%1
set "_TEST_PARAM=%~1"

if ["!_PARAM1!"]==[""] goto param_afterloop


rem ignore arguments that do not start with '-'
if "%_TEST_PARAM:~0,1%"=="-" goto param_java_check
set _APP_ARGS=!_APP_ARGS! !_PARAM1!
shift
goto param_loop

:param_java_check
if "!_TEST_PARAM:~0,2!"=="-J" (
  rem strip -J prefix
  set _JAVA_PARAMS=!_JAVA_PARAMS! !_TEST_PARAM:~2!
  shift
  goto param_loop
)

if "!_TEST_PARAM:~0,2!"=="-D" (
  rem test if this was double-quoted property "-Dprop=42"
  for /F "delims== tokens=1,*" %%G in ("!_TEST_PARAM!") DO (
    if not ["%%H"] == [""] (
      set _JAVA_PARAMS=!_JAVA_PARAMS! !_PARAM1!
    ) else if [%2] neq [] (
      rem it was a normal property: -Dprop=42 or -Drop="42"
      call set _PARAM1=%%1=%%2
      set _JAVA_PARAMS=!_JAVA_PARAMS! !_PARAM1!
      shift
    )
  )
) else (
  if "!_TEST_PARAM!"=="-main" (
    call set CUSTOM_MAIN_CLASS=%%2
    shift
  ) else (
    set _APP_ARGS=!_APP_ARGS! !_PARAM1!
  )
)
shift
goto param_loop
:param_afterloop

set _JAVA_OPTS=!_JAVA_OPTS! !_JAVA_PARAMS!
:run
 
set "APP_CLASSPATH=%APP_LIB_DIR%\io.druid.tranquility-distribution-0.8.0.jar;%APP_LIB_DIR%\io.druid.tranquility-kafka-0.8.0.jar;%APP_LIB_DIR%\io.druid.tranquility-core-0.8.0.jar;%APP_LIB_DIR%\io.druid.tranquility-server-0.8.0.jar;%APP_LIB_DIR%\org.scala-lang.scala-library-2.11.7.jar;%APP_LIB_DIR%\com.metamx.scala-util_2.11-1.11.6.jar;%APP_LIB_DIR%\com.metamx.loglady_2.11-1.1.0-mmx.jar;%APP_LIB_DIR%\org.skife.config.config-magic-0.9.jar;%APP_LIB_DIR%\com.google.guava.guava-16.0.1.jar;%APP_LIB_DIR%\com.fasterxml.jackson.core.jackson-annotations-2.4.6.jar;%APP_LIB_DIR%\com.fasterxml.jackson.core.jackson-core-2.4.6.jar;%APP_LIB_DIR%\com.fasterxml.jackson.core.jackson-databind-2.4.6.jar;%APP_LIB_DIR%\net.sf.opencsv.opencsv-2.3.jar;%APP_LIB_DIR%\io.netty.netty-3.10.5.Final.jar;%APP_LIB_DIR%\javax.validation.validation-api-1.1.0.Final.jar;%APP_LIB_DIR%\commons-lang.commons-lang-2.6.jar;%APP_LIB_DIR%\org.scalaj.scalaj-time_2.11-0.5.jar;%APP_LIB_DIR%\org.yaml.snakeyaml-1.11.jar;%APP_LIB_DIR%\com.fasterxml.jackson.dataformat.jackson-dataformat-smile-2.4.6.jar;%APP_LIB_DIR%\com.fasterxml.jackson.datatype.jackson-datatype-joda-2.4.6.jar;%APP_LIB_DIR%\com.fasterxml.jackson.module.jackson-module-scala_2.11-2.4.5.jar;%APP_LIB_DIR%\org.scala-lang.scala-reflect-2.11.2.jar;%APP_LIB_DIR%\com.thoughtworks.paranamer.paranamer-2.6.jar;%APP_LIB_DIR%\com.google.code.findbugs.jsr305-2.0.1.jar;%APP_LIB_DIR%\mysql.mysql-connector-java-5.1.18.jar;%APP_LIB_DIR%\com.h2database.h2-1.3.158.jar;%APP_LIB_DIR%\c3p0.c3p0-0.9.1.2.jar;%APP_LIB_DIR%\jline.jline-0.9.94.jar;%APP_LIB_DIR%\junit.junit-3.8.1.jar;%APP_LIB_DIR%\org.apache.zookeeper.zookeeper-3.4.6.jar;%APP_LIB_DIR%\org.codehaus.jackson.jackson-mapper-asl-1.9.13.jar;%APP_LIB_DIR%\org.codehaus.jackson.jackson-core-asl-1.9.13.jar;%APP_LIB_DIR%\com.twitter.util-core_2.11-6.30.0.jar;%APP_LIB_DIR%\com.twitter.util-function_2.11-6.30.0.jar;%APP_LIB_DIR%\com.twitter.jsr166e-1.0.0.jar;%APP_LIB_DIR%\org.scala-lang.modules.scala-parser-combinators_2.11-1.0.4.jar;%APP_LIB_DIR%\com.twitter.finagle-core_2.11-6.31.0.jar;%APP_LIB_DIR%\com.twitter.util-app_2.11-6.30.0.jar;%APP_LIB_DIR%\com.twitter.util-registry_2.11-6.30.0.jar;%APP_LIB_DIR%\com.twitter.util-cache_2.11-6.30.0.jar;%APP_LIB_DIR%\com.twitter.util-codec_2.11-6.30.0.jar;%APP_LIB_DIR%\commons-codec.commons-codec-1.9.jar;%APP_LIB_DIR%\com.twitter.util-collection_2.11-6.30.0.jar;%APP_LIB_DIR%\javax.inject.javax.inject-1.jar;%APP_LIB_DIR%\commons-collections.commons-collections-3.2.1.jar;%APP_LIB_DIR%\com.twitter.util-hashing_2.11-6.30.0.jar;%APP_LIB_DIR%\com.twitter.util-jvm_2.11-6.30.0.jar;%APP_LIB_DIR%\com.twitter.util-lint_2.11-6.30.0.jar;%APP_LIB_DIR%\com.twitter.util-logging_2.11-6.30.0.jar;%APP_LIB_DIR%\com.twitter.util-stats_2.11-6.30.0.jar;%APP_LIB_DIR%\com.twitter.finagle-http_2.11-6.31.0.jar;%APP_LIB_DIR%\org.slf4j.slf4j-api-1.7.12.jar;%APP_LIB_DIR%\org.slf4j.jul-to-slf4j-1.7.12.jar;%APP_LIB_DIR%\commons-logging.commons-logging-1.1.3.jar;%APP_LIB_DIR%\io.druid.druid-server-0.9.0.jar;%APP_LIB_DIR%\io.druid.druid-processing-0.9.0.jar;%APP_LIB_DIR%\io.druid.druid-common-0.9.0.jar;%APP_LIB_DIR%\io.druid.druid-api-0.3.16.jar;%APP_LIB_DIR%\com.metamx.java-util-0.27.7.jar;%APP_LIB_DIR%\joda-time.joda-time-2.8.2.jar;%APP_LIB_DIR%\org.mozilla.rhino-1.7R5.jar;%APP_LIB_DIR%\com.jayway.jsonpath.json-path-2.1.0.jar;%APP_LIB_DIR%\aopalliance.aopalliance-1.0.jar;%APP_LIB_DIR%\io.airlift.airline-0.7.jar;%APP_LIB_DIR%\com.google.code.findbugs.annotations-2.0.3.jar;%APP_LIB_DIR%\org.hibernate.hibernate-validator-5.1.3.Final.jar;%APP_LIB_DIR%\org.jboss.logging.jboss-logging-3.1.3.GA.jar;%APP_LIB_DIR%\com.fasterxml.classmate-1.0.0.jar;%APP_LIB_DIR%\commons-io.commons-io-2.4.jar;%APP_LIB_DIR%\org.apache.commons.commons-dbcp2-2.0.1.jar;%APP_LIB_DIR%\org.apache.commons.commons-pool2-2.2.jar;%APP_LIB_DIR%\commons-pool.commons-pool-1.6.jar;%APP_LIB_DIR%\javax.el.javax.el-api-3.0.0.jar;%APP_LIB_DIR%\com.fasterxml.jackson.datatype.jackson-datatype-guava-2.4.6.jar;%APP_LIB_DIR%\org.jdbi.jdbi-2.63.1.jar;%APP_LIB_DIR%\org.apache.logging.log4j.log4j-jul-2.5.jar;%APP_LIB_DIR%\org.slf4j.jcl-over-slf4j-1.7.12.jar;%APP_LIB_DIR%\net.java.dev.jets3t.jets3t-0.9.4.jar;%APP_LIB_DIR%\javax.activation.activation-1.1.1.jar;%APP_LIB_DIR%\org.bouncycastle.bcprov-jdk15on-1.52.jar;%APP_LIB_DIR%\com.jamesmurty.utils.java-xmlbuilder-1.1.jar;%APP_LIB_DIR%\net.iharder.base64-2.3.8.jar;%APP_LIB_DIR%\com.metamx.bytebuffer-collections-0.2.4.jar;%APP_LIB_DIR%\com.metamx.extendedset-1.3.9.jar;%APP_LIB_DIR%\org.roaringbitmap.RoaringBitmap-0.5.16.jar;%APP_LIB_DIR%\com.metamx.emitter-0.3.6.jar;%APP_LIB_DIR%\com.metamx.http-client-1.0.4.jar;%APP_LIB_DIR%\com.ning.compress-lzf-1.0.3.jar;%APP_LIB_DIR%\com.google.protobuf.protobuf-java-2.5.0.jar;%APP_LIB_DIR%\com.ibm.icu.icu4j-4.8.1.jar;%APP_LIB_DIR%\net.jpountz.lz4.lz4-1.3.0.jar;%APP_LIB_DIR%\org.mapdb.mapdb-1.0.8.jar;%APP_LIB_DIR%\io.druid.druid-aws-common-0.9.0.jar;%APP_LIB_DIR%\com.amazonaws.aws-java-sdk-1.10.21.jar;%APP_LIB_DIR%\com.amazonaws.aws-java-sdk-support-1.10.21.jar;%APP_LIB_DIR%\com.amazonaws.aws-java-sdk-core-1.10.21.jar;%APP_LIB_DIR%\org.apache.httpcomponents.httpclient-4.5.1.jar;%APP_LIB_DIR%\org.apache.httpcomponents.httpcore-4.4.3.jar;%APP_LIB_DIR%\com.amazonaws.aws-java-sdk-simpledb-1.10.21.jar;%APP_LIB_DIR%\com.amazonaws.aws-java-sdk-simpleworkflow-1.10.21.jar;%APP_LIB_DIR%\com.amazonaws.aws-java-sdk-storagegateway-1.10.21.jar;%APP_LIB_DIR%\com.amazonaws.aws-java-sdk-route53-1.10.21.jar;%APP_LIB_DIR%\com.amazonaws.aws-java-sdk-s3-1.10.21.jar;%APP_LIB_DIR%\com.amazonaws.aws-java-sdk-kms-1.10.21.jar;%APP_LIB_DIR%\com.amazonaws.aws-java-sdk-importexport-1.10.21.jar;%APP_LIB_DIR%\com.amazonaws.aws-java-sdk-sts-1.10.21.jar;%APP_LIB_DIR%\com.amazonaws.aws-java-sdk-sqs-1.10.21.jar;%APP_LIB_DIR%\com.amazonaws.aws-java-sdk-rds-1.10.21.jar;%APP_LIB_DIR%\com.amazonaws.aws-java-sdk-redshift-1.10.21.jar;%APP_LIB_DIR%\com.amazonaws.aws-java-sdk-elasticbeanstalk-1.10.21.jar;%APP_LIB_DIR%\com.amazonaws.aws-java-sdk-glacier-1.10.21.jar;%APP_LIB_DIR%\com.amazonaws.aws-java-sdk-sns-1.10.21.jar;%APP_LIB_DIR%\com.amazonaws.aws-java-sdk-iam-1.10.21.jar;%APP_LIB_DIR%\com.amazonaws.aws-java-sdk-datapipeline-1.10.21.jar;%APP_LIB_DIR%\com.amazonaws.aws-java-sdk-elasticloadbalancing-1.10.21.jar;%APP_LIB_DIR%\com.amazonaws.aws-java-sdk-emr-1.10.21.jar;%APP_LIB_DIR%\com.amazonaws.aws-java-sdk-elasticache-1.10.21.jar;%APP_LIB_DIR%\com.amazonaws.aws-java-sdk-elastictranscoder-1.10.21.jar;%APP_LIB_DIR%\com.amazonaws.aws-java-sdk-ec2-1.10.21.jar;%APP_LIB_DIR%\com.amazonaws.aws-java-sdk-dynamodb-1.10.21.jar;%APP_LIB_DIR%\com.amazonaws.aws-java-sdk-cloudtrail-1.10.21.jar;%APP_LIB_DIR%\com.amazonaws.aws-java-sdk-cloudwatch-1.10.21.jar;%APP_LIB_DIR%\com.amazonaws.aws-java-sdk-logs-1.10.21.jar;%APP_LIB_DIR%\com.amazonaws.aws-java-sdk-cognitoidentity-1.10.21.jar;%APP_LIB_DIR%\com.amazonaws.aws-java-sdk-cognitosync-1.10.21.jar;%APP_LIB_DIR%\com.amazonaws.aws-java-sdk-directconnect-1.10.21.jar;%APP_LIB_DIR%\com.amazonaws.aws-java-sdk-cloudformation-1.10.21.jar;%APP_LIB_DIR%\com.amazonaws.aws-java-sdk-cloudfront-1.10.21.jar;%APP_LIB_DIR%\com.amazonaws.aws-java-sdk-kinesis-1.10.21.jar;%APP_LIB_DIR%\com.amazonaws.aws-java-sdk-opsworks-1.10.21.jar;%APP_LIB_DIR%\com.amazonaws.aws-java-sdk-ses-1.10.21.jar;%APP_LIB_DIR%\com.amazonaws.aws-java-sdk-autoscaling-1.10.21.jar;%APP_LIB_DIR%\com.amazonaws.aws-java-sdk-cloudsearch-1.10.21.jar;%APP_LIB_DIR%\com.amazonaws.aws-java-sdk-cloudwatchmetrics-1.10.21.jar;%APP_LIB_DIR%\com.amazonaws.aws-java-sdk-swf-libraries-1.10.21.jar;%APP_LIB_DIR%\com.amazonaws.aws-java-sdk-codedeploy-1.10.21.jar;%APP_LIB_DIR%\com.amazonaws.aws-java-sdk-codepipeline-1.10.21.jar;%APP_LIB_DIR%\com.amazonaws.aws-java-sdk-config-1.10.21.jar;%APP_LIB_DIR%\com.amazonaws.aws-java-sdk-lambda-1.10.21.jar;%APP_LIB_DIR%\com.amazonaws.aws-java-sdk-ecs-1.10.21.jar;%APP_LIB_DIR%\com.amazonaws.aws-java-sdk-cloudhsm-1.10.21.jar;%APP_LIB_DIR%\com.amazonaws.aws-java-sdk-ssm-1.10.21.jar;%APP_LIB_DIR%\com.amazonaws.aws-java-sdk-workspaces-1.10.21.jar;%APP_LIB_DIR%\com.amazonaws.aws-java-sdk-machinelearning-1.10.21.jar;%APP_LIB_DIR%\com.amazonaws.aws-java-sdk-directory-1.10.21.jar;%APP_LIB_DIR%\com.amazonaws.aws-java-sdk-efs-1.10.21.jar;%APP_LIB_DIR%\com.amazonaws.aws-java-sdk-codecommit-1.10.21.jar;%APP_LIB_DIR%\com.amazonaws.aws-java-sdk-devicefarm-1.10.21.jar;%APP_LIB_DIR%\io.druid.druid-console-0.0.2.jar;%APP_LIB_DIR%\com.metamx.server-metrics-0.2.8.jar;%APP_LIB_DIR%\commons-cli.commons-cli-1.2.jar;%APP_LIB_DIR%\org.glassfish.javax.el-3.0.0.jar;%APP_LIB_DIR%\org.apache.curator.curator-framework-2.9.1.jar;%APP_LIB_DIR%\org.apache.curator.curator-client-2.9.1.jar;%APP_LIB_DIR%\org.apache.curator.curator-x-discovery-2.9.1.jar;%APP_LIB_DIR%\org.apache.curator.curator-recipes-2.9.1.jar;%APP_LIB_DIR%\com.fasterxml.jackson.jaxrs.jackson-jaxrs-json-provider-2.4.6.jar;%APP_LIB_DIR%\com.fasterxml.jackson.jaxrs.jackson-jaxrs-base-2.4.6.jar;%APP_LIB_DIR%\com.fasterxml.jackson.module.jackson-module-jaxb-annotations-2.4.6.jar;%APP_LIB_DIR%\com.fasterxml.jackson.jaxrs.jackson-jaxrs-smile-provider-2.4.6.jar;%APP_LIB_DIR%\com.sun.jersey.jersey-server-1.19.jar;%APP_LIB_DIR%\com.sun.jersey.jersey-core-1.19.jar;%APP_LIB_DIR%\javax.ws.rs.jsr311-api-1.1.1.jar;%APP_LIB_DIR%\com.sun.jersey.contribs.jersey-guice-1.19.jar;%APP_LIB_DIR%\org.eclipse.jetty.jetty-server-9.2.5.v20141112.jar;%APP_LIB_DIR%\javax.servlet.javax.servlet-api-3.1.0.jar;%APP_LIB_DIR%\org.eclipse.jetty.jetty-http-9.2.5.v20141112.jar;%APP_LIB_DIR%\org.eclipse.jetty.jetty-util-9.2.5.v20141112.jar;%APP_LIB_DIR%\org.eclipse.jetty.jetty-io-9.2.5.v20141112.jar;%APP_LIB_DIR%\org.eclipse.jetty.jetty-proxy-9.2.5.v20141112.jar;%APP_LIB_DIR%\org.eclipse.jetty.jetty-client-9.2.5.v20141112.jar;%APP_LIB_DIR%\io.tesla.aether.tesla-aether-0.0.5.jar;%APP_LIB_DIR%\org.eclipse.aether.aether-api-0.9.0.M2.jar;%APP_LIB_DIR%\org.eclipse.aether.aether-spi-0.9.0.M2.jar;%APP_LIB_DIR%\org.eclipse.aether.aether-util-0.9.0.M2.jar;%APP_LIB_DIR%\org.eclipse.aether.aether-impl-0.9.0.M2.jar;%APP_LIB_DIR%\org.eclipse.aether.aether-connector-file-0.9.0.M2.jar;%APP_LIB_DIR%\io.tesla.aether.aether-connector-okhttp-0.0.9.jar;%APP_LIB_DIR%\com.squareup.okhttp.okhttp-1.0.2.jar;%APP_LIB_DIR%\org.apache.maven.wagon.wagon-provider-api-2.4.jar;%APP_LIB_DIR%\org.codehaus.plexus.plexus-utils-3.0.15.jar;%APP_LIB_DIR%\org.apache.maven.maven-aether-provider-3.1.1.jar;%APP_LIB_DIR%\org.apache.maven.maven-model-3.1.1.jar;%APP_LIB_DIR%\org.apache.maven.maven-model-builder-3.1.1.jar;%APP_LIB_DIR%\org.codehaus.plexus.plexus-interpolation-1.19.jar;%APP_LIB_DIR%\org.apache.maven.maven-repository-metadata-3.1.1.jar;%APP_LIB_DIR%\org.apache.maven.maven-settings-builder-3.1.1.jar;%APP_LIB_DIR%\org.apache.maven.maven-settings-3.1.1.jar;%APP_LIB_DIR%\org.antlr.antlr4-runtime-4.0.jar;%APP_LIB_DIR%\org.abego.treelayout.org.abego.treelayout.core-1.0.1.jar;%APP_LIB_DIR%\net.spy.spymemcached-2.11.7.jar;%APP_LIB_DIR%\org.eclipse.jetty.jetty-servlet-9.2.5.v20141112.jar;%APP_LIB_DIR%\org.eclipse.jetty.jetty-security-9.2.5.v20141112.jar;%APP_LIB_DIR%\org.eclipse.jetty.jetty-servlets-9.2.5.v20141112.jar;%APP_LIB_DIR%\org.eclipse.jetty.jetty-continuation-9.2.5.v20141112.jar;%APP_LIB_DIR%\com.ircclouds.irc.irc-api-1.0-0014.jar;%APP_LIB_DIR%\com.maxmind.geoip2.geoip2-0.4.0.jar;%APP_LIB_DIR%\com.maxmind.maxminddb.maxminddb-0.2.0.jar;%APP_LIB_DIR%\com.google.http-client.google-http-client-1.15.0-rc.jar;%APP_LIB_DIR%\xpp3.xpp3-1.1.4c.jar;%APP_LIB_DIR%\com.google.http-client.google-http-client-jackson2-1.15.0-rc.jar;%APP_LIB_DIR%\org.apache.derby.derby-10.11.1.1.jar;%APP_LIB_DIR%\org.apache.derby.derbynet-10.11.1.1.jar;%APP_LIB_DIR%\org.apache.derby.derbyclient-10.11.1.1.jar;%APP_LIB_DIR%\com.google.inject.guice-4.0.jar;%APP_LIB_DIR%\com.google.inject.extensions.guice-servlet-4.0.jar;%APP_LIB_DIR%\com.google.inject.extensions.guice-multibindings-4.0.jar;%APP_LIB_DIR%\org.apache.kafka.kafka_2.11-0.8.2.2.jar;%APP_LIB_DIR%\com.yammer.metrics.metrics-core-2.2.0.jar;%APP_LIB_DIR%\net.sf.jopt-simple.jopt-simple-3.2.jar;%APP_LIB_DIR%\com.101tec.zkclient-0.3.jar;%APP_LIB_DIR%\org.apache.kafka.kafka-clients-0.8.2.2.jar;%APP_LIB_DIR%\org.xerial.snappy.snappy-java-1.1.1.7.jar;%APP_LIB_DIR%\ch.qos.logback.logback-core-1.1.2.jar;%APP_LIB_DIR%\ch.qos.logback.logback-classic-1.1.2.jar;%APP_LIB_DIR%\org.apache.logging.log4j.log4j-to-slf4j-2.4.jar;%APP_LIB_DIR%\org.apache.logging.log4j.log4j-api-2.4.jar;%APP_LIB_DIR%\org.slf4j.log4j-over-slf4j-1.7.12.jar;%APP_LIB_DIR%\org.scalatra.scalatra_2.11-2.3.1.jar;%APP_LIB_DIR%\org.scalatra.scalatra-common_2.11-2.3.1.jar;%APP_LIB_DIR%\org.clapper.grizzled-slf4j_2.11-1.0.2.jar;%APP_LIB_DIR%\org.scalatra.rl.rl_2.11-0.4.10.jar;%APP_LIB_DIR%\com.googlecode.juniversalchardet.juniversalchardet-1.0.3.jar;%APP_LIB_DIR%\eu.medsea.mimeutil.mime-util-2.1.3.jar;%APP_LIB_DIR%\org.joda.joda-convert-1.7.jar;%APP_LIB_DIR%\org.scala-lang.modules.scala-xml_2.11-1.0.3.jar"
set "APP_MAIN_CLASS=com.metamx.tranquility.distribution.DistributionMain"

if defined CUSTOM_MAIN_CLASS (
    set MAIN_CLASS=!CUSTOM_MAIN_CLASS!
) else (
    set MAIN_CLASS=!APP_MAIN_CLASS!
)

rem Call the application and pass all arguments unchanged.
"%_JAVACMD%" !_JAVA_OPTS! !TRANQUILITY_DISTRIBUTION_OPTS! -cp "%APP_CLASSPATH%" %MAIN_CLASS% !_APP_ARGS!

@endlocal


:end

exit /B %ERRORLEVEL%
