#!/usr/bin/perl

# Contacts
# Kaipei Chang  <kaipei@apple.com>
# Hide Tanaka   <hide@apple.com>

use strict;
use warnings;
use Getopt::Long;
use Foundation;

use constant NSUTF8StringEncoding => 4;
use constant NSPropertyListImmutable => 0;
use constant NULL => undef;

# initialize variables
# my $rel_tool_path = 'usr/bin/ibtool';
my $xcode_select_path = '/usr/bin/xcode-select';
my $xcrun_path = '/usr/bin/xcrun';
my $xcode_folder = undef;
my $ibtool = undef;
my $debug = undef;
my $verbose = undef;
my ($glotenv, $xcode, @allFiles, $lang, $isMac, $help);

# get options
GetOptions ("glotenv=s" => \$glotenv, #glotenv is mandatory
            "xcode=s"  => \$xcode, #xcode is optional
            "help" => \$help,
            "verbose" => \$verbose,
            "debug" => \$debug
            ) or die "$!\nSee the usage with --help option.\n";

if (!-e $glotenv) {
	warn "ERROR: $glotenv not found.\n";
	exit(1);
} else {
	print "\$glotenv = $glotenv\n" if ($debug);
}

# check if xcode-select exists and is executable
if (!-e $xcode_select_path) {
	warn "ERROR: $xcode_select_path not found.\n";
	exit(1);
} elsif (! -x $xcode_select_path) {
	warn "ERROR: Can't execute $xcode_select_path.\n";
	exit(1);
}

# check if xcrun exists and is executable
if (!-e $xcrun_path) {
	warn "ERROR: $xcrun_path not found.\n";
	exit(1);
} elsif (!-x $xcrun_path) {
	warn "ERROR: Can't execute $xcrun_path.\n";
	exit(1);
}

# current Xcode path
chomp($xcode_folder = `$xcode_select_path --print-path`);
if ($? != 0) {
	warn "ERROR: $xcode_select_path returned unexpected error.\n";
	exit(1);
} else {
	print "\$xcode_folder = $xcode_folder\n" if ($debug);
}

if (!-d $xcode_folder) {
	warn "ERROR: $xcode_folder is not a directory.\n";
	exit(1);
}

# current ibtool path
# $ibtool = "$xcode_folder/$rel_tool_path";
chomp($ibtool = `$xcrun_path --find ibtool`);
if ($? != 0) {
	warn "ERROR: $xcrun_path returned unexpected error.\n";
	exit(1);
} else {
	print "\$ibtool = $ibtool\n" if ($debug);
}

# Print the ibtool path & version.
print '-' x 30 ."\n";
print "The ibtool path = $ibtool\n";
my $output = `$ibtool --version`;
if ($verbose) {
	print "$output\n";
} else {
	my $ns_string = NSString->alloc()->initWithCString_encoding_($output,NSUTF8StringEncoding);
	my $ns_data = $ns_string->dataUsingEncoding_(NSUTF8StringEncoding);
	my $plist = NSPropertyListSerialization->propertyListWithData_options_format_error_($ns_data,NSPropertyListImmutable,NULL,NULL);
	my $ns_dictionary = $plist->objectForKey_('com.apple.ibtool.version');
	my $short_bundle_version = $ns_dictionary->objectForKey_('short-bundle-version')->description()->UTF8String();
	my $bundle_version = $ns_dictionary->objectForKey_('bundle-version')->description()->UTF8String();
	print "The ibtool version = $short_bundle_version ($bundle_version)\n";
}
print '-' x 30 ."\n";

# Conversion
my $newLoc = $glotenv."/_NewLoc";
my $newBase = $glotenv."/_NewBase";
if (`find $newLoc  -type d | grep -vF "English.lproj" | grep -vF "en.lproj" | grep ".lproj" | tail -n 1` =~ /.*\/(.*\.lproj)/) {$lang = $1}; #get project language name
print "\$lang = $lang\n" if ($debug);

# determine if it's a Mac or Win project. It depends on which is found, xib or nib.
@allFiles = `find $newBase -name "*.xib" -type f`; # look for xib first.
if(@allFiles) { #if xib is found.
	$isMac = 0; # it is a Win project. 
} else {
	@allFiles = `find $newBase -name "*.nib" -type d`; # look for nib, then.
	$isMac = 1; # it is a Mac project.
}
print "\$isMac = $isMac\n" if ($debug);

foreach (@allFiles) {
	chomp($_);
	my $newBaseItxib = $_;
	if($isMac) {
		$newBaseItxib =~ s/\.nib/\.itxib/;
	} else {
		$newBaseItxib =~ s/\.xib/\.itxib/;
	}

	if(-e $newBaseItxib) { #Only convert the file when ITXIB in NB exists
		my $newLocFile = $_;
		$newLocFile =~ s/\/_NewBase\//\/_NewLoc\//;
		$newLocFile =~ s/\/English.lproj\//\/$lang\//;
		$newLocFile =~ s/\/en.lproj\//\/$lang\//;
		
		my $newLocItxib = $newLocFile;
		if($isMac) { $newLocItxib =~ s/\.nib/\.itxib/; }
		else { $newLocItxib =~ s/\.xib/\.itxib/; }

		my $command = "$ibtool --output-format binary1 --objects --hierarchy $newLocFile > $newLocItxib";
		if (!system($command)) {
			# conversion went well
			if ($verbose) {
				print "[SUCCESS] $command\n";
			} else {
				$newLocFile =~ s/$glotenv\///;
				print "[SUCCESS] $newLocFile ---> itxib\n";
			}
		} else {
			# conversion went wrong
			if ($verbose) {
				print "[FAILURE] $command\n";
			} else {
				$newLocFile =~ s/$glotenv\///;
				print "[FAILURE] $newLocFile -x-> itxib\n";
			}
		}
	}
}

print '-' x 30 ."\n";

#iTunes_itxib_tool --glotenv ~/myGlotEnv/ --xcode /Xcode4.5/Xcode.app/


