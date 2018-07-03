@echo off
set P4USER=sa_ci_perforce
SET P4PASSWD=Password1
echo depot is %depot_path%
set basename=%depot_path%
for %%F in (%basename%) do set stream_name=%%~nF
echo stream name is %stream_name%
for /f "tokens=2 delims==" %%a in ('wmic OS Get localdatetime /value') do set "dt=%%a"
set "YY=%dt:~2,2%" & set "YYYY=%dt:~0,4%" & set "MM=%dt:~4,2%" & set "DD=%dt:~6,2%"
set "HH=%dt:~8,2%" & set "Min=%dt:~10,2%" & set "Sec=%dt:~12,2%"
set "datestamp=%YYYY%%MM%%DD%" & set "timestamp=%HH%%Min%%Sec%"
set "fullstamp=%YYYY%-%MM%-%DD%_%HH%-%Min%-%Sec%"
echo datestamp: "%datestamp%"
echo timestamp: "%timestamp%"
echo fullstamp: "%fullstamp%"
set P4HOME=D:\Apps\Softwares\Perforce
set p4TRIGGER=D:\Apps\Softwares\Perforce\Triggers
set P4TRIGGER_TEMP=D:\Apps\Softwares\Perforce
set triggerFile=%P4TRIGGER_TEMP%\trigger_%fullstamp%.txt
echo triggerfile: "%triggerFile%"
REM configure Perforce host information
%p4HOME%\p4 set P4PORT=10.1.8.96:1666
REM create trigger file
%p4HOME%\p4 triggers -o > %triggerFile%
echo %stream_name%-%project_name%-ci change-commit //%depot_path%/%project_name%/... "%p4TRIGGER%\change-commit.bat %stream_name%-ci %project_name%" >> %triggerFile%
type %triggerFile%
echo "Adding Triggers into Perforce"
%p4HOME%\p4 triggers -i < %triggerFile%
del %triggerFile%
