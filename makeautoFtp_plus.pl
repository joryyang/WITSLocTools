#!/usr/bin/perl
use utf8;
binmode(STDIN, ':encoding(utf8)');
binmode(STDOUT, ':encoding(utf8)');
binmode(STDERR, ':encoding(utf8)');
use open OUT=>':encoding(utf8)';
use Encode; 
use Encode::Guess qw/utf8 utf-16le/; 


if ($#ARGV < 0) {
    print "根据 xxx-checkLocFilesForLocDir.txt 和 checktarfile.txt 生成 autoFtp-CC.txt\n";
    print "用法：MakeautoFtp <Reports_CC 目录路径>,请将 checkLocFilesForLocDir report 放入 Reports_CC 目录 和 Check Tarballs 后使用\n";
    print "例如：MakeautoFtp /Volumes/ProjectsHD/_LocProj/SULionDuchess_11D15_Duchess_SWLC2_2_123/GR-SULionDuchess11D15-111611-Duchess_SWLC2_2-GlotKit/LocEnv/Reports_GR\n";
	print "Version: 1.2\n";
	print "增加 GlotEnv_flverifierReport_Pro 检测\n";
	print "Version: 1.1\n";
	print "自动识别编码（utf－8 & utf-16）\n";
    exit 1;
}

#GetOptions(
#	"rp=s"					  => \$reportPath,
#)
#or die "$!";

my $reportsPath = $ARGV[0];
my $reportPath;

###########执行 tmxtester
$reportsPath =~ /(.*?\/LocEnv\/).*?/;
$TranslationsPath = "$1GlotEnv/_Translations/";
#if(-f "$ARGV[0]/tmxtester.txt")
#{
#	`rm -d -r $ARGV[0]/tmxtester.txt`;
#}
#if(!(-f "/Volumes/ProjectsHD/_LocProj/tmxtester"))
#{
#	print "将 tmxtester 复制到 /Volumes/ProjectsHD/_LocProj/ 自动运行 tmxtester。\n";
#}
#else
#{
#	system "/Volumes/ProjectsHD/_LocProj/tmxtester "$TranslationsPath" -R >> $ARGV[0]/tmxtester.txt";
#}
###########执行 tmxtester


opendir(MYDIR,$reportsPath) || die "Can't open $locenvpath:$!\n";
@dirlist = grep(!/^\.\.?$/,readdir MYDIR);
closedir(MYDIR);
@filegrep = grep(/.*checkLocFilesForLocDir.txt$/, @dirlist);
if(@filegrep > 1)
{
	print "发现多份 checkLocFilesForLocDir report 请将多余的删除再运行。\n";
	exit 1;
}
else
{
	$reportPath = $filegrep[0];
}


###########处理 autoFtp.txt

my $saveRS = $/;
undef $/;
open FILE, "$reportsPath/checktarfile.txt" or die "Can't open $reportsPath/checktarfile.txt.\n";
my $autoFtp = <FILE>;
close FILE;
$/ = $saveRS;

$autoFtp =~ /.*#=+\s*?# Bug Fix Comments\s.*#=+\s(.*?)#=+\s*?# Check Loc Files.*/s;
@BugFixComments = split(/\n|
/,$1);
@tazs = $autoFtp =~ /.*.tgz/g; 

$BugFixes ="";
$bugids = "";
foreach $taz (@tazs) 
{
	$taz =~ /# (.*?)\.tgz.*/;
	$tarname = $1;
	$1 =~ /(.*)_[^_]+\..*\.\d+_.+_\d+$/;
	$projectname = $1;
	#print "$tarname\n";
	$mycomment = 0;
	foreach $Comment (@BugFixComments) 
	{
		## WebKit
		if($Comment =~ /^# $projectname$/)
		{
			#print "mmmmm$Comment\n";
			$mycomment = 1;
			
		}
		else
		{
			#print "nnnnnn$Comment\n";
		}
		if($mycomment)
		{
			#print "mmmmm$Comment\n";
			if($Comment =~ /<rdar:\/\/problem\/(\d+)>/)
			{
				if(length $bugids >0)
				{
					$bugids = $bugids . ", $1";
				}
				else
				{
					$bugids = $tarname . ".tgz - $1";
				}
			}
			if($Comment =~ /^#[-]{8,}/)
			{
				$mycomment = $mycomment + 1;
				if($mycomment == 3)
				{
					last;
				}
			}
		}
	}
	if(length $bugids >0)
	{
		$BugFixes = $BugFixes . "$bugids\n";
		$bugids = "";
	}
}
 my $saveRS = $/;
undef $/;
 my $str_Line;                                
     open(FH,"$reportsPath/$reportPath") ;
     $str_Line = <FH>;
$/ = $saveRS;
$decoder=Encode::Guess->guess($str_Line)->name;
#use open IN=>':encoding(utf8)';#不设这个就用不了
open (FILE,"<:encoding($decoder)","$reportsPath/$reportPath") or die "Can't open $reportsPath/$reportPath.\n";
my @data = <FILE>;#读 report
close (FILE);

my $ln = 0;
my $rpout;
my $rptmp;

foreach $line (@data) 
{

	if($line =~ m/^=+\s*?/)#匹配==============================
	{
		$rptmp = $line;
		$lln = $ln;#记录当前第几行
		
		while(true)
		{
			if($lln > scalar(@data))
			{
				last;
			}
			if($data[$lln+1] =~ m/^=+\s*?/)#匹配==============================
			{
				if($rptmp =~ m/^=+\s(.*?\s){3}\s*?$/)
				{
					#匹配
					#======﻿========================
					#/Volumes/ProjectsHD/_LocProj/SULionDuchess_11D15_Duchess_SWLC2_2_GR_A1/GR-SULionDuchess11D15-111111-Duchess_SWLC2_2-GlotKit/LocEnv/GlotEnv/_NewLoc/PrintCenter/System/Library/CoreServices/Printer Setup Utility.app/Contents/Resources/el.lproj
					#------------------------------
					### INFO - SYNCHRONIZED locversion.plist
					#
					#
				}
				else
				{
					#print "\nccc$rptmp  ccc\n";	
					$rpout = $rpout . $rptmp;
				}
				last;
			}
			else
			{
			
					if($data[$lln+1] =~ m/\*{25,}s*?/)#匹配***********************************************
					{
						if($rptmp =~ m/^=+\s(.*?\s){3}\s*?$/)
						{
						
						}
						else
						{
							$rpout = $rpout . $rptmp;
						}
						last;
					}
					else
					{
						$rptmp = $rptmp . $data[$lln+1];
					}
				}
			$lln = $lln + 1;		
			
			}	
	}
	$ln = $ln + 1;
}

$rpout =~ s/(\s){3,}/\n\n\n/g;
$rpout =~ s/## INFO - SYNCHRONIZED locversion\.plist(\s){2,}//g;
	
$reportsPath =~ /.*Reports_(.*)/;
if(length $BugFixes > 0 || length $rpout >0)
{
	open (OUTFILE, "> $reportsPath/autoFtp-$1.txt") || die "Can't open $reportsPath/autoFtp.txt for output.\n";
	if(length $BugFixes > 0)
	{
		print "\n\n$BugFixes\n";
		print OUTFILE "=====================================================================\n";
		print OUTFILE "Bug Fixes\n";
		print OUTFILE "=====================================================================\n";
		print OUTFILE "$BugFixes\n\n";	
	}
	if(length $rpout >0)
	{
		print "\n${rpout}\n";	;
		print OUTFILE "=====================================================================\n";
		print OUTFILE "Notes\n";
		print OUTFILE "=====================================================================\n";
		print OUTFILE "$rpout";	
	}
	close (OUTFILE);
}
else
{
	`cp -R /Developer/Evolution/LocEnv/autoFtp-template.txt $reportsPath/autoFtp-$1.txt`;
	print "执行完毕!没有东西需要写入 autoFtp-$1.txt。请确认！\n\n";
}


use open OUT=>':encoding(utf16)';
use open IN=>':encoding(utf8)';

my @Filters = (                     #过滤正则,匹配的将过滤掉(会保存到 _Filtered.txt)
'\.\/.*\..*\s(?:(?:.*\s){4,4})',
#./InfoPlist.strings
#<file://localhost/Volumes/ProjectsHD/_LocProj/SULionDuchess_11D27_Duchess_SWLC5_GR_A1/GR-SULionDuchess11D27-120611-Duchess_SWLC5-GlotKit/LocEnv/GlotEnv//_OldBase/AccountsPref/System/Library/PreferencePanes/Accounts.prefPane/Contents/Resources/English.lproj/InfoPlist.strings>
#<file://localhost/Volumes/ProjectsHD/_LocProj/SULionDuchess_11D27_Duchess_SWLC5_GR_A1/GR-SULionDuchess11D27-120611-Duchess_SWLC5-GlotKit/LocEnv/GlotEnv//_NewBase/AccountsPref/System/Library/PreferencePanes/Accounts.prefPane/Contents/Resources/English.lproj/InfoPlist.strings>
#<file://localhost/Volumes/ProjectsHD/_LocProj/SULionDuchess_11D27_Duchess_SWLC5_GR_A1/GR-SULionDuchess11D27-120611-Duchess_SWLC5-GlotKit/LocEnv/GlotEnv//_OldLoc/AccountsPref/System/Library/PreferencePanes/Accounts.prefPane/Contents/Resources/el.lproj/InfoPlist.strings>
#<file://localhost/Volumes/ProjectsHD/_LocProj/SULionDuchess_11D27_Duchess_SWLC5_GR_A1/GR-SULionDuchess11D27-120611-Duchess_SWLC5-GlotKit/LocEnv/GlotEnv//_NewLoc/AccountsPref/System/Library/PreferencePanes/Accounts.prefPane/Contents/Resources/el.lproj/InfoPlist.strings>

'(?:\s\d+, (?:frameOrigin|layoutFrame|frameSize|cellSize|contentRectSize)\s)(?:(?:.*\s){7,7})' ,
#	102043, screenRect
#	<nib://Volumes/ProjectsHD/_LocProj/SULionDuchess_11D27_Duchess_SWLC5_GR_A1/GR-SULionDuchess11D27-120611-Duchess_SWLC5-GlotKit/LocEnv/GlotEnv//_OldBase/AccountsPref/System/Library/PreferencePanes/Accounts.prefPane/Contents/Resources/English.lproj/AccountsPref.nib?102043>
#	<nib://Volumes/ProjectsHD/_LocProj/SULionDuchess_11D27_Duchess_SWLC5_GR_A1/GR-SULionDuchess11D27-120611-Duchess_SWLC5-GlotKit/LocEnv/GlotEnv//_NewBase/AccountsPref/System/Library/PreferencePanes/Accounts.prefPane/Contents/Resources/English.lproj/AccountsPref.nib?102043>
#	<nib://Volumes/ProjectsHD/_LocProj/SULionDuchess_11D27_Duchess_SWLC5_GR_A1/GR-SULionDuchess11D27-120611-Duchess_SWLC5-GlotKit/LocEnv/GlotEnv//_OldLoc/AccountsPref/System/Library/PreferencePanes/Accounts.prefPane/Contents/Resources/el.lproj/AccountsPref.nib?102043>
#	<nib://Volumes/ProjectsHD/_LocProj/SULionDuchess_11D27_Duchess_SWLC5_GR_A1/GR-SULionDuchess11D27-120611-Duchess_SWLC5-GlotKit/LocEnv/GlotEnv//_NewLoc/AccountsPref/System/Library/PreferencePanes/Accounts.prefPane/Contents/Resources/el.lproj/AccountsPref.nib?102043>
#		OB/NB:{{0, 0}, {1920, 1178}}
#		OL:{{0, 0}, {1440, 878}}
#		NL:{{0, 0}, {1920, 1058}}

'((\s)([-_a-zA-Z0-9]*\.nib\/.*\.nib\s(?:(?:.*\s){3,3}[^\r\n]*)))+', 
#
#AccountsPref.nib/designable.nib
#<file://localhost/Volumes/ProjectsHD/_LocProj/SULionDuchess_11D27_Duchess_SWLC5_GR_A1/GR-SULionDuchess11D27-120611-Duchess_SWLC5-GlotKit/LocEnv/GlotEnv//_OldBase/AccountsPref/System/Library/PreferencePanes/Accounts.prefPane/Contents/Resources/English.lproj/AccountsPref.nib/designable.nib>
#<file://localhost/Volumes/ProjectsHD/_LocProj/SULionDuchess_11D27_Duchess_SWLC5_GR_A1/GR-SULionDuchess11D27-120611-Duchess_SWLC5-GlotKit/LocEnv/GlotEnv//_NewBase/AccountsPref/System/Library/PreferencePanes/Accounts.prefPane/Contents/Resources/English.lproj/AccountsPref.nib/designable.nib>
#<file://localhost/Volumes/ProjectsHD/_LocProj/SULionDuchess_11D27_Duchess_SWLC5_GR_A1/GR-SULionDuchess11D27-120611-Duchess_SWLC5-GlotKit/LocEnv/GlotEnv//_OldLoc/AccountsPref/System/Library/PreferencePanes/Accounts.prefPane/Contents/Resources/el.lproj/AccountsPref.nib/designable.nib>
#<file://localhost/Volumes/ProjectsHD/_LocProj/SULionDuchess_11D27_Duchess_SWLC5_GR_A1/GR-SULionDuchess11D27-120611-Duchess_SWLC5-GlotKit/LocEnv/GlotEnv//_NewLoc/AccountsPref/System/Library/PreferencePanes/Accounts.prefPane/Contents/Resources/el.lproj/AccountsPref.nib/designable.nib>


'(?:\s<nib|<file):.*\/\/(?:_OldLoc|_OldBase|_NewBase)\/.*>\s', 
#	<nib://Volumes/ProjectsHD/_LocProj/SULionDuchess_11D27_Duchess_SWLC5_GR_A1/GR-SULionDuchess11D27-120611-Duchess_SWLC5-GlotKit/LocEnv/GlotEnv//_OldBase/AccountsPref/System/Library/PreferencePanes/Accounts.prefPane/Contents/Resources/English.lproj/AccountsPref.nib?3100536>
#	<nib://Volumes/ProjectsHD/_LocProj/SULionDuchess_11D27_Duchess_SWLC5_GR_A1/GR-SULionDuchess11D27-120611-Duchess_SWLC5-GlotKit/LocEnv/GlotEnv//_NewBase/AccountsPref/System/Library/PreferencePanes/Accounts.prefPane/Contents/Resources/English.lproj/AccountsPref.nib?3100536>
#	<nib://Volumes/ProjectsHD/_LocProj/SULionDuchess_11D27_Duchess_SWLC5_GR_A1/GR-SULionDuchess11D27-120611-Duchess_SWLC5-GlotKit/LocEnv/GlotEnv//_OldLoc/AccountsPref/System/Library/PreferencePanes/Accounts.prefPane/Contents/Resources/el.lproj/AccountsPref.nib?3100536>

#<file://localhost/Volumes/ProjectsHD/_LocProj/SULionDuchess_11D27_Duchess_SWLC5_GR_A1/GR-SULionDuchess11D27-120611-Duchess_SWLC5-GlotKit/LocEnv/GlotEnv//_OldBase/WindowVousPref/System/Library/PreferencePanes/Expose.prefPane/Contents/Resources/English.lproj/Localizable.strings>
#<file://localhost/Volumes/ProjectsHD/_LocProj/SULionDuchess_11D27_Duchess_SWLC5_GR_A1/GR-SULionDuchess11D27-120611-Duchess_SWLC5-GlotKit/LocEnv/GlotEnv//_NewBase/WindowVousPref/System/Library/PreferencePanes/Expose.prefPane/Contents/Resources/English.lproj/Localizable.strings>
#<file://localhost/Volumes/ProjectsHD/_LocProj/SULionDuchess_11D27_Duchess_SWLC5_GR_A1/GR-SULionDuchess11D27-120611-Duchess_SWLC5-GlotKit/LocEnv/GlotEnv//_OldLoc/WindowVousPref/System/Library/PreferencePanes/Expose.prefPane/Contents/Resources/el.lproj/Localizable.strings>

'(?:\/Volumes\/.*\.nib.*\.nib\s){1,}', 
#/Volumes/ProjectsHD/_LocProj/SULionDuchess_11D27_Duchess_SWLC5_GR_A1/GR-SULionDuchess11D27-120611-Duchess_SWLC5-GlotKit/LocEnv/GlotEnv/_NewLoc/Automator/Applications/Automator.app/Contents/Resources/Application Stub.app/Contents/Resources/el.lproj/ApplicationStub.nib/designable.nib
#/Volumes/ProjectsHD/_LocProj/SULionDuchess_11D27_Duchess_SWLC5_GR_A1/GR-SULionDuchess11D27-120611-Duchess_SWLC5-GlotKit/LocEnv/GlotEnv/_NewLoc/Automator/Applications/Automator.app/Contents/Resources/el.lproj/AMDocumentProgress.nib/designable.nib

'(?:\+\+\+ FocusedLocVerifier INFO.*\(a2\)\s){2,}',
#+++ FocusedLocVerifier INFO: US changed but Loc did NOT change. Is the change US specific one? (a2)

);




my $flreportPath = "$reportsPath/GlotEnv_flverifierReport.txt";

if (!(-f $flreportPath)) {
    $flreportPath = "$reportsPath/GlotEnv_flverifierReport_Pro.txt";
    if (!(-f $flreportPath)) {
	print "没有 GlotEnv_flverifierReport 退出。\n";
	exit 1;
    }
}




open (FILE, "< $flreportPath") or die "Can't open $flreportPath.\n";#"<:encoding(utf16)",
@reportPath = <FILE>;
close (FILE);

my $saveRS = $/;
undef $/;
open FILE, "$flreportPath" or die "Can't open $flreportPath.\n";
my $reportcontent = <FILE>;
close FILE;
$/ = $saveRS;

my $reportdel ="";

if(!$isdebug)
{
	foreach $filter (@Filters) 
	{
		$reportcontent =~ s/($filter)/reportdel("$1")/gme;
	}
}

sub reportdel
{
	$reportdel = $reportdel . @_[0];
	return "";
}

$flreportPath =~ /(.*?)([^\/]*?)\.txt/;
$outpath = $1;
if(length $reportcontent >0)
{
	open (OUTFILE, "> ".$outpath."FL_MUST_CHECK.txt") || die "Can't open reportcontent.txt for output.\n";
	print OUTFILE "$reportcontent";
	close (OUTFILE);
}
if(length $reportdel >0)
{
	open (OUTFILE2, "> ".$outpath."FL_QUICK_LOOK.txt") || die "Can't open reportdel.txt for output.\n";
	print OUTFILE2 "$reportdel";
	close (OUTFILE2);
}

