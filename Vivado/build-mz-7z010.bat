SET vivado=C:\Xilinx\Vivado\2017.1\bin\vivado.bat
pushd ..\HLS
call build-hls-cores.bat
popd
%vivado% -mode batch -source build-mz-7z010.tcl