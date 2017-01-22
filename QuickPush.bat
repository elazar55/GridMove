@echo off
cls
set dateTime=%DATE:~4,2%-%DATE:~7,2%-%DATE:~10,4%_%TIME:~0,2%.%TIME:~3,2%

echo %DATE%
echo %TIME%
echo %dateTime%
echo.

echo Committing changes:
git commit -a -m "Quick Push %dateTime%
echo.
echo Pushing changes:
git push
echo.
PAUSE