@echo off

REM 设置Nginx和PHP-CGI的目录和www文件夹
SET php_home=.\php-7.4.13-nts-Win32-vc15-x64
SET nginx_home=.
SET www=.\html
SET php_port=9000

REM 请不要修改这个项目
SET tempFile=.temp.txt
SET version=1.4

REM parameter handle
if "%1"=="start" (	
	call :start_all
	exit
)

if "%1"=="stop" (	
	call :stop_all
	exit
)


title nginx操控面板 v%version%
mode con cols=80 lines=25

:menu
set phpcgiRunning=
set nginxRunning=

tasklist.exe | findstr php-cgi.exe > %tempFile%
set /p phpcgiRunning=<%tempFile%

tasklist.exe | findstr nginx.exe > %tempFile%
set /p nginxRunning=<%tempFile%

del %tempFile%


echo   _______________________________________
echo  ^|                                       ^|

if "%nginxRunning%" NEQ "" (
	echo  ^|      [   NGINX    正在运行  ]         ^|
) else (
	echo  ^|      [   NGINX    ---       ]         ^|
)

if "%phpcgiRunning%" NEQ "" (
	echo  ^|      [   PHP-CGI  正在运行  ]         ^|
) else (
	echo  ^|      [   PHP-CGI  ---       ]         ^|
)

echo  ^|                                       ^|
@REM echo  ^|     www    - 打开Root文件夹           ^|
@REM echo  ^|     w      - 打开127.0.0.1            ^|
echo  ^|     re     - 重载Nginx                ^|
echo  ^|                                       ^|
echo  ^|     1      - 全部启动                 ^|
echo  ^|     2      - 全部停止                 ^|
echo  ^|                                       ^|
echo  ^|     9      - 启/停  nginx             ^|
echo  ^|     0      - 启/停  php-cgi           ^|
echo  ^|_______________________________________^|
echo.


:input
set input=
set /p input= ^> 

if "%input%"=="re" call :reload

if "%input%"=="phpcgi" call :phpcgi
if "%input%"=="nginx" call :nginx

if "%input%"=="exit" call :end
if "%input%"=="q" call :end

if "%input%"=="www" call :open_root
if "%input%"=="w" call :open_browser

if "%input%"=="1" call :start_all
if "%input%"=="2" call :stop_all

if "%input%"=="9"  call :turn_nginx, %nginxRunning%
if "%input%"=="0" call :turn_phpcgi, %phpcgiRunning%

goto menu

:reload
ECHO 正在重启 nginx...  
call :nginx_stop
call :nginx_start
echo 完成..
goto menu

:end
exit

:open_browser
start http://127.0.0.1
goto :eof

:open_root
start %www%
goto :eof

:phpcgi
ECHO 正在启动 PHP FastCGI...
echo %php_home%\php-cgi.exe -b 127.0.0.1:%php_port% -c %php_home%\php.ini
call %php_home%\php-cgi.exe -b 127.0.0.1:%php_port% -c %php_home%\php.ini
pause
goto :eof

:nginx
ECHO 正在启动 PHP FastCGI...
echo %nginx_home%\nginx.exe
call %nginx_home%\nginx.exe
pause
goto :eof


:turn_nginx
if "%1" NEQ "" (
	call :nginx_stop
) else (
	call :nginx_start
)
goto :eof

:turn_phpcgi
if "%1" NEQ "" (
	call :php_cgi_stop
) else (
	call :php_cgi_start
)
goto :eof

:start_all
call :nginx_start
call :php_cgi_start
goto :eof

:stop_all
call :nginx_stop
call :php_cgi_stop
goto :eof



:nginx_start
echo 正在启动 nginx...
RunHiddenConsole %nginx_home%\nginx.exe
goto :eof

:php_cgi_start
echo 正在启动 PHP FastCGI...
RunHiddenConsole %php_home%\php-cgi.exe -b 127.0.0.1:%php_port% -c %php_home%\php.ini
goto :eof

:nginx_stop
echo 正在停止 nginx...  
TASKKILL /F /IM nginx.exe
goto :eof

:php_cgi_stop
echo 正在停止 PHP FastCGI...
TASKKILL /F /IM php-cgi.exe
goto :eof
