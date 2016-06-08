#!/usr/bin/env python2.7

import sys
import os
import zlib
import re
from Queue import Queue

class Git_object(object):
    def __init__(self, sha1):
        global objects_dir_path
        dir_name = sha1[0:2]
        file_name = sha1[2:]
        file_path = os.path.join(objects_dir_path, dir_name, file_name)
        
        if os.path.isfile(file_path):
            with open(file_path, "r") as fh:
                content = fh.read()
        else:
            print "Error: %s not exists" % file_path
            sys.exit(1)
        
        obj_content = zlib.decompress(content)
        
        self.sha1 = sha1
        self.trees =  set()
        self.parents = set()
        self.author = "null"
        self.committer = "null"

        known_types = ["commit", "tree", "blob"]
        obj_type = filter(obj_content.startswith, known_types)
        if obj_type:
            self.type = obj_type[0]
        else:
            print """Error: unknown obj type for\n\n%s\n\n""" % obj_content
            sys.exit(1)
       
        self.body = obj_content[len(self.type):]
        self.len, self.body  = [ x.strip() for x in self.body.split("\x00")] 

        for line in self.body.split("\n"):
            if re.match(r"^ *$", line):
                break
            line = line.split()
            if line[0].lower() == "tree":
                self.trees.add(line[1])
            if line[0].lower() ==  "parent":
                self.parents.add(line[1])
            if line[0].lower() == "author":
                self.author = " ".join(line[1:])
            if line[0].lower() == "committer":
                self.committer = " ".join(line[1:])
            
    def __str__(self):
        return """trees: %s
parents: %s
author: %s
committer: %s""" % (str(self.trees), str(self.parents), self.author, self.committer)

    def previous_commit(self):
        return [Git_object(sha1) for sha1 in self.parents] if self.parents else None

dot_git_dir_path  = "/toolkit/salt/.git"
objects_dir_path = os.path.join(dot_git_dir_path, "objects")
cur_head_path = os.path.join(dot_git_dir_path, "HEAD")

if os.path.isfile(cur_head_path):
    with open(cur_head_path, "r") as fh:
        head_ref_file = os.path.join(dot_git_dir_path,fh.read().split(":")[1].strip())
else:
    print "Error: no HEAD in .git"
    sys.exit(1)

if os.path.isfile(head_ref_file):
    with open(head_ref_file, "r") as fh:
        head_commit = fh.read().strip() 
else:
    print "Error: %s not exits, your HEAD point to  nonexistent ref"
    sys.exit(1)

git_obj = Git_object(head_commit)

while True:
    print git_obj.author
    git_obj = git_obj.previous_commit()
    if not git_obj:
        break
    else:
        git_obj = git_obj[0]
