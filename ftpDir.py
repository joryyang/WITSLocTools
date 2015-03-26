#!/usr/bin/env python
#coding=utf-8

__author__ = 'Tinyliu@wistronits.com, tinyliu@me.com'

import ftplib, socket, sys, urllib2, os, json

def getSubmissionPair(url='http://10.4.2.6/ProjForFTP'):
	try:
		response = urllib2.urlopen(url, timeout = 5)
		projDict = json.loads(response.read())
		return projDict
	except:
		return {}

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
		ftpDir=ftpDir.replace("%"," ")
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
	if os.path.basename(sys.argv[1]) == 'LocEnv':
		currentSub = getSubmissionPair()
		if currentSub:
			for key in currentSub:
				if key in sys.argv[1]:
					if isinstance(currentSub[key], list):
						for i in currentSub[key]:
							print i
					else:
						print currentSub[key]
					sys.exit()
				else:
					ftpDir = ''
		else:
			ftpDir = ''
	else:
		ftpDir = sys.argv[1]
	s = listFtpDir("10.4.1.13",ftpDir)
	for i in s:
		print i
