#!/usr/bin/env python
#coding=utf-8

__author__= 'Tiny Liu (tinyliu@wistronits.com)'

import ftplib, socket, os, sys, linecache

def listFtpDir(projName, OldLocUpdate, lang, component, server='10.4.1.13'):
    ftp = ftplib.FTP()
    try:
        ftp.connect(server, timeout=3)
        ftp.login('tiny', '123456')
    except socket.error, e:
        print e
    except ftplib.error_perm, e:
        print e
    ToAALists = ['/OutBox/ToAppleAsia/ToAlvin', '/OutBox/ToAppleAsia/ToRachel', '/OutBox/ToAppleAsia/ToStanley', '/OutBox/ToAppleAsia/ToAlex']
    for ToAA in ToAALists:
        ftp.cwd(ToAA)
        projFolderList = ftp.nlst()
        if projName not in projFolderList:
            continue
        ftp.cwd(projName)
        submitted = ftp.nlst()
        submitted.sort(key=lambda x:len(x if x[-1].isdigit() else x[:-1]))
        index = submitted.index(OldLocUpdate)+1 if OldLocUpdate in submitted else 0
        for i in submitted[index:]:
            target = '%s/%s/%s'%(ToAA, projName, i)
            ftp.cwd(target)
            for tgz in ftp.nlst():
                if component in tgz and '_%s_'%lang in tgz:
                    return tgz
        break

# print listFtpDir('Gala', '15A168a', 'DK', 'AppKit')

def formatComponentDataFile(file):
    trustModel = {'0':'TRUST:OFF*', '1':'TRUST:ON', 'null':'TRUST:UNKNOWN'}
    OldLocUpdate = 'null'; TrustLocSubmission = 'null'; Update = file[29:].split('_')[0] + file[29:].split('_')[1]
    
    for n in range(len(open(file).readlines())):
        if 'OldLocUpdate' in linecache.getline(file, n):
            OldLocUpdate = linecache.getline(file, n+1)[9:-10]

        if 'TrustLocSubmission' in linecache.getline(file, n):
            TrustLocSubmission = trustModel[linecache.getline(file, n+1)[9:-10]]

    if OldLocUpdate == 'null':
        OldLocUpdate = '%s*'%Update
    
    return '%s\t%s\t%s\t'%(OldLocUpdate, Update, TrustLocSubmission)

def splitVersion(string):
    string = string.split()[0]
    proj = ''
    while not string[0].isdigit():
        proj += string[0]
        string = string[1:]
    return proj, string

def buildVersion(path):
    s1 = path.find('_LocProj/') + 9
    s2 = path.find('_', s1)
    s3 = path.find('_', s2) + 1
    s4 = path.find('_', s3)
    project = path[s1:s2]
    code = path[s3:s4]
    return project

def returnState(LocEnv):
    state = []
    lang = LocEnv.split('/')[5][:LocEnv.split('/')[5].find('-')]
    for dir in os.listdir('%s/GlotEnv/_ComponentData'%LocEnv):
        if dir != '.DS_Store':
            info = formatComponentDataFile('%s/ComponentData.plist'%os.path.join('%s/GlotEnv/_ComponentData'%LocEnv, dir))
            proj, version = splitVersion(info)
            if not proj:
                proj = buildVersion(LocEnv)
            tar = listFtpDir(proj, version, lang, dir)
            if tar:
                state.append( '%s ## Integration: %s'%(info, tar) )
            else:
                state.append( '%s\t%s'%(info, dir) )
    return state

def checksum(LocEnv):
    missingComponentData = []
    for dir in os.listdir('%s/GlotEnv/_NewLoc'%LocEnv):
        if dir not in os.listdir('%s/GlotEnv/_ComponentData'%LocEnv) and dir != '.DS_Store':
            missingComponentData.append('%s: Missing ComponentData.'%dir)
    return missingComponentData

lang = sys.argv[1].split('/')[5][:sys.argv[1].split('/')[5].find('-')]
report = '%s/Reports_%s/ComponentData.txt'%(sys.argv[1], lang)
open(report, 'w').write('#' + '=' * 74 + '\n# ComponentData Check Result\n#' + '=' * 74 + '\n')

for i in checksum(sys.argv[1]):
    print i
    open(report, 'a').write('%s\n'%i)

for i in returnState(sys.argv[1]):
    print i
    open(report, 'a').write('%s\n'%i)