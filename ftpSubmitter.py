#!/usr/bin/env python
#coding=utf-8

__author__ = 'Tinyliu@wistronits.com, tinyliu@me.com'

import ftplib, socket, sys, os, json

def submitResources(locFolder, A=''): #A=A1
	submitContents = {'TarOut':[]}
	for unit in os.listdir(locFolder):
		if unit == 'TarOut':
			TarOut = os.path.join(locFolder, unit)
			for file in os.listdir(TarOut):
				if file[-4:] == '.tgz':
					submitContents['TarOut'].append(os.path.join(TarOut, file))
		elif unit[:8] == 'Reports_' and unit[-4:] == '.zip' and len(unit) < 15:
			submitContents['report'] = os.path.join(locFolder, unit)
			submitContents['lang'] = unit[8:-4]
			if A:
				submitContents['lang'] += '/%s'%A
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
		if len(sys.argv)==3:
			submitDict = submitResources(sys.argv[1],'')
		else:
			submitDict = submitResources(sys.argv[1],sys.argv[3])
		submitting(submitDict, sys.argv[2])
		print '## Done'
	except:
		print '## Error'
