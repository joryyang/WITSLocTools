#! /usr/bin/env python
#coding=utf-8
	
import os
import sys
import linecache
import re
sys.path.append(sys.argv[0][:-14])

def tittle():
    print '*' * 70
    print 'You are using the script xliffdiffer to verify you translation improvement.'
    print '*' * 70

def tester(agTran, agTran2):
	
    def extract(file):
	
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
	
    xlifffiles = []
    xlifffiles2 = []
    for dir in os.listdir(agTran):
        if '.xliff' in dir:
            xlifffiles.append(os.path.join(agTran, dir))
    for dir in os.listdir(agTran2):
        if '.xliff' in dir:
            xlifffiles2.append(os.path.join(agTran2, dir))
    
    for n in range(len(xlifffiles)):
        mCount = 0
        nCount = 0
        s1 = extract(xlifffiles[n])
        s2 = extract(xlifffiles2[n])
        for key in s1:
            if key in s2 and s1[key] == s2[key]:
                mCount +=1;

            elif key not in s2:
                print xlifffiles[n]
                print 'Missed translation: %s\n%s\n'%(key, s1[key])

            elif key in s2 and s1[key] <> s2[key]:
                print xlifffiles[n]
                print 'Translation mismatch:\n%s\nOriginal: %s\nNow: %s\n'%(key, s1[key], s2[key])

        for key in s2:
            if key in s1 and s1[key] == s2[key]:
                nCount += 1
                    
            elif key not in s1:
                print xlifffiles2[n]
                print 'Extra translation in your Env: %s\n%s\n'%(key, s1[key])
        if mCount==len(s1) and nCount==len(s2):
            print "*" * 60
            print xlifffiles[n][xlifffiles[n].rfind("/")+1:]
            print "*" * 60
            print "No Problem\n"


tester(sys.argv[1], sys.argv[2]) #old xliff folder, new xliff folder