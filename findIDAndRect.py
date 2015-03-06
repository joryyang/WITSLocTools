#!/usr/bin/env python
#coding = utf-8

import re
import sys
import os

keyWordArr=["textField","button"]
keyWordArr2=["NSButton","NSTextField"]


def FindIDAndRect(string):
	ID=re.findall("id=\"([\w\W]*?)\"",string)
	x=re.findall("x=\"([\w\W]*?)\"",string)
	y=re.findall("\" y=\"([\w\W]*?)\"",string)
	width=re.findall("width=\"([\w\W]*?)\"",string)
	height=re.findall("height=\"([\w\W]*?)\"",string)
	title=re.findall("title=\"([\w\W]*?)\"",string)
	rect=[x,y,width,height]
	return ID,rect,title

def findXYWH(frame):
	x=frame[1:frame.find(",")]
	temp=frame[frame.find(","):]
	y=temp[2:temp.find("},")]
	temp1=temp[temp.find("},")+3:]
	w=temp1[1:temp1.find(",")]
	temp2=temp1[temp1.find(","):]
	h=temp2[2:-1]
	return x,y,w,h

def findTitle(string):
	title=re.findall("<string key=\"NSContents\">([\w\W]*?)</string>",string)
	return title

def findIDAndrect2(string):
	x=""
	y=""
	width=""
	height=""
	frame=re.findall("<string key=\"NSFrame\">{([\w\W]*?)}</string",string)
	if len(frame)!=0:
		temp=frame[0]
		x,y,width,height=findXYWH(temp)
	return x,y,width,height
	

def findResult(path):
	resultArr=[]
	designPath="%s/designable.nib"%path
	if os.path.exists(designPath):
		strings=open(designPath,"r").read()
		for aa in keyWordArr:
			result=re.findall("<%s ([\w\W]*?)</%s>"%(aa,aa),strings)
			if result:
				for bb in result:
					ID,Rect,Title=FindIDAndRect(bb)
					if len(Title)!=0 and len(Rect[0])!=0:
						temp=[]
						if aa=="textField":
							temp.append("textfield")
						else:
							temp.append("button")
						temp.append([Rect[0][0],Rect[1][0],Rect[2][0],Rect[3][0]])
						temp.append(Title[0])
						resultArr.append(temp)
		for cc in keyWordArr2:
			result = re.findall("<object class=\"%s\"([\w\W]*?)<bool key=\"NSAllowsLogi"%cc,strings)
			if result:
				for dd in result:
					x,y,width,height=findIDAndrect2(dd)
					title=findTitle(dd)
					if len(title)!=0:
						temp=[]
						if cc=="NSButton":
							temp.append("button")
						else:
							temp.append("textfield")
						temp.append([x,y,width,height])
						temp.append(title[0])
						resultArr.append(temp)

	return resultArr

def test(path):
	nibs=[]
	resultArr=[]
	result={}
	for root,folders,files in os.walk(path):
		for aa in folders:
			if aa[-4:]==".nib":
				nibs.append(os.path.join(root,aa))
	for bb in nibs:
		if "en.lproj" not in bb and "English.lproj" not in bb and "Base.lproj" not in bb:
			resultArr.append(bb)
	for cc in resultArr:
		temp=findResult(cc)
		if temp:
			result[cc]=temp
	return result


def main(path):
	result=test(path)
	for aa in result:
		temp=result[aa]
		for bb in temp:
			print aa+"\t"+bb[0]+"\t"+bb[1][0]+"\t"+bb[1][1]+"\t"+bb[1][2]+"\t"+bb[1][3]+"\t"+bb[2]

main(sys.argv[1])



















