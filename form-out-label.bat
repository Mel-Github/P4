@ECHO OFF
SETLOCAL EnableDelayedExpansion EnableExtensions
SET P4USER=perforce
SET P4PASSWD=2AC9CB7DCxxxxxx8E549B63
SET P4PORT=localhost:1666
 
 
SET jenkinsHost=localhost:8080
SET jenkinsCred=jenkins_admin:e92c66690e15fxxxxxxx3500d41c2
SET jenkinsCrumb=Jenkins-Crumb:186c4254d7877cxxxx78e233
 
 
SET projectName=""
SET streamName=""
SET mavenProject=""
SET previousValue=""
SET currentValue=""
 
 
SET curlHOME=E:\Apps\Softwares\Curl
SET perforceDirectory=E:\Perforce
SET tempDirectory=E:\temp
SET logFileName=full-build-log.txt
 
echo "*********************************Logging Starts*********************************************" Â >> !tempDirectory!\!logFileName! 2>&1
!perforceDirectory!\p4 resolved >> !tempDirectory!\!logFileName! 2>&1
echo Parameter=%1 >> !tempDirectory!\!logFileName! 2>&1
echo Parameter2=%2 >> !tempDirectory!\!logFileName! 2>&1
SET input=%2
echo First character is !input:~3,1! >> !tempDirectory!\!logFileName! 2>&1
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
REM From Eclipse parameter 2 is Â "-lRM000005_CR000003,//streams-depot/RM000005/..."
REM From Perforce parameter 1 is "-l,RM000005_CR000003,//streams-depot/RM000005/...#head"
echo "String length is %_strlen%" >> !tempDirectory!\!logFileName! 2>&1
SET input_temp=!input:~3,1!
echo input_temp is !input_temp! >> !tempDirectory!\!logFileName! 2>&1
IF "!input_temp!" NEQ "," (
echo "this is an error string" >> !tempDirectory!\!logFileName! 2>&1
SET header=!input:~1,2!,
echo Header is !header! >> !tempDirectory!\!logFileName! 2>&1
SET footer=!input:~3,%_strlen%!
echo Footer is !footer! >> !tempDirectory!\!logFileName! 2>&1
SET concatParameter=!header!!Footer!
echo parameter is !concatParameter! >> !tempDirectory!\!logFileName! 2>&1
) ELSE (
echo "This is a correct string" >> !tempDirectory!\!logFileName! 2>&1
SET concatParameter=!input!
)
REM ****************************** End of fix for Eclipse plugin bug ******************************
echo Parameter2=!concatParameter!>> !tempDirectory!\!logFileName! 2>&1
for /f "tokens=2 delims=, " %%a in ("!concatParameter!") do set labelname=%%a
echo labelname=!labelname! >> !tempDirectory!\!logFileName! 2>&1
echo Parameter2=!concatParameter! >> !tempDirectory!\!logFileName! 2>&1
for /f "tokens=3 delims=, " %%a in ("!concatParameter!") do set depotStream=%%a
echo depotStream=!depotStream! >> !tempDirectory!\!logFileName! 2>&1
 
REM Extract the RM and CR info
for /f "tokens=1,2 delims=_ " %%a in ("!labelname!") do set RM=%%a&set CR=%%b
echo RM=%RM% CR=%CR% >> !tempDirectory!\!logFileName! 2>&1
 
REM Extract the depot and stream info
for /f "tokens=1,2,3 delims=/ " %%a in ("!depotStream!") do set depotName=%%a&set streamName=%%b&set projectName=%%c
 
echo depotName=!depotName! streamName=!streamName! projectName=!projectName! >> !tempDirectory!\!logFileName! 2>&1
 
GOTO skipWorkspaceLabel
 
REM remove this later. This is just here to create the error
SET streamInfo=//!depotName!/!streamName!
!perforceDirectory!\p4 streams !streamInfo! >> !tempDirectory!\!logFileName! 2>&1
 
REM code to enable workspace label ongoing
echo reached_0 >> !tempDirectory!\!logFileName! 2>&1
REM if streamName is a space, parameter2 contains a workspace path rather than a stream
 
REM RM2 is the label and stream I'm aiming for
set workspacePath=c:\Users\Administrator\Perforce\admin_WIN-CDQKNRLGFBU_RM00000002_4539\sewpims
 
REM very first return of perforce clients cmd with the extra parts
set workspacePath=c:\Users\Administrator\Perforce\admin_WIN-CDQKNRLGFBU_3994\sewpims\...#head
 
 
REM very first return of perforce clients cmd
set workspacePath=c:\Users\Administrator\Perforce\admin_WIN-CDQKNRLGFBU_3994
 
REM test token print
set entry=admin_WIN-CDQKNRLGFBU_3994 2018/06/25 root C:\Users\Administrator\Perforce\admin_WIN-CDQKNRLGFBU_3994 'Created by admin. '
 
 
 
 
echo errorlevel=!ERRORLEVEL! >> !tempDirectory!\!logFileName! 2>&1
REM reset the error level to detect other issues
 
REM test code v2
IF %ERRORLEVEL% NEQ 0 (
 
echo errorlevel=!ERRORLEVEL! >> !tempDirectory!\!logFileName! 2>&1
REM reset the error level to detect other issues
echo resetting error level >> !tempDirectory!\!logFileName! 2>&1
ver
echo errorlevel=!ERRORLEVEL! >> !tempDirectory!\!logFileName! 2>&1
 
set /a count = 1
 
 
for /f "tokens=2*" %%a in ('!perforceDirectory!\p4 clients') do (
echo [INFO]: Perforce output line number = !count! >> !tempDirectory!\!logFileName! 2>&1
set /a count += 1
set perforceline=%%a
echo [INFO]: PF output line = !perforceline! >> !tempDirectory!\!logFileName! 2>&1
call :echoMethod "%%a", !workspacePath!
 
)
 
)
 
echo exiting now >> !tempDirectory!\!logFileName! 2>&1
exit
 
REM test code
IF %ERRORLEVEL% NEQ 0 (
 
echo errorlevel=!ERRORLEVEL! >> !tempDirectory!\!logFileName! 2>&1
REM reset the error level to detect other issues
echo resetting error level >> !tempDirectory!\!logFileName! 2>&1
ver
echo errorlevel=!ERRORLEVEL! >> !tempDirectory!\!logFileName! 2>&1
 
for /f "tokens=1*" %%a in ('!perforceDirectory!\p4 clients') do (
set entry=%%b
echo entry=!entry! >> !tempDirectory!\!logFileName! 2>&1
call :echoMethod "%%b", !workspacePath!
 
)
 
)
 
echo exiting now >> !tempDirectory!\!logFileName! 2>&1
exit
 
 
 
IF %ERRORLEVEL% NEQ 0 (
 
REM get correct client name
for /F "tokens=1*" %%a in ('!perforceDirectory!\p4 clients') do (
set lineEntryPart2=%%b
echo lineEntryPart2=!lineEntryPart2! >> !tempDirectory!\!logFileName! 2>&1
echo workspacePath=!workspacePath! >> !tempDirectory!\!logFileName! 2>&1
 
 
 
 
 
REM take the latter part of the command output and try to match the root directory to the input directory path
REM current solution requires a one to one mathc
set entry=%%b
for /F "tokens=1 delims= " %%x in ("!entry!") do set client=%%x
 
:NextEntry
if NOT "!entry!" NEQ "" goto :NoMoreEntries
for /F "tokens=1* delims= " %%x in ("!entry!") do (
set token=%%x
echo token is !token! >> !tempDirectory!\!logFileName! 2>&1
 
set refined=!token:%workspacePath%=!
echo refined=!refined! >> !tempDirectory!\!logFileName! 2>&1
 
if !token! NEQ !refined! (
echo this token is a match to !workspacePath! >> !tempDirectory!\!logFileName! 2>&1
echo token=!token! >> !tempDirectory!\!logFileName! 2>&1
echo the client is !client! >> !tempDirectory!\!logFileName! 2>&1
)
 
set entry=%%y
 
)
goto NextEntry
)
:NoMoreEntries
echo "no more entries" >> !tempDirectory!\!logFileName! 2>&1
 
REM get depot stream
echo reached_1 >> !tempDirectory!\!logFileName! 2>&1
 
REM test values
set client=admin_WIN-CDQKNRLGFBU_RM00000002_4539
echo testClient=!client! >> !tempDirectory!\!logFileName! 2>&1
set root=C:\Users\Administrator\Perforce\admin_WIN-CDQKNRLGFBU_RM00000002_4539
echo testRoot=!root! >> !tempDirectory!\!logFileName! 2>&1
 
REM Note: How does the code know to pick up the stream name? And why is the p4 client command necessary?
!perforceDirectory!\p4 client -o !client!
for /F "tokens=2,3 delims=:" %%a in ('!perforceDirectory!\p4 client -o !client!') do set depotStream=%%a
 
echo depotStream=!depotStream! >> !tempDirectory!\!logFileName! 2>&1
 
REM get values
echo reached_2 >> !tempDirectory!\!logFileName! 2>&1
 
REM get the 2 values from the depotStream
for /f "tokens=2,3 delims=/ " %%a in ("!depotStream!") do set depotName=%%a&set streamName=%%b
 
REM get projectName
set tempProjectName=!workspacePath:%root%=!
echo tempProjectName=!tempProjectName! >> !tempDirectory!\!logFileName! 2>&1
for /F "tokens=1 delims=\" %%a in ("!tempProjectName!") do set projectName=%%a
)
 
 
 
 
echo depotName=!depotName! streamName=!streamName! projectName=!projectName! >> !tempDirectory!\!logFileName! 2>&1
 
:skipWorkspaceLabel
 
REM Ensure user is performing the label from the Perforce Stream Perspective
SET streamInfo=//!depotName!/!streamName!
echo streamInfo=!streamInfo! >> !tempDirectory!\!logFileName! 2>&1
!perforceDirectory!\p4 streams !streamInfo! >> !tempDirectory!\!logFileName! 2>&1
 
REM if errorlevel still NEQ 0, then an error was made or stream could not be matched
IF %ERRORLEVEL% NEQ 0 (
echo "Please create label from stream perspective instead of workspace" >> !tempDirectory!\!logFileName! 2>&1
exit
)
 
SET argument=%RM%_%CR%
echo !argument! %CR% %RM% >> !tempDirectory!\!logFileName! 2>&1
REM set projectName=!projectName:~0,3!
set projectName=!projectName!
echo projectName=!projectName! >> !tempDirectory!\!logFileName! 2>&1
set tempProjectName=!projectName:~0,3!
echo tempProjectName=!tempProjectName! >> !tempDirectory!\!logFileName! 2>&1
 
REM //streams-depot/RM000005/sewpims/Jenkinsfile#1 - branch change 4644 (text)
REM Label applied to only 1 project, build only 1 project
IF "!tempProjectName!" NEQ "..." (
REM Check if Jenkinfile exist
FOR /F "tokens=3,4 delims=/" %%a in ('!perforceDirectory!\p4 files @!argument!') do (
set p4projectName=%%a
set 1_Jenkinsfile=%%b
REM echo Comparing p4projectName=!p4projectName! and projectName=!projectName! >> !tempDirectory!\!logFileName! 2>&1
IF "!p4projectName!"=="!projectName!" (
REM echo Match project!
set 1_Jenkinsfile=!1_Jenkinsfile:~0,11!
REM echo checking 1_Jenkinsfile=!1_Jenkinsfile! >> !tempDirectory!\!logFileName! 2>&1
REM jenkinsfile first letter is uppercase
IF "!1_Jenkinsfile!"=="Jenkinsfile" (
echo Maven project >> !tempDirectory!\!logFileName! 2>&1
SET mavenProject="Y"
GOTO BUILD_ONE
)
 
REM jenkinsfile is in lowercase
IF "!1_Jenkinsfile!"=="jenkinsfile" (
echo Maven project >> !tempDirectory!\!logFileName! 2>&1
SET mavenProject="Y"
GOTO BUILD_ONE
)
)
)
REM End of FOR Loop
IF NOT !mavenProject!=="Y" (
echo "Skipping non maven project !projectName!" >> !tempDirectory!\!logFileName! 2>&1
GOTO:EOF
)
)
FOR /F "tokens=3,4 delims=/" %%a in ('!perforceDirectory!\p4 files @!argument!') do (
IF %previousValue%=="" (
SET pathname=%%a
SET "result=!pathname:~0,11!"
REM echo a=%%a and result=!result!
REM Skip processing any Jenkinsfile in the root directory
IF NOT "!result!"=="Jenkinsfile" (
REM SET "currentValue=%%a"
REM SET "previousValue=%%a"
REM ECHO currentValue is !currentValue! previousValue is !previousValue!
SET "checkfile==%%b"
SET "result2=!checkfile:~1,11!"
REM ECHO result2=!result2!
IF "!result2!"=="Jenkinsfile" (
SET "currentValue=%%a"
SET "previousValue=%%a"
echo FOUND -- currentValue is !currentValue! previousValue is !previousValue! >> !tempDirectory!\!logFileName! 2>&1
echo ***FIRE JENKINS JOBS FOR PROJECT !currentValue! *** >> !tempDirectory!\!logFileName! 2>&1
echo FIRE URL http://!jenkinsHost!/job/!RM!-ci/job/!currentValue!/build >> !tempDirectory!\!logFileName! 2>&1
 
echo !curlHOME!\bin\curl -X POST "http://!jenkinsHost!/job/!RM!-ci/job/!currentValue!/build" -u "!jenkinsCred!" -H "!jenkinsCrumb!" --data-urlencode json= "{"parameter":[{"name":'labelname', "value":'!labelname!'}]}" >> !tempDirectory!\!logFileName! 2>&1
 
!curlHOME!\bin\curl -X POST "http://!jenkinsHost!/job/!RM!-ci/job/!currentValue!/build" -u "!jenkinsCred!" -H "!jenkinsCrumb!" --data-urlencode json= "{"parameter":[{"name":'labelname', "value":'!labelname!'}]}" >> !tempDirectory!\!logFileName! 2>&1
)
) ELSE IF NOT "!previousValue!"==%%a (
REM Process the different project folders
SET "checkfile==%%b"
SET "result2=!checkfile:~1,11!"
ECHO result2=!result2!
echo result2=!result2!
IF "!result2!"=="Jenkinsfile" (
SET "previousValue=%%a"
SET "currentValue=%%a"
echo New currentValue is !currentValue! previousValue is !previousValue! >> !tempDirectory!\!logFileName! 2>&1
echo ***FIRE JENKINS JOBS*** >> !tempDirectory!\!logFileName! 2>&1
 
echo FIRE URL http://!jenkinsHost!/job/!RM!-ci/job/!currentValue!/build >> !tempDirectory!\!logFileName! 2>&1
 
echo !curlHOME!\bin\curl -X POST "http://!jenkinsHost!/job/!RM!-ci/job/!currentValue!/build" -u "!jenkinsCred!" -H "!jenkinsCrumb!" --data-urlencode json="{"parameter":[{"name":'labelname', "value":'!labelname!'}]}" >> !tempDirectory!\!logFileName! 2>&1
 
!curlHOME!\bin\curl -X POST "http://!jenkinsHost/job/!RM!-ci/job/!currentValue!/build" -u "!jenkinsCred!" -H "!jenkinsCrumb!" --data-urlencode json= "{"parameter":[{"name":'labelname', "value":'!labelname!'}]}" >> !tempDirectory!\!logFileName! 2>&1
)
)
)
REM End of For loop
)
GOTO:EOF
 
 
REM Function section
 
REM build one Jenkins Project
:BUILD_ONE
echo "Building one project !projectName!" >> !tempDirectory!\!logFileName! 2>&1
echo jenkinsCred=!jenkinsCred! >> !tempDirectory!\!logFileName! 2>&1
echo !curlHOME!\bin\curl -X POST "http://!jenkinsHost!/job/!RM!-ci/job/!p4projectName!/build" -u "!jenkinsCred!" -H "!jenkinsCrumb!" --data-urlencode json="{"parameter":[{"name":'labelname', "value":'!labelname!'}]}" >> !tempDirectory!\!logFileName! 2>&1
 
!curlHOME!\bin\curl -X POST "http://!jenkinsHost!/job/!RM!-ci/job/!p4projectName!/build" -u "!jenkinsCred!" -H "!jenkinsCrumb!" --data-urlencode json="{"parameter":[{"name":'labelname', "value":'!labelname!'}]}" >> !tempDirectory!\!logFileName! 2>&1
GOTO:EOF
 
REM method 2
:echoMethod
echo: >> !tempDirectory!\!logFileName! 2>&1
echo starting echoMethod >> !tempDirectory!\!logFileName! 2>&1
set entry=%1
set workspacePath=%2
 
echo entry=%1 >> !tempDirectory!\!logFileName! 2>&1
echo workspacePath=!workspacePath! >> !tempDirectory!\!logFileName! 2>&1
 
:echoMain
for /f "tokens=2,5 delims= " %%b IN ("!entry!") do (
echo %%b %%c >> !tempDirectory!\!logFileName! 2>&1
echo c=%%c workspacepath=workspacePath >> !tempDirectory!\!logFileName! 2>&1
if not %%c NEQ !workspacePath! (
echo WE HAVE A MATCH >> !tempDirectory!\!logFileName! 2>&1
echo [INFO]: Path = %%c >> !tempDirectory!\!logFileName! 2>&1
echo [INFO]: Token = %%b >> !tempDirectory!\!logFileName! 2>&1
goto :eof
)
)
)
goto :eof
 
 
REM ref method
:echoMethod1
echo: >> !tempDirectory!\!logFileName! 2>&1
echo starting echoMethod >> !tempDirectory!\!logFileName! 2>&1
set entry=%1
set workspacePath=%2
 
echo entry=%1 >> !tempDirectory!\!logFileName! 2>&1
echo workspacePath=!workspacePath! >> !tempDirectory!\!logFileName! 2>&1
 
:echoMain1
if NOT "!entry!" NEQ "" (
echo leaving echoMethod >> !tempDirectory!\!logFileName! 2>&1
echo: >> !tempDirectory!\!logFileName! 2>&1
goto:eof
)
for /f "tokens=1* delims= " %%x in ("!entry!") do (
set entryPart=%%x
echo: >> !tempDirectory!\!logFileName! 2>&1
echo entryPart=!entryPart! >> !tempDirectory!\!logFileName! 2>&1
 
REM try to match root dir to workspace path input
 
set replaced=!workspacePath:%entryPart%=!
echo replaced=!replaced! >> !tempDirectory!\!logFileName! 2>&1
 
if !workspacePath! NEQ !replaced! (
echo this token is a match to !workspacePath! >> !tempDirectory!\!logFileName! 2>&1
)
 
 
set entry=%%y
)
goto echoMain
