@echo off
echo Cleaning directory from EXE's, MSG, TRA, and HIS files.
echo.
pause
del /q *.MSG
del /q *.TRA
del /q *.HIS
del *.exe
echo That's all...
