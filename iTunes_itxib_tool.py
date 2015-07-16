#!/usr/bin/env python
#coding=utf-8

__author__= 'Tiny Liu (tinyliu@me.com)'

'''
sudo xcode-select -s /Volumes/ProjectsHD/Xcodes/Xcode4.app
xcode-select --print-path
    
sudo xcode-select -s /Applications/Xcode.app
xcode-select --print-path
'''

import os, sys

def returniTunes(folder):
    if not os.path.isfile('/Applications/Xcode.app/Contents/Developer/usr/bin/ibtool'):
        print 'Please check your Xcode'
        sys.exit()
    if os.path.isdir('%s/GlotEnv/_NewLoc/iTunes/Applications/iTunes.app/Contents/Resources'%folder):
        return '%s/GlotEnv/_NewLoc/iTunes/Applications/iTunes.app/Contents/Resources'%folder
    else:
        print 'Not iTunes project, process break.'
        sys.exit()

def itxiblist(English):
    itxibs = []
    for file in os.listdir(English):
        if file[-6:] == '.itxib':
            itxibs.append(file)
    return itxibs

def itxibTool(itxib):
    os.system('/Applications/Xcode.app/Contents/Developer/usr/bin/ibtool --output-format binary1 --objects --hierarchy %s.nib > %s'%(itxib[:-6], itxib))
    print '[SUCCESS] %s ---> itxib'%itxib[itxib.find('_NewLoc'):]
    sys.stdout.flush()

def process(Resources):
    us = ''; loc = ''
    for dir in os.listdir(Resources):
        if 'English.lproj' in dir or 'en.lproj' in dir:
            us = '%s/%s'%(Resources, dir)
        else:
            loc = '%s/%s'%(Resources, dir)
    return us, loc

def start(LocEnv):
    locfiles = process(returniTunes(LocEnv))
    for itxib in itxiblist(locfiles[0]):
        if os.path.isdir('%s/%s'%(locfiles[1], itxib.replace('.itxib', '.nib'))):
            itxibTool('%s/%s'%(locfiles[1], itxib))
        else:
            print 'Error found:\n%s\n%s\n'%(itxib, itxib.replace('.itxib', '.nib'))

start(sys.argv[1]) # LoEnv