# Add some services here...
select(STDERR); $| = 1;
select(STDOUT); $| = 1;

# **All dirs returned end in "/"

# Functions available in Loc:
#  GetTProj($projname)
#  GetProjType($typename)
#  LocDir
#  ToMergeDir
#  RootDir($projname)		--use _Tier1
#  GetDictionary($lang)
#  InfoDir
#  Build
#  SetOutput(FILEHANDLE)
#  Tier1Projects
#  IsTier1Project
#  Lang2Letter($lang)
#  U2A($line)
#  A2U($line)
#  GetArgs(@items)
#  FindFiles($extension, [$language])
#  Run($command)
#  NewStringsFile
#  ReadStringsFile($file)
#  StringMaster($line)
#  ReadTFiles(@files)

# We need to bootstrap the package in the following way:
# -Find out where exactly this file sits
# -Make a few globals out of that data
# -Add the lib directory to @INC to pick up sub libs
# -Find and eval the Globals file
# -make some more globals

package Loc;

use Exporter;
@ISA = qw(Exporter);

@EXPORT = qw(Warning Debug Fatal);

# Loc globals (not externally accessible)

# These are mostly caches for easy access to data once calculated
my(@Projects);
my(@Exts);
my(%Dirs);

# Do dynamic searching for LocArchive
my($LocDir);
foreach $inc(@INC) {
	if (-e "$inc/Loc.pm") {
		# Resolve the path fully.
		my($cwd);
		chop($cwd = `pwd`);
		chdir($inc);
		chop($LocDir = `pwd`);
		$LocDir =~ s#/locbin$##;
		chdir($cwd);
		last;
	}
}

# Add locbin/lib to @INC so we can find sub libs
unshift(@INC, "$LocDir/locbin/lib");

my($InfoDir) = "$LocDir/Info";
my($Output) = "STDERR";

# On init, load the globals file
# Enclose in a do-block to avoid cluttering namespace
my(@Langs);
my($BTrain, $BTier, $BTarFormat);

do {
	my(%globals);
	my($globfile) = "$InfoDir/Globals";
	if (-e $globfile) {
		if (!open($globfile, $globfile)) {
			print "### Error loading Globals file.\n";
			return(0);
		}
		my($save) = $/;
		undef($/);
		my($line) = <$globfile>;
		close($globfile);
		$/ = $save;
		%globals = eval($line);
		if (!%globals) {
			print "### Error reading Globals file.\n";
			return(0);
		}
	}	
	@Langs = @{$globals{'Languages'}};
	$BTrain = $globals{'Train'};
	$BTier = $globals{'Tier'};
	$BTarFormat = $globals{'TarFormat'};
};

my($MainRcDir) = "/private/Network/Servers/seaport/release/Software/Updates/$BTrain";

$Dirs{'LocDir'} = "$LocDir/";
$Dirs{'InfoDir'} = "$InfoDir/Projects/";
$Dirs{'MainRcDir'} = "$MainRcDir/";
$Dirs{'MergeDir'} = "$LocDir/Summary/";
$Dirs{'MergeDirFull'} = "$LocDir/SummaryAD/";

# ********************************************************************************
# General utilities

# ================================================================================
# Returns the path to global dictionary for the specified language.

sub GetDictionary {
	my($lang) = $_[0];
	
	"$LocDir/Dictionaries/English-$lang.strings";
}


# ================================================================================
# Returns the current build name

sub Build {
	$BTrain;
}

# ================================================================================
# Returns the current Tier number

sub Tier {
	$BTier;
}

# ================================================================================
# Returns the current Tier number

sub TarFormat {
	$BTarFormat;
}

# ================================================================================
# Sets the output to the desired handle.  Could be STDOUT, STDERR (default), an
# opened filehandle or pipe, or something undefined to suppress output

sub SetOutput {
	$Output = $_[0];
}

# ================================================================================
# Some default output functions to maintain consistency

sub Fatal {
	print "Fatal: $_[0]\nExiting.\n";
	exit(1);
}

sub Warning {
	print "Warning: $_[0]\nContinuing anyway.\n";
}

# The technique of using a functiopn pointer was complicated and not really
# worth the effort.
sub Debug {
# 	my($package, $file, $lineno) = caller;
# 	($file) = $file =~ /([^\/]+)$/;
# 	print "Debug ($file $lineno): $_[0]\n" if ($main::Debug);
	print "Debug: $_[0]\n" if ($main::Debug);
}


# ================================================================================
# Returns the various global paths

sub Dir {
	my($dir) = $_[0];
	
	# Better to return LocDir on error than to let things happen at root
	if ($Dirs{$dir}) {
		return($Dirs{$dir});
	} else {
		return($Dirs{'LocDir'});
	}
}

# ================================================================================
# Gives the abbreviation for a language.

sub Lang2Letter {
	my($lang) = $_[0];
	my($iso_lang);
	
	if ($lang =~ /[a-z][a-z]|[a-z][a-z]_[A-Z][A-Z]/) { # ISO code?
		$iso_lang = &ISO2Lang($lang);
		$iso_lang = $lang if (!$iso_lang);
	}
	my(%langs) = (  'French' => 'FU',
			'German' => 'D',
			'Japanese' => 'J',
			'Dutch' => 'N',
			'Italian' => 'T',
			'Spanish' => 'E',
			'Swedish' => 'S',
			'Korean' => 'KH',
			'Danish' => 'DK',
			'Norwegian' => 'H',
			'Portuguese' => 'PT',
			'Brazilian' => 'BR',
			'Finnish' => 'K',
			'SimpChinese' => 'CH',
			'TradChinese' => 'TA',
			'Czech' => 'CZ',
			'Polish' => 'PL',
			'Bulgarian' => 'BG',
			'Hungarian' => 'MG',
			'Romanian' => 'RO',
			'Ukranian' => 'UK',
			'Russian' => 'RS',
			'Greek' => 'GR',
			'Turkish' => 'TU',
			'Arabic' => 'AR',
			'Hebrew' => 'HB',
			'Thai' => 'TH',
			'Icelandic' => 'IS',
			'Croatian' => 'CR'
			);
	
	return($langs{$iso_lang});
}

# ================================================================================
# Gives the language for the ISO code.   (03082001: Mic Kimbara)

sub ISO2Lang {
	my($iso_lang) = $_[0];
	
	my(%langs) = (  'zh_TW'		=> 'TradChinese',
			'zh_CN'		=> 'SimpChinese',
			'ko'		=> 'Korean',
			'da'		=> 'Danish',
			'sv'		=> 'Swedish',
			'fi'		=> 'Finnish',
			'no'		=> 'Norwegian',
			'en'		=> 'English',
			'ko_KR'		=> 'Korean',
			'pt'		=> 'Brazilian',
			'pt_PT'		=> 'Portuguese',
			'da_DK'		=> 'Danish',
			'sv_SE'		=> 'Swedish',
			'fi_FI'		=> 'Finnish',
			'no_NO'		=> 'Norwegian',
			'en_US'		=> 'English',
			'fr'		=> 'French',
			'de'		=> 'German',
			'ja'		=> 'Japanese',
			'es'		=> 'Spanish',
			'nl'		=> 'Dutch',
			'it'		=> 'Italian',
			'cs'		=> 'Czech',
			'pl'		=> 'Polish',
			'bg'		=> 'Bulgarian',
			'hu'		=> 'Hungarian',
			'ro'		=> 'Romanian',
			'uk'		=> 'Ukranian',
			'ru'		=> 'Russian',
			'el'		=> 'Greek',
			'tr'		=> 'Turkish',
			'ar'		=> 'Arabic',
			'he'		=> 'Hebrew',
			'th'		=> 'Thai',
			'is'		=> 'Icelandic',
			'hr'		=> 'Croatian'
			);
	
	return($langs{$iso_lang});
}

# ================================================================================
# Gives the language for the ISO code.   (03082001: Mic Kimbara)

sub Lang2ISO {
	my($iso_lang) = $_[0];
	
	my(%langs) = (  'TradChinese'	=> 'zh_TW',
			'SimpChinese'	=> 'zh_CN',
			'Korean'	=> 'ko',
			'Brazilian'	=> 'pt',
			'Portuguese'	=> 'pt_PT',
			'Danish'	=> 'da',
			'Swedish'	=> 'sv',
			'Finnish'	=> 'fi',
			'Norwegian'	=> 'no',
			'English'	=> 'en',
			'French'	=> 'fr',
			'German'	=> 'de',
			'Japanese'	=> 'ja',
			'Spanish'	=> 'es',
			'Dutch'		=> 'nl',
			'Italian'	=> 'it',
			'Czech' 	=> 'cs',
			'Polish' 	=> 'pl',
			'Greek' 	=> 'el',
			'Hungarian' 	=> 'hu',
			'Romanian' 	=> 'ro',
			'Ukranian' 	=> 'uk',
			'Russian' 	=> 'ru',
			'Greek'		=> 'el',
			'Turkish'	=> 'tr',
			'Arabic'	=> 'ar',
			'Hebrew'	=> 'he',
			'Thai'		=> 'th',
			'Icelandic'	=> 'is',
			'Croatian'	=> 'hr'
			);
	
	return($langs{$iso_lang});
}

# ================================================================================
# A quick-n-dirty way to translate unicode to ascii.  Kills all nulls, which
# may give strange results on non Roman text.

sub U2A {
	my($line) = $_[0];
	my($i, $result);
	my($strnum, $outstr, $i, $uchar);
	my(%acconv) = ( "\x20\x26", "\xc9", "\x20\x22", "\xa5",
			"\x00\xae", "\xa8", "\x21\x22", "\xaa",
			"\x00\xab", "\xc7", "\x00\xbb", "\xc8",
			"\x20\x1c", "\xd2", "\x20\x1d", "\xd3",
			"\x20\x18", "\xd4", "\x20\x19", "\xd5",
			"\x02\xda", "\xfb" );

	$line =~ s/\376\377//g;
	$result = "";
	for ($i = 0; $i < length($line); $i+=2) {
		$uchar = substr($line, $i, 2);
		$achar = $acconv{$uchar};
		if ($achar eq "") {
			$uchar =~ s/\0//g;
			$result .= $uchar;
		} else {
			$result .= $achar;
		}
	}
	$result;
}

# ================================================================================
# A quick-n-dirty way to translate ascii to unicode.  Puts nulls between all 
# characters, which may give strange results on non Roman text.

sub A2U {
	my($line) = $_[0];
	my($achar, $uchar, $result);
	my(%ucconv) = ( "\xc9", "\x20\x26", "\xa5", "\x20\x22",
			"\xa8", "\x00\xae", "\xaa", "\x21\x22",
			"\xc7", "\x00\xab", "\xc8", "\x00\xbb",
			"\xd2", "\x20\x1c", "\xd3", "\x20\x1d",
			"\xd4", "\x20\x18", "\xd5", "\x20\x19",
			"\xfb", "\x02\xda" );

	$result = "";
	foreach $achar (split(//, $line)) {
		$uchar = $ucconv{$achar};
		if ($uchar eq "") {
			$result .= "\0".$achar;
		} else {
			$result .= $uchar;
		}
	}
	$result;
}

# ================================================================================
# Gives a list of the global languages (as defined in the Globals file).

sub GlobalLangs {
	@Langs;
}


# ********************************************************************************
# Specific to proj info files...

# ================================================================================
# Returns a list of all Tier1 projects

sub Tier1Projects {
	my($file);
	
	if (!$Projects[0]) {
		opendir($InfoDir, "$InfoDir/Projects");
		while ($file = readdir($InfoDir)) {
			next if ($file =~ /^\./);
			next if (-d "$InfoDir/Projects/$file");
			next if (-l "$InfoDir/Projects/$file");
			push(@Projects, $file);
		}
		closedir($InfoDir);
	}
	@Projects;	
}

# ================================================================================
# Returns a 1 if the specified project name is being currently localized.
	
sub IsTier1Project {
	my($proj) = $_[0];
	
	if (-e "$InfoDir/Projects/$proj") {
		return(1);
	}
	return(0);
}

# ================================================================================
# Loads the project info into a hash and returns that hash.
# The hash is blessed into the LocProj package and can use
# the associated methods.
# Takes in a project name (like "Mail")

sub GetTProj {
	my($name) = $_[0];
	my($infofile, $line);
	my($save, $proj);
		
	$infofile = "$InfoDir/Projects/$name";
	if (!open($infofile, $infofile)) {
		print $Output "Loc.pm: Error opening project $name\n";
		return(undef);
	}
	
	$save = $/;
	undef($/);
	$line = <$infofile>;
	close($infofile);
	$/ = $save;
	
	$proj = eval($line);
	if (!$proj) {
		print $Output "Loc.pm: Error eval'ing project $name\n";
		return(undef);
	}

	my %projHash = %{$proj};
	if ($projHash{'RcName'} !~ $name) {
		print $Output "Loc.pm: Bad project name: $name\n";
		return(undef);
	}
	
	require LocProj;
	bless($proj, "LocProj");
	
	return($proj);
}

# ********************************************************************************
# Specific to file extensions

# ================================================================================
# Returns a list of all known file extensions

sub FileExts {
	my($file);
	
	if (!$Exts[0]) {
		opendir($InfoDir, "$InfoDir/Files");
		while ($file = readdir($InfoDir)) {
			next if (-d $file);
			next if (-l $file);
			# Suppress "generic" as a file type...
			next if ($file eq 'generic');
			push(@Exts, $file);
		}
		closedir($InfoDir);
	}
	@Exts;	
}

# ================================================================================
# Loads the file type info into a hash and returns that hash.
# The hash is blessed into the LocFileType package and can use
# the associated methods.
# Takes in an extension name (like "nib")

sub GetFileExt {
	my($name) = $_[0];
	my($infofile, $line);
	my($save, $type);
	
	$infofile = "$InfoDir/Files/$name";
	$infofile = "$InfoDir/Files/generic" if (!-e $infofile);
		
	if (!open($infofile, $infofile)) {
		print $Output "Loc.pm: Error reading type $name\n";
		return(undef);
	}
	$save = $/;
	undef($/);
	$line = <$infofile>;
	close($infofile);
	$/ = $save;
	
	$type = eval($line);
	if (!$type) {
		print $Output "Loc.pm: Error eval'ing type $name\n";
		return(undef);
	}
	
	require LocFileType;
	bless($type, "LocFileType");
	
	return($type);
}

# ================================================================================
# Makes a new loc file, for whatever reason one might want

sub NewLocFile {
	my($path) = @_;
	my($locfile, $lang, $locpath);
	
	if ($path !~ /English/) {
		$path =~ s/\w+\.lproj/English.lproj/;
	}
	
	${$locfile}{'Paths'}{'English'} = $path;
	
	require LocFile;
	bless($locfile, 'LocFile');
	
	return($locfile);
}

# ================================================================================
# Returns the path project roots, after a build.
# Since English and Tier1 roots are mixed together, the _Tier1 must
# be included.  In practice, one never needs Tier1 roots, so no matter...

sub RootDir {
	my ($proj) = $_[0];
	my($latest);
	
	my($dir) = "/Network/Servers/seaport/release/".
	#"Updates/$BTrain/Current/Roots/$proj/";
	"Software/$BTrain/Roots/$proj/";
	
	open($dir, "ls -t $dir |");
	chop($latest = <$dir>);
	close($dir);
	$dir .= "$latest/";
	
	# Hack alert!
	# $dir = "/private/Network/Servers/seaport/release/Software/Kodiak/Updates/Kodiak1C5/Roots/$proj/";
	
	$dir;
}

# ********************************************************************************
# Advanced utilities

# ================================================================================
# Yet another way to process the argument list.  Takes a list of switches and 
# returns the values specified.  For example, a script is executed as:
#    % script.pl -arg1 Big -arg2 Fun
# with a call to GetArgs:
#   ($arg1, $arg2) = &Loc::GetArgs("-arg1", "-arg2");
# would put "Big" into $arg1 and "Fun" into $arg2.
# Anything that wasn't processed is slapped onto the end of the return list,
# which is useful for detecting errors:
#   ($arg1, $arg2, @err) = &Loc::GetArgs("-arg1", "-arg2");
# where extra stuff goes into @err.  Thus if @err is defined after that 
# operation, we probably have a usage error.  
# If there are commandline switches that don't have an associated value, then
# GetArgs may not be that useful...

# Also, may want to preserve @ARGV...
sub GetArgs {
	my(@items) = @_;
	my(@rets, %temp, $arg);
	
	foreach $item(@items) {
		$temp{$item} = '';
		push(@rets, '');
	}
	
	while ($arg = shift(@main::ARGV)) {
		# A secret feature!
		if ($arg eq '-Debug') {
			$main::Debug = 1;
			next;
		}
		if (defined($temp{$arg})) {
			$temp{$arg} = shift(@main::ARGV);
		} else {
			push(@rets, $arg);
		}
	}
	
	foreach $i(0..$#items) {
		$rets[$i] = $temp{$items[$i]};
	}
	
	@rets;			
}

# ================================================================================
# A common way to find files, since it's done so often.  Takes in an extension
# to look for, and possibly a language.  The extension will be something like
# "strings" or "nib", and the return value will be a list of all files that match.
# To look for all files, use "*" as the extension.  
# This searches in the current working dir, so it's usually wise to call chdir
# before calling FindFiles.

sub FindFiles {
	my($extension, $language) = @_;
	my($find, %files, $file, $ext);
	
	$find = "find . -name '*.$extension' -print |";
	if ($language) {
		$find .= " grep $language |";
	}

	open($find, $find);
	while($file = <$find>) {
		chop($file);
		next if (-d $file);
		$file =~ s#^\./##;						# Kill leading ./
		($ext) = $file =~ /\.(\w+)$/;
		$file =~ s#^(.*\.$ext)/.+$#$1# if ($ext);	# Kill *.nib/classes.nib, etc.
		$files{$file}++;
	}
	close($find);
	return(keys(%files));
}

# ================================================================================
# A different way to find files.  Performs the same basic function as FindFiles, 
# but returns a list of LocFile types instead of paths.  As such, can only look for 
# English files.
# Same usage as FindFiles.

sub FindEngFiles {
	my($extension) = @_;
	my($find, %files, $file, $ext, $subfile, $filename);
	
	$find = "find . -name '*.$extension' -print | grep English |";
	open($find, $find);
	while($filename = <$find>) {
		chop($filename);
		next if (-d $filename);
		# Kill CVS and *.*~ files
		next if ($filename =~ /CVS/);
		next if ($filename =~ /~$/);
		next if ($filename =~ /~\//);
		next if ($filename =~ /English-\w+\.strings/);
		
		# Kill leading ./
		$filename =~ s#^\./##;
						
		$subfile = $filename;
		($ext) = $filename =~ /\.(\w+)$/;
		$filename =~ s#^(.*\.$ext)/.+$#$1# if ($ext && $ext!='app');
		
		if (!$files{$filename}) {
			$file = &NewLocFile($filename);
			$files{$filename} = $file;
		} else {
			$file = $files{$filename};
		}
		
		if ($subfile ne $filename) {
			$file->AddSub($subfile);
		}
	}
	close($find);
	return(values(%files));
}


# ================================================================================
# Fork a process and run $command in it.
# Do this to allow main to catch ^C
# Returns 1 on success, 0 on err

sub Run {
	my(@commands) = @_;
	my($pid, $command);
	
	# Don't process first arg, because it will most likely
	# not be a filename
	for $i(1..$#commands) {
		$commands[$i] = "\'".$commands[$i]."\'";
#		$commands[$i] =~ s/ /\\ /g;
#		$commands[$i] =~ s/&/\\&/g;
	}
	$command = join(" ", @commands);
	
	# Should this be a Debug statement?  Or maybe a LibDebug?
	# print "Command = $command\n";
	
	$pid = fork;
	if (!defined($pid)) {
		print $Output "Loc.pm: Error on fork\n";
		return(0);
	}
	if (!$pid) {
		# Child here
		exec($command);
		# If exec fails, we need to exit with error
		exit(1);
	}
	# Parent here

	# wait was sometimes reaping some other child (which?), 
	# so replaced it with a blocking waitpid call
	#wait;
	waitpid($pid, 0);
	# Change retval to 1 on success
	# Allows me to use "if !Run() {err!}" syntax
	if ($?) {
		return(0);
	}
	return(1);
}

# ********************************************************************************
# Specific to strings files

# ================================================================================
# Returns an empty dictionary, blessed into the LocStrings package.  Suitable for
# adding strings to and then writing to disk.

sub NewStringsFile {
	my(%strings, $out);
	
	$out = \%strings;
	require LocStrings;
	bless($out, "LocStrings");
	return($out);
}

# ================================================================================
# Parse a strings file and return the dictioanry hash. The hash is blessed into the
# LocStrings package and all associated methods.  
# It will pop out unicode strings no matter what the input.  That works well for 
# ascii and unicode, but can cause problems for utf-8, so the user needs to beware.

sub ReadStringsFile {
	my($file) = $_[0];
	my(%strings, $in, $uline, $uniline, $title, $comment, $key, $phrase);
	my($tline, $ascii, $out, $num, $db);

	if(&IsXMLFormat($file) == 1)
	{
		$out = \%strings;
		require LocStrings;
		bless($out, "LocStrings");
		return($out);
	}
	
	if(!open($file, $file)) {
		print $Output "Loc.pm: Error reading strings file.\n";
		print $Output ">>> $file\n";
		return;
	}
	
	$in = $/;
	$/ = "\n";
	
	# Discover encoding first
	if (<$file> !~ /^\376\377/) {
		$ascii = 1;
	} else {
		$/ = "\0$/";
	}

	if ($ascii == 1) {
		my($return_r, $return_n);
		open($file, $file);
		$return_r = index(<$file>, "\r");
		open($file, $file);
		$return_n = index(<$file>, "\n");
		if ($return_r < $return_n) {
			$/ = "\r";
		}
		$/ = "\n" if ($return_r < 0);
		$/ = "\r" if ($return_n < 0);
	}
	
	open($file, $file);
	while($uline = <$file>) {
		chomp($uline);
		# print ">>>ASC($ascii):$uline\n";  ### Kimbara
		$ascline = $uline;
		if ($ascii) {
			$uline = &A2U($uline);
		}
		$uline =~ s/\376\377//g;
		$uline =~ s/\0$//;
		$tline++ if ($uline =~ /^\s*\0\/\0\*/);
		if ($tline > 0) {
			$title .= "$uline\0\n";
			if ($uline =~ /\0\*\0\//) {
				$tline--;
				next;
			}
		}
		next if ($tline > 0);
		if ($uline =~ /^\W*\0\/\0\/(.*)$/) {
			$title = $1;
			next;
		}
		# $db = 1;
		$uniline = $uline;
		$uniline = $uniline . "\0;" if ($uniline =~ /\0=/);	
		# Look for key = phrase pairs...
		if ($uniline =~ /\0\"/) {
			print "\n# >> [$ascline]" if ($db);  #DEBUG-kimbara
			if ($uniline =~ m/\0\@\0\"(.*?\0\")[\0\s]*?\0=[\0\s]*?\0\@\0\"(.*?\0\")[\0\s]*\0;/sg) {
				print "\n# <<Match \@\"A\"=\@\"A\">>" if ($db);	#DEBUG-kimbara
				($key, $phrase) = ($1, $2);
				$key = "\0\"\0[\0S\0Y\0M\0\@\0\]". $key;
				$phrase = "\0\"\0[\0S\0Y\0M\0\@\0\]". $phrase;
				print "\nK=$key\nP=$phrase\n" if ($db);	#DEBUG-kimbara
				$key = &StringMaster($key);
				$phrase = &StringMaster($phrase);
			} elsif ($uniline =~ m/(\0\".*?\0\")[\0\s]*?\0=[\0\s]*?(\0\".*?\0\")[\0\s]*\0;/sg) {
				print "\n# <<Match \"A\"=\"A\">>" if ($db);	#DEBUG-kimbara
				($key, $phrase) = ($1, $2);
				print "\nK=$key\nP=$phrase\n" if ($db);	#DEBUG-kimbara
				$key = &StringMaster($key);
				$phrase = &StringMaster($phrase);
			} elsif ($uniline =~ m/([^\"\s]*?)[\0\s]*?\0=[\0\s]*?(\0\".*?\0\")[\0\s]*\0;/sg) {
				print "\n# <<Match A=\"A\">>" if ($db); #DEBUG-kimbara
				($key, $phrase) = ($1, $2);
				$phrase = &StringMaster($phrase);
				my ($fname) = $file =~ /\/([^\/]+$)/;
				$fname = &A2U($fname);
				$key = "\0[\0S\0Y\0M\0:". $fname."\0]".$key;
				$key = &StringMaster($key);
				print "\nK=$key\n" if ($db);	#DEBUG-kimbara
			} elsif ($uniline =~ m/\0\@\0\"(.*?\0\")[\0\s]*\0;/sg) {
				print "\n# <<Match \@\"A\">>" if ($db); #DEBUG-kimbara
				$key = $1;
				$key = "\0\"\0[\0S\0Y\0M\0\@\0\]". $key;
				print "\nK=P=$key\n" if ($db);	#DEBUG-kimbara
				$key = &StringMaster($key);
				$phrase = $key;
			} else {
				print "\n# <<Match other>>" if ($db); #DEBUG-kimbara
				$uniline =~ m/(\0\".*\0\")/sg;
				$key = $1;
				print "\nK=P=$key\n" if ($db);	#DEBUG-kimbara
				$key = &StringMaster($key);
				$phrase = $key;
			}
			#if ($phrase) {
			#	$phrase = &StringMaster($phrase);
			#} else {
			#	$phrase = $key;
			#}
			#print "\n# >>>> [K=$key,P=$phrase]"; #DEBUG-kimbara
		}#
		# Will remove leading \0, so add in
		# if ($uline =~ m#\0/\0/[\0\s]*(.*)$#) {  - Fix 2705282
		if ($uline =~ m#\0\"\0\;[\0\s]*\0/\0/[\0\s]*(.*)$#) {
			$comment = "\0$1";
			# print "[$uline]==>[$comment]\n"; #DEBUG-kimbara
		}
		if ($key && $phrase) {
			# Postprocess the title field...
			$title =~ s/^.*\0\/\0\*//;
			$title =~ s/\0\*\0\/.*$//s;
			$strings{$key} = [$phrase, $title, $comment, $num];
			$key = ""; $phrase = ""; $title = ""; $comment = "";
			$num++;
		}	
	}
	close($file);
	
	$/ = $in;
	
	$out = \%strings;
	require LocStrings;
	bless($out, "LocStrings");
	return($out);
}


# ================================================================================
# Given an arbitrary line with a string, this routine will do it's damndest to 
# extract that string.  It looks for and corrects strings that have extra quotes,
# not enough quotes, and extra \376\377 (forbidden in unicode).
  
sub StringMaster {
	my($line) = $_[0];
	my($phrase, $prob);
	
	# print "\nINSTR=[$line]"; #DEBUG-kimbara
	my($checkquotes) = sub {
		my($line) = $_[0];
		my($text, $bnum, $anum);
	
		# Try to find the string...
		$bnum = $line =~ s/\0\\\0"/\377\376/g;			# embedded \"
		# $line =~ s#\0/\0/.*$##;							# // comments 
		# $line =~ s#\0/\0\*.*\0\*\0/##;					# /* comments */
		($text) = $line =~ /(\0".*\0")/s;
	
		# Make sure we don't have too many quotes in the match...
		if ($text =~ /\0".*\0".*\0"/s) {
			return(-1);
		}
		
		# We're cool, send it back.	
		if ($text) {
			# Watch for extra \377\376 (illegal!)
			$anum = $text =~ s/\377\376/\0\\\0"/g;
			if ($anum != $bnum) {
				return(-5);
			} 
			return($text);
		}
		
		# For the following routines, may want to replace \w with
		# [^"] or some such thing because japanese phrases may not have 
		# any \w's in them.

		# Since we're not now planning on returning strings, it might
		# be easier to work in ascii.
		$line =~ s/\0//sg;			# Kill nulls... (our pseudo-conversion)
		$line =~ s/\n|\r//sg;		# Kill embedded newlines
	
		# Perhaps missing an end quote...
		if ($line =~ /\W*".*\w/) {
			return(-2);
		}

		# Perhaps missing a start quote...
		if ($line =~ /.*\w.*"/) {
			return(-3);
		}
	
		# Perhaps unquoted...
		if ($line !~ /"/) {  #"
			return(-4);
		}
	
		#Unknown problem.
		return(-6);
	};

	my($fix) = sub {
		my($problem, $line) = @_;
	
		if ($problem == -1) {
			$line =~ s/(\0".*[^\\])\0"(.*\0")/$1$2/;
			$line =~ s/\0"\0"/\0"/;
		}
		if (($problem == -2) || ($problem == -4)) {
			$line =~ s/(\0\s)*$//;
			$line .= "\0\"";
		}
		if (($problem == -3) || ($problem == -4)) {
			$line =~ s/^(\0\s)*//;
			$line = "\0\"".$line;
		}
		if ($problem == -5) {
			$line =~ s/\377\376//g;
		}
		$line;
	};
	
	$phrase = &$checkquotes($line);
	# print "line=$line, phrase=$phrase\n";
	while ($phrase < 0 && $phrase > -6) {
		if ($prob++ > 20) {
			return("");
		}
		$line = &$fix($phrase, $line);
		$phrase = &$checkquotes($line);
	}
	if ($phrase == -6) {
		return("");
	}
	$phrase;
}

# ================================================================================
# Reads one or more summary files, and returns an unblessed hash.  Useful only for
# reading merge files, since every other file is probably a strings file.
# $xlats{$path}{$key} = $translation

sub ReadSFiles {
	my(@files) = @_;
	
	my(%xlats, $path, $key);
	my($tag, $u_tag, $value, %paths, $lang);
	my($inFile, $in, $tmp);
			
	# Private subroutine to process strings
	my($procstr) = sub {
		my($str) = $_[0];
		my($strnum, $outstr, $i, $uchar);

		$strnum = length ($str);
		$outstr = "";
		for ($i = 0; $i < $strnum; $i+=2)
		{
			$uchar = substr ($str, $i, 2);
			$uchar =~ s/\0\n/\0\\\0n/g;
			$uchar =~ s/\0"/\0\\\0"/g;
			$outstr .= $uchar;
		}
		$outstr = "\0\"" . $outstr . "\0\"";
		$outstr;
	};
	
	$in = $/;
	$/ = "";

	foreach $file(@files) {
		if (!open($file, "$file")) {
			print $Output "Loc.pm: Warning: Couldn't open $file.\n";
			next;
		}
		
		# Summary file sould be unicode encoding.
		# print "### Parsing File=[$file]\n";
		$inFile = <$file>;
		close($file);

		while($inFile =~ /\0<\0!\0-\0-.*?\0-\0-\0>|\0<([\0\w]+?)\0>(.*?)\0<\0\/\1\0>/sgi) {
			($tag, $value) = ($1, $2);
			$tag = &U2A($tag);
			$x=&U2A($value);
			#print "# tag=[$tag]\n# value=[$value]\n"; #DEBUG-kimbara
			next if ($& =~ /^\0<\0!\0-\0-/);
			next if ($tag =~ /^proj|type|source|title|format|version|comment|key$/i);

			if ($tag =~ /^english$/i) {
				$key = $value;
			} elsif ($tag =~ /^file$/i) {
				# Since we got a new file tag, should write previous items
				if ($path && $key && %paths) {
					$key = &$procstr($key);
					foreach $p(keys(%paths)) {
						$tmp = $paths{$p};											$tmp = &$procstr($tmp);
						$xlats{$p}{$key} = $tmp;
						#DEBUG-kimbara
						#print "\n### p=$p\n, key=$key\n, tmp=$tmp\n"; #DEBUG-kimbara
					}
					undef($key);
					undef(%paths);
				}
				$path = $value;
				$path = &U2A($path);
			} else {
				$lang = $tag;
				# Make sure we have "French" and not "fReNCh"
				$lang =~ tr/A-Z/a-z/;
				$lang = ucfirst($lang);
				($tmp = $path) =~ s/English/$lang/;
				$paths{$tmp} = $value;
			}
		}
		
		# We got EOF, but there still could be lingering data to write out...
		if ($path && $key && %paths) {
			$key = &$procstr($key);
			foreach $p(keys(%paths)) {
				$tmp = $paths{$p};
				$tmp = &$procstr($tmp);
				$xlats{$p}{$key} = $tmp;
			}
		}
		
		undef($path);
		undef($key);
		undef(%paths);
	}
	
	$/ = $in;
	%xlats;
}

sub IsXMLFormat {
	my($file) = $_[0];
	my($line, $rc);
	
	if(!open($file, $file)) {
		return;
	}
	
	$/ = "\n";	
	$rc = 0;
	while($line = <$file>) {
		chomp($line);
		# print "%%% $line\n";
		$rc = 1 if ($line =~ /\<\?xml .*\?\>/i);
	}
	close($file);

	return($rc);
}


1;
