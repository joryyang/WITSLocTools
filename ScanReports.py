#! /usr/bin/env python
#coding=utf-8

__author__ = 'Tiny'

import os, sys, re, time, smtplib
from socket import *
from email.mime.multipart import MIMEMultipart
from email.mime.text import MIMEText
from email.mime.image import MIMEImage

def client(locenv, script):
    try:
        s = socket(AF_INET, SOCK_STREAM)
        s.connect(('10.4.2.6', 8989))
        s.send('%s process script %s in %s'%(time.strftime("%Y-%m-%d %H:%M:%S", time.localtime()) , script, locenv))
        s.close()
    except:
        pass

def mailto(receiver, subject, content, files=[]):
    if not receiver:
        return
    msg = MIMEMultipart()
    msg.attach(MIMEText(content))
    for file in files:
        msg.attach(MIMEImage(open(file).read()))
        msg.attach(MIMEText('\n\n'))
    
    sender = 'tinyliu@wistronits.com'
    msg['Subject'] = subject
    msg['From'] = sender
    msg['To'] = receiver
    
    try:
        s = smtplib.SMTP('10.1.100.47')
        s.sendmail(sender, receiver.split(';'), msg.as_string())
        s.quit()
    except:
        pass

def formateReports(folder):
    dir = []
    for root, dirs, files in os.walk(folder):
        dir += dirs
    if 'TarOut' not in dir:
        return
    for root, dirs, files in os.walk(folder):
        for file in files:
            if 'Reports_' in file:
                os.chdir(os.path.join(root, file)[:os.path.join(root, file).rfind('Reports')])
                os.system('tar zxf %s'%(os.path.join(root, file)))

    for root, dirs, files in os.walk(folder):
        for file in files:
            if '.txt' in file:
                path = os.path.join(root, file)
                os.system('ditto %s %s'%(path, path[:path.rfind('/Report')]))

    os.system('find %s -name "TarOut" -exec rm -R {} \;'%folder)
    os.system('find %s -name "Reports?*" -exec rm -R {} \;'%folder)
    os.system('find %s -name "__MACOSX" -exec rm -R {} \;'%folder)

def checkSubmission(GlotEnv):
    if not os.path.isdir(GlotEnv):
        return
    locLproj = []
    componentList = [i for i in os.listdir('%s/_NewLoc_org'%GlotEnv) if i!='.DS_Store']
    for root, dirs, files in os.walk('%s/_OldLoc'%GlotEnv):
        for dir in dirs:
            if '.lproj' in dir and dir not in locLproj:
                locLproj.append(dir)
                break
    # locLproj = ['ar.lproj', 'es.lproj', 'de.lproj', 'ko.lproj', 'no.lproj', 'ca.lproj', 'German.lproj', 'tr.lproj', 'vi.lproj', 'nl.lproj', 'cs.lproj', 'sv.lproj', 'en_GB.lproj', 'it.lproj', 'pt_BR.lproj', 'he.lproj', 'hr.lproj', 'id.lproj', 'el.lproj', 'da.lproj', 'hu.lproj', 'zh_CN.lproj', 'ru.lproj', 'pt_PT.lproj', 'uk.lproj', 'fr.lproj', 'es_MX.lproj', 'pl.lproj', 'th.lproj', 'sk.lproj', 'ro.lproj', 'ms.lproj', 'fi.lproj', 'ja.lproj', 'zh_TW.lproj', 'Dutch.lproj', 'English.lproj', 'French.lproj', 'Italian.lproj', 'Japanese.lproj', 'pt.lproj', 'Spanish.lproj']
    locFiles = []
    for root, dirs, files in os.walk('%s/_NewLoc_org'%GlotEnv):
        for file in files:
            if file != 'locversion.plist':
                locFile = os.path.join(root, file)
                for l in locLproj:
                    if l in locFile:
                        locFiles.append(locFile)
    NewLocFiles = [i for i in locFiles if os.path.isfile(i)]
    submitComponent = []; Identical = []
    for i in NewLocFiles:
        states = 1
        try:
            if os.path.exists(i.replace('_NewLoc_org', '_OldLoc')) and open(i).read() == open(i.replace('_NewLoc_org', '_OldLoc')).read() == open(i.replace('_NewLoc_org', '_NewLoc')).read():
                states = 0
        except error:
            if os.path.exists(i.replace('_NewLoc_org', '_OldLoc')) and os.stat(i).st_mtime == os.stat(i.replace('_NewLoc_org', '_OldLoc')).st_mtime == os.stat(i.replace('_NewLoc_org', '_NewLoc')).st_mtime:
                states = 0
        except:
            pass
        if states:
            Submit = re.findall('_NewLoc_org/(.*?)/', i)[0]
            if Submit not in submitComponent:
                submitComponent.append(Submit)
    for c in componentList:
        if c not in submitComponent:
            Identical.append(c)
    return Identical

def excludes(string):
    for i in ['ibMirrorLayoutDirectionWhenInternationalizing', 'ibExternalSetsMaxLayoutWidthAtFirstLayout', 'autoresizingMask', 'autoresizesSubviews', 'ibExternalWasMisplacedOnLastSave', 'ibExternalHadAnyAmbiguityOnLastSave', 'ibExternalUserDefinedRuntimeAttributes\n', 'insertionPointColor\n', 'alignment\n', 'titleWidth\n', ', width\n', 'wantsLayer\n', 'doubleValue\n']:
        if i in string:
            return
    return 1

def extractKeyword(string, keyword):
    return string[string.rfind(keyword)+len(keyword):string.find('\n', string.rfind(keyword))]

def scanFlverifierFilteredReport(file, extra):
    states = []; translation = []
    reports = open(file).read().decode('utf16').replace('\x00', '').encode('utf8')
    for i in re.findall('\t[0-9a-zA-Z-]+,[\s\S]*?NL:[\s\S]*?\n', reports):#|<file://localhost/[\s\S]*?NL:[\s\S]*?\n
        if 0 < len(re.findall('[-0-9]+',extractKeyword(i, 'NB:'))) < 2 and excludes(i):
            if extractKeyword(i, 'NB:') != extractKeyword(i, 'NL:') and len(extractKeyword(i, 'NB:')) < 3:
                states.append(re.sub('<nib://[\s\S]+_NewBase[\s\S]*?_NewLoc/|<file://[\s\S]+_NewBase[\s\S]*?_NewLoc/', '', i))

    for i in re.findall('\t[0-9a-zA-Z-"]+[\s\S]*?NL:[\s\S]*?\n|<file://localhost/[\s\S]*?NL:[\s\S]*?\n', reports):#|<file://localhost/[\s\S]*?NL:[\s\S]*?\n
        if len(re.findall('[a-zA-Z"]+',extractKeyword(i, 'NB:'))) > 0 and extra == 'on':
            if extractKeyword(i, 'NB:') == extractKeyword(i, 'NL:') and extractKeyword(i, 'OL:'):
                translation.append(re.sub('<nib://[\s\S]+_NewBase[\s\S]*?_NewLoc/|<file://[\s\S]+_NewBase[\s\S]*?_NewLoc/', '', i))

    if len(states) + len(translation) == 0:
        states.append('No problem found\n')
    return states, translation
    for i in states:
        print i.replace('\t', '')
    for i in translation:
        print i.replace('\t', '')

def excludes1(string):
    for i in ['## INFO - SKIP CHEKING ', 'INCORRECT UNICODE FILE [Need to be UTF-16 (LE or BE) (0xFEFF or 0xFFFE at the top of file)]']:
        if i in string:
            return
    return 1

def scanCheckLocFilesForLocDir(file):
    checkList = []; results = []
    for i in re.findall('==[\s\S]*?\n\n\n', open(file).read()):
        if '## ERROR' or '## WARNING' in i:
            checkList.append(re.sub('## WARNING - MISSING FILE[\s\S]*?nib\n\n\n|## WARNING - EXTRA FILE[\s\S]*?nib\n\n\n|----[\s\S]*?locversion.plist\n|## INFO - SKIP CHEKING[\s\S]*?.xml\n\n', '', i))

    for i in checkList:
        if '.xml\n' in i:
            results.append(i)
        elif '## ERROR' in i and excludes1(i):
            results.append(i)
        elif 'DIRECTORY ' in i:
            results.append(i)
        elif 'EXTRA METADATA' in i:
            results.append(i)
        elif '## WARNING' in i:
            results.append(i)
        elif ' missing from ' in i:
            results.append(i)
    if len(results) == 0:
        results.append('No problem found\n')
    return results

def scanChecktarfile(file):
    results = []
    checkLoctar = open(file).read()
    for tar in re.findall('[-]+\n# ([\s\S]*?.tgz)\n', checkLoctar[checkLoctar.rfind('Check loctar Result'):]):
        if '_1.tgz' not in tar or '.01_' not in tar:
            results.append('illegal tar found: %s'%tar)

    if len(results) == 0:
        results.append('No problem found\n')
    return results

def scanXliffdifferfile(file):
    if '\nTranslation mismatch:' in open(file).read():
        print 'Translation issues in xliffdiffer, please check.'
        os.system('open %s'%file)

def main():
    mailContent = ''
    trustModel = 'on'
    if len(sys.argv) > 2:
        trustModel = 'off'
    elif len(sys.argv) == 1:
        print 'Usage: %s path/to/Reports/folder'%sys.argv[0]
        sys.exit()
    # formateReports(sys.argv[1])
    for root, dirs, files in os.walk(sys.argv[1]):
        for file in files:
            if 'checkLocFilesForLocDir' in file:
                results = scanCheckLocFilesForLocDir(os.path.join(root, file))
                print os.path.join(root, file)
                mailContent += '%s\n'%(os.path.join(root, file))
                for i in results:
                    print i
                    mailContent += '%s\n'%i
            elif file[:32] == 'GlotEnv_flverifierFilteredReport':
                print os.path.join(root, file)
                mailContent += '%s\n'%(os.path.join(root, file))
                differ, similar = scanFlverifierFilteredReport(os.path.join(root, file), trustModel)
                for d in differ:
                    print d.replace('\t', '')
                    mailContent += '%s\n'%d.replace('\t', '')
                for s in similar:
                    print s.replace('\t', '')
                    mailContent += '%s\n'%s.replace('\t', '')
            elif file == 'checktarfile.txt':
                print os.path.join(root, file)
                for illegalTars in scanChecktarfile(os.path.join(root, file)):
                    print illegalTars
                print ''
            if file[:12] == 'xliffdiffer_':
                scanXliffdifferfile(os.path.join(root, file))
    GlotEnv = os.path.dirname(sys.argv[1]) + '/GlotEnv'
    if os.path.isdir(GlotEnv):
        ComponentData = sys.argv[1] + '/' + 'ComponentData.txt'
        IdenticalComponent = checkSubmission(GlotEnv)
        currentData = open(ComponentData).read()
        currentData = currentData[:currentData.find('\n\n#====')] + '\n\n#==========================================================================\n# Identical Component Check Result\n#==========================================================================\n'
        if IdenticalComponent:
            print '## Identical Component:'
            for c in IdenticalComponent:
                print c
                currentData += '%s\n'%c
            print
        else:
            currentData += 'No problem found'
        open(ComponentData, 'w').write(currentData)

    client(sys.argv[1], 'ScanReports')
    #mailto('tinyliu@wistronits.com', 'Please check and fix', mailContent)
    print 'Trust: %s'%trustModel
if __name__ == '__main__':
    main()