#!/usr/bin/env bash

current_dir_path=$(cd "$(dirname ${BASH_SOURCE[0]})" && pwd)
source $current_dir_path/string.sh

function get_package {
    local package_url=$1
    local package_name=$2
    [ -z $package_url ] && echo "Usage: get_package <package_url>" && exit 1
    
    [ -z $package_name ] && package_name=${package_url##*/}

    [ -z $cache_dir_path ] && echo "Error: you should source layout.sh frist" && exit 1

    if [ "$DEBUG" == "true" ];then
        echo "package_url: $package_url"
        echo "package_name: $package_name"
    fi 

    local package_path=$cache_dir_path/$package_name
    [ "$DEBUG" == "true" ] && echo "Info: downloading package $package_name"
    if [ ! -f $package_path ];then
        if [ "$DEBUG" == "true" ];then
            wget  -t 3 $package_url -O $package_path
        else
            wget -nv  -t 3 $package_url -O $package_path
        fi
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

function extract_package {
    local package_path=$1
    local package_name=$(basename $package_path)
    local pacakge_name=${package_name%%.tar*}
    local extrcact_dir_path=$2
    
    if [ -z $package_path ];then
        echo "Usage: extract_package_name <package_name_or_path> [extract_dir_path]" 
        exit 1
    elif ! __startswith__ $package_path "/" >/dev/null;then
        package_path=$cache_dir_path/$package_path
    fi

    if [ -z "$extract_dir_path" ];then
        extract_dir_path=$build_dir_path
    fi

    if [ -d "$extract_dir_path/$package_name" ];then
        rm -rf $extract_dir_path/$package_name
    fi

    if [ "$DEBUG" == "true" ];then
        echo $package_path
        echo $extract_dir_path
    fi

    [ ! -f $package_path ] && echo "Error: $package_path not exists" && exit 1

    local file_format=$(__lower__ $(file -b $package_path))    

    [ "$DEBUG" == "true" ] && echo "Info: extracting package $package_path"
    if __in__ "gzip" $file_format >/dev/null;then
        file_format="gzip"
        tar xzf $package_path -C $extract_dir_path
    elif __in__ "xz" $file_format >/dev/null;then
        tar xJf $package_path -C $extract_dir_path
    elif __in__ "bzip2" $file_format >/dev/null;then 
        tar xjf $package_path -C $extract_dir_path
    else
        echo "Error: $file_format is an unsupported format, check $package_path format" 
        exit 1
    fi
}

function install_package_deps {
    local arch=$(uname -m)
    local package_name=""
    local arr=$(declare -p $1)
    local package_regex="[a-zA-Z0-9._-]\\\.$arch *"
    eval "declare -A package_deps=${arr#*=}"
    for package in ${package_deps["package"]}
    do
        [ "$DEBUG" == "true" ] && echo "Info: installing dep package $package"
        yum -q -e 1 -y install $package &>/dev/null
        [ $? -ne 0 ] && echo "Error: some errors happened while installing package $package" && exit 1
    done

    for binary in ${package_deps["binary"]}
    do
        package_name=$(yum whatprovides "*bin/$binary" | \
            awk -F: -v regex="$package_regex" 'BEGIN{r=regex}$1 ~ r{print $1;exit}')
        if [ -n "$package_name" ];then
            [ "$DEBUG" == "true" ] && echo "Info: installing package $package_name"
            yum -q -e 1 -y install $package_name  &>/dev/null
            [ $? -ne 0 ] && echo "Error: some errors happened while installing package $package" && exit 1
        else
            echo "Error: no package_name from yum provides, check package_regex $package_regex"
            exit 1
        fi
    done
}
