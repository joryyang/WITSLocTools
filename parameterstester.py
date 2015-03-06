#! /usr/bin/env python
#coding=utf-8

__author__= 'Tiny Liu (tinyliu@wistronits.com)'

import os, sys, re, time
from socket import *

'''To scan parameter, Mac OS X, year issues in xliffs'''

# Last modified: 2014/10/08

def client(locenv, script):
    try:
        s = socket(AF_INET, SOCK_STREAM)
        s.connect(('10.4.2.6', 8989))
        s.send('%s process script %s in %s'%(time.strftime("%Y-%m-%d %H:%M:%S", time.localtime()) , script, locenv))
        s.close()
    except:
        pass

def segmentation(text, n):
    return '#' + '=' * 74 + '\n# %s Check Result\n#'%text + '=' * 74 + '%s'%n

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
            strings.append(ii[a1:a2] + '\nid: ' + i[16:m1] + '\nUS string: ' + i[m2:m3] + '\nLoc string: ' + i[m4:m5] + '\n')
    return strings

def addorder(source):
    return [source[i] if '$' in source[i] else source[i].replace('%', '%%%s$'%(i+1)) for i in range(len(source))]

def parameters(us, loc):
    checklist = ['Mac OS X', '^b', '^b\n', '\f', '^', '^0', '^1', '^2', '^3', '^4', '%TRACKNAME', '%a', '%b', '%c', '%e', '%f', '%g', '%h', '%j', '%k', '%m', '%n', '%o', '%p', '%q', '%r', '%t', '%v', '%w', '%x', '%y', '%z'] # ignored: '%'
    checklist1 = ['%@', '%d', '%S', '%s', '%u', '%lld', '%ld', '%l', '%i']
    checklist2 = ['%1$', '%2$', '%3$', '%4$', '%5$', '%6$', '%7$']
    for i in checklist:
        loc = loc.replace('\xc2\xa0', ' ')
        us = us.replace('\xc2\xa0', ' ')
        if us.count(i) <> loc.count(i):
            return i

    for i in checklist1:
        if len( re.findall('%%[0-9]\$%s'%i[1:], us) ) + us.count(i) <> len( re.findall('%%%s[0-9]?'%i[1:], loc) ) + len( re.findall('%%[0-9]\$%s'%i[1:], loc) ):
            return 'number of %s mismatch'%i
        elif len( re.findall('%%[0-9]\$%s'%i[1:], loc) ) > 0 and loc.count(i) > 0:
            return i + ' partly ordered'
        elif len( re.findall('%%%s[0-9]'%i[1:], loc) ) <> loc.count(i) and len( re.findall('%%%s[0-9]'%i[1:], loc) ) > 0:
            return i + ' .js file'

    for i in checklist2:
        if us.count(i) <> loc.count(i) and us.count(i) > 0:
            return 'number of %s mismatch'%i
        elif us.count(i) <> loc.count(i) and loc.count(i) > 1:
            return i + ' duplicate order'

    for i in re.findall('(?<![Un])19[89][0-9]|(?<![Un])20[01][0-9]', us):
        if i not in loc.replace('٠', '0').replace('١', '1').replace('٢', '2').replace('٣', '3').replace('٤', '4').replace('٥', '5').replace('٦', '6').replace('٧', '7').replace('٨', '8').replace('٩', '9') and '{\\rtf1\\ansi\\' not in us:
            return 'year'

    if sorted(addorder(re.findall('%[0-9$.]+[a-zA-Z@]|%[a-zA-Z@]', us))) <> sorted(addorder(re.findall('%[0-9$.]+[a-zA-Z@]|%[a-zA-Z@]', loc))):
        return 'misplaced order'

def start(files):
    macResult = []; yearResult = []; argsResult = []
    for i in locstrings(files):
        start = i.find('US string: ')
        end = i.find('Loc string: ')
        checkresult = parameters( i[start:end], i[end:] )
        if  checkresult:
            if checkresult == 'Mac OS X':
                macResult.append('%s\n%s'%(files, i))
            
            elif checkresult == 'year':
                yearResult.append('%s\n%s'%(files, i))
            
            else:
                argsResult.append('%s\n%s## %s.\n'%(files, i, checkresult))

    if not argsResult:
        argsResult.append('%s\nNo problem found\n'%files)
    return macResult, yearResult, argsResult

def parameterstester(pathxliff):
    xliffs = []
    if os.path.isdir(pathxliff):
        for root, dirs, files in os.walk(pathxliff): #'/Volumes/ProjectsHD/_AG/AG_%s_check/_Translations'%langs | pathxliff
            for file in files:
                if '.xliff' in file:
                    xliffs.append(os.path.join(root, file))
    elif pathxliff[-5:] == 'xliff':
        xliffs.append(pathxliff)

    macs = []; years = []
    print segmentation('parameters', '')
    for i in xliffs:
        mac, year, arg = start(i)
        for warning in arg:
            print warning
        macs += mac
        years += year

    print segmentation('Mac OS X', '')
    if macs:
        for warning in macs:
            print warning
    else:
        print 'No problem found\n'

    print segmentation('year', '')
    if years:
        for warning in years:
            print warning
    else:
        print 'No problem found\n'

def main():
    if len(sys.argv) == 2:
        parameterstester(sys.argv[1])
        client(sys.argv[1], 'parametersTester')
    else:
        print 'Usage: %s path/to/xliff/folder'%sys.argv[0]
main()