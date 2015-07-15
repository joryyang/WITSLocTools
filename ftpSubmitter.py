#!/usr/bin/env python
#coding=utf-8

__author__ = 'Tinyliu@wistronits.com, tinyliu@me.com'

import ftplib, sys, os, json, re, time
from socket import *

def client(locenv, text):
    platform = 'null'; xcodeVersion = 'null'
    if os.path.isfile('/System/Library/CoreServices/SystemVersion.plist'):
        platform = re.findall('[0-9]+[A-Z][0-9a-z]+', open('/System/Library/CoreServices/SystemVersion.plist').read())[0]
    if os.path.isfile('/Applications/Xcode.app/Contents/version.plist'):
        xcodeVersion = re.findall('CFBundleVersion[\s\S]*?([.0-9z]+)[\s\S]*?ProductBuildVersion', open('/Applications/Xcode.app/Contents/version.plist').read())[0]
    try:
        s = socket(AF_INET, SOCK_STREAM)
        s.connect(('10.4.2.6', 8888))
        s.send('%s process %s at %s %s %s'%(time.strftime("%Y-%m-%d %H:%M:%S", time.localtime()), text, locenv[29:], platform, xcodeVersion))
        #   tm = s.recv(1024)
        #   print tm
        s.close()
    except:
        pass
# client('/Volumes/ProjectsHD/_LocProj/Cumin_1L24_U20_LC1_TA/TA-Cumin1L24-111414-U20_LC1-GlotKit/LocEnv', 'ScanReports')

def sendTarballListToServer(tarballList):
	if not tarballList:
		return
    try:
        s = socket(AF_INET, SOCK_STREAM)
        s.connect(('10.4.2.6', 8989))
        s.send('locSubmitTarOut'.join(tarballList))
        s.close()
    except:
        pass

def submitResources(locFolder, A=''): #A=A1
	submitContents = {'TarOut':[]}
	for unit in os.listdir(locFolder):
		if unit == 'TarOut':
			TarOut = os.path.join(locFolder, unit)
			for file in os.listdir(TarOut):
				if file[-4:] == '.tgz':
					submitContents['TarOut'].append(os.path.join(TarOut, file))
		elif unit[:8] == 'Reports_' and ' ' not in unit and len(unit) < 15:
			if unit[-4:] == '.zip':
				pass
			else:
				os.chdir(locFolder)
				os.popen('zip %s.zip %s/*'%(unit, unit))
				unit = unit + '.zip'
			submitContents['report'] = os.path.join(locFolder, unit)
			submitContents['lang'] = unit[8:-4]
			if A:
				submitContents['lang'] += '/%s'%A
	# sendTarballListToServer(submitContents['TarOut'])
	return submitContents

def submitting(submitDict, ftpDir): #ftpDir = //SoftwareDev/_OS_X_10.11_SW_Gala/Software_Develop/LS#1_Pre#2
	if 'lang' not in submitDict:
		print '## Can not detect Reprots_CC.zip file'
		return

	submitFoder = '%s/%s'%(ftpDir, submitDict['lang'])
	ftp = ftplib.FTP()
	ftp.connect('10.4.1.13', timeout=3)
	ftp.login('amoszhong', '123456')
	try:
		ftp.cwd(submitFoder)
	except:
		ftp.mkd(submitFoder)
		ftp.cwd(submitFoder)
	ftp.storbinary('STOR %s'%os.path.basename(submitDict['report']), open(submitDict['report'], 'r'))
	print '## uploaded %s'%os.path.basename(submitDict['report'])
	try:
		ftp.cwd('%s/TarOut'%submitFoder)
	except:
		ftp.mkd('%s/TarOut'%submitFoder)
		ftp.cwd('%s/TarOut'%submitFoder)
	for tar in submitDict['TarOut']:
		ftp.storbinary('STOR %s'%(os.path.basename(tar)), open(tar, 'r'))
		print '## uploaded %s'%tar

def multiProcess(Folder, ftpDir, A=''):
	for file in os.listdir(Folder):
		if os.path.isdir('%s/%s'%(Folder, file)):
			submitDict = submitResources('%s/%s'%(Folder, file), A)
			submitting(submitDict, ftpDir)

def main():
	if len(sys.argv) == 2 and os.path.basename(sys.argv[1]) == 'LocEnv':
		ftp, A = submissionChoice(sys.argv[1])
		submitDict = submitResources(sys.argv[1], A)
		submitting(submitDict, ftp)
	else:
		print '\n\tusage: %s path/to/LocEnv\n'%__file__

if __name__ == '__main__':
	try:
		if len(sys.argv) == 3:
			submitDict = submitResources(sys.argv[1])
		else:
			submitDict = submitResources(sys.argv[1],sys.argv[3])
		submitting(submitDict, sys.argv[2])
		print '## Done'
		client(sys.argv[1], 'Submission_UI')
	except:
		print '## Error'
