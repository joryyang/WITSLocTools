#! /usr/bin/env python
#coding=utf-8

__author__		= "Tiny Liu (tinyliu@wistronits.com)"

import os,sys

start='''echo '# progress started\n\n\''''
end='''echo '\n\n# progress ended\n\''''

os.system('%s'%(start))
os.system('%s %s'%(sys.argv[1], sys.argv[3]))
os.system('%s %s'%(sys.argv[2], sys.argv[3]))
os.system('%s'%(end))