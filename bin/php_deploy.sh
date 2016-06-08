#!/usr/bin/env bash

source ../lib/layout.sh

source $lib_dir_path/package_lib.sh

DEBUG="true"

php_package_url="http://cn2.php.net/distributions/php-5.6.22.tar.bz2"
php_package_name=${php_package_url##*/}
php_build_dir_name=${php_package_name%%.tar.*}
declare -A php_deps
package_deps=("systemtap-sdt-devel" "libxml2-devel" "libpng-devel")
binary_deps=("make" "gcc" "bison")
php_deps["package"]=${package_deps[@]}
php_deps["binary"]=${binary_deps[@]}

get_package $php_package_url $php_package_name
extract_package $php_package_name $build_dir_path
install_package_deps php_deps

cd $build_dir_path/$php_build_dir_name

./configure --prefix=$deploy_root_path/php \
            --bindir=$deploy_root_path/php/bin \
            --sbindir=$deploy_root_path/php/sbin \
            --sysconfdir=$deploy_root_path/php/etc \
            --with-apxs2=$deploy_root_path/httpd/bin/apxs \
            --with-mysql=$deploy_root_path/mysql/ \
            --with-mysqli=mysqlnd \
            --with-pdo-mysql=mysqlnd \
            --with-gettext \
            --with-gd \
            --with-jpeg-dir=/usr \ # just usr not /usr/lib64
            --with-png-dir=/usr \
            --with-freetype-dir=/usr \
            --with-zlib \
            --enable-mbstring=all \
            --enable-bcmath \
            --enable-sockets \
            --enable-cli \
            --enable-cgi \
            --enable-debug \
            --enable-fpm \
            --enable-dtrace 

            
