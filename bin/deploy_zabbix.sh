#!/usr/bin/env bash

source ../lib/layout.sh

source $lib_dir_path/package_lib.sh

DEBUG="true"

zabbix_package_url="http://iweb.dl.sourceforge.net/project/zabbix/ZABBIX%20Latest%20Stable/3.0.3/zabbix-3.0.3.tar.gz"
zabbix_package_name="zabbix-3.0.3.tar.gz"
zabbix_build_dir_name="zabbix-3.0.3"
declare -A zabbix_deps
package_deps=("a" "b" "c")
binary_deps=("d" "e" "f")
zabbix_deps["package"]=${package_deps[@]}
zabbix_deps["binary"]=${binary_deps[@]}

#get_package $zabbix_package_url $zabbix_package_name
extract_package $zabbix_package_name $build_dir_path
install_package_deps zabbix_deps
echo ${new_arr[@]}
