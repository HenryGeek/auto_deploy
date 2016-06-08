#!/usr/bin/env python2.7

from __future__ import print_function
from urlparse import urljoin
from lxml import etree
from pprint import pprint
from multiprocessing import Pool, cpu_count
import os
import sys
import urllib2
import mimetypes
import json
import errno

centos_version = 7
start_url = "http://mirrors.aliyun.com/centos/%s/" % centos_version
start_file_path = "/repo/"
black_dir_list = ("repo/" "isos/" "../")
max_process_num = cpu_count() * 10
task = []
retry_task = []
fail_task = []

def do_log(msg, msg_type="error", do_exit=False):
    if msg:
        if msg_type == "error":
            print("Error: %s" % msg)
        elif msg_type == "info":
            print("Info: %s" % msg)
    if do_exit:
        sys.exit(1)

def head(full_url):
    request = urllib2.Request(full_url)
    request.get_method = lambda : 'HEAD'
    try:
        response = urllib2.urlopen(request)
    except:
        return None
    return response
    

def url_walk(start_url, start_file_path):
    global black_dir_list
    global task
    global retry_task

    resp = head(start_url) 
    if not resp:
        retry_task.append((start_url, start_file_path))
        return None
    try:
        content_type = resp.headers["Content-type"]
    except:
        content_type = None

    if not content_type:
        content_type = mimetypes.guess_type(start_url, strict=1)[0]

    if content_type.lower() == "text/html":
        task.append((start_url, start_file_path, "directory"))
        print(len(task))
        try:
            resp = urllib2.urlopen(start_url)
        except:
            retry_task.append((start_url, start_file_path))
            return None
        tree = etree.HTML(resp.read())
        href_xpath = '//a["href"]/@href'
        hrefs = tree.xpath(href_xpath)
        hrefs = [ x for x in hrefs if x not in black_dir_list ]
        for file_name in hrefs:
            full_url = urljoin(start_url, file_name)
            url_walk(full_url, os.path.join(start_file_path, file_name))
    else:
        task.append((start_url, start_file_path, "file"))
        print(len(task))

def makedir(dir_lst):
    for d in dir_lst:
        try:
            os.makedirs(d)
        except OSError as e:
            if e.errno == errno.EEXIST:
                pass
            else:
                do_log(e.message)

def get_file(file_url, file_path):
    if not os.path.isfile(file_path):
        try:
            resp = urllib2.urlopen(file_url, timeout=5)
        except:
            do_log("get_file:failed to get :%s" % file_url)
        
        if resp:
            with open(file_path, "wb") as fh:
                fh.write(resp.read())
        else:
            do_log("get_file:no response from %s" % file_url)
            return None
    else:
        return True
            
        
def main():
    layout_file_path = "/repo/layout.json"
    if not os.path.isfile(layout_file_path):
        url_walk(start_url, start_file_path)
        with open("/toolkit/repo.json", "w") as fh:
            json.dump(task, fh)
    else:
        with open(layout_file_path, "r") as fh:
            task = json.load(fh)

    dir_lst = [x[1] for x in task if x[2] == "directory"]
    makedir(dir_lst)
    file_lst = [x[:2] for x in task if x[2] == "file"]
    pool = Pool(max_process_num)
    for file_url, file_path in file_lst:
        pool.apply_async(get_file, (file_url, file_path))

    pool.close()
    pool.join()

    if any([worker.is_alive() for worker in pool._pool]):
        do_log("some worker not exit")    

    do_log("all done","info")
if __name__ == "__main__":
    main()
            
