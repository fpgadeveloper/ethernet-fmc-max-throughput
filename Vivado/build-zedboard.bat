SET vivado=C:\Xilinx\Vivado\2016.2\bin\vivado.bat
pushd ..\HLS
call build-hls-cores.bat
popd
%vivado% -mode batch -source build-zedboard.tcl
