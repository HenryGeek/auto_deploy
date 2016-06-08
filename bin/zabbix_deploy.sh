#!/usr/bin/env bash

source ../lib/layout.sh

source $lib_dir_path/package_lib.sh

DEBUG="true"

zabbix_package_url="http://iweb.dl.sourceforge.net/project/zabbix/ZABBIX%20Latest%20Stable/3.0.3/zabbix-3.0.3.tar.gz"
zabbix_package_name=${zabbix_package_url##*/}
zabbix_build_dir_name=${zabbix_package_name%%.tar.*}
declare -A zabbix_deps
package_deps=("coreutils")
binary_deps=("ps" "gcc")
zabbix_deps["package"]=${package_deps[@]}
zabbix_deps["binary"]=${binary_deps[@]}

get_package $zabbix_package_url $zabbix_package_name
extract_package $zabbix_package_name $build_dir_path
install_package_deps zabbix_deps

[ ! -d $deploy_root_path ] && echo "Error: $deploy_root_path not exists, \
        maybe you don't create user wspace" && exit 1
cd $build_dir_path/$zabbix_build_dir_name

./configure --prefix=$deploy_root_path/zabbix  \
    --with-mysql=$deploy_root_path/mysql/bin/mysql_config \
    --bindir=$deploy_root_path/zabbix/sbin \
    --sbindir=$deploy_root_path/zabbix/bin \
    --sysconfdir=$deploy_root_path/zabbix/etc \
    --enable-server --enable-proxy --enable-agent

make && make install
