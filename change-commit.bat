@ECHO OFF
SETLOCAL EnableDelayedExpansion EnableExtensions
SET P4USER=perforce
SET P4PASSWD=2AC9CB7DC0xxxxxxx98E549B63
SET P4PORT=localhost:1666
 
SET jenkinsHost=localhost:8080
SET jenkinsCred=jenkins_admin:e92c66690e1xxxxxxxxxx
SET jenkinsCrumb=Jenkins-Crumb:186c4254d7xxxxxxxxx33
 
SET projectName=""
SET streamName=""
SET jenkinsFolder=""
SET jenkinsJobName=""
SET mavenProject=""
 
SET curlHOME=E:\Apps\Softwares\Curl
SET perforceDirectory=E:\Perforce
SET tempDirectory=E:\temp
SET logFileName=partial-build-log.txt
 
echo "*********************************Logging Starts*********************************************"  >>  !tempDirectory!\!logFileName!  2>&1
!perforceDirectory!\p4.exe -V >>  !tempDirectory!\!logFileName!  2>&1
echo Parameter=%1>>  !tempDirectory!\!logFileName!  2>&1
echo Parameter2=%2  >>  !tempDirectory!\!logFileName!  2>&1
echo Parameter3=%3  >>  !tempDirectory!\!logFileName!  2>&1
 
 
REM echo values <delete later>
echo jenkinsHost=!jenkinsHost! jenkinsCrumb=!jenkinsCrumb! >>  !tempDirectory!\!logFileName!  2>&1
 
SET filePresence=""
 
REM Parameter3 is //EMC/Integration_Stream/JPetStore/src/main/java/org/mybatis/jpetstore/domain/*
 
SET Parameter3=%3
for /f "tokens=1,2,3 delims=/ " %%a in ("!Parameter3!") do set Depot=%%a&set StreamName=%%b& set Project=%%c
echo Depot=%Depot% StreamName=%StreamName% Project=%Project% >>  !tempDirectory!\!logFileName!  2>&1
 
SET projectPath=//!Depot!/!StreamName!/!Project!/Jenkinsfile
echo projectPath=!projectPath! >>  !tempDirectory!\!logFileName!  2>&1
 
FOR /F "tokens=1,2 delims=-" %%a in ('!perforceDirectory!\p4 files !projectPath!') do (
set file=%%a
set filePresence=%%b
echo OUTPUT file=!file! and filePresence=!filePresence! >>  !tempDirectory!\!logFileName!  2>&1
)
 
REM filePresence output will be "" if the earlier command did not find the Jenkinsfile
IF NOT !filePresence!=="" (
    SET mavenProject="Y"
    echo mavenProject=!mavenProject! >>  !tempDirectory!\!logFileName!  2>&1
)
 
 
REM we will skip the Jenkins build if the project does not have a Jenkinsfile
IF NOT !mavenProject!=="Y" (
    echo "Skipping non Maven project" >>  !tempDirectory!\!logFileName!  2>&1
    GOTO:EOF
)
 
 
REM we will invoke partial build for maven project.
echo "Invoking Maven partial build"  >>  !tempDirectory!\!logFileName!  2>&1
 
SET jenkinsFolder=!streamName!-ci
SET jenkinsJobName=!Project!
 
echo -X POST "http://%jenkinsHost%/job/!jenkinsFolder!/job/!jenkinsJobName!/build" -u "%jenkinsCred%" -H "%jenkinsCrumb%" --data-urlencode json="{"parameter":[{"name":'labelname', "value":''}]}" >>  !tempDirectory!\!logFileName!  2>&1
%curlHOME%\bin\curl -X POST "http://%jenkinsHost%/job/!jenkinsFolder!/job/!jenkinsJobName!/build" -u "%jenkinsCred%" -H "%jenkinsCrumb%" --data-urlencode json="{"parameter":[{"name":'labelname', "value":''}]}"
