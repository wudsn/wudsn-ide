@echo off
setlocal
set PATH=%PATH%;C:\jac\bin\wbin
set FOLDER=C:\jac\system\Java\Programming\Repositories\WUDSN-IDE
cd %FOLDER%

echo Checking bundle versions in %FOLDER%.
call :check com.wudsn.ide.base
call :check com.wudsn.ide.hex
call :check com.wudsn.ide.dsk
call :check com.wudsn.ide.gfx
call :check com.wudsn.ide.lng
call :check com.wudsn.ide.lng.asm
call :check com.wudsn.ide.lng.pas
call :check com.wudsn.ide.snd

call :check com.wudsn.ide.base.feature
call :check com.wudsn.ide.feature
pause
goto :eof


:check
echo Plugin: %1
if exist %1\META-INF\MANIFEST.MF grep Bundle-Version %1\META-INF\MANIFEST.MF
if exist %1\META-INF\MANIFEST.MF grep Bundle-RequiredExecutionEnvironment %1\META-INF\MANIFEST.MF
if exist %1\build.properties     grep jre.compilation.profile %1\build.properties
if exist %1\feature.xml          grep version= %1\feature.xml|grep qualifier
echo.
goto :eof
