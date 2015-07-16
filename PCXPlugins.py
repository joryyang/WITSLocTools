#!/usr/bin/env python
#coding=utf-8

__author__= 'Tiny Liu (tinyliu@wistronits.com)'

import os, sys
from biplist import *

pcxPlugins = {" -ib_plugin '/AppleInternal/Library/EmbeddedFrameworks/ProKit/EmbeddedProKit.ibplugin:/AppleInternal/Library/EmbeddedFrameworks/ProApps/IBPlugIns/LunaKitEmbedded.ibplugin'": ['ProEditor','Compressor', 'CompressorKit', 'Flexo', 'iMovieX', 'MotionSharedCode', 'Motion', 'ProChannel', 'ProCurveEditor'],
                " -ib_plugin '/AppleInternal/Developer/Plugins/MAToolKitLogicIBPlugIn.ibplugin'":['MALogic']}

def replacePCX(string, plugin=''):
    if '/BuildRoot' not in string:
        if '/BinaryCache' in string:
            string = string.replace('/BinaryCache', '/BuildRoot/BinaryCache')
        elif '/Library' in string:
            string = string.replace('/Library', '/BuildRoot/Library')
    if plugin not in string:
        string = string.replace('nib$/;\'', 'nib$/;\'%s'%plugin)
    return string

def returnPlist(file):
    if '_OB_NB.plist' in file and 'PCX_' not in file:
        return 1
    elif '_OL_NL.plist' in file and 'PCX_' not in file:
        return 1
    else:
        return 0

def processPlist(plist, plugin=''):
    if returnPlist(plist):
        content = readPlist(plist)
        content['pcxoptions'] = replacePCX(content['pcxoptions'], plugin)
        writePlist(content, plist)
        print '"%sBuildRoot" >> %s'%(plugin[1:12], os.path.basename(plist))

def segregatePlist(folder):
    for file in os.listdir(folder):
        c = 1
        for key in pcxPlugins:
            if file[:file.find('_')] in pcxPlugins[key]:
                processPlist('%s/%s'%(folder, file), plugin=key); c = 0
        if c:
            processPlist('%s/%s'%(folder, file))

def main():
    if len(sys.argv) == 2:
        if sys.argv[1][-19:] == 'flidentifier_result':
            segregatePlist(sys.argv[1])
        else:
            print 'Usage: %s path/to/flidentifier_result/'%sys.argv[0]
    else:
        os.system('%s %s'%(sys.argv[0], raw_input('Enter path/to/flidentifier_result/\n')))
main()