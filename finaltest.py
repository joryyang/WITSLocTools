#! /usr/bin/env python
#coding=utf-8

import os, sys, re, urllib2, time, linecache
from biplist import *

def tittle():
    print '*' * 70
    print 'You are using the script finallytest to detect you project folder.'
    print '*' * 70

def sysinfo():
    return linecache.getline(r'/System/Library/CoreServices/SystemVersion.plist',6)[9:-10]

def segmentation(text, n):
    return '#' + '=' * 74 + '\n# %s Check Result\n#'%text + '=' * 74 + '%s'%n

def nibs(path):
    nibs = []
    for root, dirs, files in os.walk(path):
        for file in files:
            if 'designable.nib' == file:
                if 'Base.lproj' not in os.path.join(root, file) and 'English.lproj' not in os.path.join(root, file) and '/en.lproj' not in os.path.join(root, file):
                    nibs.append( os.path.join(root, file) )
    return nibs

def stringsfile(path):
    stringsfile = []
    for root, dirs, files in os.walk('%s/GlotEnv/_NewBase'%path):
        for file in files:
            if file[-8:] == '.strings':
                stringsfile.append(os.path.join(root, file))
    return stringsfile

def duplicationkey(stringsfiles):
    duplication = {}; store = []
    for stringsfile in stringsfiles:
        content = open(stringsfile).readlines()
        keys = [re.findall('^"(.*?)" =', i.replace('\x00', '')) for i in content]
        tmp = [['']]
        for key in keys:
            if key not in tmp:
                tmp.append(key)
                try:
                    first = keys.index(key)
                    second = keys.index(key, first+1)
                    if stringsfile in duplication:
                        duplication[stringsfile] += '[Error] line %s: duplicated key [%s] already defined in line: %s\n'%(second+1, key[0], first+1)
                    else:
                        duplication[stringsfile] = '[Error] line %s: duplicated key [%s] already defined in line: %s\n'%(second+1, key[0], first+1)
                except:
                    pass
        # for line in content:
        #     if content.count(line) > 1 and line.count('=') == 1 and '/*' not in line.replace('\x00', '') and '%s%s'%(stringsfile, line) not in store:
        #         store.append('%s%s'%(stringsfile, line))
        #         try:
        #             duplication[stringsfile] += line.replace('\x00', '')
        #         except KeyError:
        #             duplication[stringsfile] = line.replace('\x00', '')
    if not duplication:
        duplication['No problem found'] = ''
    return duplication

def compare(path):
    NL = path + '/GlotEnv/_NewLoc'
    warnings = []; c = 0
    for i in nibs(NL):
        platform = sysinfo()
        checklist = open(i).read()
        try:
            checklist1 = open(i.replace('_NewLoc', '_NewLoc_org')).read()
            systemversion = (re.findall('[1][012345][ABCDEFGHIJK][0-9a-z]+', checklist) + ['null'])[0]
            version = re.findall('version=[0-9".]+', checklist)[1]
            
            if systemversion not in checklist1 and systemversion != platform or version not in checklist1:
                warnings.append( '## Warning: Illicit nib found! Platform: %s, IB tools %s\n%s\n'%(systemversion, version, i[:-15]) )
                c = 1

        except IOError:
            if not os.path.isdir(os.path.dirname(i.replace('_NewLoc', '_NewLoc_org'))):
                warnings.append('## ERROR: Extra nib in LocEnv:\n%s\n'%i[:-15])
                c = 1
    if c == 0:
        warnings.append('No problem found')
    
    return warnings

def dirlist(path, keyword):
    for dirs in os.listdir(path):
        if dirs[:8] == keyword and len(dirs) < 11:
            return os.path.join(path, dirs)

def exportNonGlotableFiles(path):
    glotable = ['nib', 'strings', 'rtf', 'txt', 'html', 'iblabels']
    temp = []
    NewLoc = []; OldLoc = []; NewBase = []; OldBase = []
    for root, dirs, files in os.walk(path):
        for file in files:
            ext = file[file.rfind('.')+1:]
            locfile = os.path.join(root, file)
            if ext not in glotable and '.lproj' in locfile and 'Base.lproj' not in locfile:
                temp.append(locfile)
    
    for i in temp:
        if '_NewBase' in i:
            NewBase.append(i)
        
        if '_OldLoc' in i:
            OldLoc.append(i)
        
        if '_OldBase' in i:
            OldBase.append(i)
        
        if '_NewLoc' in i and 'English.lproj' not in i and 'en.lproj' not in i:
            NewLoc.append(i)
    
    return NewLoc, OldLoc, NewBase, OldBase

def fileContent(file):
    if file[-6:] == '.plist':
        try:
            return readPlist(file)
        except:
            return open(file).read()
    else:
        return open(file).read()

def compareNonGlotableFiles(NL, OL, NB, OB):
    warnings = []; mark = 0
    OldFile = {}; NewFile = {}
    for oldlocfile in OL:
        for oldbasefile in OB:
            if oldlocfile[oldlocfile.find('_OldLoc')+8:].split('/')[:-2] + oldlocfile[oldlocfile.find('_OldLoc')+8:].split('/')[-1:] == oldbasefile[oldbasefile.find('_OldBase')+9:].split('/')[:-2] + oldbasefile[oldbasefile.find('_OldBase')+9:].split('/')[-1:]:
                OldFile[oldlocfile] = oldbasefile
    
    for newlocfile in NL:
        for newbasefile in NB:
            if newlocfile[newlocfile.find('_NewLoc')+8:].split('/')[:-2] + newlocfile[newlocfile.find('_NewLoc')+8:].split('/')[-1:] == newbasefile[newbasefile.find('_NewBase')+9:].split('/')[:-2] + newbasefile[newbasefile.find('_NewBase')+9:].split('/')[-1:]:
                NewFile[newlocfile] = newbasefile
    
    for key in OldFile:
        if os.path.isfile(key.replace('_OldLoc', '_NewLoc')):
            if fileContent(key) <> fileContent(OldFile[key]) and fileContent(key.replace('_OldLoc', '_NewLoc')) == fileContent(NewFile[key.replace('_OldLoc', '_NewLoc')]):
                warnings.append('## Please process Non-glotable file:\n%s\n'%key.replace('_OldLoc', '_NewLoc'))
                mark = 1

        elif not os.path.isfile(key.replace('_OldLoc', '_NewLoc')) and os.path.isfile(OldFile[key].replace('_OldBase', '_NewBase')):
            warnings.append('## Missing Non-glotable file in _NewLoc:\n%s\n'%key.replace('_OldLoc', '_NewBase'))
            mark = 1

    if mark == 0:
        warnings.append('No problem found\n')

    return warnings

def start(path):
    report = open(dirlist(path, 'Reports_') + '/Envtester_Finally.txt', 'a')
    report.write(segmentation('Duplicated key', '\n'))
    print segmentation('Duplicated key', '')
    dup = duplicationkey(stringsfile(path))
    for key in dup:
        report.write('%s\n%s\n'%(key, dup[key]))
        print '%s\n%s'%(key, dup[key])
    report.write(segmentation('Non-Glotable', '\n'))
    print segmentation('Non-Glotable', '')
    a, b, c, d = exportNonGlotableFiles(path+'/GlotEnv')
    for i in compareNonGlotableFiles(a, b, c, d):
        report.write(i + '\n')
        print i
    report.write(segmentation('nib-tools', '\n'))
    print segmentation('nib-tools', '')
    for i in compare(path):
        report.write(i + '\n')
        print i
    report.write('\n' + time.ctime())
    report.close()
start(sys.argv[1])