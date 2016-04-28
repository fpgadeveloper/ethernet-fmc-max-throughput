SET vivado=C:\Xilinx\Vivado\2016.1\bin\vivado.bat
pushd ..\HLS
call build-hls-cores.bat
popd
%vivado% -mode batch -source build-pz-7z010.tcl
