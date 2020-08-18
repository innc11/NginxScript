@echo off

REM ����Nginx��PHP-CGI��Ŀ¼��www�ļ���
SET php_home=.\php-7.4.8-nts-Win32-vc15-x64
SET nginx_home=.
SET www=.\html
SET php_port=9000

REM �벻Ҫ�޸������Ŀ
SET tempFile=.temp.txt
SET version=1.3.1

REM parameter handle
if "%1"=="start" (	
	call :start_all
	exit
)

if "%1"=="stop" (	
	call :stop_all
	exit
)

:menu
set phpcgiRunning=
set nginxRunning=

tasklist.exe | findstr php-cgi.exe > %tempFile%
set /p phpcgiRunning=<%tempFile%

tasklist.exe | findstr nginx.exe > %tempFile%
set /p nginxRunning=<%tempFile%

del %tempFile%

title nginx��php-cgi������� v%version%

cls
echo   __________________________________________
echo  ^|                                          ^|

if "%nginxRunning%" NEQ "" (
	echo  ^|      [   NGINX    ��������  ]            ^|
) else (
	echo  ^|      [   NGINX    ---       ]            ^|
)

if "%phpcgiRunning%" NEQ "" (
	echo  ^|      [   PHP-CGI  ��������  ]            ^|
) else (
	echo  ^|      [   PHP-CGI  ---       ]            ^|
)

echo  ^|                                          ^|
echo  ^|     www    - ��Root�ļ���              ^|
echo  ^|     w      - ��http://127.0.0.1        ^|
echo  ^|     re     - ����Nginx                   ^|
echo  ^|                                          ^|
echo  ^|     1      - ȫ������                    ^|
echo  ^|     2      - ȫ��ֹͣ                    ^|
echo  ^|                                          ^|
echo  ^|     9      - ��/ͣ  nginx                ^|
echo  ^|     0      - ��/ͣ  php-cgi              ^|
echo  ^|__________________________________________^|
echo.


:input
set input=
set /p input=  ����ָ�� ^>

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
ECHO �������� nginx...  
call :nginx_stop
call :nginx_start
echo ���..
@ping 127.0.0.1 -n 2 >nul
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
ECHO �������� PHP FastCGI...
echo %php_home%/php-cgi.exe -b 127.0.0.1:%php_port% -c %php_home%/php.ini
call %php_home%/php-cgi.exe -b 127.0.0.1:%php_port% -c %php_home%/php.ini
pause
goto :eof

:nginx
ECHO �������� PHP FastCGI...
echo %nginx_home%/nginx.exe
call %nginx_home%/nginx.exe
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
ECHO �������� nginx...
call :nginx_start
ECHO �������� PHP FastCGI...
call :php_cgi_start
echo ���.
@ping 127.0.0.1 -n 2 >nul
goto :eof

:stop_all
ECHO ����ֹͣ nginx...  
call :nginx_stop
ECHO ����ֹͣ PHP FastCGI...
call :php_cgi_stop
echo ���..
@ping 127.0.0.1 -n 2 >nul
goto :eof



:nginx_start
echo �������� nginx...
RunHiddenConsole %nginx_home%/nginx.exe
echo ���..
@ping 127.0.0.1 -n 2 >nul
goto :eof

:php_cgi_start
echo �������� PHP FastCGI...
RunHiddenConsole %php_home%/php-cgi.exe -b 127.0.0.1:%php_port% -c %php_home%/php.ini
echo ���..
@ping 127.0.0.1 -n 2 >nul
goto :eof

:nginx_stop
echo ����ֹͣ nginx...  
TASKKILL /F /IM nginx.exe
echo ���..
@ping 127.0.0.1 -n 2 >nul
goto :eof

:php_cgi_stop
echo ����ֹͣ PHP FastCGI...
TASKKILL /F /IM php-cgi.exe
echo ���..
@ping 127.0.0.1 -n 2 >nul
goto :eof
