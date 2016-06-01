#!/usr/bin/env bash

source ../lib/layout.sh

source $lib_dir_path/package_lib.sh

DEBUG="true"

mysql_package_url="http://cdn.mysql.com//Downloads/MySQL-5.7/mysql-5.7.12.tar.gz"
mysql_package_name=${mysql_package_url##*/}
mysql_build_dir_name=${mysql_package_name%%.tar.*}
declare -A mysql_deps
package_deps=("ncurses-devel")
binary_deps=("gcc" "g++" "cmake" "bison")
mysql_deps["package"]=${package_deps[@]}
mysql_deps["binary"]=${binary_deps[@]}

get_package $mysql_package_url $mysql_package_name
extract_package $mysql_package_name $build_dir_path
install_package_deps mysql_deps

boost_package_url="http://pilotfiber.dl.sourceforge.net/project/boost/boost/1.59.0/boost_1_59_0.tar.gz"
boost_package_name=${boost_package_url##*/}
get_package $boost_package_url $boost_package_name
cp -f $cache_dir_path/$boost_package_name $build_dir_path 

[ ! -d $deploy_root_path ] && echo "Error: $deploy_root_path not exists, \
        maybe you don't create user wspace" && exit 1
cd $build_dir_path/$mysql_build_dir_name

mkdir $build_dir_path/$mysql_build_dir_name/_build
cd $build_dir_path/$mysql_build_dir_name/_build
cmake   -D CMAKE_INSTALL_PREFIX=$deploy_root_path/mysql \
        -D CMAKE_INSTALL_SYSCONFDIR=etc \
        -D CMAKE_INSTALL_BINDIR=bin \
        -D CMAKE_INSTALL_SBINDIR=sbin \
        -D DEFAULT_CHARSET=utf8 \
        -D DEFAULT_COLLATION=utf8_general_ci \
        -D WITH_EXTRA_CHARSETS=all \
        -D WITH_INNOBASE_STORAGE_ENGINE=1 \
        -D WITH_MYISAM_STORAGE_ENGINE=1 \
        -D WITH_MEMORY_STORAGE_ENGINE=1 \
        -D WITH_READLINE=1 \
        -D MYSQL_DATADIR=data \
        -D MYSQL_USER=wspace \
        -D CMAKE_C_COMPILER=$(which gcc) \
        -D CMAKE_CXX_COMPILER=$(which g++) \
        -DDOWNLOAD_BOOST=1 -DWITH_BOOST=$build_dir_path/$boost_package_name ..

make && make install



