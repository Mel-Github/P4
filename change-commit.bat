@ECHO OFF
SETLOCAL EnableDelayedExpansion EnableExtensions
SET P4USER=jenkins
SET P4PASSWD=password
SET P4PORT=localhost:1666
SET curlHOME=C:\Curl
SET JenkinsHOST=localhost:8080
SET jenkinsCred=jenkins:password
SET jenkinsCrumb=Jenkins-Crumb:a71452fe7326edd7f8b7cb7610fdf335
SET projectName=""
SET streamName=""
SET jenkinsFolder=""
SET jenkinsJobName=""
SET mavenProject=""
SET previousValue=""
SET currentValue=""
SET perforceDirectory=C:\EMC\Perforce\Cli
echo "*********************************Logging Starts*********************************************"  >>  C:\temp\label-trigger1.txt  2>&1
!perforceDirectory!\p4.exe -V >>  C:\temp\label-trigger1.txt  2>&1
echo Parameter=%1>>  C:\temp\label-trigger1.txt  2>&1
echo Parameter2=%2  >>  C:\temp\label-trigger1.txt  2>&1
echo Parameter3=%3  >>  C:\temp\label-trigger1.txt  2>&1
SET filePresence=""
REM Parameter3 is //EMC/Integration_Stream/JPetStore/src/main/java/org/mybatis/jpetstore/domain/* 
SET Parameter3=%3
for /f "tokens=1,2,3 delims=/ " %%a in ("!Parameter3!") do set Depot=%%a&set StreamName=%%b& set Project=%%c
echo Depot=%Depot% StreamName=%StreamName% Project=%Project% >>  C:\temp\label-trigger1.txt  2>&1
SET projectPath=//!Depot!/!StreamName!/!Project!/Jenkinsfile
echo projectPath=!projectPath! >>  C:\temp\label-trigger1.txt  2>&1
FOR /F "tokens=1,2 delims=-" %%a in ('!perforceDirectory!\p4 files !projectPath!') do (
set file=%%a
set filePresence=%%b
echo OUTPUT file=!file! and filePresence=!filePresence! >>  C:\temp\label-trigger1.txt  2>&1
)
REM filePresence output will be "" if the earlier command did not find the Jenkinsfile
IF NOT !filePresence!=="" (
SET mavenProject="Y"
echo mavenProject=!mavenProject! >>  C:\temp\label-trigger1.txt  2>&1
)
REM we will skip the Jenkins build if the project does not have a Jenkinsfile
IF NOT !mavenProject!=="Y" (
echo "Skipping non Maven project" >>  C:\temp\label-trigger1.txt  2>&1
GOTO:EOF
)
REM we will invoke partial build for maven project.
echo "Invoking Maven partial build"  >>  C:\temp\label-trigger1.txt  2>&1
SET jenkinsFolder=!streamName!-ci
SET jenkinsJobName=!Project!
echo -X POST "http://%JenkinsHOST%/job/!jenkinsFolder!/job/!jenkinsJobName!/build" -u "%jenkinsCred%" -H "%jenkinsCrumb%" --data-urlencode json="{"parameter":[{"name":'labelname', "value":''}]}" >>  C:\temp\label-trigger1.txt  2>&1
%curlHOME%\bin\curl -X POST "http://%JenkinsHOST%/job/!jenkinsFolder!/job/!jenkinsJobName!/build" -u "%jenkinsCred%" -H "%jenkinsCrumb%" --data-urlencode json="{"parameter":[{"name":'labelname', "value":''}]}"
