mp.exe Example.pas
if ERRORLEVEL 1 goto :error

mads.exe Example.a65 -x -i:base -o:Example.xex
if ERRORLEVEL 1 goto :error

start Example.xex
goto: eof

:error
pause



