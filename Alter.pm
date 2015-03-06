#!/usr/bin/perl
# Apple Inc.
# Author(s): Salem BEN YAALA
# Created: Thursday, April 30, 2010
# Modified: Thursday, May 20, 2010
# Description:
# 
#

my $gAlterScriptFullPath = $0;
my $gAlterScriptPath = dirname($gAlterScriptFullPath) . "/";


# my $gIBPlugins = "--plugin-dir '/System/Library/Frameworks/AddressBook.framework/Versions/A/Resources/' --plugin-dir '/System/Library/Frameworks/Automator.framework/Versions/A/Resources/' --plugin-dir '/System/Library/Frameworks/Automator.framework/Versions/A/Resources/' --plugin-dir '/System/Library/Frameworks/DiscRecordingUI.framework/Versions/A/Resources/' --plugin-dir '/System/Library/Frameworks/OSAKit.framework/Versions/A/Resources/' --plugin-dir '/System/Library/Frameworks/QTKit.framework/Versions/A/Resources/' --plugin-dir '/System/Library/Frameworks/Quartz.framework/Versions/A/Frameworks/ImageKit.framework/Versions/A/Resources/' --plugin-dir '/System/Library/Frameworks/Quartz.framework/Versions/A/Frameworks/PDFKit.framework/Versions/A/Resources/' --plugin-dir '/System/Library/Frameworks/Quartz.framework/Versions/A/Frameworks/QuartzComposer.framework/Versions/A/Resources/' --plugin-dir '/System/Library/PrivateFrameworks/Assistant.framework/Versions/A/Resources/' --plugin-dir '/AppleInternal/Developer/Plugins/' --plugin-dir '/Developer/Plugins/'";
# my $gIBPlugins = "--plugin-dir '/System/Library/Frameworks/AddressBook.framework/Versions/A/Resources/' --plugin-dir '/System/Library/Frameworks/Automator.framework/Versions/A/Resources/' --plugin-dir '/System/Library/Frameworks/Automator.framework/Versions/A/Resources/' --plugin-dir '/System/Library/Frameworks/DiscRecordingUI.framework/Versions/A/Resources/' --plugin-dir '/System/Library/Frameworks/OSAKit.framework/Versions/A/Resources/' --plugin-dir '/System/Library/Frameworks/QTKit.framework/Versions/A/Resources/' --plugin-dir '/System/Library/Frameworks/Quartz.framework/Versions/A/Frameworks/ImageKit.framework/Versions/A/Resources/' --plugin-dir '/System/Library/Frameworks/Quartz.framework/Versions/A/Frameworks/PDFKit.framework/Versions/A/Resources/' --plugin-dir '/System/Library/Frameworks/Quartz.framework/Versions/A/Frameworks/QuartzComposer.framework/Versions/A/Resources/' --plugin-dir '/System/Library/PrivateFrameworks/Assistant.framework/Versions/A/Resources/' --plugin-dir '/AppleInternal/Developer/Plugins/'";
my $gIBPlugins = "";


our $VERSION = "0.1";

package Alter;

use strict;
use warnings;

use File::Basename;
use XML::LibXML;

sub new {
	
	my $oThis = {};
	bless $oThis;
	
	shift;
	$oThis->{"conf.file"} = shift;

	$oThis->{"masterlog.dir"} = shift;
	$oThis->{"verbose"} = shift;
	$oThis->{"color"} = shift;
	$oThis->{"open"} = shift;
		
	$oThis->{"template.plist"} = $gAlterScriptPath . "template.plist";
	
	$oThis->{"keys.plist"} = $gAlterScriptPath . "keys.plist";
	
	$oThis->{"parser"} = new XML::LibXML;
	
	return $oThis;
	
}

# void Alter::writeFile(string $sContent, $sOutFileName)
sub writeFile {
	
	my $oThis = shift;
	my $sInContent = shift;
	my $sOutFile = shift;
	
	# Todo: Check inputs and throw error if needed
	
	open FILE, ">", $sOutFile or die $!;
	print FILE $sInContent;
	close FILE;
	
}

# void Alter::cleanFile(string $sInFileName, string $sOutFileName)
# string Alter::cleanFile(string $sInFileName)
sub cleanFile {
	my $oThis = shift;
	my $sInFile = shift;
	my $sOutFile = shift;
	
	my $oDoc = $oThis->{"parser"}->load_xml(
		location => $sInFile
	);
	
	my $stoSave = $oDoc->toString();
	$stoSave =~ s/[\t|\n]//g;
	
	if ($sOutFile) {
		$oThis->writeFile($stoSave, $sOutFile);
	} else {
		return $stoSave;
	}
}

# void Alter::file(string $sInFileName, string $sOutFileName)
sub file {
	
	my $oThis = shift;
	
	$oThis->{"in.file"} = shift;
	$oThis->{"out.file"} = shift;
	
	(-d $oThis->{"in.file"}) or die "Input file does't exist." . "\n";
	# (-d $oThis->{"out.file"}) or die "Output file does't exist." . "\n";
	
	$oThis->{"log.dir"} = $oThis->{"masterlog.dir"} . "/" . basename($oThis->{"in.file"}, ".nib");
	
	(-d $oThis->{"log.dir"}) and `rm -r '$oThis->{"log.dir"}'`;
	(-d $oThis->{"log.dir"}) or `mkdir -p '$oThis->{"log.dir"}'`;
	
	# print "In: " . $oThis->{"in.file"} . "\t" . " Out: " . $oThis->{"out.file"} . "\n";

	$oThis->getExportPlistFromXML();
	$oThis->exportPlist();
	$oThis->apply();
	$oThis->importNib();
	
}

# void Alter::bulk(string $sInDirName, string $sOutDirName)
sub bulk {
	
	my $oThis = shift;
	
	$oThis->{"in.dir"} = shift;
	$oThis->{"out.dir"} = shift;
	
	$oThis->{"bulk"} = 1;
	
	(-d $oThis->{"in.dir"}) or die "Input directory does't exist." . "\n";
	(-d $oThis->{"out.dir"}) or die "Output directory does't exist." . "\n";
	
	my $s = $oThis->{"in.dir"};
	
	# TODO: clear path to get always (or not) a / at the end
	# my @files = <$s/*.nib>;
	
	foreach my $file (<$s/*.nib>) {
		$oThis->file($file, $oThis->{"out.dir"} . basename($file));
	}
	
}

# void Alter::log(string $sNSObjectName, string $sNSObjectID, string $sMessage)
sub log {
	my $oThis = shift;
	my $sNSObjectName = shift;
	my $sNSObjectID = shift;
	my $sMessage = shift;
	
	my $sLogFileName = $oThis->{"log.dir"} . "/" . $sNSObjectName . "." . $sNSObjectID . ".log";
	
	# Do better. Very very bad for performence issues
	open FILE, ">>", $sLogFileName or die $!;
	print FILE $sMessage . "\n";
	close FILE;
	
}

# void Alter::getExportPlistFromXML([string $sExportPlistFile])
sub getExportPlistFromXML {
	
	my $oThis = shift;
	my $sOutPlistFile = shift;
	
	if ($sOutPlistFile) {
		$oThis->{"keys.plist"} = $sOutPlistFile;
	}
	
	my $oConf = $oThis->{"parser"}->load_xml(
		string => $oThis->cleanFile($oThis->{"conf.file"})
	);
	
	my $oPlist = $oThis->{"parser"}->load_xml(
		string => $oThis->cleanFile($oThis->{"template.plist"})
	);
	
	my $oDict = $oPlist->findnodes("/plist/dict")->get_node(1);
	
	# print $oConf->toString() . "\n";
	
	foreach my $oObject ($oConf->findnodes("/conf/object")) {
		
		my $oKey = $oObject->firstChild();
		my $oValues = $oKey->nextSibling();
		
		# Create key element
		my $o = $oPlist->createElement("key");
		$o->appendTextNode($oKey->to_literal());
		
		$oDict->appendChild($o);
		
		# print $oValues->toString() . "\n";
		
		my $oArray = $oPlist->createElement("array");

		foreach my $oValue ($oValues->findnodes("./key")) {
			
		 	my $o = $oPlist->createElement("string");
		 	$o->appendTextNode($oValue->to_literal());
			
			$oArray->appendChild($o);
		}
		
		$oDict->appendChild($oArray);
		
	}
	
	# print $oConf->toString() . "\n";
	# print $oPlist->toString() . "\n";
	
	$oThis->writeFile($oPlist->toString(), $oThis->{"keys.plist"});
	
}

# Export through ibtool and fix resulting 
# void Alter::exportPlist()
sub exportPlist {
	my $oThis = shift;

	$oThis->{"values.plist"} = $oThis->{"in.file"} . ".plist";
	
	my $sToFixe = `ibtool --export '$oThis->{"keys.plist"}' '$oThis->{"in.file"}'`;
	
	$sToFixe =~ s/[\t|\n]//g;
	
	#SA	if ($sToFixe =~ m/com.apple.ibtool.errors/) {
	#SA		print $sToFixe . "\n";
		
	#SA		die;
	#SA	}

	# print "export plist file generated..." . "\n";
	
	my $oValues = $oThis->{"parser"}->load_xml(
		string => $sToFixe
	);

	my @aNodeToSave = $oValues->findnodes("/plist/dict/dict");

	$oValues->findnodes("/plist/dict")->get_node(1)->unbindNode();
	
	my $oParent = $oValues->findnodes("/plist")->get_node(1);
	
	foreach my $oNode (@aNodeToSave) {
		$oParent->appendChild($oNode);
	}
	
	open FILE, ">", $oThis->{"values.plist"} or die $!;
	print FILE $oValues->toString();;
	close FILE;
	
	# print "export plist fixed..." . "\n";
}

sub apply {
	my $oThis = shift;
	
	($oThis->{"conf.file"}) or die $!;
	($oThis->{"values.plist"}) or die $!;

	my $oNewValues = $oThis->{"parser"}->load_xml(
		location => $oThis->{"conf.file"}
	);
	
	# Can do better
	my $sNewValues = $oNewValues->toString();
	$sNewValues =~ s/[\t|\n]//g;

	$oNewValues = $oThis->{"parser"}->load_xml(
		string => $sNewValues
	);
	
	my $oOldValues = $oThis->{"parser"}->load_xml(
		location => $oThis->{"values.plist"}
	);
	
	# We don't want them anymore, moreover ibtool --import don't like it
	foreach my $o ($oNewValues->findnodes("/conf/object/attributes/key[. = 'class.description']")) {
		$o->unbindNode();
	}

	foreach my $oNewObject ($oNewValues->findnodes("/conf/object/name")) {
		
		my $sNSObjectName = $oNewObject->to_literal(); 
		my $oNewObjectValues = $oNewObject->getNextSibling(); # /conf/object/array
		
		# print "Current NSObject: " . $sNSObjectName . "\n";

		foreach my $oOldObjectValues ($oOldValues->findnodes("/plist/dict/dict[string = '$sNSObjectName']")) {
			
			# $sNSObjectName; # NSObjectName
			my $sNSObjectID = $oOldObjectValues->getPreviousSibling()->to_literal(); # NSObjectID 
			
			foreach my $oOldObjectValue ($oOldObjectValues->getChildnodes()) { # /plist/dict/dict/*
				
				if ($oOldObjectValue->to_literal() eq "class.description") {
					
					$oOldObjectValue->getNextSibling()->unbindNode(); # /plist/dict/dict/key
					$oOldObjectValue->unbindNode(); # /plist/dict/dict/[string | integer]
					
				} elsif ($oOldObjectValue->getName() eq "key") { # /plist/dict/dict/key
					
					my $oNewObjectKey = $oNewObjectValues->findnodes("./key[. = '" . $oOldObjectValue->to_literal() . "']")->get_node(1);
					
					if ($oNewObjectKey) {
						my $oNewObjectValue = $oNewObjectKey->getNextSibling();
						
						my $sNewObjectValue = undef;
						
						if ($oNewObjectValue->getFirstChild()->hasChildNodes()) { # Trick
							# Array cases
							foreach my $oNewObjectCase ($oNewObjectValue->findnodes("./if")) {
								
								if ($oOldObjectValue->getNextSibling()->to_literal() eq $oNewObjectCase->to_literal()) {
									# Log
									$oThis->log($sNSObjectName, $sNSObjectID, "Changed " . $oOldObjectValue->to_literal() . " from " . $oOldObjectValue->getNextSibling()->to_literal() . " to " . $oNewObjectCase->getNextSibling()->to_literal() . ".");
									
									$sNewObjectValue = $oNewObjectCase->getNextSibling()->to_literal();
									
									last;
								}
								
							}

						} else {
							# Set value
							# Log
							$oThis->log($sNSObjectName, $sNSObjectID, "Set " . $oOldObjectValue->to_literal() . " to " . $oNewObjectValue->to_literal() . ". Old value was " . $oOldObjectValue->getNextSibling()->to_literal() . ".");
							
							$sNewObjectValue = $oNewObjectValue->to_literal();
						}
						
						if (defined $sNewObjectValue) {
							my $o = $oNewValues->createElement("integer");
							$o->appendTextNode($sNewObjectValue);
							$oOldObjectValue->getNextSibling()->replaceNode($o);
						}
						
					}
				}

			}
			
		}
		
	}
	
	open FILE, ">", $oThis->{"values.plist"} or die $!;
	print FILE $oOldValues->toString();
	close FILE;
	
	# print "new values applied..." . "\n";
}

sub importNib {
	my $oThis = shift;
	
	($oThis->{"values.plist"}) or die $!;
	
	my $sOutput = `ibtool --import '$oThis->{"values.plist"}' --write '$oThis->{"out.file"}' '$oThis->{"in.file"}'`;
	
	if ($sOutput =~ m/com.apple.ibtool.errors/) {
		#SA	print $sOutput . "\n";
		print "\t#Error: cannot localize\n";
		
		# `rm $oThis->{"keys.plist"}`;
		# `rm $oThis->{"values.plist"}`;
		# `rm -r $oThis->{"new.plist"}`;
		#SA die;
	}
	else
	{
		print "\tNew nib file created..." . "\n";
	}

	# Not a very elegent solution. See for better...
	#SA	if ($oThis->{"color"} == 1) {
	#SA		`xattr -wx com.apple.FinderInfo '00 00 00 00 00 00 00 00 00 04 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00' '$oThis->{"in.file"}'`;
	#SA	}
}
