##*****************************************************************************
##
##  Project Name:	AALocCommand
##     File Name:	AALocFileUtilities
##        Author:	Stanley Au-Yeung
##          Date:	Saturday, May 10, 2008
##
##   Description:	What it does...
##
##                            Copyright Apple Inc.
##                            All rights reserved.
##
##*****************************************************************************
##                       A U T H O R   I D E N T I T Y
##*****************************************************************************
##
##	Initials	Name
##	--------	-----------------------------------------------
##	SA			Stanley Au-Yeung (stanleyauyeung@asia.apple.com)
##
##*****************************************************************************
##                      R E V I S I O N   H I S T O R Y
##*****************************************************************************
##
##	Date		Time	Author	Description
##	--------	-----	------	---------------------------------------------
##	05/10/08	12:00	SA		Original version
##
##*****************************************************************************

package AALocFileUtilities;

#=============================================================================================
#	Modules Used
#=============================================================================================

use File::Path;
use File::Find;
use File::stat;
use File::Spec;
use File::Copy;
use File::Basename;

use AALocUtilities;

use constant kNotOpen				=> 0;
use constant kOpen					=> 1;



#=============================================================================================
#	Loc File Utilities
#=============================================================================================

#---------------------------------------------------------------------------------------------
#	SetFileLabel
#---------------------------------------------------------------------------------------------

sub SetFileLabel
{
	my ($inFile, $inColor) = @_;
	
	`setFinderLabel $inColor "$inFile"`;
}


#---------------------------------------------------------------------------------------------
#	GetFileLabel
#---------------------------------------------------------------------------------------------

sub GetFileLabel
{
	my ($inFile) = @_;
	my $outLabelColor = 'None';
	
	my %colorLabels = ();
	
	
	$colorLabels = `getFinderLabel "$inFile"`;
	eval $colorLabels;
	
	#--Debug----------------------------------------------------------------------------------
	print STDERR "[Debug:GetFileLabel]  colorLabels = $colorLabels\n" if ($gDebug);
	#-----------------------------------------------------------------------------------------
	
	$outLabelColor = $colorLabels{"$inFile"};
	
	#--Debug----------------------------------------------------------------------------------
	print STDERR "[Debug:GetFileLabel]  labelColor = $outLabelColor\n" if ($gDebug);
	#-----------------------------------------------------------------------------------------
	
	return $outLabelColor;
}


#---------------------------------------------------------------------------------------------
#	IsFileUpdatedOrNew
#
#	Return whether the File is updated/new.
#---------------------------------------------------------------------------------------------

sub IsFileUpdatedOrNew
{
	my ($inFile) = @_;
	
	$labelColor = GetFileLabel($inFile);
	
	if ($labelColor eq "None")
	{
		return 0;
	}
	else
	{
		return 1;
	}
}


#---------------------------------------------------------------------------------------------
#	GetFileStatus
#
#	Return whether the File is updated/new.
#---------------------------------------------------------------------------------------------

sub GetFileStatus
{
	my ($inFile) = @_;
	
	$labelColor = GetFileLabel($inFile);
	
	if ($labelColor eq "Yellow")
	{
		return "Updated";
	}
	elsif ($labelColor eq "Red")
	{
		return "New";
	}
	else
	{
		return "Old";
	}
}


#---------------------------------------------------------------------------------------------
#	CreateFileCopy
#---------------------------------------------------------------------------------------------

sub CreateFileCopy
{
	my ($inFile) = @_;
	
	$outFile = "";
	
	if (-e $inFile)
	{
		$fileName = GetFilenameWithoutExtension($inFile);
		$fileExtension =  GetFileExtension($inFile);
		
		$outFile = $fileName . "_copy." . $fileExtension;
		
		`ditto "$inFile" "$outFile"`;
	}
		
	return $outFile;
}


#---------------------------------------------------------------------------------------------
#	CreateNibFileCopy
#---------------------------------------------------------------------------------------------

sub CreateNibFileCopy
{
	my ($inFile) = @_;
	
	$outFile = "";
	
	if (-e $inFile)
	{
		$fileName = GetFilenameWithoutExtension($inFile);
		$fileExtension =  GetFileExtension($inFile);
		
		$outFile = $fileName . "~." . $fileExtension;
		
		`ditto "$inFile" "$outFile"`;
	}
	
	return $outFile;
}


#---------------------------------------------------------------------------------------------
#	RemoveFile
#---------------------------------------------------------------------------------------------

sub RemoveFile
{
	my ($inFile) = @_;
	
	if (-e $inFile)
	{
		`rm -d -r "$inFile"`;
	}
}


#---------------------------------------------------------------------------------------------
#	RemoveFolder
#---------------------------------------------------------------------------------------------

sub RemoveFolder
{
	my ($inFolder) = @_;
	
	if (-d $inFolder)
	{
		`rm -d -r "$inFolder"`;
	}
}


#---------------------------------------------------------------------------------------------
#	RemoveFoldersInside
#---------------------------------------------------------------------------------------------

sub RemoveFoldersInside
{
	my ($inFolder) = @_;
	
	if (-d $inFolder)
	{
		AALocUtilities::PrintLog("\n");
		AALocUtilities::PrintLog("#----------------------------------------------------------------------------------------\n");
		AALocUtilities::PrintLog("# Remove folders inside $inFolder\n");
		AALocUtilities::PrintLog("#----------------------------------------------------------------------------------------\n");
		
		opendir(directory, $inFolder);
		@searchResult = grep { !/^\./} readdir(directory);
		closedir(directory);
		
		foreach $file (@searchResult)
		{
			$folder = $inFolder . $file;
			
			if (-d $folder)
			{
				AALocUtilities::PrintLog("Removing $file\n");
				`rm -d -r "$folder"`;
			}
		}
	}
}


#---------------------------------------------------------------------------------------------
#	RemoveFileAndFolder
#---------------------------------------------------------------------------------------------

sub RemoveFileAndFolder
{
	my ($inItem) = @_;
	
	if (-e $inItem || -d $inItem)
	{
		`rm -d -r "$inItem"`;
	}
}


#---------------------------------------------------------------------------------------------
#	GetFilenameWithoutExtension
#---------------------------------------------------------------------------------------------

sub GetFilenameWithoutExtension
{
	my ($inFileName) = @_;
	
	$inFileName =~ /(.*)\.(.*)$/;
	
	return $1;
}


#---------------------------------------------------------------------------------------------
#	GetFileExtension
#---------------------------------------------------------------------------------------------

sub GetFileExtension
{
	my ($inFileName) = @_;
	
	$inFileName =~ /(.*)\.(.*)$/;
	
	return $2;
}


#---------------------------------------------------------------------------------------------
#	GetDirectoryBaseName
#---------------------------------------------------------------------------------------------

sub GetDirectoryBaseName
{
	my ($inDirectoryPath) = @_;
	
	$inDirectoryPath =~ s|/$||;		# remove trailing slash
	
	return basename($inDirectoryPath);
}


#---------------------------------------------------------------------------------------------
#	CreateFolderIfNotExist
#---------------------------------------------------------------------------------------------

sub CreateFolderIfNotExist
{
	my ($inDirectoryPath) = @_;
	
	if (!(-d "$inDirectoryPath"))
	{
		`mkdir "$inDirectoryPath"`;
	}
}


#---------------------------------------------------------------------------------------------
#	IsEmptyFolder
#---------------------------------------------------------------------------------------------

sub IsEmptyFolder
{
	my ($inDirectoryPath) = @_;
	my $outIsEmptyFolder = 1;
	
	if (-d "$inDirectoryPath")
	{
		opendir DIR, $inDirectoryPath;
		if (scalar(grep( !/^\.\.?$/, readdir(DIR)) != 0))
		{
			$outIsEmptyFolder = 0;
		}
		
        closedir DIR;
		
	}
	
	return $outIsEmptyFolder;
}


#---------------------------------------------------------------------------------------------
#	RemoveFolderContent
#---------------------------------------------------------------------------------------------

sub RemoveFolderContent
{
	my ($inDirectoryPath) = @_;
	
	if (-d "$inDirectoryPath")
	{
		if (!IsEmptyFolder($inDirectoryPath))
		{
			`rm -R $inDirectoryPath*`;
		}
	}
}


#---------------------------------------------------------------------------------------------
#	MoveFile
#---------------------------------------------------------------------------------------------

sub MoveFile
{
	my ($inSource, $inDest) = @_;
	
	if (-e $inSource)
	{
		`cp "$inSource" "$inDest"`;
		
		if ($inOpen == kOpen)
		{
			`open -a "AD Viewer" "$inDest"`;
		}
	}
	else
	{
		AALocUtilities::PrintLog("### ERROR: specified file '$inSource' doesn't exist.\n");
	}
}


#---------------------------------------------------------------------------------------------
#	CopyFile
#---------------------------------------------------------------------------------------------

sub CopyFile
{
	my ($inSource, $inDest, $inOpen) = @_;
	
	if (-e $inSource)
	{
		`cp "$inSource" "$inDest"`;
		
		if ($inOpen == kOpen)
		{
			`open -a "AD Viewer" "$inDest"`;
		}
	}
	else
	{
		AALocUtilities::PrintLog("### ERROR: specified file '$inSource' doesn't exist.\n");
	}
}


#---------------------------------------------------------------------------------------------
#	CopyFileIfExist
#---------------------------------------------------------------------------------------------

sub CopyFileIfExist
{
	my ($inSource, $inDest) = @_;
	
	if (-e $inSource)
	{
		`ditto "$inSource" "$inDest"`;
	}
}


#---------------------------------------------------------------------------------------------
#	CopyFolder
#---------------------------------------------------------------------------------------------

sub CopyFolder
{
	my ($inSource, $inDest) = @_;
	
	if (-d $inSource)
	{
		`ditto "$inSource" "$inDest"`;
	}
	else
	{
		AALocUtilities::PrintLog("### ERROR: specified folder '$inSource' doesn't exist.\n");
	}
}


#---------------------------------------------------------------------------------------------
#	CopyFolderIfExist
#---------------------------------------------------------------------------------------------

sub CopyFolderIfExist
{
	my ($inSource, $inDest) = @_;
	
	if (-d $inSource)
	{
		`ditto "$inSource" "$inDest"`;
	}
}


#---------------------------------------------------------------------------------------------
#	CopyZipOrDmgToFolder
#---------------------------------------------------------------------------------------------

sub CopyZipOrDmgToFolder
{
	my ($inSource, $inDest) = @_;
	my $result = 1;
	
	
	#-----------------------------------------------------------------------------------------
	#	Check input path
	#-----------------------------------------------------------------------------------------
	
	if (!(-e "$inSource"))
	{
		AALocUtilities::PrintLog("\n### ERROR: The specified file $inSource doesn't exist.\n");
		return 0;
	}
	
	if (!(-d "$inDest"))
	{
		AALocUtilities::PrintLog("\n### ERROR: The specified folder $inDest doesn't exist.\n");
		return 0;
	}
	
	
	#-----------------------------------------------------------------------------------------
	#
	#-----------------------------------------------------------------------------------------
	
	if ($inSource =~ /(.*)\.zip$/)
	{
		#-------------------------------------------------------------------------------------
		#	.zip
		#--------------------------------------------------------------------------------------
		
		`unzip \"$inSource\" -d \"$inDest\"`;
		
		sleep 10;
		
		opendir(directory, $inDest);
		@searchResult = grep { !/^\./} readdir(directory);
		closedir(directory);
		
		foreach $file (@searchResult)
		{
			if ($file ne "__MACOSX")
			{
				`mv $inDest$file/* $inDest`;
				RemoveFolder($inDest . $file);
			}
		}
		
		RemoveFolder($inDest . "__MACOSX/");
	}
	elsif ($inSource =~ /(.*)\.dmg$/)
	{
		#-------------------------------------------------------------------------------------
		#	.dmg
		#--------------------------------------------------------------------------------------
		
		# Using VFS & DiskImage to do the image mounting and copying
		# much cleaner and safer than calling hdid and hdiutil directly.
		my $dmgObj 	   = undef;
		my $mountpoint = undef;
		
		# mount the image
		$dmgObj = DiskImage->new(image => $inSource);
		$dmgObj->attach(readonly => 1);
		
		# copy its contents
		$mountpoint = $dmgObj->getOneMountpoint();
		
		if ($mountpoint)
		{
			`ditto "$mountpoint" "$inDest"`;
		}
		
		# unmount the image
		$dmgObj->detach();
	}
	else
	{
		AALocUtilities::PrintLog("\n### ERROR: The specified file $inSource is not either .zip or .dmg.\n");
		$result = 0;
	}
	
	return $result;
}


#---------------------------------------------------------------------------------------------
#	GetFileEncoding
#---------------------------------------------------------------------------------------------

sub GetFileEncoding
{
	my($inFile) = @_;
	my $outEncoding = "UTF-8 no BOM";
	
	
	#-----------------------------------------------------------------------------------------
	#	Check input path
	#-----------------------------------------------------------------------------------------
	
	if (!(-e "$inFile"))
	{
		AALocUtilities::PrintLog("\n### ERROR: The path $inFile doesn't exist.\n");
		return;
	}
	
	
	#-----------------------------------------------------------------------------------------
	#
	#-----------------------------------------------------------------------------------------
	
	my $firstLine;
	
	open(FILECONTENT, "<$inFile") or die "Cannot open '$inFile': $!";
	$firstLine = <FILECONTENT>;
	close(FILECONTENT);
	
	
	if ($firstLine =~ /^\xFE\xFF/)
	{
		$outEncoding = "UTF-16 BE";
	}
	elsif ($firstLine =~ /^\xFF\xFE/)
	{
		$outEncoding = "UTF-16 LE";
	}
	elsif ($firstLine =~ /^\xEF\xBB\xBF/)
	{
		$outEncoding = "UTF-8";
	}
	else
	{
		# file type unknown
		$outEncoding = "UTF-8 no BOM";
	}
	
	return $outEncoding;
}


#---------------------------------------------------------------------------------------------
#	GetHTMLFileCharset
#---------------------------------------------------------------------------------------------

sub GetHTMLFileCharset
{
	my($inFile) = @_;
	my $charset = "No charset";
	
	
	#-----------------------------------------------------------------------------------------
	#	Check input path
	#-----------------------------------------------------------------------------------------
	
	if (!(-e "$inFile"))
	{
		AALocUtilities::PrintLog("\n### ERROR: The path $inFile doesn't exist.\n");
		return;
	}
	
	
	#-----------------------------------------------------------------------------------------
	#
	#-----------------------------------------------------------------------------------------
	
	if (!open(LVFILE, "$inFile"))
	{
		AALocUtilities::PrintLog("### ERROR: Can't open file $inFile\n");
	}
	else
	{
		$saveRS = $/;
		undef $/;
		$newBaseLocVersData = <LVFILE>;
		$/ = $saveRS;
		close (LVFILE);
		
		if ($newBaseLocVersData =~ m/charset=(.*?)\"/)
		{
			$charset = $1;
		}
	}

	return $charset;
}


#---------------------------------------------------------------------------------------------
#	GetFileURL
#---------------------------------------------------------------------------------------------

sub GetFileURL
{
	my($inFilePath) = @_;
	my $outFileURL = $inFilePath;


	#-----------------------------------------------------------------------------------------
	#	Process TXT.rtf inside .rtfd
	#-----------------------------------------------------------------------------------------
			
	my $fileBaseName = basename($outFileURL);

	if ($fileBaseName eq "TXT.rtf")
	{
		$outFileURL =~ s/TXT.rtf//;		# take out "TXT.rtf"
	}


	#-----------------------------------------------------------------------------------------
	#
	#-----------------------------------------------------------------------------------------

	$outFileURL =~ s/\///;
	$outFileURL =~ s/ /%20/g;
	$outFileURL =~ s/\#/%23/g;
	$outFileURL = "<file://localhost/$outFileURL>";
			
	return $outFileURL;
}




1;

#=============================================================================================
#									E N D   O F   F I L E
#=============================================================================================
