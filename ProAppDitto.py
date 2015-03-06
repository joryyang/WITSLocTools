#!/usr/bin/env python
#coding=utf-8

__author__ = 'TinyLiu@wistronits.com;TinyLiu@me.com'

'''ditto Compressor identical files'''

# last modified date: 2015-01-13

import os, sys, tarfile, time

def exception(file):
	exceptionList = ['English.lproj', 'en.lproj', 'ModalProgress.nib', 'ShareMonitor.help', 'locversion.plist', '.iblabels']
	for i in exceptionList:
		if i in file:
			return
	return 1

def scanFolderFiles(folder):
	fileList = []
	for root, dirs, files in os.walk(folder):
		for file in files:
			baseFile = os.path.join(root, file)
			if exception(baseFile) and '.lproj' in baseFile:
				fileList.append(baseFile)
	if fileList:
		return fileList
	else:
		return []

def exceptionKit(file):
	exceptionList = ['English.lproj', 'en.lproj', 'ShareMonitor.help', 'locversion.plist', '.iblabels']
	for i in exceptionList:
		if i in file:
			return
	return 1

def scanFolderFilesKit(folder):
	fileList = []
	for root, dirs, files in os.walk(folder):
		for file in files:
			baseFile = os.path.join(root, file)
			if exceptionKit(baseFile) and '.lproj' in baseFile:
				fileList.append(baseFile)
	if fileList:
		return fileList
	else:
		return []

def dittoLocFile(file1, file2):
	if not os.path.isfile(file1) or not os.path.isfile(file2):
		# print '\n## %s\n%s\n'%(file1, file2)
		return
	os.system('ditto %s %s'%(file1.replace(' ', '\ '), file2.replace(' ', '\ ')))
	if '_NewLoc' in file1:
		print '%s >> %s'%(file1[file1.find('_NewLoc')+7:], file2[file2.find('_NewLoc')+7:])
	else:
		print '%s >> %s'%(file1[file1.find('Applications'):], file2[file2.find('_NewLoc')+7:])

def dittoLocFilebyDate(file1, file2):
	if not os.path.isfile(file1) or not os.path.isfile(file2):
		print '\n## %s\n%s\n'%(file1, file2)
		return
	if os.stat(file1).st_mtime > os.stat(file2).st_mtime:
		os.system('ditto %s %s'%(file1.replace(' ', '\ '), file2.replace(' ', '\ ')))
		print file1[file1.find('_NewLoc'):], '>', file2[file2.find('_NewLoc'):]
	else:
		os.system('ditto %s %s'%(file2.replace(' ', '\ '), file1.replace(' ', '\ ')))
		print file2[file2.find('_NewLoc'):], '>', file1[file1.find('_NewLoc'):]

def processProDitto(NewLocFolder='', bundleInTarBall='', times=0):
	mergeDict = {'CompressorKit/AppleInternal/Library/EmbeddedFrameworks/ProApps/Frameworks/Qmaster.framework':'CompressorKit/AppleInternal/Library/EmbeddedFrameworks/ProApps/PlugIns/Compressor/CompressorKit.bundle/Contents/Frameworks/Qmaster.framework',
				'CompressorKit/AppleInternal/Library/EmbeddedFrameworks/ProApps/Frameworks/Compressor.framework':'CompressorKit/AppleInternal/Library/EmbeddedFrameworks/ProApps/PlugIns/Compressor/CompressorKit.bundle/Contents/Frameworks/Compressor.framework',
				'CompressorKit/AppleInternal/Library/EmbeddedFrameworks/ProApps/Frameworks/DSPPublishing.framework':'CompressorKit/AppleInternal/Library/EmbeddedFrameworks/ProApps/PlugIns/Compressor/CompressorKit.bundle/Contents/Frameworks/DSPPublishing.framework',
				'ProEditorTrial/Applications/Final Cut Pro Trial.app':'ProEditor/Applications/Final Cut Pro.app'} #back to front
	mergeDict2 = {'Compressor/Applications/Compressor.app/Contents/PlugIns/Compressor/CompressorKit.bundle':'CompressorKit/AppleInternal/Library/EmbeddedFrameworks/ProApps/PlugIns/Compressor/CompressorKit.bundle'} # front to back
	mergeList = ['Motion/Applications/Motion.app/Contents/PlugIns/Compressor/CompressorKit.bundle',
				'ProEditor/Applications/Final Cut Pro.app/Contents/PlugIns/Compressor/CompressorKit.bundle',
				'ProEditor/Applications/Final Cut Pro.app/Contents/PlugIns/FxPlug']

	if bundleInTarBall:
		for unit in mergeList:
			proPath = '%s/%s'%(NewLocFolder, unit)
			if os.path.isdir(proPath) and os.path.basename(unit) == os.path.basename(bundleInTarBall):
				os.system('ditto %s %s'%(bundleInTarBall.replace(' ', '\ '), proPath.replace(' ', '\ ')))
				print 'ditto %s >> %s\n...\n'%(os.path.basename(bundleInTarBall), unit)
				time.sleep(2)
	if times:
		return
	for key in mergeDict2:
		for file in scanFolderFiles('%s/%s'%(NewLocFolder, key)):
			dittoLocFile(file, file.replace(key, mergeDict2[key]))
			# print 'ditto %s >> %s'%(os.path.basename(file), file.replace(key, mergeDict2[key]))
	for key in mergeDict:
		for file in scanFolderFilesKit('%s/%s'%(NewLocFolder, key)):
			if not os.path.isdir(file.replace(key, mergeDict[key])):
				print '## Inexistence target folder: %s'%file.replace(key, mergeDict[key])
			dittoLocFile(file.replace(key, mergeDict[key]), file)
			# print 'ditto %s >> %s'%(os.path.basename(file), file)

def extraComprocessKitBundle(tgz):
	if os.path.isdir('/tmp/tmpTars'):
		os.system('sudo rm -R /tmp/tmpTars')
	tgzContent = tarfile.open(tgz)
	for i in tgzContent:
		if i.name.find('.tar') != -1:
			tgzContent.extract(i, '/tmp/tmpTars')

	for root, dirs, files in os.walk('/tmp/tmpTars'):
		for file in files:
			if file[-4:] == '.tar':
				tarContent = tarfile.open(os.path.join(root, file))
				tarContent.extractall('/tmp/tmpTars/extracted')

	CompressorKitBundle = '/Applications/Compressor.app/Contents/PlugIns/Compressor/CompressorKit.bundle'
	for root, dirs, files in os.walk('/tmp/tmpTars/extracted'):
		for dir in dirs:
			targetdir = os.path.join(root, dir)
			if targetdir[-77:] == CompressorKitBundle:
				# print targetdir
				return targetdir
	print '## Invalied loctar: %s'%tgz

def extraMotionPlugIns(tgz):
	if os.path.isdir('/tmp/tmpTars'):
		os.system('sudo rm -R /tmp/tmpTars')
	tgzContent = tarfile.open(tgz)
	for i in tgzContent:
		if i.name.find('.tar') != -1:
			tgzContent.extract(i, '/tmp/tmpTars')

	for root, dirs, files in os.walk('/tmp/tmpTars'):
		for file in files:
			if file[-4:] == '.tar':
				tarContent = tarfile.open(os.path.join(root, file))
				tarContent.extractall('/tmp/tmpTars/extracted')

	MotionPlugIns = '/Applications/Motion.app/Contents/PlugIns/FxPlug'
	for root, dirs, files in os.walk('/tmp/tmpTars/extracted'):
		for dir in dirs:
			targetdir = os.path.join(root, dir)
			if targetdir[-48:] == MotionPlugIns:
				# print targetdir
				return targetdir
	print '## Invalied loctar: %s'%tgz

def main():
	try:
		if sys.argv[1][-7:] == '_NewLoc':
			processProDitto(NewLocFolder=sys.argv[1])
		elif os.path.basename(sys.argv[1])[:11] == 'Compressor_' and sys.argv[1][-4:] == '.tgz' and sys.argv[2][-7:] == '_NewLoc':
			CompressorBundle = extraComprocessKitBundle(sys.argv[1])
			processProDitto(NewLocFolder=sys.argv[2], bundleInTarBall=CompressorBundle)
		elif os.path.isdir(sys.argv[1]):
			for file in os.listdir(sys.argv[1]):
				if file[:11] == 'Compressor_' and file[-4:] == '.tgz' and sys.argv[2][-7:] == '_NewLoc':
					CompressorBundle = extraComprocessKitBundle('%s/%s'%(sys.argv[1], file))
					processProDitto(NewLocFolder=sys.argv[2], bundleInTarBall=CompressorBundle, times=1)
				elif file[:7] == 'Motion_' and file[-4:] == '.tgz' and sys.argv[2][-7:] == '_NewLoc':
					MotionPlugIns = extraMotionPlugIns('%s/%s'%(sys.argv[1], file))
					processProDitto(NewLocFolder=sys.argv[2], bundleInTarBall=MotionPlugIns)
				else:
					processProDitto(NewLocFolder=sys.argv[2])
	except:
		print '\nusage:\nCompressor: ~/%s path/to/_NewLoc\n'%os.path.basename(sys.argv[0])
		print 'FCP/Motion: ~/%s {Compressor_Ifrit.1A49.01_FU_1.tgz} path/to/_NewLoc\n'%os.path.basename(sys.argv[0])

if __name__ == '__main__':
	main()