#!/usr/bin/env python
#coding=utf-8

__author__ = 'Tinyliu@wistronits.com, tinyliu@me.com'

import ftplib, socket, sys

def listFtpDir(server='10.4.1.13', ftpDir=''):
	ftp = ftplib.FTP()
	try:
		ftp.connect(server, timeout=3)
		ftp.login('amoszhong', '123456')
	except socket.error, e:
		print e
	except ftplib.error_perm, e:
		print e
	if ftpDir:
		try:
			root = '//SoftwareDev/%s/Software_Develop/'%ftpDir
			ftp.cwd(root)
		except:
			root = '//SoftwareDev/%s/'%ftpDir
			ftp.cwd(root)
		dirList = ftp.nlst()
		return [i for i in dirList if 'LS#' in i]
	ftp.cwd('SoftwareDev')
	dirList = ftp.nlst()
	return [i for i in dirList if i != '_DONE_TO_BE_KILLED']

if __name__ == '__main__':
	ftpDir = sys.argv[1] if len(sys.argv) == 2 else ''
	s = listFtpDir(ftpDir=ftpDir)
	if ftpDir:
		for i in s[-2:]:
			print i
	else:
		for i in s:
			print i