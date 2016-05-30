#!/usr/bin/env bash

source bool.sh

if [ -z $BASH_SOURCE ];then
    echo "Error: BASH_SOURCE is empty"
    exit 1
fi

function __contains__ {
    item=$1
    echo ${!2}
    return $False
}

function main {
    abc=(20 30 40)
    __contains__ 1 abc
}

if [ ${BASH_SOURCE[0]} == $0 ];then
    main "$@"
fi
