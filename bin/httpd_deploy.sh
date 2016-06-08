#!/usr/bin/env bash

source ../lib/layout.sh

source $lib_dir_path/package_lib.sh

DEBUG="true"

httpd_package_url="http://mirrors.hust.edu.cn/apache/httpd/httpd-2.4.20.tar.bz2"
httpd_package_name=${httpd_package_url##*/}
httpd_build_dir_name=${httpd_package_name%%.tar.*}
declare -A httpd_deps
package_deps=("apr-devel" "apr-util-devel" "pcre-devel")
binary_deps=("make" "gcc")
httpd_deps["package"]=${package_deps[@]}
httpd_deps["binary"]=${binary_deps[@]}

get_package $httpd_package_url $httpd_package_name
extract_package $httpd_package_name $build_dir_path
install_package_deps httpd_deps

[ ! -d $deploy_root_path ] && echo "Error: $deploy_root_path not exists, \
        maybe you don't create user wspace" && exit 1
cd $build_dir_path/$httpd_build_dir_name

./configure --prefix=$deploy_root_path/httpd \
            --bindir=$deploy_root_path/httpd/bin \
            --sbindir=$deploy_root_path/httpd/sbin \
            --sysconfdir=$deploy_root_path/httpd/etc \
            --enable-so \
            --enable-cgi

make && make install
