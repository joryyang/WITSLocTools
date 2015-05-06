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

import os, sys, re, linecache, urllib2, time, shutil

#shutil.rmtree(dir) 删除多层目录

def tittle():
    print '*' * 70
    print 'You are using the script Envtester to detect you project folder.'
    print '*' * 70

def segmentation(text, n):
    return '#' + '=' * 74 + '\n# %s Check Result\n#'%text + '=' * 74 + '%s'%n

def backupfolder(folder):
    if os.path.isdir(folder + '_org'):
        pass
    else:
        os.popen('ditto %s %s'%(folder, folder + '_org'))

def backupfolder1(folder):
    if os.path.isdir(folder[:folder.rfind('/')] + '/_Backup%s'%(folder[folder.rfind('/'):])):
        pass
    else:
        os.popen('ditto %s %s'%(folder, folder[:folder.rfind('/')] + '/_Backup%s'%(folder[folder.rfind('/'):])))

def createmailnotify():
    return 'locsubmits@group.apple.com, stanleyauyeung@apple.com, queenie.chui@apple.com, rachel.yu@apple.com, alvinjim@apple.com, wong_alex@apple.com, Leaders.Apple@wistronits.com'

def dntlist(url):
    try:
        response = urllib2.urlopen(url, timeout = 5)
        return response.read().split('\n')
    except urllib2.URLError:
        return []

def createfolder(folder):
    if os.path.isdir(folder):
        pass
    else:
        os.mkdir(folder)

def checklocversion(path):
    lproj = []
    s = ''
    for root, dirs, files in os.walk(path):
        for dir in dirs:
            if '.lproj' in dir:
                lproj .append( os.path.join(root, dir+'/locversion.plist') )
    
    for i in lproj:
        if not os.path.isfile(i):
            s += i
    return s

def checkmailnotify(mailnotify):
    if 'stanleyauyeung' in open(mailnotify).read():
        return True

def locstrings(xliff):
    strings = []
    usstrings = []
    locstrings = []
	
    s = re.findall('<file [\s\S]*?</file>', open(xliff).read())
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
            singed = 'off' if 'signed-off' in i else 'ffo'

            strings.append(ii[a1:a2] + '\nid: ' + i[16:m1] + '\nUS string: ' + i[m2:m3] + '\nLoc string: ' + i[m4:m5] + '\n' + singed)
    return strings

def getlangs(path):
    OldLocUpdate = 'null'
    langs = path.split('/')[5][:path.split('/')[5].find('-')]
    ComponentDatas = []
    for root, dirs, files in os.walk(path):
        for ComponentData in files:
            if 'ComponentData.plist' in ComponentData:
                ComponentDatas.append(os.path.join(root, ComponentData))
    
    if len(ComponentDatas) > 0:
        f = open(ComponentDatas[0], 'r')
        for n in range(len(f.readlines())):
            if 'OldLocUpdate' in linecache.getline(r'%s'%ComponentDatas[0],n):
                OldLocUpdate = linecache.getline(r'%s'%ComponentDatas[0],n + 1)[9:-10]
        f.close()
    
    NewLocupdate = path[29:].split('_')[0] + path[29:].split('_')[1]
    return langs, OldLocUpdate, NewLocupdate

def TransState(file, keyword, keyword1, keyword2, keyword3):
    state = {}
    checkfile = open(file).read()
    state[keyword] = checkfile.count(keyword)
    state[keyword1] = checkfile.count(keyword1)
    state[keyword2] = checkfile.count(keyword2)
    state[keyword3] = checkfile.count(keyword3)
    return state

def checkxliffdiffer(reportfolder):
    for dir in os.listdir(reportfolder):
        if 'xliffdiffer_' in dir:
            return 1

def appleglot(lang, plugin, pathNL, pathag):
    pluginlist = {1:'', 2:'-g /AppleInternal/Library/EmbeddedFrameworks/ProKit/EmbeddedProKit.ibplugin -g /AppleInternal/Library/EmbeddedFrameworks/ProApps/IBPlugIns/LunaKitEmbedded.ibplugin', 3:'-g /AppleInternal/Developer/Plugins/MAToolKitLogicIBPlugIn.ibplugin'}
    aglangs = {'AB':'ar', 'B':'en_GB', 'BR':'pt_BR', 'CA':'ca', 'CH':'zh_CN', 'CR':'hr', 'CZ':'cs', 'D':'de', 'D_1':'German','DK':'da', 'E':'es', 'FU':'fr', 'GR':'el', 'H':'no', 'HB':'he', 'ID':'id', 'J':'ja', 'K':'fi', 'KH':'ko', 'MG':'hu', 'MY':'ms', 'MX':'es_MX', 'N':'nl', 'PL':'pl', 'PO':'pt_PT', 'RO':'ro', 'RS':'ru', 'S':'sv', 'SL':'sk', 'T':'it', 'TA':'zh_TW', 'TH':'th', 'TU':'tr', 'UA':'uk', 'VN':'vi'}

    if os.path.isfile(plugin):
        plugins = open(plugin).read()
    else:
        plugins = pluginlist[ input('1, OSX, Server, iTunes, Remote Desktop, iWork, iBook\n2, ProApps, iPhoto, iMovie\n3, GarageBand\n4, Enter other plugins\nPlease select your project: ') ]

    if os.path.isdir(pathag):
        os.system('rm -R %s'%pathag)
        time.sleep(0)
        os.makedirs(pathag)
    else:
        os.makedirs(pathag)

    os.chdir(pathag)
    agOL = pathag + '/_OldLoc'
    agNB = pathag + '/_NewBase'
    agOB = pathag + '/_OldBase'
    os.system('/usr/local/bin/appleglot -d . -x create')
    os.system('/usr/local/bin/appleglot setlangs en %s'%(aglangs[lang]))
    os.system('/usr/local/bin/appleglot getlangs')
    os.system('ditto %s %s'%(pathNL, agOL))
    os.system('ditto %s %s'%(pathNL, agNB))
    os.system('ditto %s %s'%(pathNL, agOB))
    os.system('/usr/local/bin/appleglot -d . -x populate %s'%plugins)

def addorder(source):
    return [source[i] if '$' in source[i] else source[i].replace('%', '%%%s$'%(i+1)) for i in range(len(source))]

def parameters(us, loc):
    checklist = ['Mac OS X', '^b', '^b\n', '\f', '^', '^0', '^1', '^2', '^3', '^4', '%TRACKNAME', '%a', '%b', '%c', '%e', '%f', '%g', '%h', '%j', '%k', '%m', '%n', '%o', '%p', '%q', '%r', '%t', '%v', '%w', '%x', '%y', '%z'] # ignored: '%'
    checklist1 = ['%@', '%d', '%S', '%s', '%u', '%lld', '%ld', '%l', '%i']
    checklist2 = ['%1$', '%2$', '%3$', '%4$', '%5$', '%6$', '%7$']
    for i in checklist:
        loc = loc.replace('\xc2\xa0', ' ')
        us = us.replace('\xc2\xa0', ' ')
        if us.count(i) != loc.count(i):
            return i

    for i in checklist1:
        if len( re.findall('%%[0-9]\$%s'%i[1:], us) ) + us.count(i) != len( re.findall('%%%s[0-9]?'%i[1:], loc) ) + len( re.findall('%%[0-9]\$%s'%i[1:], loc) ):
            return 'number of %s mismatch'%i
        elif len( re.findall('%%[0-9]\$%s'%i[1:], loc) ) > 0 and loc.count(i) > 0:
            return i + ' partly ordered'
        elif len( re.findall('%%%s[0-9]'%i[1:], loc) ) != loc.count(i) and len( re.findall('%%%s[0-9]'%i[1:], loc) ) > 0:
            return i + ' .js file'

    for i in checklist2:
        if us.count(i) != loc.count(i) and us.count(i) > 0:
            return 'number of %s mismatch'%i
        elif us.count(i) != loc.count(i) and loc.count(i) > 1:
            return i + ' duplicate order'

    for i in re.findall('(?<![Un])19[89][0-9]|(?<![Un])20[01][0-9]', us):
        if i not in loc.replace('٠', '0').replace('١', '1').replace('٢', '2').replace('٣', '3').replace('٤', '4').replace('٥', '5').replace('٦', '6').replace('٧', '7').replace('٨', '8').replace('٩', '9') and '{\\rtf1\\ansi\\' not in us:
            return 'year'

    if sorted(addorder(re.findall('%[0-9$.]+[a-zA-Z@]|%[a-zA-Z@]', us))) != sorted(addorder(re.findall('%[0-9$.]+[a-zA-Z@]|%[a-zA-Z@]', loc))):
        return 'misplaced order'

def untranslatedtester(us, loc, dnt):
    if loc[-3:] == 'ffo':
        return
    else:
        loc = loc[:-3]
    dnt.sort(key=lambda x:len(x))
    try:
        for i in dnt:
            if 'DNL' not in us and 'T LOCALIZE' not in us.upper():
                if us.replace(i, '')[11:] == loc.replace(i, '')[12:] and len(re.findall('[a-zA-Z]', us.replace(i, '')[11:])):
                    return 1
    except NameError:
        pass

def dnttester(us, loc, dnt):
    try:
        for i in dnt:
            if i in us:
                if len(re.findall('\W%s\W'%i, us)) != len(re.findall('\W%s\W'%i, loc)):
                    return i
    except NameError:
        pass


def start(files):
    macResult = []; yearResult = []; argsResult = []; dntcontent = []
    dnttester = []
    dnt = dntlist('http://10.4.2.6/dntlist')
    dnt1 = dntlist('http://10.4.2.6/dnt')

    for i in locstrings(files):
        start = i.find('US string: ')
        end = i.find('Loc string: ')
        checkresult = parameters( i[start:end], i[end:-3] )
        if  checkresult:
            if checkresult == 'Mac OS X':
                macResult.append('%s\n%s'%(files, i[:-3]))
            
            elif checkresult == 'year':
                yearResult.append('%s\n%s'%(files, i[:-3]))
            
            else:
                argsResult.append('%s\n%s## %s.\n'%(files, i[:-3], checkresult))
    
        if untranslatedtester( i[start:end], i[end:], dnt1 ):
            dntcontent.append('%s%s'%(files[files.rfind('/')+1:-6], i[start+9:end]))

    dntcontent.sort(key=lambda x:len(x))

#        if dnttester(us, loc, dnt1):
#            dnttester.append('%s\n%s'%(files, i))

    if not argsResult:
        argsResult.append('%s\nNo problem found\n'%files)
    if not dntcontent:
        dntcontent.append('%s\nNo problem found\n'%files)

    return macResult, yearResult, argsResult, dntcontent[::-1]

def buildVersion(path):
    s1 = path.find('_LocProj/') + 9
    s2 = path.find('_', s1)
    s3 = path.find('_', s2) + 1
    s4 = path.find('_', s3)
    project = path[s1:s2]
    code = path[s3:s4]
    return '%s%s'%(project, code)

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

def main2(pathEnv):# Envtester_beta
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
    report = open('%s/Reports_%s/Envtester_%s.txt'%(pathEnv, langs, langs), 'w+')
    report1 = open('%s/Reports_%s/untranslation.txt'%(pathEnv, langs), 'w+')
    report.write('\nLoc Eng based on %s for US update, leverage from %s.\n\n'%(NewLocupdate, OldLocUpdate))
    #    report = open('%s/Reports_%s/Envtester_%s.txt'%(pathEnv, langs, langs), 'w+') | report = open('%s/Reports_%s/Envtester_Finally.txt'%(pathEnv, langs), 'w+')
    xliffs = []
    for root, dirs, files in os.walk(pathxliff): #'/Volumes/ProjectsHD/_AG/AG_%s_check/_Translations'%langs | pathxliff
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
    if not checkmailnotify(pathmailnotify):
        open(pathmailnotify, 'w').write(createmailnotify())
    if checkmailnotify(pathmailnotify):
        backupfolder1(pathinfo)
        backupfolder1(pathprojects)
        backupfolder(pathNL)
        print 'No problem found\n'
        report.write('No problem found\n\n')
    
    else:
        print '## ERROR: Please process your MailNotify.\n'
        report.write('## ERROR: Please process your MailNotify.\n\n')
    report.write('\nEnvtester verison: 4.0')

def test(path):
    xliffs = []
    for root, dirs, files in os.walk(path):
        for file in files:
            if '.xliff' in file:
                xliffs.append(os.path.join(root, file))
    
    print segmentation('parameters', '')
    for i in xliffs:
        warnings, dntcontents = start(i)
        for warning in warnings:
            print warning

def parameterstester(pathxliff):
    xliffs = []
    for root, dirs, files in os.walk(pathxliff): #'/Volumes/ProjectsHD/_AG/AG_%s_check/_Translations'%langs | pathxliff
        for file in files:
            if '.xliff' in file:
                xliffs.append(os.path.join(root, file))
    
    print segmentation('parameters', '')
    for i in xliffs:
        warnings, dntcontents = start(i)
        for warning in warnings:
            print warning
main2(sys.argv[1])