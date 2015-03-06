#!/usr/bin/env python
#coding=utf-8

import os, sys

def tittle():
	print '*' * 70
	print 'You are using the script makeautoFtp_plus to create autoFtp-cc.txt.'
	print '*' * 70

def autoftp(path):
    pathEnv = path
    pathinfo = pathEnv + '/Info/Released'
    pathprojects = pathEnv + '/Projects'
    pathprojectsbackup = pathEnv + '/Projects_org' #pathEnv + '/_Backup/Projects'
    uppath = path[:path[:-10].rfind('/')]
    for dir in os.listdir(uppath):
        if dir == '_Logs':
            logspath = os.path.join(uppath, dir)

    for root, dirs, files in os.walk(logspath):
        for file in files:
            if 'checkLocFilesForLocDir' in file:
                report = os.path.join(root, file)


    for dir in os.listdir(path):
        if 'Reports_' in dir and '.zip' not in dir and len(dir) < 11:
            reportfolder = os.path.join(path, dir)
            try:
                os.popen('find %s -name  "*-checkLocFilesForLocDir.txt" -exec rm -R {} \\;'%reportfolder)
                os.popen('ditto %s %s'%(report, reportfolder))
                os.popen('rm -R %s'%pathinfo)
                os.popen('ditto %s %s'%(pathprojectsbackup, pathprojects))
                os.popen('/Developer/WistronITS_Files/makeautoFtp_plus.pl %s'%reportfolder)
                os.popen('rm -R %s'%report) #删除源文件
        
            except UnboundLocalError:
                print 'Please process "Check Loc Files..." first!!'

tittle()
autoftp(sys.argv[1])
