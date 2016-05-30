#!/usr/bin/env bash

function get_package {
    package_url=$1
    package_name=$2
    [ -z $package_url ] && echo "get_package <package_url>" && exit 1
    
    [ -z $package_name ] && package_name=${package_url##*/}

    if [ $DEBUG == "true" ];then
        echo "package_url: $package_url"
        echo "package_name: $package_name"
    fi 

    package_path=$cache_dir_path/$package_name
    if [ ! -f $package_path ];then
        wget  -t 3 $package_url -O $package_path
        if [ $? -eq 4 ];then
            echo "Error: wget failed to resolve ${package_url%%/*}"
            exit 1
        elif [ $? -eq 8 ];then
            echo "Info: a redirect just happened"
        fi
    else
        echo "Info: $package_path already exists"
    fi
}

DEBUG="false"
source layout.sh
get_package http://www.baidu.com/123

