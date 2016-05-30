#!/usr/bin/env bash

current_dir_path=$(cd "$(dirname ${BASH_SOURCE[0]})" && pwd)
source $current_dir_path/bool.sh


if [ -z $BASH_SOURCE ];then
    echo "Error: BASH_SOURCE is empty"
    exit 1
fi

function __in__ {
    substr=$1
    string=$2
    if [[ "$string" == *${substr}* ]];then
        echo 0
        return 0
    else
        echo 1
        return 1
    fi
    return $False
}

function __startswith__ {
    string=$1
    substr=$2
    if [[ "$string" == "${substr}"* ]];then
        echo 0
        return 0
    else
        echo 1
        return 1
    fi

}

function __lower__ {
    if __startswith__  $BASH_VERSION "5" >/dev/null;then
        echo ${1,,}
    else
        echo "$1" | tr '[:upper:]' '[:lower:]'
    fi
}

function main {
    __lower__ AbC
}

if [ ${BASH_SOURCE[0]} == $0 ];then
    main "$@"
fi
