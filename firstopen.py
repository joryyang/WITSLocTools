#!/usr/bin/env python
#coding=utf-8
import sys, urllib2, os, time

def main():
    url = 'http://10.4.2.6/wiki/pages/D1b8Q7B3/LocTools.html'
    try:
        response = urllib2.urlopen(url, timeout = 5)
        if 'LocTools 2.2.3' in response.read():
            pass
        else:
            print 'the version is old'

    except urllib2.URLError, e:
        print 'Network is unreachable'
main()

'''返回 1 说明有更新; 返回 0 则需要连接公司网络'''