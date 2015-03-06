#!/usr/bin/env python
#coding=utf-8

import urllib2

def notice():
    try:
        print urllib2.urlopen('http://10.4.2.6/notice', timeout = 5).read()

    except:
        print '''
'''

notice()