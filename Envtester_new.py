#! /usr/bin/env python
#coding=utf-8

#	File:		Envtester_Finally.py
#
#	Contains:	This script scans LocEnv to check Mailnotify, parameters issues, new strings in xliffs,
#               Locversion.plist issues and execute other commands for loc engineering.
#
#	Author:		Tiny Liu tinyliu@wistronits.com Please contact me if you have any suggestion or feedback.


'''
    This script scans LocEnv to check Mailnotify, parameters issues, new strings in xliffs and Locversion.plist issues and execute other commands for loc engineering.
'''

# strings for info commands
__author__		= "Tiny Liu (tinyliu@wistronits.com)"
__version__		= "$Revision: custom $"[11:-2]
__date__		= "$Date: 2014-10-10 $"[7:-2]
__copyright__	= "Wistron ITS"

import os, sys
sys.path.append(os.path.dirname(__file__))
from Envtester_base import *

def main(pathEnv, states): # autoFtp
    pathGlotEnv = pathEnv + '/GlotEnv'
    pathxliff = pathEnv + '/GlotEnv/_Translations'
    pathNB = pathEnv + '/GlotEnv/_NewBase'
    pathinfo = pathEnv + '/Info'
    pathmailnotify = pathEnv + '/Info/MailNotify'
    pathprojects = pathEnv + '/Projects'
    pathNL = pathGlotEnv + '/_NewLoc'
    pathcomponentData = pathEnv + '/GlotEnv/_ComponentData'
    
    os.popen('find %s -name ".marking" -exec rm -R {} \;'%pathEnv)
    
    langs, OldLocUpdate, NewLocupdate = getlangs(pathcomponentData)
    createfolder('%s/Reports_%s'%(pathEnv, langs))
    if checkxliffdiffer('%s/Reports_%s'%(pathEnv, langs)) and states == 'on':
        appleglot(langs, '/Volumes/ProjectsHD/_AG/AG_%s_%s/plugins'%(langs, buildVersion(pathEnv)), pathNL, '/Volumes/ProjectsHD/_AG/AG_%s_%s_finally'%(langs, buildVersion(pathEnv)))
        pathxliff = '/Volumes/ProjectsHD/_AG/AG_%s_%s_finally/_Translations'%(langs, buildVersion(pathEnv)) #'/Volumes/ProjectsHD/_AG/AG_%s_check/_Translations'%langs | pathxliff
    
    report = open('%s/Reports_%s/Envtester_Finally.txt'%(pathEnv, langs), 'w+')
    report1 = open('%s/Reports_%s/untranslation.txt'%(pathEnv, langs), 'w+')
    report.write('\nLoc Eng based on %s for US update, leverage from %s.\n\n'%(NewLocupdate, OldLocUpdate))
    #    report = open('%s/Reports_%s/Envtester_%s_test.txt'%(pathEnv, langs, langs), 'w+')
    xliffs = []
    for root, dirs, files in os.walk(pathxliff):
        for file in files:
            if '.xliff' in file:
                xliffs.append(os.path.join(root, file))
    
    print segmentation('parameters', '')
    report.write(segmentation('parameters', '\n'))
    report1.write(segmentation('untranslated', '\n'))
    macs = []; years = []
    for i in xliffs:
        mac, year, arg, dntcontents = start(i)
        for warning in arg:
            print warning
            report.write('%s\n'%warning)
        macs += mac
        years += year

        for dntcontent in dntcontents:
            report1.write('%s\n'%dntcontent)

    print segmentation('Mac OS X', '')
    report.write(segmentation('Mac OS X', '\n'))
    if macs:
        for warning in macs:
            print warning
            report.write('%s\n'%warning)
    else:
        print 'No problem found\n'
        report.write('No problem found\n\n')

    print segmentation('year', '')
    report.write(segmentation('year', '\n'))
    if years:
        for warning in years:
            print warning
            report.write('%s\n'%warning)
    else:
        print 'No problem found\n'
        report.write('No problem found\n\n')

    print segmentation('xliff', '')
    report.write(segmentation('xliff', '\n'))
    k1 = 0; k2 = 0; k3 = 0
    for i in xliffs:
        keywords = TransState(i, 'state="new', 'state=\'new', 'needs-review-translation', 'signed-off')
        k1 += keywords['state="new'] + keywords['state=\'new']
        k2 += keywords['needs-review-translation']
        k3 += keywords['signed-off']
    print 'New strings: %s\nNeeds-review-translation strings: %s\nSigned-off strings: %s\n'%(k1, k2, k3)
    report.write('New strings: %s\nNeeds-review-translation strings: %s\nSigned-off strings: %s\n\n'%(k1, k2, k3))
    
    print segmentation('Locversion.plist', '')
    report.write(segmentation('Locversion.plist', '\n'))
    c = 1
    for i in checklocversion(pathNB).split('locversion.plist')[:-1]:
        print 'Missing Locversion.plist\n%s\n'%i
        report.write('Missing Locversion.plist\n%s\n\n'%i)
        c = 0
    if c != 0:
        print 'No problem found\n'
        report.write('No problem found\n\n')
    
    print segmentation('MailNotify', '')
    report.write(segmentation('MailNotify', '\n'))
    if checkmailnotify(pathmailnotify):
        backupfolder1(pathinfo)
        backupfolder1(pathprojects)
        backupfolder(pathNL)
        print 'No problem found\n'
        report.write('No problem found\n\n')
    
    else:
        print '## ERROR: Please process your MailNotify.\n'
        report.write('## ERROR: Please process your MailNotify.\n\n')

main(sys.argv[1], sys.argv[2]) # pathEnv, on/off