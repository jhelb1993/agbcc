#!/bin/sh
set -e
CCOPT=
CXXOPT=

# error if devkitarm is not installed and binutils-arm-none-eabi is not installed
if ! ([ -n "$DEVKITARM" ] && [ -d "$DEVKITARM/bin" ]) && ! (command -v arm-none-eabi-as &> /dev/null && command -v arm-none-eabi-ar &> /dev/null) ; then
	echo "Could not find a binutils installation! Re-read the instructions and make sure you've installed either devkitARM or binutils-arm-none-eabi, depending on your system."
	exit 1
fi

if [ ! -z "$CC" ]; then CCOPT=CC=$CC; fi
if [ ! -z "$CXX" ]; then CXXOPT=CXX=$CXX; fi

if [ "`uname`" == "OpenBSD" ];then
	MAKE='gmake'
else
	MAKE='make'
fi;

${MAKE} -C gcc clean
${MAKE} -C gcc old $CCOPT $CXXOPT
mv gcc/old_agbcc .
${MAKE} -C gcc clean
${MAKE} -C gcc $CCOPT $CXXOPT
mv gcc/agbcc .
# not sure if the ARM compiler is the old one or the new one (-DOLD_COMPILER)
rm -f gcc_arm/config.status gcc_arm/config.cache
cd gcc_arm && ./configure --target=arm-elf --host=i386-linux-gnu && make cc1 && cd ..
mv gcc_arm/cc1 agbcc_arm
${MAKE} -C libgcc clean
${MAKE} -C libgcc $CCOPT $CXXOPT
mv libgcc/libgcc.a .
${MAKE} -C libc clean
${MAKE} -C libc $CCOPT $CXXOPT
mv libc/libc.a .
