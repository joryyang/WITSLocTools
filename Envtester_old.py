#! /usr/bin/env python
#coding=utf-8
	
#	File:		Envtester.py
#
#	Contains:	This script scans LocEnv to check Mailnotify, parameters issues, new strings in xliffs,
#               Locversion.plist issues and execute other commands for loc engineering.
#
#	Author:		Tiny Liu tinyliu@wistronits.com Please contact me if you have any suggestion or feedback.
	
	
'''
This script scans LocEnv to check Mailnotify, parameters issues, new strings in xliffs and Locversion.plist issues and execute other commands for loc engineering.
'''
	
# strings for info commands
__author__		= "Tiny Liu (tinyliu@wistronits.com)"
__version__		= "$Revision: beta 0.9 $"[11:-2]
__date__		= "$Date: 2013-12-16 $"[7:-2]
__copyright__	= "Wistron ITS"
	
import os, sys, linecache, re, urllib2
sys.path.append(sys.argv[0][:-12])

def tester(pathEnv):
	
	key_word = 'state="new'
	key_words = 'state=\'new'
	key_word2 = 'signed-off'
	key_word3 = 'needs-review-translation'
	#定义三个需要搜索的关键字
	
	k1 = 0
	k2 = 0
	k3 = 0
	
	pathGlotEnv = pathEnv + '/GlotEnv'
	path = pathEnv + '/GlotEnv/_Translations'   #Conductor GlotEnv/_Translations 路径
	pathNB = pathEnv + '/GlotEnv/_NewBase'      #path 指向 LocEnv 的 NB
	pathinfo = pathEnv + '/Info'
	pathinfobackup = pathEnv + '/Info_org'
	pathprojects = pathEnv + '/Projects'
	pathprojectsbackup = pathEnv + '/Projects_org'
	pathNL = pathGlotEnv + '/_NewLoc'
	pathNLbackup = pathNL + '_org'
	
	
	def getlangs(path):
		OldLocUpdate = 'null'
		langs = path.split('/')[5][:path.split('/')[5].find('-')]
		ComponentDatas = []
		for root, dirs, files in os.walk(path):
			for ComponentData in files:
				if 'ComponentData.plist' in ComponentData:
					ComponentDatas.append(os.path.join(root, ComponentData))
        
		if len(ComponentDatas) > 0:
			f = open(ComponentDatas[0], 'r')
			for n in range(len(f.readlines())):
				if 'OldLocUpdate' in linecache.getline(r'%s'%ComponentDatas[0],n):
					OldLocUpdate = linecache.getline(r'%s'%ComponentDatas[0],n + 1)[9:-10]
			f.close()
        
		NewLocupdate = path[29:].split('_')[0] + path[29:].split('_')[1]
		return langs, OldLocUpdate, NewLocupdate

	langs, OldLocUpdate, NewLocupdate = getlangs(pathEnv)
	reports = pathEnv + '/Reports_%s'%langs
	
	if os.path.isdir(reports):
	    pass
	else:
	    os.mkdir(reports)
	
	reportpath = reports + '/Envtester_%s.txt'%langs
	reportpath1 = reports + '/Untranslation_%s.txt'%langs
	report = open(reportpath, "w")
	
	def locversioncheck(locversion):    #locversion.plsit tester
	    lproj = []
	    for root, dirs, files in os.walk(locversion):
	        for dir in dirs:
	            if '.lproj' in dir:
	                lproj.append(os.path.join(root, dir))   #NB 中所有包含 .lproj 的 folder 路径
	    
	    plist = []
	    for root, dirs, files in os.walk(locversion):
	        for file in files:
	            if 'locversion.plist' in file:
	                plist.append(os.path.join(root, file)[:-17])    #NB 中所有 locversion.plist 的 .lproj folder 路径
	    
	    n = 0
	    for i in lproj:
	        if 'en.lproj' in i and i.replace('en.lproj', 'English.lproj') in lproj:
	            print 'Both en.lproj and English.lproj found in NewBase.\n%s\n%s\n'%(i, i.replace('en.lproj', 'English.lproj'))
	            report.write('Both en.lproj and English.lproj found in NewBase.\n%s\n%s\n\n'%(i, i.replace('en.lproj', 'English.lproj')))
	            n = 1
	    for x in lproj:
	        if x not in plist:
	            print 'Missing locversion.plist:\n', x, '\n'
	            report.write('Missing locversion.plist:\n' + x + '\n\n')
	            n = 1
	    if n == 0:
	        print 'No problem found'
	        report.write('No problem found\n\n')
	
	def dntlist(strings):
	    sums = []
	    dntlist = ['           ', '--:--:--.---', 'HiraKakuProN', 'Georgia', 'Superclaredon', 'Optima', 'Helvetica', 'MarkerFelt', 'BradleyHandITCTT', 'STHeitiTC', 'STHeitiSC', 'Didot', 'Palatino', 'Cochin', 'HiraMinProN', 'Avenir', 'BodoniSvtyTwoITCTT', 'HoeflerText', 'Baskerville', ' kHz', ' khz', 'OtherViews', '1-Click', '.Mac', 'A-Net', 'A.PACK', 'ACT!', 'Active Directory', 'Ad Lib', 'AddMotion', 'Advanced Video Coding = AVC', 'AIM', 'AirDrop', 'AirPlay', 'AirPort', 'AirPort Express', 'AirPort Extreme', 'AirPrint', 'AirTunes', 'Amp Designer', 'AMR Narrowband = AMR NB', 'Apache', 'Aperture', 'App Nap', 'App Store', 'Apple', 'AppleOrder', 'AppleScript', 'AFP', 'AppleScript Studio', 'AppleTalk', 'AppleVision', 'Apple Cinema Display', 'Apple Configurator', 'Apple Developer', 'Apple DocViewer', 'Apple Hardware Test', 'Apple Inc.', 'Apple Loop', 'Apple Loops', 'Apple Lossless', 'Apple Remote', 'Apple Remote Desktop', 'Apple Software Restore (asr)', 'Apple Store', 'Apple TechStep', 'Apple Thunderbolt Display', 'Apple TV', 'Aqua', 'Assembled in the USA', 'AssistiveTouch', 'Audible', 'Audio Units', 'Automator', 'Batch Monitor', 'Bento', 'Bicycle', 'Bluetooth', 'Bonjour', 'Book Proofer', 'Boot Camp', 'Bring Learning Home', 'Cable Micro', 'Carbon', 'Cards', 'Cinema Tools', 'Cocoa', 'ColorSync', 'Compressor', 'Core Animation', 'Core Image', 'Core Storage', 'Core Video', 'Cover Flow', 'Dashboard', 'Dashcode', 'DECnet', 'Designed by Apple in California', 'Device Micro', 'DialAssist', 'Dock', 'Domain Admins', 'Drummer', 'DVD Studio Pro', 'DVD@CCESS', 'EarPods', 'Eudora', 'Exchange', 'Exposé', 'Extensions Manager', 'FaceTime', 'FairPlay', 'FileVault', 'Final Cut', 'Final Cut Pro', 'Final Cut Studio', 'Finder', 'FireWire', 'Flex Pitch', 'Flex Time', 'Flyover', 'Fusion Drive', 'Game Center', 'GarageBand', 'Gatekeeper', 'Genius', 'Google', 'GRid', 'https://iforgot.apple.com', 'iAd', 'iBooks', 'iBooks Author', 'iBooks Store', 'iCal', 'ICCID', 'iChat', 'iChat Theater', 'iCloud', 'ICQ', 'iDisk', 'iDVD', 'iLife', 'iMac', 'IMEI', 'iMessage', 'iMovie', 'iMovie Theater', 'iOS', 'iPad', 'iPad mini', 'iPhone', 'iPhone 3G', 'iPhone 3GS', 'iPhone 4', 'iPhone 4s', 'iPhone 5c', 'iPhone 5s', 'iPhoto', 'iPod', 'iPod classic', 'iPod nano', 'iPod shuffle', 'iPod touch', 'iSight', 'iTunes', 'iTunes Connect', 'iTunes Extras', 'iTunes Live', 'iTunes LP', 'iTunes Match', 'iTunes Media', 'iTunes Music Store', 'iTunes Pass', 'iTunes Producer', 'iTunes Store', 'iTunes U', 'iWeb', 'iWork', 'Jam Pack', 'Java', 'Ken Burns', 'Keynote', 'Launchpad', 'Lightning', 'Logic Remote', 'Mac', 'MacBook', 'MacBook Air', 'MacBook Pro', 'Macintosh', 'Mac App Store', 'Mac mini', 'Mac OS', 'Mac OS X', 'Mac OS X Leopard', 'Mac OS X Lion', 'Mac OS X Lion Developer Preview', 'Mac OS X Snow Leopard', 'Mac Pro', 'Magic Mouse', 'Magic Songs', 'Magic Trackpad', 'Mail', 'MainStage', 'Marker Felt', 'Micro', 'Mission Control', 'Mobile Applications', 'Mobile Time Machine', 'MobileMe', 'Motion', 'Multi-Touch', 'Music Store', 'Nike+', 'Nike + iPod', 'Noteworthy', 'NTSC', 'Numbers', 'On-The-Go', 'Open Link', 'OS X', 'OS X Mavericks', 'OS X Mountain Lion', 'ou=people, o=company ', 'Pages', 'PAL', 'Passbook', 'Pedalboard', 'Photo Booth', 'Ping', 'Podcast Capture', 'Podcast Producer', 'Podcast Producer Server', 'Podcast Publisher', 'Port Micro', 'Port Micro 0', 'Port Micro 1', 'Power Nap', 'PowerSong', 'Proof', 'Push', 'QuickTime', 'QuickTime Player', 'Rendezvous', 'Retina', 'Rosetta', 'Safari', 'SANE', 'SDK', 'Server', 'Setting the Pace', 'Shop different', 'Siri', 'Smart Control', 'SnapBack', 'Sound Manager', 'Spaces', 'Spotlight', 'STAKCopy', 'STAKNode', 'Starbucks', 'SuperDrive', 'Super Port Micro', 'The power to be your best.', 'The Universal Client', 'There’s an app for that', 'Think different', 'Time Capsule', 'Time Machine', 'TokenTalk', 'Top Sites', 'Touch ID', 'Tremor', 'TrueType', 'Twitter', 'Unicode', 'VoiceDial', 'VoiceOver', 'VoiceOver Kit', 'VPN', 'Web Clip', 'WebObjects', 'WebScript', 'Wi-Fi + Cellular', 'Wi-Fi Direct', 'Wiki Server', 'X Window System', 'Xray', 'Xsan', 'Xserve', 'Yahoo!', 'YouTube', 'Text Cell', 'Table View Cell', 'DON\'T LOCALIZE', 'DNL']
	    for i in dntlist:
	        sums.append(strings.count(i))
	    if len(re.findall('[a-zA-Z]+', strings)) > 0:
	        return sum(sums)
	    else:
	        return 1
	
	def check(file):
	    strings = []
	    usstrings = []
	    locstrings = []
	
	    tmx = open(file, "r")
	
	    tmxs = tmx.read()
	    s = re.findall('<file [\s\S]*?</file>', tmxs)
	    for ii in s:
	        x = re.findall('<trans-unit [\s\S]*?</trans-unit>', ii)
    
	        for i in x:
	            a1 = ii.find('origin=') + 8
	            a2 = ii.find(' source-language') - 1
	            if i.find('" restype=', 16) > i.find('\' restype=', 16):
	                m1 = i.find('" restype=', 16)
	            else:
	                m1 = i.find('\' restype=', 16)
	            m2 = i.find('<source>') + 8
	            m3 = i.find('</source>')
	            m4 = i.find('>', i.find('<target')+7) + 1
	            if i.rfind('</target>') == -1:
	                m5 = m4
	            else:
	                m5 = i.rfind('</target>')
	            strings.append(ii[a1:a2] + '\nid: ' + i[16:m1] + '\nUS string: ' + i[m2:m3] + '\nLoc string: ' + i[m4:m5] + '\n')
	
	    for i in strings:
	        start = i.find('US string: ')
	        end = i.find('Loc string: ')
	        usstrings.append(i[start:end])
	        locstrings.append(i[end:])
	
	    c = 0
	    n = 0
	    args = []
	    while n < len(usstrings):
	        
	        for i in re.findall('[0-9]+', usstrings[n]):
	            if len(i) == 4 and i[:2] == '20' and i not in locstrings[n].replace('٠', '0').replace('١', '1').replace('٢', '2').replace('٣', '3').replace('٤', '4').replace('٥', '5').replace('٦', '6').replace('٧', '7').replace('٨', '8').replace('٩', '9') and '\u20' not in usstrings[n].lower() and '!#x20' not in usstrings[n] and str(int(i) + 543) not in locstrings[n] and '\\rtf1\\ansi' not in usstrings[n]:
	                args.append(usstrings[n])
	                print file + '\n', strings[n], '## ERROR: Years mismatch.\n- Thai Buddhist calendar is 543 bigger than Gregorian calendar.\n- AB number format: ٠١٢٣٤٥٦٧٨٩.\n'
	                report.write(file + '\n' + strings[n] + '## ERROR: Years mismatch.\n- Thai Buddhist calendar is 543 bigger than Gregorian calendar.\n- AB number format: ٠١٢٣٤٥٦٧٨٩.\n\n')
	                c = 1
	
	        if usstrings[n].count('\\f') <> locstrings[n].count('\\f') and '\\rtf1\\ansi' not in usstrings[n]:
	            print file + '\n', strings[n] + '\n## ERROR: Number of "\\f" mismatch.\n'
	            report.write(file + '\n' + strings[n] + '## ERROR: Number of "\\f" mismatch.\n\n')
	            c = 1
	        
	        if usstrings[n][usstrings[n].find('\\f'):].count('\\n') <> locstrings[n][locstrings[n].find('\\f'):].count('\\n') and '\\f' in usstrings[n] and '\\f' in locstrings[n] and '\\rtf1\\ansi' not in usstrings[n]:
	            print file + '\n', strings[n]
	            report.write(file + '\n' + strings[n] + '## ERROR: Number of "\\n" mismatch.\n\n')
	            c = 1
	
	        if 'Mac OS X' in locstrings[n] and 'Mac OS X' not in usstrings[n]:
	            print file + '\n', strings[n] + '\n## ERROR: "Mac" was dropped from the name since Lion, and it is now simply "OS X".\n'
	            report.write(file + '\n' + strings[n] + '## ERROR: "Mac" was dropped from the name since Lion, and it is now simply "OS X".\n\n')
	            c = 1
	
	        if usstrings[n].count('%1$') <> locstrings[n].count('%1$') and locstrings[n].count('%1$') > 1:  #如果本地化字串有一个以上 1$，才与英文字串对比
	            x1 = usstrings[n]
	            print file + '\n', strings[n]
	            report.write(file + '\n' + strings[n] + '\n')
	            args.append(usstrings[n])
	            c = 1
	        
	        if usstrings[n].count('%2$') <> locstrings[n].count('%2$') and locstrings[n].count('%2$') > 1:
	            x2 = usstrings[n]
	            if x2 not in args:
	                print file + '\n', strings[n]
	                report.write(file + '\n' + strings[n] + '\n')
	                args.append(usstrings[n])
	                c = 1
	        
	        if usstrings[n].count('%3$') <> locstrings[n].count('%3$') and locstrings[n].count('%3$') > 1:
	            x3 = usstrings[n]
	            if x3 not in args:
	                print file + '\n', strings[n]
	                report.write(file + '\n' + strings[n] + '\n')
	                args.append(usstrings[n])
	                c = 1
	        
	        if usstrings[n].count('%4$') <> locstrings[n].count('%4$') and locstrings[n].count('%4$') > 1:
	            x31 = usstrings[n]
	            if x31 not in args:
	                print file + '\n', strings[n]
	                report.write(file + '\n' + strings[n] + '\n')
	                args.append(usstrings[n])
	                c = 1
	
	        if usstrings[n].count('%5$') <> locstrings[n].count('%5$') and locstrings[n].count('%5$') > 1:
	            x32 = usstrings[n]
	            if x32 not in args:
	                print file + '\n', strings[n]
	                report.write(file + '\n' + strings[n] + '\n')
	                args.append(usstrings[n])
	                c = 1
	
	        if usstrings[n].count('%6$') <> locstrings[n].count('%6$') and locstrings[n].count('%6$') > 1:
	            x33 = usstrings[n]
	            if x33 not in args:
	                print file + '\n', strings[n]
	                report.write(file + '\n' + strings[n] + '\n')
	                args.append(usstrings[n])
	                c = 1
	
	        if usstrings[n].count('%7$') <> locstrings[n].count('%7$') and locstrings[n].count('%7$') > 1:
	            x34 = usstrings[n]
	            if x34 not in args:
	                print file + '\n', strings[n]
	                report.write(file + '\n' + strings[n] + '\n')
	                args.append(usstrings[n])
	                c = 1
	
	        if usstrings[n].count('%') <> locstrings[n].count('%') + locstrings[n].count('٪') and '%' in usstrings[n]:
	            x4 = usstrings[n]
	            if x4 not in args:
	                print file + '\n', strings[n]
	                report.write(file + '\n' + strings[n] + '\n')
	                args.append(usstrings[n])
	                c = 1
	        
	        if usstrings[n].count('%@') + usstrings[n].count('%1$@') + usstrings[n].count('%2$@') + usstrings[n].count('%3$@') + usstrings[n].count('%4$@') + usstrings[n].count('%5$@') + usstrings[n].count('%6$@') + usstrings[n].count('%7$@') + usstrings[n].count('%@1') + usstrings[n].count('%@2') + usstrings[n].count('%@3') + usstrings[n].count('%@4') <> locstrings[n].count('%@') + locstrings[n].count('%1$@') + locstrings[n].count('%2$@') + locstrings[n].count('%3$@') + locstrings[n].count('%4$@') + locstrings[n].count('%5$@') + locstrings[n].count('%6$@') + locstrings[n].count('%7$@') + locstrings[n].count('%@1') + locstrings[n].count('%@2') + locstrings[n].count('%@3') + locstrings[n].count('%@4'):
	            x5 = usstrings[n]
	            if x5 not in args:
	                print file + '\n', strings[n]
	                report.write(file + '\n' + strings[n] + '\n')
	                args.append(usstrings[n])
	                c = 1
	        
	        if usstrings[n].count('^') <> locstrings[n].count('^'):
	            x6 = usstrings[n]
	            if x6 not in args:
	                print file + '\n', strings[n]
	                report.write(file + '\n' + strings[n] + '\n')
	                args.append(usstrings[n])
	                c = 1
	    
	        if usstrings[n].count('^b') <> locstrings[n].count('^b'):
	            x61 = usstrings[n]
	            if x61 not in args:
	                print file + '\n', strings[n] + '## ERROR: Number of ^b mismatch.\n'
	                report.write(file + '\n' + strings[n] + '## ERROR: Number of ^b mismatch.\n\n')
	                args.append(usstrings[n])
	                c = 1
	
	        if locstrings[n].count('^b\n') + usstrings[n].count('^b\n') > 0:
	            x62 = usstrings[n]
	            if x62 not in args:
	                print file + '\n', strings[n] + '## ERROR: String should not end with ^b.\n'
	                report.write(file + '\n' + strings[n] + '## ERROR: String should not end with ^b.\n\n')
	                args.append(usstrings[n])
	                c = 1
	
	        if usstrings[n].count('^0') <> locstrings[n].count('^0'):
	            x7 = usstrings[n]
	            if x7 not in args:
	                print file + '\n', strings[n]
	                report.write(file + '\n' + strings[n] + '\n')
	                args.append(usstrings[n])
	                c = 1
	        
	        if usstrings[n].count('^1') <> locstrings[n].count('^1'):
	            x8 = usstrings[n]
	            if x8 not in args:
	                print file + '\n', strings[n]
	                report.write(file + '\n' + strings[n] + '\n')
	                args.append(usstrings[n])
	                c = 1
	        
	        if usstrings[n].count('^2') <> locstrings[n].count('^2'):
	            x9 = usstrings[n]
	            if x9 not in args:
	                print file + '\n', strings[n]
	                report.write(file + '\n' + strings[n] + '\n')
	                args.append(usstrings[n])
	                c = 1
	        
	        if usstrings[n].count('^3') <> locstrings[n].count('^3'):
	            x10 = usstrings[n]
	            if x10 not in args:
	                print file + '\n', strings[n]
	                report.write(file + '\n' + strings[n] + '\n')
	                args.append(usstrings[n])
	                c = 1
	        
	        if usstrings[n].count('%lld') <> locstrings[n].count('%lld') and usstrings[n].count('%lld') <> locstrings[n].count('%1$lld') + locstrings[n].count('%2$lld') + locstrings[n].count('%3$lld') + locstrings[n].count('%4$lld'):
	            x11 = usstrings[n]
	            if x11 not in args:
	                print file + '\n', strings[n]
	                report.write(file + '\n' + strings[n] + '\n')
	                args.append(usstrings[n])
	                c = 1
	        
	        if usstrings[n].count('%%') <> locstrings[n].count('%%'):
	            x12 = usstrings[n]
	            if x12 not in args:
	                print file + '\n', strings[n], '\nThe two % should not be separated.\n'
	                report.write(file + '\n' + strings[n] + 'The two % should not be separated.\n\n')
	                args.append(usstrings[n])
	                c = 1
	        
	        if usstrings[n].count('%TRACKNAME') <> locstrings[n].count('%TRACKNAME'):
	            x13 = usstrings[n]
	            if x13 not in args:
	                print file + '\n', strings[n], '\nThis parameter should not be translated.\n'
	                report.write(file + '\n' + strings[n] + 'This parameter should not be translated.\n\n')
	                args.append(usstrings[n])
	                c = 1
	        
	        if usstrings[n].count('%ld') <> locstrings[n].count('%ld') and usstrings[n].count('%ld') <> locstrings[n].count('%1$ld') + locstrings[n].count('%2$ld') + locstrings[n].count('%3$ld') + locstrings[n].count('%4$ld'):
	            x14 = usstrings[n]
	            if x14 not in args:
	                print file + '\n', strings[n]
	                report.write(file + '\n' + strings[n] + '\n')
	                args.append(usstrings[n])
	                c = 1
	    
	        if usstrings[n].count('%a') <> locstrings[n].count('%a'):
	            a = usstrings[n]
	            if a not in args:
	                print file + '\n', strings[n]
	                report.write(file + '\n' + strings[n] + '\n')
	                args.append(usstrings[n])
	                c = 1
	        
	        if usstrings[n].count('%b') <> locstrings[n].count('%b'):
	            b = usstrings[n]
	            if b not in args:
	                print file + '\n', strings[n]
	                report.write(file + '\n' + strings[n] + '\n')
	                args.append(usstrings[n])
	                c = 1
	        
	        if usstrings[n].count('%c') <> locstrings[n].count('%c'):
	            ce = usstrings[n]
	            if ce not in args:
	                print file + '\n', strings[n]
	                report.write(file + '\n' + strings[n] + '\n')
	                args.append(usstrings[n])
	                c = 1
	        
	        if usstrings[n].count('%d') <> locstrings[n].count('%d') and usstrings[n].count('%d') <> locstrings[n].count('%1$d') + locstrings[n].count('%2$d') + locstrings[n].count('%3$d') + locstrings[n].count('%4$d'):
	            d = usstrings[n]
	            if d not in args:
	                print file + '\n', strings[n]
	                report.write(file + '\n' + strings[n] + '\n')
	                args.append(usstrings[n])
	                c = 1
	        
	        if usstrings[n].count('%e') <> locstrings[n].count('%e'):
	            e = usstrings[n]
	            if e not in args:
	                print file + '\n', strings[n]
	                report.write(file + '\n' + strings[n] + '\n')
	                args.append(usstrings[n])
	                c = 1
	        
	        if usstrings[n].count('%f') <> locstrings[n].count('%f'):
	            f = usstrings[n]
	            if f not in args:
	                print file + '\n', strings[n]
	                report.write(file + '\n' + strings[n] + '\n')
	                args.append(usstrings[n])
	                c = 1
	        
	        if usstrings[n].count('%g') <> locstrings[n].count('%g'):
	            g = usstrings[n]
	            if g not in args:
	                print file + '\n', strings[n]
	                report.write(file + '\n' + strings[n] + '\n')
	                args.append(usstrings[n])
	                c = 1
	        
	        if usstrings[n].count('%h') <> locstrings[n].count('%h'):
	            h = usstrings[n]
	            if h not in args:
	                print file + '\n', strings[n]
	                report.write(file + '\n' + strings[n] + '\n')
	                args.append(usstrings[n])
	                c = 1
	        
	        if usstrings[n].count('%i') <> locstrings[n].count('%i'):
	            i = usstrings[n]
	            if i not in args:
	                print file + '\n', strings[n]
	                report.write(file + '\n' + strings[n] + '\n')
	                args.append(usstrings[n])
	                c = 1
	        
	        if usstrings[n].count('%j') <> locstrings[n].count('%j'):
	            j = usstrings[n]
	            if j not in args:
	                print file + '\n', strings[n]
	                report.write(file + '\n' + strings[n] + '\n')
	                args.append(usstrings[n])
	                c = 1
	        
	        if usstrings[n].count('%k') <> locstrings[n].count('%k'):
	            k = usstrings[n]
	            if k not in args:
	                print file + '\n', strings[n]
	                report.write(file + '\n' + strings[n] + '\n')
	                args.append(usstrings[n])
	                c = 1
	        
	        if usstrings[n].count('%l') <> locstrings[n].count('%l') and usstrings[n].count('%l') <> locstrings[n].count('%1$l') + locstrings[n].count('%2$l') + locstrings[n].count('%3$l') + locstrings[n].count('%4$l'):
	            l = usstrings[n]
	            if l not in args:
	                print file + '\n', strings[n]
	                report.write(file + '\n' + strings[n] + '\n')
	                args.append(usstrings[n])
	                c = 1
	        
	        if usstrings[n].count('%m') <> locstrings[n].count('%m'):
	            m = usstrings[n]
	            if m not in args:
	                print file + '\n', strings[n]
	                report.write(file + '\n' + strings[n] + '\n')
	                args.append(usstrings[n])
	                c = 1
	        
	        if usstrings[n].count('%n') <> locstrings[n].count('%n'):
	            n1 = usstrings[n]
	            if n1 not in args:
	                print file + '\n', strings[n]
	                report.write(file + '\n' + strings[n] + '\n')
	                args.append(usstrings[n])
	                c = 1
	        
	        if usstrings[n].count('%o') <> locstrings[n].count('%o'):
	            o = usstrings[n]
	            if o not in args:
	                print file + '\n', strings[n]
	                report.write(file + '\n' + strings[n] + '\n')
	                args.append(usstrings[n])
	                c = 1
	        
	        if usstrings[n].count('%p') <> locstrings[n].count('%p'):
	            p = usstrings[n]
	            if p not in args:
	                print file + '\n', strings[n]
	                report.write(file + '\n' + strings[n] + '\n')
	                args.append(usstrings[n])
	                c = 1
	        
	        if usstrings[n].count('%q') <> locstrings[n].count('%q'):
	            q = usstrings[n]
	            if q not in args:
	                print file + '\n', strings[n]
	                report.write(file + '\n' + strings[n] + '\n')
	                args.append(usstrings[n])
	                c = 1
	        
	        if usstrings[n].count('%r') <> locstrings[n].count('%r'):
	            r = usstrings[n]
	            if r not in args:
	                print file + '\n', strings[n]
	                report.write(file + '\n' + strings[n] + '\n')
	                args.append(usstrings[n])
	                c = 1
	        
	        if usstrings[n].count('%s') <> locstrings[n].count('%s') and usstrings[n].count('%s') <> locstrings[n].count('%1$s') + locstrings[n].count('%2$s') + locstrings[n].count('%3$s') + locstrings[n].count('%4$s'):
	            s = usstrings[n]
	            if s not in args:
	                print file + '\n', strings[n]
	                report.write(file + '\n' + strings[n] + '\n')
	                args.append(usstrings[n])
	                c = 1
	
	        if usstrings[n].count('%1$S') + usstrings[n].count('%2$S') + usstrings[n].count('%3$S') + usstrings[n].count('%4$S') <> locstrings[n].count('%1$S') + locstrings[n].count('%2$S') + locstrings[n].count('%3$S') + locstrings[n].count('%4$S'):
	            S = usstrings[n]
	            if S not in args:
	                print file + '\n', strings[n]
	                report.write(file + '\n' + strings[n] + '\n')
	                args.append(usstrings[n])
	                c = 1
	
	        if usstrings[n].count('%S') <> locstrings[n].count('%S') and usstrings[n].count('%S') <> locstrings[n].count('%1$S') + locstrings[n].count('%2$S') + locstrings[n].count('%3$S') + locstrings[n].count('%4$S'):
	            S1 = usstrings[n]
	            if S1 not in args:
	                print file + '\n', strings[n]
	                report.write(file + '\n' + strings[n] + '\n')
	                args.append(usstrings[n])
	                c = 1
	
	        if usstrings[n].count('%t') <> locstrings[n].count('%t'):
	            t = usstrings[n]
	            if t not in args:
	                print file + '\n', strings[n]
	                report.write(file + '\n' + strings[n] + '\n')
	                args.append(usstrings[n])
	                c = 1
	        
	        if usstrings[n].count('%u') <> locstrings[n].count('%u') and usstrings[n].count('%u') <> locstrings[n].count('%1$u') + locstrings[n].count('%2$u') + locstrings[n].count('%3$u') + locstrings[n].count('%4$u'):
	            u = usstrings[n]
	            if u not in args:
	                print file + '\n', strings[n]
	                report.write(file + '\n' + strings[n] + '\n')
	                args.append(usstrings[n])
	                c = 1
	        
	        if usstrings[n].count('%v') <> locstrings[n].count('%v'):
	            v = usstrings[n]
	            if v not in args:
	                print file + '\n', strings[n]
	                report.write(file + '\n' + strings[n] + '\n')
	                args.append(usstrings[n])
	                c = 1
	        
	        if usstrings[n].count('%w') <> locstrings[n].count('%w'):
	            w = usstrings[n]
	            if w not in args:
	                print file + '\n', strings[n]
	                report.write(file + '\n' + strings[n] + '\n')
	                args.append(usstrings[n])
	                c = 1
	        
	        if usstrings[n].count('%x') <> locstrings[n].count('%x'):
	            x = usstrings[n]
	            if x not in args:
	                print file + '\n', strings[n]
	                report.write(file + '\n' + strings[n] + '\n')
	                args.append(usstrings[n])
	                c = 1
	        
	        if usstrings[n].count('%y') <> locstrings[n].count('%y'):
	            y = usstrings[n]
	            if y not in args:
	                print file + '\n', strings[n]
	                report.write(file + '\n' + strings[n] + '\n')
	                args.append(usstrings[n])
	                c = 1
	        
	        if usstrings[n].count('%z') <> locstrings[n].count('%z'):
	            z = usstrings[n]
	            if z not in args:
	                print file + '\n', strings[n]
	                report.write(file + '\n' + strings[n] + '\n')
	                args.append(usstrings[n])
	                c = 1
	        
	        n = n + 1
	    
	    if c == 0:
	        print file, '\nNo problem found\n'
	        report.write(file + '\nNo problem found\n\n')
	
	tmxs = []
	print 'Loc Eng based on %s for US update, leverage from %s.'%(NewLocupdate, OldLocUpdate)
	report.write('\nLoc Eng based on %s for US update, leverage from %s.\n\n'%(NewLocupdate, OldLocUpdate))
	print '#' + '=' * 74 + '\n# parameters Check Result\n#' + '=' * 74
	report.write('#' + '=' * 74 + '\n# parameters Check Result\n#' + '=' * 74 + '\n')
	for root, dirs, files in os.walk(path):
	    for tmx in files:
	        if '.xliff' in tmx:
	            tmxs.append(os.path.join(root, tmx))
	
	for n in range(0, len(tmxs)):
	    check(tmxs[n])
	
	os.system('find %s -name ".DS_Store" -exec rm {} \;'%(pathEnv))    #删除 _Translations folder 中包含的 .DS_Store 隐藏档；
	
	for root, dirs, files in os.walk(pathGlotEnv):
	    if '_NewLoc_org' not in dirs:
	        os.system('ditto %s %s'%(pathNL, pathNLbackup))
	    break
	# 备份 NL，如果已经存在备份则跳过
	
	fl = []
	for root, dirs, files in os.walk(path):
	    for f in files:
	        if '.xliff' in f:
	            fl.append(os.path.join(root, f))
	
	MailNotify = []
	for root, dirs, files in os.walk(pathEnv):
	    for m in files:
	        if 'MailNotify' in m:
	            MailNotify.append(os.path.join(root, m))
	
	for line1 in range(len(fl)):
	    opent = open(fl[line1],"r")
	    k1 = k1 + opent.read().count(key_word)
	opent.close()
	
	for line1 in range(len(fl)):
	    opent = open(fl[line1],"r")
	    k1 = k1 + opent.read().count(key_words)
	opent.close()
	
	#所有 xliff 中 state="new 的数量
	
	for line2 in range(len(fl)):
	    opent = open(fl[line2],"r")
	    k2 = k2 + opent.read().count(key_word2)
	opent.close()
	#所有 xliff 中 signed-off 的数量
	
	for line3 in range(len(fl)):
	    opent = open(fl[line3],"r")
	    k3 = k3 + opent.read().count(key_word3)
	opent.close()
	#所有 xliff 中 needs-review-translation 的数量
	
	os.system('find %s -name ".marking" -exec rm -R {} \;'%(pathEnv))   #删除 .marking 隐藏档
	
	print ''
	print '#' + '=' * 74 + '\n# xliff Check Result\n#' + '=' * 74
	report.write('#' + '=' * 74 + '\n# xliff Check Result\n#' + '=' * 74 + '\n')
	print 'New strings: %s\nNeeds-review-translation strings: %s\nSigned-off strings: %s\n'%(k1, k3, k2)
        report.write('New strings: %s\nNeeds-review-translation strings: %s\nSigned-off strings: %s\n\n'%(k1, k3, k2))
	
	print '#' + '=' * 74 + '\n# Locversion.plist Check Result\n#' + '=' * 74
	report.write('#' + '=' * 74 + '\n# Locversion.plist Check Result\n#' + '=' * 74 + '\n')
	locversioncheck(pathNB)    #调用 CheckLocversion 检查 NB 中是否缺失 Locversion.plist
	print ''
	
	print '#' + '=' * 74 + '\n# MailNotify Check Result\n#' + '=' * 74
	report.write('#' + '=' * 74 + '\n# MailNotify Check Result\n#' + '=' * 74 + '\n')
	Checkmail = open(MailNotify[0],"r")
	k4 = Checkmail.read().count('stanleyauyeung')   #搜索 MailNotify 中是否包含 stanley
	Checkmail.close()
	while k4 == 1:                                     #如果包含 stanley 则已经正常替换
	    print 'No Problem Found'
	    report.write('No Problem Found\n')
	#---- 备份 info 跟 projects ----
	    for root, dirs, files in os.walk(pathEnv):
	        if 'Info_org' not in dirs:
	            os.system('ditto %s %s'%(pathinfo, pathinfobackup))
	            os.system('ditto %s %s'%(pathprojects, pathprojectsbackup))
	#---- 备份 info 跟 projects ----
	        break
	    break
	else:
	    print '## ERROR: Please process your MailNotify.'
	    report.write('## ERROR: Please process your MailNotify.\n\n')
	print ''
	
	print 'Language: ' + langs + '\n'
	
	#---- check tool version ----
	url = 'http://10.4.2.6/wiki/pages/01Y8Y6S81/Envtester.html'
	try:
	    response = urllib2.urlopen(url, timeout = 5)
	    if 'Envtester3.4' in response.read():
	        print 'Envtester verison: 3.5'
	        report.write('\n\nEnvtester verison: 3.5\n')
	
	    else:
	        print 'The new version has been released to: \nhttp://10.4.2.6/wiki/pages/01Y8Y6S81/Envtester.html\nPlease update immediately.'
	        report.write('\nThe new version has been released to: \nhttp://10.4.2.6/wiki/pages/01Y8Y6S81/Envtester.html\nPlease update immediately.\n')
	except urllib2.URLError,e:
	    print e.reason, '\nPlease connect to intranet for version info.'
	    report.write(e.reason + '\n\nPlease connect to intranet for version info.\n')
	
	report.close

def tittle():
    print '*' * 70
    print 'You are using the script Envtester to detect you project folder.'
    print '*' * 70

tester(sys.argv[1])