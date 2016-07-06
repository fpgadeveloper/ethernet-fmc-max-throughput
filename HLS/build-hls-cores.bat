@ECHO OFF

SET vivado_hls=C:\Xilinx\Vivado_HLS\2016.2\bin\vivado_hls.bat

for /d %%a in (*) do call :build %%a

goto:end

:build
cd .\%1
if exist .\%1.tcl (
  if exist .\proj_%1 (
    echo Core %1 already built
  ) else (
    echo Building core %1
    call %vivado_hls% -f %1.tcl
  )
)
cd ..
exit /b 0

:end
