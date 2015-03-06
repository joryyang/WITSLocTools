#!/usr/bin/env python
#coding=utf-8
	
import os, sys, re

def tittle():
    print '*' * 70
    print 'You are using the script bfc to create bugfixcomment.'
    print '*' * 70

def splitradars(radars):
    group = radars.replace('<rdar:', 'splitsign<rdar:').split('splitsign')
    group.remove('')
    
    for i in group:
        if '[' and ']' not in i:
            print '## Warning: Can not judge the component of this bug, please process manually.\n%s\n'%i
    
    splited = {}
    components = []
    
    for i in re.findall('[\[0-9a-zA-Z_]+\]', radars):
        if i not in components:
            components.append(i)
    
    for key in components:
        bugs = ''
        for i in group:
            if key in i:
                bugs += i
        
        splited[ key[1:-1] ] = bugs
    
    return splited


def selectDIR():
    i = 1
    print 'a. alvinjim@apple.com\nr. rachel.yu@apple.com\ns. stanleyauyeung@apple.com\nw. wong_alex@apple.com\nq. queenie.chui@apple.com\nPlease select AA DRI.'
    while i:
        s = raw_input('')
        
        if s == 'a':
            return 'alvinjim@apple.com'
            i = 0
        
        if s == 'r':
            return 'rachel.yu@apple.com'
            i = 0
        
        if s == 's':
            return 'stanleyauyeung@apple.com'
            i = 0
        
        if s == 'w':
            return 'wong_alex@apple.com'
            i = 0
        
        if s == 'q':
            return 'queenie.chui@apple.com'
            i = 0
        
        if s == '0':
            sys.exit()
        
        else:
            print 'Please select the listed DIR.'

def bugcomment(path, AADIR):
    s1 = path.find('_LocProj/') + 9
    s2 = path.find('_', s1)
    s3 = path.find('_', s2) + 1
    s4 = path.find('_', s3)
    project = path[s1:s2]
    code = path[s3:s4]
    
    return 'Loc submission for US changes, based on %s %s.\n\n%s'%(project, code, AADIR)


def addcomment(path, AADIR, radars):
    bugs = splitradars(radars)
    bfixpath = path[:path[:-10].rfind('/')+1] + 'MultiLangBugFixComments'
    
    files = {}
    for dir in os.listdir(bfixpath):
        files[dir] = os.path.join(bfixpath, dir)
    
    for key in files:
        f = open(files[key], 'w')
        if key in bugs and 'iWork' not in bugs:
            f.write('Fixed the following bugs:\n%s\n\n'%(bugs[key]))
            f.write(AADIR)
            print 'Fixed the following bugs:\n%s\n\n'%(bugs[key]), AADIR


        elif 'iWork' in bugs and 'Pages' in key and 'Pages' in bugs:
            f.write('Fixed the following bugs:\n%s%s\n\n'%(bugs['iWork'], bugs['Pages']))
            f.write(AADIR)
            print 'Fixed the following bugs:\n%s%s\n\n'%(bugs['iWork'], bugs['Pages']), AADIR

        elif 'iWork' in bugs and 'Pages' in key and 'Pages' not in bugs:
            f.write('Fixed the following bugs:\n%s\n\n'%(bugs['iWork']))
            f.write(AADIR)
            print 'Fixed the following bugs:\n%s\n\n'%(bugs['iWork']), AADIR
        
        elif 'iWork' in bugs and 'Keynote' in key and 'Keynote' in bugs:
            f.write('Fixed the following bugs:\n%s%s\n\n'%(bugs['iWork'], bugs['Keynote']))
            f.write(AADIR)
            print 'Fixed the following bugs:\n%s%s\n\n'%(bugs['iWork'], bugs['Keynote']), AADIR
        
        elif 'iWork' in bugs and 'Keynote' in key and 'Keynote' not in bugs:
            f.write('Fixed the following bugs:\n%s\n\n'%(bugs['iWork']))
            f.write(AADIR)
            print 'Fixed the following bugs:\n%s\n\n'%(bugs['iWork']), AADIR
        
        elif 'iWork' in bugs and 'Numbers' in key and 'Numbers' in bugs:
            f.write('Fixed the following bugs:\n%s%s\n\n'%(bugs['iWork'], bugs['Numbers']))
            f.write(AADIR)
            print 'Fixed the following bugs:\n%s%s\n\n'%(bugs['iWork'], bugs['Numbers']), AADIR
        
        elif 'iWork' in bugs and 'Numbers' in key and 'Numbers' not in bugs:
            f.write('Fixed the following bugs:\n%s\n\n'%(bugs['iWork']))
            f.write(AADIR)
            print 'Fixed the following bugs:\n%s\n\n'%(bugs['iWork']), AADIR
        
        else:
            f.write(bugcomment(path, AADIR))
            print bugcomment(path, AADIR)
        f.close()
    
    for key in files:
        if key in bugs:
            del bugs[key]
        
        if 'iWork' in bugs:
            del bugs['iWork']
    
    for key in bugs:
        if key:
            print '## Warning: You did not work on [%s], please check the releated bugs:%s\n'%(key, bugs[key])
            sys.exit()
    
    if len(bugs) == 0:
        print '*' * 70 + '\nProcess Done! Please create tars and submit asap.\n' + '*' * 70

start='''# progress started\n\n'''
end='''\n\n# progress ended\n'''

print start
tittle()
addcomment(sys.argv[1], sys.argv[2], sys.argv[3])
print end
