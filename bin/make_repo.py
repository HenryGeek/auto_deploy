#!/usr/bin/env python

import urllib2
from lxml import etree
from urlparse import urljoin
import sys
import os
from pprint import pprint
from multiprocessing import Pool, cpu_count

DEBUG=False
max_process_num = cpu_count() * 5
centos_version = 7
centos_arch = "x86_64"
repo_dir_path = "/toolkit/local_repo"
black_dir_list = ("../", "isos/")
start_url = "http://mirrors.aliyun.com/centos/%s/" % centos_version
to_do_lst = []

def head(full_url):
    request = urllib2.Request(full_url)
    request.get_method = lambda : 'HEAD'
    response = urllib2.urlopen(request)
    return response


def do_log(boolean, err_msg=None, info_msg=None, do_exit=False):
    if not boolean:
        if err_msg:
            print "Error: %s" % err_msg
        if do_exit:
            sys.exit(1)
    elif info_msg:
        print "Info: %s" % info_msg

def make_layout(start_url, start_file_path):
    global black_dir_list
    global to_do_lst
    if DEBUG:
        print("start_url before resp:%s" % start_url)
    try:
        resp = head(start_url)
    except:
        do_log(False, "failed to urlopen %s" % start_url, do_exit=True)
    
    if not str(resp.getcode()).startswith("2"):
        do_log(False, "%s return status code: %s" % str(resp.getcode()), do_exit=True)

    if "Content-type" not in resp.headers:
        do_log(False, "no Content-type header in resp from %s" % start_url,do_exit=True)

    if "html" in resp.headers["Content-type"].lower():
        if not os.path.isdir(start_file_path):
            try:
                os.mkdir(start_file_path)
            except:
                do_log(False, "failed to mdir %s" % start_file_path, do_exit=True)

        try:
            resp = urllib2.urlopen(start_url)
        except:
            do_log(False, "failed to urlopen %s" % start_url)

        tree = etree.HTML(resp.read())
        href_xpath = '//a["href"]/@href'
        hrefs = tree.xpath(href_xpath)
        hrefs = [ x for x in hrefs if x not in black_dir_list ]
        if DEBUG: 
            pprint(hrefs)
        for file_name in hrefs:
            full_url = urljoin(start_url, file_name)
            make_layout(full_url, os.path.join(start_file_path, file_name))
    else:
        to_do_lst.append((start_url, start_file_path))
        pprint(to_do_lst)

def download(file_url, file_path):
    try:
        resp = urllib2.urlopen(file_url)
    except:
        do_log(False, err_msg="failed to urlopen %s" % file_url)

    if not os.path.isfile(file_path):
        with open(file_path, "wb") as fh:
            fh.write(resp.read())
        do_log(False, info_msg="download %s done" % start_file_path)
    else:
        do_log(False, info_msg="%s already exists" % start_file_path)
    

make_layout(start_url, repo_dir_path)
pool = Pool(max_process_num)
pprint(to_do_lst)
