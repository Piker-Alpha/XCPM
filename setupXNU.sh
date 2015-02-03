#!/bin/sh

#
# Version control (latest versions for Yosemite)
#
DTRACE_VERSION="147"
AVAILABILITY_VERSION="9"
XNU_VERSION="2782.1.97"

#
# Path and filename setup.
#
gHome=$(echo $HOME)
gProjectDirectory="${gHome}/Projects/Apple"

#
# Check project directory
#
if [[ ! "${gProjectDirectory}" ]];
  then
    mkdir "${gProjectDirectory}"
  else
    cd "${gProjectDirectory}"
fi

echo "Checking dtrace-${DTRACE_VERSION} setup ..."

if [[ ! "dtrace-${DTRACE_VERSION}.tar.gz" ]];
  then
    #
    # Not there. Get (latest) tarball from Apple.
    #
    curl -O "http://opensource.apple.com/tarballs/dtrace/dtrace-${DTRACE_VERSION}.tar.gz"
fi

if [[ ! "dtrace-${DTRACE_VERSION}" ]];
  then
    #
    # Unpack the downloaded tarball.
    #
    tar zxf "dtrace-${DTRACE_VERSION}.tar.gz"
fi

if [[ "dtrace-${DTRACE_VERSION}" ]];
  then
    cd "dtrace-${DTRACE_VERSION}"

    if [[ ! dst ]];
      then
        mkdir -p obj sym dst
    fi

    xcodebuild install -target ctfconvert -target ctfdump -target ctfmerge ARCHS="x86_64" SRCROOT=$PWD OBJROOT=$PWD/obj SYMROOT=$PWD/sym DSTROOT=$PWD/dst
    #
    # Check return status.
    #
    if [[ $? -eq 0 ]];
      then
        sudo ditto dst/usr/local /usr/local
      else
        exit 1
    fi
fi

cd ..

echo "Checking AvailabilityVersions-${AVAILABILITY_VERSION} setup ..."

if [[ ! "AvailabilityVersions-${AVAILABILITY_VERSION}.tar.gz" ]];
  then
    #
    # Not there. Get (latest) tarball from Apple.
    #
    curl -O "http://opensource.apple.com/tarballs/AvailabilityVersions/AvailabilityVersions-${AVAILABILITY_VERSION}.tar.gz"
fi

if [[ ! "AvailabilityVersions-${AVAILABILITY_VERSION}" ]];
  then
    #
    # Unpack the downloaded tarball.
    #
    tar zxf "AvailabilityVersions-${AVAILABILITY_VERSION}.tar.gz"
fi

if [[ "AvailabilityVersions-${AVAILABILITY_VERSION}" ]];
  then
    cd "AvailabilityVersions-${AVAILABILITY_VERSION}"

    if [[ ! dst ]];
      then
        mkdir -p dst
    fi

    make install SRCROOT=$PWD DSTROOT=$PWD/dst
    #
    # Check return status.
    #
    if [[ $? -eq 0 ]];
      then
        printf "Installing AvailabilityVersions ... "
        sudo ditto $PWD/dst/usr/local `xcrun -sdk macosx -show-sdk-path`/usr/local
        printf "Done\n"
      else
        printf "Error!\n"
        exit 1
    fi
  else
    echo "Error: ${PROJECT_DIR}/AvailabilityVersions-${AVAILABILITY_VERSION} not found!"
    exit 1
fi

cd ..

echo "Checking xnu-${XNU_VERSION} source code setup ..."

if [[ ! "xnu-${XNU_VERSION}.tar.gz" ]];
  then
    #
    # Not there. Get (latest) tarball from Apple.
    #
    curl -O "http://opensource.apple.com/tarballs/xnu/xnu-${XNU_VERSION}.tar.gz"
fi

if [[ ! "xnu-${AVAILABILITY_VERSION}" ]];
  then
    #
    # Unpack the downloaded tarball.
    #
    tar zxf “xnu-${XNU_VERSION}.tar.gz”
fi

if [[ "xnu-${AVAILABILITY_VERSION}" ]];
  then
    cd "xnu-${XNU_VERSION}"
    #
    # Haswell target (note the "H")
    #
    printf "Compiling XNU source code ... "
    make SDKROOT=macosx ARCH_CONFIGS=X86_64H KERNEL_CONFIGS=RELEASE
    #
    # Check return status.
    #
    if [[ $? -eq 0 ]];
      then
        printf "Done\n"
      else
        printf "Error\n"
    fi

fi

exit 0
