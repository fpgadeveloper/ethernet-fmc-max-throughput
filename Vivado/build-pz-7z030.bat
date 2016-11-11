SET vivado=C:\Xilinx\Vivado\2016.3\bin\vivado.bat
pushd ..\HLS
call build-hls-cores.bat
popd
%vivado% -mode batch -source build-pz-7z030.tcl
