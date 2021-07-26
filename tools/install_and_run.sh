#!/bin/bash

apt-get update
apt-get -y install libatomic1

# download arm gcc and untar
wget https://developer.arm.com/-/media/Files/downloads/gnu-rm/10-2020q4/gcc-arm-none-eabi-10-2020-q4-major-x86_64-linux.tar.bz2
tar xf gcc-arm-none-eabi-10-2020-q4-major-x86_64-linux.tar.bz2

# download ethos-u core platform
wget https://git.mlplatform.org/ml/ethos-u/ethos-u-core-platform.git/snapshot/ethos-u-core-platform-b5f7cfe253dfeadd83caf60fde34b5b66f356782.tar.gz
tar xf ethos-u-core-platform-b5f7cfe253dfeadd83caf60fde34b5b66f356782.tar.gz
mv ethos-u-core-platform-b5f7cfe253dfeadd83caf60fde34b5b66f356782 ethos_u_core_platform

# download CMSIS_5
git clone "https://github.com/arm-software/CMSIS_5" CMSIS_5

# parse platform.ld
gcc-arm-none-eabi-10-2020-q4-major/bin/arm-none-eabi-gcc -E -x c -P -o \
ethos_u_core_platform/targets/corstone-300/platform_parsed.ld \
ethos_u_core_platform/targets/corstone-300/platform.ld

# add retarget for gcc
cat <<EOT >> ethos_u_core_platform/targets/corstone-300/retarget.c
void RETARGET(exit)(int return_code) {
  _exit(return_code);
  while (1) {}
}
EOT

# download FVP
wget https://developer.arm.com/-/media/Arm%20Developer%20Community/Downloads/OSS/FVP/Corstone-300/FVP_Corstone_SSE-300_Ethos-U55_11.13_41.tgz
tar xf FVP_Corstone_SSE-300_Ethos-U55_11.13_41.tgz
./FVP_Corstone_SSE-300_Ethos-U55.sh --i-agree-to-the-contained-eula -d FVP_Corstone_SSE-300_Ethos-U55 --no-interactive

#Build the application
make -j8

# Run the fvp
FVP="FVP_Corstone_SSE-300_Ethos-U55/models/Linux64_GCC-6.4/FVP_Corstone_SSE-300_Ethos-U55 "
FVP+="-C ethosu.num_macs=256 "
FVP+="-C mps3_board.visualisation.disable-visualisation=1 "
FVP+="-C mps3_board.telnetterminal0.start_telnet=0 "
FVP+='-C mps3_board.uart0.out_file="fvp_output.txt" '
FVP+='-C mps3_board.uart0.unbuffered_output=1 '
FVP+='-C mps3_board.uart0.shutdown_on_eot=1'

$FVP main
