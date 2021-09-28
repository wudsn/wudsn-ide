echo off
rem
rem The image and file resource files for the IDE help are original in the "site\productions\java\ide" folder.
rem The are linked into the "com.wudsn.ide.lng/help/productions/java/ide project" folder via a symbolic link.
rem This way, the Eclipse build uses the latest versions automatically.
rem The HTML files for the online help are original in the com.wudsn.ide.lng/help" folder.
rem They have to be copied into the Joomla using the "export.bat" script when something is changed.
rem 
rem Important: Run this script in an Administrator shell.
rem

echo on
setlocal
set REPOSITORY=C:\jac\system\Java\Programming\Repositories\WUDSN-IDE
set SITE=C:\jac\system\WWW\Sites\www.wudsn.com
set SYMBOLIC_LINK=%REPOSITORY%\com.wudsn.ide.lng\help\productions\java\ide
set REAL_FOLDER=%SITE%\productions\java\ide

rmdir %SYMBOLIC_LINK%
mklink /D %SYMBOLIC_LINK% %REAL_FOLDER%
pause
