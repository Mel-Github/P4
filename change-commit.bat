@echo off
SET P4USER=
SET P4PORT=
SET P4PASSWD=


REM To add Perforce Triggers
REM mainline-project-ci change-commit //streams-depot/mainline/project/... "E:\Perforce\Triggers\change-commit.bat mainline-ci project"
set curlHOME=E:\Apps\Softwares\Curl
SET JenkinsHOST=JenkinsHost:8080

echo  -X POST "http://%JenkinsHOST%/job/%1/job/%2/build" -u "jenkins_admin:e92c66690e15f0429b35be73500d41c2" -H "Jenkins-Crumb:186c4254d7877c454324f337f678e233"  --data-urlencode json="{"parameter":[{"name":'labelname', "value":''}]}" 

%curlHOME%\bin\curl -X POST "http://%JenkinsHOST%/job/%1/job/%2/build" -u "jenkins_admin:e92c66690e15f0429b35be73500d41c2" -H "Jenkins-Crumb:186c4254d7877c454324f337f678e233"  --data-urlencode json="{"parameter":[{"name":'labelname', "value":''}]}"
