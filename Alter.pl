#!/usr/bin/perl
# Apple Inc.
# Author(s): Salem BEN YAALA
# Created: Thursday, April 29, 2010
# Modified: Thursday, May 20, 2010
# Description:
# 
# Usages:
# ./Alter.pl -h
# ./Alter.pl -v
# ./Alter.pl -c ar.xml -i old/file.nib -o new/file.nib
# ./Alter.pl -b -c ar.xml -i old/ -o new/
# ./Alter.pl -c ar.xml -i old/file.nib -o new/file.nib -l changes.log

use strict;
use warnings;

use Getopt::Long;

our $VERSION = "0.1";

use XML::LibXML;

use Alter;

my $help;
my $verbose;
my $bulk;
my $input;
my $output;
my $conf;
my $log;
my $version;
my $open;

GetOptions(
	"h|help" => \$help,
	"v|verbose" => \$verbose,
	"b|bulk" => \$bulk,
	"i|input=s" => \$input,
	"o|output=s" => \$output,
	"c|conf=s" => \$conf,
	"l|log=s" => \$log,
	"version" => \$version,
	"open" => \$open
);

sub _help {
	my $sText = "Usages: ". "\n";
	# $sText .= "\n";
	$sText .= "\t" . "./Alter.pl -h" . "\n";
	$sText .= "\t" . "./Alter.pl --version" . "\n";
	$sText .= "\t" . "./Alter.pl -c conf.xml -i old/file.nib -o new/file.nib [-v] [-l logdir] [-open]" . "\n";
	$sText .= "\t" . "./Alter.pl -b -c conf.xml -i old/ -o new/ [-v] [-l logdir]" . "\n";
	# $sText .= "\n";
	
	return $sText;
}

sub _usage {
	my $sText = "Bad usages." . "\n";
	$sText .= "\t" . "Check ./Alter.pl -h for help." . "\n";
	
	return $sText;
}

sub _version {
	my $sText = "Alter NIB Localization Tool v" . $VERSION . "\n";
	
	return $sText;
}

if ($help) { print _help();	exit; }
if ($version) {	 print _version(); exit; }
if (!$conf or !$input or !$output) { print _usage(); exit; }

if (!$log) {
	$log = "logs/";
}

if (!$verbose) {
	$verbose = 0;
}

#
my $oAlter = Alter->new($conf, $log, $verbose);

if ($bulk) {
	$oAlter->bulk($input, $output);
} else {
	$oAlter->file($input, $output);
}

if ($open and !$bulk) {
	`open $input`;
	`open $output`;
}

# ($#ARGV == 2) or die "Bad usage";

# my $sConfFile = shift @ARGV;
# my $sInNibFile = shift @ARGV;
# my $sOutNibFile = shift @ARGV;
# my $bVerbose = 1;