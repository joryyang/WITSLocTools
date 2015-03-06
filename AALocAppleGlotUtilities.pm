##*****************************************************************************
##
##  Project Name:	AALocCommand
##     File Name:	AALocAppleGlotUtilities
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
##	09/03/08	14:00	SA		Added MoveWGFilesFromTranslationToWGFolder
##								and MoveADFilesFromTranslationToADFolder
##	08/29/08	12:00	SA		Added NewLocToNewBaseFilePath
##	05/10/08	12:00	SA		Original version
##
##*****************************************************************************

package AALocAppleGlotUtilities;

#=============================================================================================
#	Modules Used
#=============================================================================================

use File::Path;
use File::Find;
use File::stat;
use File::Spec;
use File::Copy;
use File::Basename;

use AALocFileUtilities;


#=============================================================================================
#	AppleGlot Utilities
#=============================================================================================

#---------------------------------------------------------------------------------------------
#	CheckAppleGlotEnvironmentPermissions
#---------------------------------------------------------------------------------------------

sub CheckAppleGlotEnvironmentPermissions
{
	my ($inAppleGlotEnvPath) = @_;
	
	my $numOfError = 0;
	my $error = "";
	my $file;
	
	
	print "----- Check AppleGlot Environment Permissions -----\n";
	
	print "#--------------------------------------------------------------------------\n";
	print "# AppleGlot Environment Permission Check Result\n";
	print "#--------------------------------------------------------------------------\n";
	
	$numOfError = 0;
	
	chomp(@searchResult = `find "$inAppleGlotEnvPath" -type d`);
	
	foreach $file (@searchResult)
	{
		$error = `ls -dl "$file"`;
		
		if ($error =~ m/dr-xr-xr-x/)
		{
			if ($numOfError == 0)
			{
				print "The following folders have permission problem:\n";
			}
			
			print "dr-xr-xr-x  $file\n";
			
			$numOfError++;
		}
	}
	
	if ($numOfError != 0)
	{
		print "\n";
	}
	
	
	$error = "";
	$error = `ls -Rl $inAppleGlotEnvPath | grep "\\-r--r--r-"`;
	
	if ($error ne "")
	{
		print "The following files have permission problem:\n";
		print "$error";
		
		$numOfError++;
	}
	
	
	if ($numOfError == 0)
	{
		print "No Problem Found\n";
	}
	
	return $numOfError;
}


#---------------------------------------------------------------------------------------------
#	NewBaseToNewLocFilePath
#---------------------------------------------------------------------------------------------

sub NewBaseToNewLocFilePath
{
	my ($inNewBaseFilePath, $inLanguage) = @_;
	
	my $directoryPath;
	my $outNewLocFilePath = $inNewBaseFilePath;
	
	$outNewLocFilePath =~ s/_NewBase/_NewLoc/;
	$outNewLocFilePath =~ s/English.lproj/$inLanguage.lproj/;
	
	
	$directoryPath = dirname($outNewLocFilePath);
	
	if (!(-d "$directoryPath"))
	{
		$outNewLocFilePath = $inNewBaseFilePath;
		$outNewLocFilePath =~ s/_NewBase/_NewLoc/;
		$outNewLocFilePath =~ s/en.lproj/$inLanguage.lproj/;
	}
	
	
	$directoryPath = dirname($outNewLocFilePath);
	
	if (!(-d "$directoryPath"))
	{
		my $shortFormLanguage = $AALocUtilities::kLprojShortForm{$inLanguage};
		
		$outNewLocFilePath = $inNewBaseFilePath;
		$outNewLocFilePath =~ s/_NewBase/_NewLoc/;
		$outNewLocFilePath =~ s/English.lproj/$shortFormLanguage.lproj/;
	}
	
	
	$directoryPath = dirname($outNewLocFilePath);
	
	if (!(-d "$directoryPath"))
	{
		my $shortFormLanguage = $AALocUtilities::kLprojShortForm{$inLanguage};
		
		$outNewLocFilePath = $inNewBaseFilePath;
		$outNewLocFilePath =~ s/_NewBase/_NewLoc/;
		$outNewLocFilePath =~ s/en.lproj/$shortFormLanguage.lproj/;
	}
	
	
	$directoryPath = dirname($outNewLocFilePath);
	
	if (!(-d "$directoryPath"))
	{
		$outNewLocFilePath = "";
	}
	
	return $outNewLocFilePath;
}


#---------------------------------------------------------------------------------------------
#	NewLocToNewBaseFilePath
#---------------------------------------------------------------------------------------------

sub NewLocToNewBaseFilePath
{
	my ($inNewLocFilePath) = @_;
	
	my $directoryPath;
	my $outNewBaseFilePath = $inNewLocFilePath;


	$inNewLocFilePath =~ m/^(.*)\/(.*).lproj\/(.*)$/;
	$language = $2;
	
	$outNewBaseFilePath =~ s/_NewLoc/_NewBase/;
	$outNewBaseFilePath =~ s/$language.lproj/English.lproj/;
	
	
	$directoryPath = dirname($outNewBaseFilePath);
	
	if (!(-d "$directoryPath"))
	{
		$outNewBaseFilePath = $inNewLocFilePath;
		$outNewBaseFilePath =~ s/_NewLoc/_NewBase/;
		$outNewBaseFilePath =~ s/$language.lproj/en.lproj/;
	}
	
	
	$directoryPath = dirname($outNewBaseFilePath);
	
	if (!(-d "$directoryPath"))
	{
		$outNewBaseFilePath = "";
	}
	
	return $outNewBaseFilePath;
}


#---------------------------------------------------------------------------------------------
#	GetPartialFilePathNameInAppleGlotEnv
#---------------------------------------------------------------------------------------------

sub GetPartialFilePathNameInAppleGlotEnv
{
	my ($inFullFilePath, $inAppleGlotEnvPath) = @_;
	
	$inFullFilePath =~ s/$inAppleGlotEnvPath//;		# take out the base path
	$inFullFilePath =~ m/\/(.*)/;							# take out the first /
	$patialFilePathNameInAppleGlotEnv = $1;
	
	
	#-----------------------------------------------------------------------------------------
	#	Process TXT.rtf inside .rtfd
	#-----------------------------------------------------------------------------------------
	
	my $fileBaseName = basename($patialFilePathNameInAppleGlotEnv);
	
	if ($fileBaseName eq "TXT.rtf")
	{
		$patialFilePathNameInAppleGlotEnv =~ s/TXT.rtf//;		# take out "TXT.rtf"
	}
	
	
	return $patialFilePathNameInAppleGlotEnv;
}


#---------------------------------------------------------------------------------------------
#	GetComponentNameInAppleGlotEnv
#---------------------------------------------------------------------------------------------

sub GetComponentNameInAppleGlotEnv
{
	my ($inFullFilePath, $inAppleGlotEnvPath) = @_;
	my $outComponentName = "";
	
	$inFullFilePath =~ m/$inAppleGlotEnvPath\/(.*?)\/(.*)/;
	$outComponentName = $1;
	
	
	return $outComponentName;
}


#---------------------------------------------------------------------------------------------
#	GetFileSubPathInAppleGlotEnv
#---------------------------------------------------------------------------------------------

sub GetFileSubPathInAppleGlotEnv
{
	my ($inFullFilePath, $inAppleGlotEnvPath) = @_;
	$outFileSubPath = "";
	
	$inFullFilePath =~ m/$inAppleGlotEnvPath\/(.*?)\/(.*)/;
	$outFileSubPath = $2;
	
	return $outFileSubPath;
}


#---------------------------------------------------------------------------------------------
#	MoveWGFilesFromTranslationToWGFolder
#---------------------------------------------------------------------------------------------

sub MoveWGFilesFromTranslationToWGFolder
{
	my ($inAppleGlotEnvPath) = @_;

	my $appleGlotTranslationsPath = $inAppleGlotEnvPath . "_Translations/";
	my $appleGlotWGPath = $inAppleGlotEnvPath . "_WorkGlossary/";

	
	chomp(@searchResult = `find "$appleGlotTranslationsPath" -type f | grep ".wg"`);
	
	foreach $file (@searchResult)
	{
		$filename = $file;
		$filename =~ s/$appleGlotTranslationsPath//;
		
		$targetFile = $appleGlotWGPath . $filename;
		
		`mv "$file" "$targetFile"`;
	}
}


#---------------------------------------------------------------------------------------------
#	MoveADFilesFromTranslationToADFolder
#---------------------------------------------------------------------------------------------

sub MoveADFilesFromTranslationToADFolder
{
	my ($inAppleGlotEnvPath) = @_;
	
	my $appleGlotTranslationsPath = $inAppleGlotEnvPath . "_Translations/";
	my $appleGlotADPath = $inAppleGlotEnvPath . "_ApplicationDictionaries/";
	
	
	chomp(@searchResult = `find "$appleGlotTranslationsPath" -type f | grep ".ad"`);
	
	foreach $file (@searchResult)
	{
		$filename = $file;
		$filename =~ s/$appleGlotTranslationsPath//;
		
		$targetFile = $appleGlotADPath . $filename;
		
		`mv "$file" "$targetFile"`;
	}
}


1;


#=============================================================================================
#									E N D   O F   F I L E
#=============================================================================================

