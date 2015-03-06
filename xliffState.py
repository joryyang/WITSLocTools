#!/usr/bin/env python
#coding=utf-8

'''
    To scan the number of new/Signed-off/Needs-review-translation strings in each xliff files.
'''

__author__= 'Tiny Liu (tinyliu@wistronits.com)'

import os, sys, time
from socket import *

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

def TransState(file, keyword, keyword1, keyword2, keyword3):
    state = {}
    checkfile = open(file).read()
    state[keyword] = checkfile.count(keyword)
    state[keyword1] = checkfile.count(keyword1)
    state[keyword2] = checkfile.count(keyword2)
    state[keyword3] = checkfile.count(keyword3)
    return state

def start(folder):
    if not os.path.isdir(folder):
        print 'Please enter a xliff foder.'
        sys.exit()
    
    xliffs = []
    for xliff in os.listdir(folder):
        if xliff[-6:] == '.xliff':
            xliffs.append(os.path.join(folder, xliff))

    if xliffs:
        return xliffs
    else:
        print 'Can not find xliffs in this folder.'
        sys.exit()

def main(path):
    print segmentation('xliff', '')
    for i in start(path):
        keywords = TransState(i, 'state="new', 'state=\'new', 'needs-review-translation', 'signed-off')
        k1 = keywords['state="new'] + keywords['state=\'new']
        k2 = keywords['needs-review-translation']
        k3 = keywords['signed-off']
        print i
        print 'New strings: %s\nNeeds-review-translation strings: %s\nSigned-off strings: %s\n'%(k1, k2, k3)
    client(path, 'xliffState')
main(sys.argv[1]) #path to xliff folder