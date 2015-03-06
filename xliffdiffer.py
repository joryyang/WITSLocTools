#! /usr/bin/env python
#coding=utf-8
	
#	File:        glossarytester.py
#
#	Contains:	This script scans xliffs folder to check the glossary mismatch issues.
#
#	Author:        tiny Liu tinyliu@wistronits.com
	
import os
import sys
import linecache
import re
sys.path.append(sys.argv[0][:-14])

def tittle():
    print '*' * 70
    print 'You are using the script to verify your translation improvement.'
    print '*' * 70

def tester(pathEnv, plugins):
    pathGlotEnv = pathEnv + '/GlotEnv'
    path = pathEnv + '/GlotEnv/_Translations'   #Conductor GlotEnv/_Translations 路径
    pathNB = pathEnv + '/GlotEnv/_NewBase'      #path 指向 LocEnv 的 NB
    pathinfo = pathEnv + '/Info'
    pathinfobackup = pathEnv + '/Info_org'
    pathprojects = pathEnv + '/Projects'
    pathprojectsbackup = pathEnv + '/Projects_org'
    pathNL = pathGlotEnv + '/_NewLoc'
    pathNLbackup = pathNL + '_org'
	
    aglangs = {'AB':'ar', 'B':'en_GB', 'BR':'pt_BR', 'CA':'ca', 'CH':'zh_CN', 'CR':'hr', 'CZ':'cs', 'D':'de', 'D_1':'German','DK':'da', 'E':'es', 'FU':'fr', 'GR':'el', 'H':'no', 'HB':'he', 'ID':'id', 'J':'ja', 'K':'fi', 'KH':'ko', 'MG':'hu', 'MY':'ms', 'MX':'es_MX', 'N':'nl', 'PL':'pl', 'PO':'pt_PT', 'RO':'ro', 'RS':'ru', 'S':'sv', 'SL':'sk', 'T':'it', 'TA':'zh_TW', 'TH':'th', 'TU':'tr', 'UA':'uk', 'VN':'vi'}
	
    def getlangs(path):
        ComponentDatas = []
        for root, dirs, files in os.walk(path):
            for ComponentData in files:
                if 'ComponentData.plist' in ComponentData:
                    ComponentDatas.append(os.path.join(root, ComponentData))
        
        if len(ComponentDatas) > 0:
            f = open(ComponentDatas[0], "r")
            for n in range(len(f.readlines())):
                if 'Language' in linecache.getline(r'%s'%ComponentDatas[0],n):
                    return linecache.getline(r'%s'%ComponentDatas[0],n + 1)[9:-10]
            f.close()
        
        else:
            return raw_input('Please enter your language:\n')
	
    yn = getlangs(pathEnv)
	
    reports = pathEnv + '/Reports_%s'%yn
	
    if os.path.isdir(reports):
        pass
    else:
        os.mkdir(reports)
	
    reportpath = reports + '/xliffdiffer_%s.txt'%yn
    report = open(reportpath, "w")
	
	
    def extract(file):
        report.write(file + '\n')
	
        f = open(file, "r")
        xliff = f.read()
        es = {'&gt;':'>', '&quot;':'"', '&apos;':'\'', '&lt;':'<', '&#9;':'    '}  #消除转义字符不同造成的 different
        for key in es:
            xliff = xliff.replace(key, es[key])
        
        s = re.findall('<file [\s\S]*?</file>', xliff)
        string = {}
        for ii in s:
            x = re.findall('<trans-unit [\s\S]*?</trans-unit>', ii)
    
            for i in x:
                a1 = ii.find('origin=') + 8
                a2 = ii.find(' source-language') - 1
                if i.find('" restype=', 16) > i.find('\' restype=', 16):
                    m1 = i.find('" restype=', 16)
                else:
                    m1 = i.find('\' restype=', 16)
                m2 = i.find('<source>') + 8
                m3 = i.find('</source>')
                m4 = i.find('>', i.find('<target')+7) + 1
                if i.rfind('</target>') == -1:
                    m5 = m4
                else:
                    m5 = i.rfind('</target>')
                string[ ii[a1:a2] + '\nid: ' + i[16:m1] ] = '\nUS string: ' + i[m2:m3] + '\nLoc string: ' + i[m4:m5]
    
        return string
	
    def buildVersion(path):
        s1 = path.find('_LocProj/') + 9
        s2 = path.find('_', s1)
        s3 = path.find('_', s2) + 1
        s4 = path.find('_', s3)
        project = path[s1:s2]
        code = path[s3:s4]
        return '%s%s'%(project, code)

    agOL = '/Volumes/ProjectsHD/_AG/AG_%s_%s/_OldLoc'%(yn, buildVersion(pathEnv))
    agNB = '/Volumes/ProjectsHD/_AG/AG_%s_%s/_NewBase'%(yn, buildVersion(pathEnv))
    agOB = '/Volumes/ProjectsHD/_AG/AG_%s_%s/_OldBase'%(yn, buildVersion(pathEnv))
    agTran = '/Volumes/ProjectsHD/_AG/AG_%s_%s/_Translations_org/'%(yn, buildVersion(pathEnv))
    agTran2 = '/Volumes/ProjectsHD/_AG/AG_%s_%s/_Translations/'%(yn, buildVersion(pathEnv))
	
    def appleglot(plugins):
        if yn in aglangs:
            os.system('/usr/local/bin/appleglot -d . -x create')
            os.system('/usr/local/bin/appleglot setlangs en %s'%(aglangs[yn]))
            os.system('/usr/local/bin/appleglot getlangs')
            os.system('ditto %s %s'%(pathNL, agOL))
            os.system('ditto %s %s'%(pathNL, agNB))
            os.system('ditto %s %s'%(pathNL, agOB))
            os.system('find %s -name "*.xliff" -exec ditto {} %s \;'%(path, agTran))
            os.system('/usr/local/bin/appleglot -d . -x populate %s'%plugins)
        else:
            print 'Please select the correct langs code, such as D, RS, TU..'
            sys.exit()

    _ag = '/Volumes/ProjectsHD/_AG'
    if os.path.isdir(_ag):
        pass
    
    else:
        os.mkdir(_ag)

    ag = '/Volumes/ProjectsHD/_AG/AG_%s_%s'%(yn, buildVersion(pathEnv))
    if os.path.isdir(ag):
        os.system('rm -R %s'%ag)
        os.mkdir(ag)
    else:
        os.mkdir(ag)
	
    os.chdir(ag)    #指向到 AG 环境
    open('plugins', 'w').write(plugins)

    appleglot(plugins)

    xlifffiles = []
    xlifffiles2 = []
    for dir in os.listdir(agTran):
        xlifffiles.append(os.path.join(agTran, dir))

    for i in xlifffiles:
        i2 = i.replace('_Translations_org', '_Translations')
        s1 = extract(i)
        s2 = extract(i2)
        for key in s1:
            if key in s2 and s1[key] == s2[key]:
                pass

            elif key not in s2:
                print i
                print 'Missed translation:\n%s%s\n'%(key, s1[key])
                report.write('Missed translation:\n%s%s\n\n'%(key, s1[key]))

            elif key in s2 and s1[key] <> s2[key] and '\\rtf1\\ansi' not in s1[key]:
                print i
                print 'Translation mismatch:\n%s\nOriginal: %s\nNow: %s\n'%(key, s1[key], s2[key])
                report.write('Translation mismatch:\n%s\nOriginal: %s\nNow: %s\n\n'%(key, s1[key], s2[key]))

        for key in s2:
            if key in s1 and s1[key] == s2[key]:
                pass
                    
            elif key not in s1:
                print i2
                print 'Extra translation in your Env:\n%s%s\n'%(key, s2[key])
                report.write('Extra translation in your Env:\n%s%s\n\n'%(key, s2[key]))

    report.write('\nProcess done.\n\nxliffdiffer version: 2.0')

start='''# progress started\n\n'''
end='''\n\n# progress ended\n'''

tittle()
tester(sys.argv[1], sys.argv[2])
print end

'''
1, OSX, Server, iTunes, Remote Desktop, iWork, iBook: null
2, ProApps, iPhoto, iMovie: -g /AppleInternal/Library/EmbeddedFrameworks/ProKit/EmbeddedProKit.ibplugin -g /AppleInternal/Library/EmbeddedFrameworks/ProApps/IBPlugIns/LunaKitEmbedded.ibplugin
3, GarageBand: -g /AppleInternal/Developer/Plugins/MAToolKitLogicIBPlugIn.ibplugin
4, Enter other plugins: user enters'''