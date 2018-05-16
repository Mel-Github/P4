@ECHO OFF
SETLOCAL EnableDelayedExpansion EnableExtensions


REM To add to Perforce triggers
REM full-build command post-user-tag "E:\Perforce\Triggers\form-out-label.bat %command% %quote%%argsQuoted%%quote%"
SET P4USER=
SET P4PORT=hostname:1666
SET P4PASSWD=

SET curlHOME=E:\Apps\Softwares\Curl
SET JenkinsHOST=JenkinsHOst:8080


SET mavenProject=""
SET previousValue=""
SET currentValue=""
E:\Perforce\p4  resolved >>  E:\temp\label-trigger1.txt  2>&1
echo Parameter=%1>>  E:\temp\label-trigger1.txt  2>&1
echo Parameter2=%2  >>  E:\temp\label-trigger1.txt  2>&1

SET input=%2
echo First character is !input:~3,1! >>  E:\temp\label-trigger1.txt  2>&1



REM Find the string length of argument 2
SET _str=%2
REM Remove any quotes
SET _str=%_str:"=%

REM Test if empty
if not defined _str Echo String Length = 0 & ENDLOCAL & set _strlen=0&goto:eof

For /l %%g in (0,1,8191) do (
	REM extract one character
	Set "_char=!_str:~%%g,1!"
	REM if _char is empty we are at the end of the string
	REM if not defined _char Echo String Length = %%g & ENDLOCAL & set _strlen=%%g
	if not defined _char set _strlen=%%g
)
REM ****************************** Start of fix for Eclipse plugin bug ******************************
REM The following section of the code is to fix a bug in the Eclipse Perforce plugin. 
REM The parameter 2 value passed from Eclipse and from Perforce are slightly different (missing comma). 
REM From Eclipse parameter 2 is  "-lRM000005_CR000003,//streams-depot/RM000005/..."  
REM From Perforce parameter 1 is "-l,RM000005_CR000003,//streams-depot/RM000005/...#head"

echo "String length is %_strlen%" >>  E:\temp\label-trigger1.txt  2>&1
	
SET input_temp=!input:~3,1!
echo input_temp is !input_temp! >>  E:\temp\label-trigger1.txt  2>&1

IF "!input_temp!" NEQ "," (
	echo "This is an error string" >>  E:\temp\label-trigger1.txt  2>&1
	
	SET header=!input:~1,2!,
	echo Header is !header! >>  E:\temp\label-trigger1.txt  2>&1
	
	SET footer=!input:~3,%_strlen%!
	echo Footer is !footer! >>  E:\temp\label-trigger1.txt  2>&1

	SET concatParameter=!header!!Footer!
	echo parameter is !concatParameter! E:\temp\label-trigger1.txt  2>&1

) ELSE (
	echo "This is an correct string" >>  E:\temp\label-trigger1.txt  2>&1
	SET concatParameter=!input!
)

REM ****************************** End of fix for Eclipse plugin bug ******************************

echo Parameter2=!concatParameter!  >>  E:\temp\label-trigger1.txt  2>&1
for /f "tokens=2 delims=, " %%a in ("!concatParameter!") do set labelname=%%a
echo labelname=!labelname! >>  E:\temp\label-trigger1.txt  2>&1


echo Parameter2=!concatParameter!  >>  E:\temp\label-trigger1.txt  2>&1
for /f "tokens=3 delims=, " %%a in ("!concatParameter!") do set depotStream=%%a
echo depotStream=!depotStream! >>  E:\temp\label-trigger1.txt  2>&1

REM Extract the RM and CR info
for /f "tokens=1,2 delims=_ " %%a in ("!labelname!") do set RM=%%a&set CR=%%b
echo RM=%RM% CR=%CR%  >>  E:\temp\label-trigger1.txt  2>&1

REM Extract the depot and stream info
for /f "tokens=1,2,3 delims=/ " %%a in ("!depotStream!") do set depotName=%%a&set streamName=%%b&set projectName=%%c
echo depotName=%depotName% streamName=%streamName% projectName=%projectName% >>  E:\temp\label-trigger1.txt  2>&1

SET argument=%RM%_%CR%
echo !argument! %CR% %RM% 

REM set projectName=!projectName:~0,3!
set projectName=!projectName!
echo projectName=!projectName!

set tempProjectName=!projectName:~0,3!
echo tempProjectName=!tempProjectName!

REM Label applied to only 1 project, build only 1 project
IF "!tempProjectName!" NEQ "..." (
	REM Check if Jenkinfile exist
	FOR /F "tokens=3,4 delims=/" %%a in ('E:\Perforce\p4 files @!argument!') do (
		set p4projectName=%%a
		set 1_Jenkinsfile=%%b
		echo Comparing p4projectName=!p4projectName! and projectName=!projectName!  
		IF "!p4projectName!"=="!projectName!" (
			echo Match project! 
			set 1_Jenkinsfile=!1_Jenkinsfile:~0,11!
			
			IF "!1_Jenkinsfile!"=="Jenkinsfile" (
				echo Maven project >> E:\temp\label-trigger1.txt 2>&1
				SET mavenProject="Y"
				GOTO BUILD_ONE
			)
		)
	) 
REM End of FOR Loop
	
	IF NOT !mavenProject!=="Y" (
		Echo "Skipping non maven project !projectName!"  >> E:\temp\label-trigger1.txt 2>&1
		GOTO:EOF
	)
) 


FOR /F "tokens=3,4 delims=/" %%a in ('E:\Perforce\p4 files @!argument!') do (

IF %previousValue%=="" (
	SET pathname=%%a
	SET "result=!pathname:~0,11!"
	REM echo a=%%a and result=!result! 
	REM Skip processing any Jenkinsfile in the root directory
	IF NOT "!result!"=="Jenkinsfile" (
		REM SET "currentValue=%%a"
		REM SET "previousValue=%%a"
		REM ECHO currentvalue is !currentValue! previousValue is !previousValue!
		SET "checkfile==%%b"
		SET "result2=!checkfile:~1,11!"		
		REM ECHO result2=!result2! 
			IF "!result2!"=="Jenkinsfile" (
				SET "currentValue=%%a"
				SET "previousValue=%%a"
				ECHO FOUND -- currentvalue is !currentValue! previousValue is !previousValue!
				ECHO ***FIRE JENKINS JOBS FOR PROJECT !currentValue! ***
				ECHO FIRE URL http://!JenkinsHOST!/job/!RM!-ci/job/!currentValue!/build >> E:\temp\label-trigger1.txt 2>&1
				ECHO !curlHOME!\bin\curl -X POST "http://!JenkinsHOST!/job/!RM!-ci/job/!currentValue!/build" -u "jenkins_admin:e92c66690e15f0429b35be73500d41c2" -H REM "Jenkins-Crumb:186c4254d7877c454324f337f678e233"  --data-urlencode json="{"parameter":[{"name":'labelname', "value":'!labelname!'}]}"  >> E:\temp\label-trigger1.txt 2>&1
				!curlHOME!\bin\curl -X POST "http://!JenkinsHOST!/job/!RM!-ci/job/!currentValue!/build" -u "jenkins_admin:e92c66690e15f0429b35be73500d41c2" -H "Jenkins-Crumb:186c4254d7877c454324f337f678e233"  --data-urlencode json="{"parameter":[{"name":'labelname', "value":'!labelname!'}]}"  >> E:\temp\label-trigger1.txt 2>&1
			)
	) ELSE IF NOT "!previousValue!"==%%a (	
		REM Process the different project folders
		SET "checkfile==%%b"
		SET "result2=!checkfile:~1,11!"		
		ECHO result2=!result2! 
			IF "!result2!"=="Jenkinsfile" (
				SET "previousValue=%%a"
				SET "currentValue=%%a"
				ECHO New currentvalue is !currentValue! previousValue is !previousValue!
				ECHO ***FIRE JENKINS JOBS***
				ECHO FIRE URL http://!JenkinsHOST!/job/!RM!-ci/job/!currentValue!/build >> E:\temp\label-trigger1.txt 2>&1
				ECHO !curlHOME!\bin\curl -X POST "http://!JenkinsHOST!/job/!RM!-ci/job/!currentValue!/build" -u "jenkins_admin:e92c66690e15f0429b35be73500d41c2" -H "Jenkins-Crumb:186c4254d7877c454324f337f678e233"  --data-urlencode json="{"parameter":[{"name":'labelname', "value":'!labelname!'}]}"  >> E:\temp\label-trigger1.txt 2>&1
				!curlHOME!\bin\curl -X POST "http://!JenkinsHOST!/job/!RM!-ci/job/!currentValue!/build" -u "jenkins_admin:e92c66690e15f0429b35be73500d41c2" -H "Jenkins-Crumb:186c4254d7877c454324f337f678e233"  --data-urlencode json="{"parameter":[{"name":'labelname', "value":'!labelname!'}]}"  >> E:\temp\label-trigger1.txt 2>&1

			)
	)
)
REM End of For loop
)
GOTO:EOF

:BUILD_ONE
	Echo "Building one project !projectName!"  >> E:\temp\label-trigger1.txt 2>&1
	ECHO !curlHOME!\bin\curl -X POST "http://!JenkinsHOST!/job/!RM!-ci/job/!p4projectName!/build" -u "jenkins_admin:e92c66690e15f0429b35be73500d41c2" -H REM "Jenkins-Crumb:186c4254d7877c454324f337f678e233"  --data-urlencode json="{"parameter":[{"name":'labelname', "value":'!labelname!'}]}"  >> E:\temp\label-trigger1.txt 2>&1
	!curlHOME!\bin\curl -X POST "http://!JenkinsHOST!/job/!RM!-ci/job/!p4projectName!/build" -u "jenkins_admin:e92c66690e15f0429b35be73500d41c2" -H "Jenkins-Crumb:186c4254d7877c454324f337f678e233"  --data-urlencode json="{"parameter":[{"name":'labelname', "value":'!labelname!'}]}"  >> E:\temp\label-trigger1.txt 2>&1


