@echo on
for /f "tokens=2 delims==" %%a in ('wmic OS Get localdatetime /value') do set "dt=%%a"
set "YY=%dt:~2,2%" & set "YYYY=%dt:~0,4%" & set "MM=%dt:~4,2%" & set "DD=%dt:~6,2%"
set "HH=%dt:~8,2%" & set "Min=%dt:~10,2%" & set "Sec=%dt:~12,2%"
set "datestamp=%YYYY%%MM%%DD%"
ROBOCOPY "%systemdrive%%homepath%\Downloads" "D:\downloads" /NP /TEE /dcopy:T /Z /E
pause



###
https://stackoverflow.com/questions/10868613/detect-usb-and-copy-to-usb-drive-using-batch-script

@echo off
for /F "tokens=1*" %%a in ('fsutil fsinfo drives') do (
   for %%c in (%%b) do (
      for /F "tokens=3" %%d in ('fsutil fsinfo drivetype %%c') do (
         if %%d equ Removable (
            echo Drive %%c is Removable (USB^)
         )
      )
   )
)


or from Tom Lavedas
https://social.technet.microsoft.com/Forums/exchange/en-US/bc64aef0-e4c0-43fb-ad20-49951f3abde4/batch-script-to-detect-drive-letter-of-a-usb-flash-drive

@echo off
  if [%1]==[] echo Volume label input missing & goto :eof
  setlocal
  set n=0
  set ltrs=ABCDEFGHIJKLMNOPQRSTUVWXYZ
 :Loop
  call set ltr=%%ltrs:~%n%,1%%
  set /a n +=1
  vol %ltr%: 2>nul|find /i " %1">nul||if %n% lss 26 goto :loop
  if %n% equ 26 (set "ltr="
    echo No matching volume label found.
  ) else (echo Volume %1 is drive %ltr%:)
  endlocal & set ltr=%ltr%
