#!/usr/bin/env python
#coding=utf-8

__author__= 'Tiny Liu (tinyliu@wistronits.com)'

import os, sys, linecache

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

def returnState(LocEnv):
    state = []
    for dir in os.listdir('%s/GlotEnv/_ComponentData'%LocEnv):
        if dir <> '.DS_Store':
            state.append( '%s\t%s'%(formatComponentDataFile('%s/ComponentData.plist'%os.path.join('%s/GlotEnv/_ComponentData'%LocEnv, dir)), dir) )
    return state

def checksum(LocEnv):
    missingComponentData = []
    for dir in os.listdir('%s/GlotEnv/_NewLoc'%LocEnv):
        if dir not in os.listdir('%s/GlotEnv/_ComponentData'%LocEnv) and dir <> '.DS_Store':
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