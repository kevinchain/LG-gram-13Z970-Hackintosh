#!/bin/bash

curl_options="--retry 5 --location --progress-bar"
curl_options_silent="--retry 5 --location --silent"

# download latest release from github
function download_github()
# $1 is sub URL of release page
# $2 is partial file name to look for
# $3 is file name to rename to
{
    echo "downloading `basename $3 .zip`:"
    curl $curl_options_silent --output /tmp/com.hieplpvip.download.txt "https://github.com/$1/releases/latest"
    local url=https://github.com`grep -o -m 1 "/.*$2.*\.zip" /tmp/com.hieplpvip.download.txt`
    echo $url
    curl $curl_options --output "$3" "$url"
    rm /tmp/com.hieplpvip.download.txt
    echo
}

# download latest release from RehabMan bitbucket
function download_RHM()
# $1 is subdir on rehabman bitbucket
# $2 is prefix of zip file name
{
    echo "downloading $2:"
    curl $curl_options_silent --output /tmp/com.hieplpvip.download.txt https://bitbucket.org/RehabMan/$1/downloads/
    local url=https://bitbucket.org`grep -o -m 1 "/RehabMan/$1/downloads/$2.*\.zip" /tmp/com.hieplpvip.download.txt|perl -ne 'print $1 if /(.*)\"/'`
    echo $url
    curl $curl_options --output "$2.zip" "$url"
    rm /tmp/com.hieplpvip.download.txt
    echo
}

function download_raw()
{
    echo "downloading $2"
    echo $1
    curl $curl_options --output "$2" "$1"
    echo
}

rm -rf download && mkdir ./download
cd ./download

# download kexts
mkdir ./zips && cd ./zips
download_github "acidanthera/Lilu" "RELEASE" "acidanthera-Lilu.zip"
download_github "acidanthera/AppleALC" "RELEASE" "acidanthera-AppleALC.zip"
download_github "acidanthera/CPUFriend" "RELEASE" "acidanthera-CPUFriend.zip"
download_github "acidanthera/HibernationFixup" "RELEASE" "acidanthera-HibernationFixup.zip"
download_github "acidanthera/NVMeFix" "RELEASE" "acidanthera-NVMeFix.zip"
download_github "acidanthera/VirtualSMC" "RELEASE" "acidanthera-VirtualSMC.zip"
download_github "BAndysc/VoodooPS2" "RELEASE" "BAndysc-VoodooPS2.zip"
download_github "acidanthera/WhateverGreen" "RELEASE" "acidanthera-WhateverGreen.zip"
download_github "lvs1974/CpuTscSync" "RELEASE" "lvs1974-CpuTscSync.zip"
download_github "hieplpvip/LGWMI" "RELEASE" "hieplpvip-LGWMI.zip"
download_github "OpenIntelWireless/itlwm" "AirportItlwm.*Catalina" "OpenIntelWireless-AirportItlwm.zip"
download_github "OpenIntelWireless/IntelBluetoothFirmware" "IntelBluetooth" "OpenIntelWireless-IntelBluetoothFirmware.zip"
download_github "cholonam/Sinetek-rtsx" "Sinetek-rtsx-" "cholonam-Sinetek-rtsx.zip"
download_RHM os-x-null-ethernet RehabMan-NullEthernet
download_RHM os-x-acpi-debug RehabMan-Debug
cd ..

# download drivers
mkdir ./drivers && cd ./drivers
download_raw https://github.com/acidanthera/OcBinaryData/raw/master/Drivers/HfsPlus.efi HfsPlus.efi
cd ..

KEXTS="Lilu|AppleALC|CPUFriend|WhateverGreen|VirtualSMC|SMCBatteryManager|SMCLightSensor|SMCProcessor|VoodooPS2Controller|CpuTscSync|NVMeFix|IntelBluetooth|Sinetek-rtsx|AirportItlwm|LGWMI|ACPIDebug|Fixup"

function check_directory
{
    for x in $1; do
        if [ -e "$x" ]; then
            return 1
        else
            return 0
        fi
    done
}

function unzip_kext
{
    out=${1/.zip/}
    rm -Rf $out/* && unzip -q -d $out $1
    check_directory $out/Release/*.kext
    if [ $? -ne 0 ]; then
        for kext in $out/Release/*.kext; do
            kextname="`basename $kext`"
            if [[ "`echo $kextname | grep -E $KEXTS`" != "" ]]; then
                cp -R $kext ../kexts
            fi
        done
    fi
    check_directory $out/*.kext
    if [ $? -ne 0 ]; then
        for kext in $out/*.kext; do
            kextname="`basename $kext`"
            if [[ "`echo $kextname | grep -E $KEXTS`" != "" ]]; then
                cp -R $kext ../kexts
            fi
        done
    fi
    check_directory $out/Kexts/*.kext
    if [ $? -ne 0 ]; then
        for kext in $out/Kexts/*.kext; do
            kextname="`basename $kext`"
            if [[ "`echo $kextname | grep -E $KEXTS`" != "" ]]; then
                cp -R $kext ../kexts
            fi
        done
    fi
    check_directory $out/Catalina/*.kext
    if [ $? -ne 0 ]; then
        for kext in $out/Catalina/*.kext; do
            kextname="`basename $kext`"
            if [[ "`echo $kextname | grep -E $KEXTS`" != "" ]]; then
                cp -R $kext ../kexts
            fi
        done
    fi
}

mkdir ./kexts

check_directory ./zips/*.zip
if [ $? -ne 0 ]; then
    echo Unzipping...
    cd ./zips
    for kext in *.zip; do
        unzip_kext $kext
    done

    cd ..
fi

cd ..
