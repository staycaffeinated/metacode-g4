#!/bin/sh
#
VERSION=$(head -n 1 ../version.txt)
DESTINATION=$HOME/Scratch/Metacode/v${VERSION}

mkdir -pv ${DESTINATION} 

cp ./build/libs/metacode-${VERSION}.jar ${DESTINATION}

