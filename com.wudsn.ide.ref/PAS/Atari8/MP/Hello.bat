mp.exe Hello.pas
if ERRORLEVEL 1 goto :error

mads.exe Hello.a65 -x -i:base -o:Hello.xex
if ERRORLEVEL 1 goto :error

start Hello.xex
goto: eof

:error
pause
