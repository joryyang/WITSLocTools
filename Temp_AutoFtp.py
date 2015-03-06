#! /usr/bin/env python
#coding=utf-8

__author__		= "Tiny Liu (tinyliu@wistronits.com)"

import os,sys

start='''echo '# progress started\n\n\''''
end='''echo '\n\n# progress ended\n\''''

os.system('%s'%(start))
os.system('%s %s'%(sys.argv[1], sys.argv[4])) #autoFtp + LocEnv
os.system('%s %s %s'%(sys.argv[2], sys.argv[4],sys.argv[5])) #Envtester_new + LocEnv
os.system('%s %s'%(sys.argv[3], sys.argv[4])) #finaltest + LocEnv
os.system('%s'%(end))