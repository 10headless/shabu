@echo off
setlocal
if not [%1]==[] pushd %1
for /r %%F in (*.lua) do call :sub "%%F"
echo Total lines in %Files% files: %Total%
set /a Total-=10543
echo Total without pl lib: %Total%
popd
pause
exit /b 0
:Sub
set /a Cnt=0
for /f %%n in ('type %1') do set /a Cnt+=1
set /a Total+=Cnt
set /a Files+=1
echo %1: %Cnt% lines
