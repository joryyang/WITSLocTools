##*****************************************************************************
##
##  Project Name:	AALocCommand
##     File Name:	AALocEnvUtilities
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
##	05/20/12	12:00	SA		Support ID/VN/MY/CA
##	10/10/09	12:00	SA		Support Conductor loc env
##	07/02/08	12:00	SA		Support PAR and 019 loc env
##	05/10/08	12:00	SA		Original version
##
##*****************************************************************************


#=============================================================================================
#	Modules Used
#=============================================================================================

package AALocEnvUtilities;

use AALocUtilities;
use AALocFileUtilities;

use constant kWrongLocEnv			=> -1;
use constant kMacSWLocEnv			=> 0;
use constant kMacSWPDSLocEnv		=> 1;
use constant kMacSWBugFixLocEnv		=> 2;
use constant kWinSWLocEnv			=> 3;
use constant kMacHelpLocEnv			=> 4;
use constant kPARLocEnv				=> 5;
use constant k019LocEnv				=> 6;
use constant kConductorLocEnv		=> 7;
use constant kMacSWProLocEnv		=> 8;


use constant kNotOpen				=> 0;
use constant kOpen					=> 1;




#=============================================================================================
#	Loc Env Utilities
#=============================================================================================

#---------------------------------------------------------------------------------------------
#	IsLocEnv
#---------------------------------------------------------------------------------------------

sub IsLocEnv
{
	my ($inLocEnvString) = @_;
	my $isLocEnv = 0;
	
	if (($inLocEnvString eq "LocEnv")
		|| ($inLocEnvString eq "MacSWPDSLocEnv")
		|| ($inLocEnvString eq "MacSWLocEnv")
		|| ($inLocEnvString eq "kMacSWProLocEnv")
		|| ($inLocEnvString eq "MacSWBugFixLocEnv")
		|| ($inLocEnvString eq "WinSWLocEnv")
		|| ($inLocEnvString eq "MacHelpLocEnv")
		|| ($inLocEnvString eq "WinHelpLocEnv")
		|| ($inLocEnvString eq "PARLocEnv")
		|| ($inLocEnvString eq "019LocEnv"))
	{
		$isLocEnv = 1;
	}
	
	return $isLocEnv;
}


#---------------------------------------------------------------------------------------------
#	CheckLocEnvName
#---------------------------------------------------------------------------------------------

sub CheckLocEnvName
{
	my ($inLocEnvPath) = @_;
	my $correctLocEnvName = 0;
	my $locEnvName = AALocFileUtilities::GetDirectoryBaseName($inLocEnvPath);
	
	$locEnvName =~ m/^(.*?)_(.*?)_(.*?)_(.*?)_(.*?)_(.*?)$/;
	my ($locEnv, $projectName, $buildNumber, $locSubmitNumber, $countryCode, $localizer) = ($1, $2, $3, $4, $5, $6);
	
	if (IsLocEnv($locEnv))
	{
		if ($countryCode eq "J" || $countryCode eq "FU" || $countryCode eq "D" || $countryCode eq "N"
			|| $countryCode eq "T" || $countryCode eq "E" || $countryCode eq "CH" || $countryCode eq "KH"
			|| $countryCode eq "TA" || $countryCode eq "S" || $countryCode eq "DK" || $countryCode eq "H"
			|| $countryCode eq "K" || $countryCode eq "BR" || $countryCode eq "RS" || $countryCode eq "PO"
			|| $countryCode eq "PL" || $countryCode eq "AB" || $countryCode eq "CR" || $countryCode eq "CZ"
			|| $countryCode eq "GR" || $countryCode eq "HB" || $countryCode eq "MG" || $countryCode eq "RO"
			|| $countryCode eq "SL" || $countryCode eq "TU" || $countryCode eq "UA" || $countryCode eq "TH"
			|| $countryCode eq "B" || $countryCode eq "CA" || $countryCode eq "ID" || $countryCode eq "MY"
			|| $countryCode eq "VN"|| $countryCode eq "MX"|| $countryCode eq "X"|| $countryCode eq "C"
			|| $countryCode eq "HK"|| $countryCode eq "HI")
		{
			$correctLocEnvName = 1;
		}
	}
	else
	{
		$locEnvName =~ m/^(.*?)-(.*?)-(.*?)-(.*?)-(.*?)$/;
		my ($countryCode, $projectName, $date, $locSubmitNumber, $glotKit) = ($1, $2, $3, $4, $5);

		if ($glotKit eq "GlotKit")
		{
			if ($countryCode eq "J" || $countryCode eq "FU" || $countryCode eq "D" || $countryCode eq "N"
				|| $countryCode eq "T" || $countryCode eq "E" || $countryCode eq "CH" || $countryCode eq "KH"
				|| $countryCode eq "TA" || $countryCode eq "S" || $countryCode eq "DK" || $countryCode eq "H"
				|| $countryCode eq "K" || $countryCode eq "BR" || $countryCode eq "RS" || $countryCode eq "PO"
				|| $countryCode eq "PL" || $countryCode eq "AB" || $countryCode eq "CR" || $countryCode eq "CZ"
				|| $countryCode eq "GR" || $countryCode eq "HB" || $countryCode eq "MG" || $countryCode eq "RO"
				|| $countryCode eq "SL" || $countryCode eq "TU" || $countryCode eq "UA" || $countryCode eq "TH"
				|| $countryCode eq "B" || $countryCode eq "CA" || $countryCode eq "ID" || $countryCode eq "MY"
				|| $countryCode eq "VN"|| $countryCode eq "MX"|| $countryCode eq "X"|| $countryCode eq "C"
				|| $countryCode eq "HK"|| $countryCode eq "HI")
			{
				$correctLocEnvName = 1;
			}
		}
	}
	
	return $correctLocEnvName;
}


#---------------------------------------------------------------------------------------------
#	IsJapanLocEnv
#---------------------------------------------------------------------------------------------

sub IsJapanLocEnv
{
	my ($inLocEnvPath) = @_;
	my $countryCode = GetCountryCodeFromLocEnv($inLocEnvPath);
	
	if ($countryCode eq "J")
	{
		return 1;
	}
	else
	{
		return 0;
	}
}


#---------------------------------------------------------------------------------------------
#	GetLocEnvTypeFromLocEnv
#---------------------------------------------------------------------------------------------

sub GetLocEnvTypeFromLocEnv
{
	my ($inLocEnvPath) = @_;
	my $locEnvName = AALocFileUtilities::GetDirectoryBaseName($inLocEnvPath);
	
	$locEnvName =~ m/^(.*?)_(.*?)_(.*?)_(.*?)_(.*?)_(.*?)$/;
	my ($locEnv, $projectName, $buildNumber, $locSubmitNumber, $countryCode, $localizer) = ($1, $2, $3, $4, $5, $6);
	
	if ($locEnv eq "MacSWLocEnv" || $locEnv eq "LocEnv")
	{
		return kMacSWLocEnv;
	}
	elsif ($locEnv eq "MacSWPDSLocEnv")
	{
		return kMacSWPDSLocEnv;
	}
	elsif ($locEnv eq "MacSWProLocEnv")
	{
		return kMacSWProLocEnv;
	}
	elsif ($locEnv eq "MacSWBugFixLocEnv")
	{
		return kMacSWBugFixLocEnv;
	}
	elsif ($locEnv eq "WinSWLocEnv")
	{
		return kWinSWLocEnv;
	}
	elsif ($locEnv eq "MacHelpLocEnv")
	{
		return kMacHelpLocEnv;
	}
	elsif ($locEnv eq "PARLocEnv")
	{
		return kPARLocEnv;
	}
	elsif ($locEnv eq "019LocEnv")
	{
		return k019LocEnv;
	}
	else
	{
		$locEnvName =~ m/^(.*?)-(.*?)-(.*?)-(.*)-(.*?)$/;
		##$locEnvName =~ m/^(.*?)-(.*?)-(.*?)-(.*?)-(.*?)$/;
		my ($countryCode, $projectName, $date, $locSubmitNumber, $glotKit) = ($1, $2, $3, $4, $5);

		if ($glotKit eq "GlotKit")
		{
			return kConductorLocEnv;
		}
	}
	
	return kWrongLocEnv;
}


#---------------------------------------------------------------------------------------------
#	GetProjectNameFromLocEnv
#---------------------------------------------------------------------------------------------

sub GetProjectNameFromLocEnv
{
	my ($inLocEnvPath) = @_;
	my $outProjectName = "ProjectName";
	my $locEnvType = GetLocEnvTypeFromLocEnv($inLocEnvPath);
	my $locEnvName = AALocFileUtilities::GetDirectoryBaseName($inLocEnvPath);
	
	if ($locEnvType == kConductorLocEnv)
	{
		$locEnvName =~ m/^(.*?)-(.*?)-(.*?)-(.*?)-(.*?)$/;
		my ($countryCode, $projectName, $date, $locSubmitNumber, $glotKit) = ($1, $2, $3, $4, $5);
		
		$outProjectName = $projectName;
	}
	else
	{
		$locEnvName =~ m/^(.*?)_(.*?)_(.*?)_(.*?)_(.*?)_(.*?)$/;
		my ($locEnv, $projectName, $buildNumber, $locSubmitNumber, $countryCode, $localizer) = ($1, $2, $3, $4, $5, $6);
		
		if (IsLocEnv($locEnv))
		{
			$outProjectName = $projectName;
		}
	}
	
	return $outProjectName;
}


#---------------------------------------------------------------------------------------------
#	GetBuildNumberFromLocEnv
#---------------------------------------------------------------------------------------------

sub GetBuildNumberFromLocEnv
{
	my ($inLocEnvPath) = @_;
	my $locEnvName = AALocFileUtilities::GetDirectoryBaseName($inLocEnvPath);
	
	$locEnvName =~ m/^(.*?)_(.*?)_(.*?)_(.*?)_(.*?)_(.*?)$/;
	my ($locEnv, $projectName, $buildNumber, $locSubmitNumber, $countryCode, $localizer) = ($1, $2, $3, $4, $5, $6);
	
	if (IsLocEnv($locEnv))
	{
		return $buildNumber;
	}
	else
	{
		return "BuildNumber";
	}
}


#---------------------------------------------------------------------------------------------
#	IsEuroLocEnv
#---------------------------------------------------------------------------------------------

sub IsEuroLocEnv
{
	my ($inLocEnvPath) = @_;
	my $outIsEuroLocEnv = 1;
	
	my $countryCode = GetCountryCodeFromLocEnv($inLocEnvPath);
	
	if ($countryCode eq "TA" || $countryCode eq "CH" || $countryCode eq "KH" || $countryCode eq "J" || $countryCode eq "TH")
	{
		$outIsEuroLocEnv = 0;
	}
	
	return $outIsEuroLocEnv;
}


#---------------------------------------------------------------------------------------------
#	GetCountryCodeFromLocEnv
#---------------------------------------------------------------------------------------------

sub GetCountryCodeFromLocEnv
{
	my ($inLocEnvPath) = @_;
	my $outCountryCode = "cc";
	my $locEnvType = GetLocEnvTypeFromLocEnv($inLocEnvPath);
	my $locEnvName = AALocFileUtilities::GetDirectoryBaseName($inLocEnvPath);
	
	
	if ($locEnvType == kConductorLocEnv)
	{
		$locEnvName =~ m/^(.*?)-(.*?)-(.*?)-(.*?)-(.*?)$/;
		my ($countryCode, $projectName, $date, $locSubmitNumber, $glotKit) = ($1, $2, $3, $4, $5);
		
		$outCountryCode = $countryCode;
	}
	else
	{
		$locEnvName =~ m/^(.*?)_(.*?)_(.*?)_(.*?)_(.*?)_(.*?)$/;
		my ($locEnv, $projectName, $buildNumber, $locSubmitNumber, $countryCode, $localizer) = ($1, $2, $3, $4, $5, $6);
		
		if (IsLocEnv($locEnv))
		{
			$outCountryCode = $countryCode;
		}
	}
	
	return $outCountryCode;
}


#---------------------------------------------------------------------------------------------
#	GetCountryCodeFromAppleGlotPath
#---------------------------------------------------------------------------------------------

sub GetCountryCodeFromAppleGlotPath
{
	my ($inAppleGlotEnvPath) = @_;
	my $appleGlotEnvironmentName = AALocFileUtilities::GetDirectoryBaseName($inAppleGlotEnvPath);
	
	$appleGlotEnvironmentName =~ m/^(.*?)_(.*?)_(.*?)_(.*?)_(.*?)_(.*?)$/;
	my ($agEnv, $projectName, $buildNumber, $locSubmitNumber, $countryCode, $localizer) = ($1, $2, $3, $4, $5, $6);
	
	if ($agEnv eq "AG")
	{
		return $countryCode;
	}
	else
	{
		return "CountryCode";
	}
}


#---------------------------------------------------------------------------------------------
#	GetCountryCodeFromLocKitPath
#---------------------------------------------------------------------------------------------

sub GetCountryCodeFromLocKitPath
{
	my ($inLocKitPath) = @_;
	my $locKitname = AALocFileUtilities::GetDirectoryBaseName($inLocKitPath);
	my $outCountryCode = "";
	
	$locKitname =~ m/^(.*?)-(.*?)$/;
	my ($outCountryCode, $others) = ($1, $2);
	
	return $outCountryCode;
}


#---------------------------------------------------------------------------------------------
#	GetLocalizerFromLocEnv
#---------------------------------------------------------------------------------------------

sub GetLocalizerFromLocEnv
{
	my ($inLocEnvPath) = @_;
	my $locEnvName = AALocFileUtilities::GetDirectoryBaseName($inLocEnvPath);
	
	$locEnvName =~ m/^(.*?)_(.*?)_(.*?)_(.*?)_(.*?)_(.*?)$/;
	my ($locEnv, $projectName, $buildNumber, $locSubmitNumber, $countryCode, $localizer) = ($1, $2, $3, $4, $5, $6);
	
	if (IsLocEnv($locEnv))
	{
		return $localizer;
	}
	else
	{
		return "Localizer";
	}
}


#---------------------------------------------------------------------------------------------
#	GetAppleGlotEnvFromLocEnv
#---------------------------------------------------------------------------------------------

sub GetAppleGlotEnvFromLocEnv
{
	my ($inLocEnvPath) = @_;
	my $locEnvName = AALocFileUtilities::GetDirectoryBaseName($inLocEnvPath);
	
	$locEnvName =~ m/^(.*?)_(.*?)_(.*?)_(.*?)_(.*?)_(.*?)$/;
	my ($locEnv, $projectName, $buildNumber, $locSubmitNumber, $countryCode, $localizer) = ($1, $2, $3, $4, $5, $6);
	
	if (IsLocEnv($locEnv))
	{
		return "AG_" . $projectName . "_" . $buildNumber . "_" . $locSubmitNumber . "_" . $countryCode . "_" . $localizer;
	}
	else
	{
		$locEnvName =~ m/^(.*?)-(.*?)-(.*?)-(.*)-(.*?)$/;
		##$locEnvName =~ m/^(.*?)-(.*?)-(.*?)-(.*?)-(.*?)$/;
		my ($countryCode, $projectName, $date, $locSubmitNumber, $glotKit) = ($1, $2, $3, $4, $5);

		if ($glotKit eq "GlotKit")
		{
			return "LocEnv/GlotEnv";
		}
	}
	
	return "Env";
}


#---------------------------------------------------------------------------------------------
#	GetAppleGlotEnvPathFromLocEnv
#---------------------------------------------------------------------------------------------

sub GetAppleGlotEnvPathFromLocEnv
{
	my ($inLocEnvPath) = @_;
	
	return $inLocEnvPath . GetAppleGlotEnvFromLocEnv($inLocEnvPath) . "/";
}


#---------------------------------------------------------------------------------------------
#	GetHelpEnvFromLocEnv
#---------------------------------------------------------------------------------------------

sub GetHelpEnvFromLocEnv
{
	my ($inLocEnvPath) = @_;
	my $locEnvName = AALocFileUtilities::GetDirectoryBaseName($inLocEnvPath);
	
	$locEnvName =~ m/^(.*?)_(.*?)_(.*?)_(.*?)_(.*?)_(.*?)$/;
	my ($locEnv, $projectName, $buildNumber, $locSubmitNumber, $countryCode, $localizer) = ($1, $2, $3, $4, $5, $6);
	
	if (IsLocEnv($locEnv))
	{
		return "Help_" . $projectName . "_" . $buildNumber . "_" . $locSubmitNumber . "_" . $countryCode . "_" . $localizer;
	}
	else
	{
		return "Env";
	}
}


#---------------------------------------------------------------------------------------------
#	GetHelpEnvPathFromLocEnv
#---------------------------------------------------------------------------------------------

sub GetHelpEnvPathFromLocEnv
{
	my ($inLocEnvPath) = @_;
	
	return $inLocEnvPath . GetHelpEnvFromLocEnv($inLocEnvPath) . "/";
}


#---------------------------------------------------------------------------------------------
#	GetLprojLanguageCodeFromLocEnv
#---------------------------------------------------------------------------------------------

sub GetLprojLanguageCodeFromLocEnv
{
	my ($inLocEnvPath) = @_;
	my $outLang = "";
	my $locEnvType = GetLocEnvTypeFromLocEnv($inLocEnvPath);
	my $locEnvName = AALocFileUtilities::GetDirectoryBaseName($inLocEnvPath);
	
	
	if ($locEnvType == kConductorLocEnv)
	{
		$locEnvName =~ m/^(.*?)-(.*?)-(.*?)-(.*?)-(.*?)$/;
		my ($countryCode, $projectName, $date, $locSubmitNumber, $glotKit) = ($1, $2, $3, $4, $5);
		
		$outLang = $AALocUtilities::kCountryCode2LprojLanguageCode{$countryCode};
	}
	else
	{
		$locEnvName =~ m/^(.*?)_(.*?)_(.*?)_(.*?)_(.*?)_(.*?)$/;
		my ($locEnv, $projectName, $buildNumber, $locSubmitNumber, $countryCode, $localizer) = ($1, $2, $3, $4, $5, $6);
		
		if (IsLocEnv($locEnv))
		{
			$outLang = $AALocUtilities::kCountryCode2LprojLanguageCode{$countryCode};
		}
	}
	
	return $outLang;
}


#---------------------------------------------------------------------------------------------
#	GetReportsFromLocEnv
#---------------------------------------------------------------------------------------------

sub GetReportsFromLocEnv
{
	my ($inLocEnvPath) = @_;
	my $locEnvType = GetLocEnvTypeFromLocEnv($inLocEnvPath);
	my $locEnvName = AALocFileUtilities::GetDirectoryBaseName($inLocEnvPath);
	

	if ($locEnvType == kConductorLocEnv)
	{
		$locEnvName =~ m/^(.*?)-(.*?)-(.*?)-(.*?)-(.*?)$/;
		my ($countryCode, $projectName, $date, $locSubmitNumber, $glotKit) = ($1, $2, $3, $4, $5);
		
		return "Reports_" . $countryCode;
	}
	else
	{
		$locEnvName =~ m/^(.*?)_(.*?)_(.*?)_(.*?)_(.*?)_(.*?)$/;
		my ($locEnv, $projectName, $buildNumber, $locSubmitNumber, $countryCode, $localizer) = ($1, $2, $3, $4, $5, $6);
		
		# return "_Reports_" . $projectName . "_" . $buildNumber . "_" . $locSubmitNumber . "_" . $countryCode . "_" . $localizer;
		return "_Reports_" . $countryCode;
	}
}


#---------------------------------------------------------------------------------------------
#	GetReportsPathFromLocEnv
#---------------------------------------------------------------------------------------------

sub GetReportsPathFromLocEnv
{
	my ($inLocEnvPath) = @_;
	my $locEnvType = GetLocEnvTypeFromLocEnv($inLocEnvPath);
	

	if ($locEnvType == kConductorLocEnv)
	{
		$reportFolderPath = $inLocEnvPath . "LocEnv/" . GetReportsFromLocEnv($inLocEnvPath) . "/";

		AALocFileUtilities::CreateFolderIfNotExist($reportFolderPath);
		
		return $reportFolderPath;
	}
	else
	{
		return $inLocEnvPath . GetReportsFromLocEnv($inLocEnvPath) . "/";
	}
}


#---------------------------------------------------------------------------------------------
#	GetCheckListFromLocEnv
#---------------------------------------------------------------------------------------------

sub GetCheckListFromLocEnv
{
	my ($inLocEnvPath) = @_;
	
	return "_CheckList_" . GetCountryCodeFromLocEnv($inLocEnvPath);
}


#---------------------------------------------------------------------------------------------
#	GetCheckListPathFromLocEnv
#---------------------------------------------------------------------------------------------

sub GetCheckListPathFromLocEnv
{
	my ($inLocEnvPath) = @_;
	
	return $inLocEnvPath . "_CheckList_" . GetCountryCodeFromLocEnv($inLocEnvPath) . "/";
}


#---------------------------------------------------------------------------------------------
#	GetHistoryPathFromLocEnv
#---------------------------------------------------------------------------------------------

sub GetHistoryPathFromLocEnv
{
	my ($inLocEnvPath) = @_;
	
	return $inLocEnvPath . "_History/";
}


#---------------------------------------------------------------------------------------------
#	GetUniqueTranslationKitFromLocEnv
#---------------------------------------------------------------------------------------------

sub GetUniqueTranslationKitFromLocEnv
{
	my ($inLocEnvPath) = @_;
	my $outTranslationKitName;
	
	my $locEnvName = AALocFileUtilities::GetDirectoryBaseName($inLocEnvPath);
	
	$locEnvName =~ m/^(.*?)_(.*?)_(.*?)_(.*?)_(.*?)_(.*?)$/;
	my ($locEnv, $projectName, $buildNumber, $locSubmitNumber, $countryCode, $localizer) = ($1, $2, $3, $4, $5, $6);
	
	if (IsLocEnv($locEnv))
	{
		my $dateString = `date "+%m%d%y"`;
		chomp($dateString);
		
		$outTranslationKitName = "TransEnv_" . $countryCode . "_" . $projectName . "_" . $buildNumber . "_" . $dateString . "_";
		
		my $translationKitPath;
		
		for ($revision = 1; $revision < 100; $revision++)
		{
			$translationKitPath = $inLocEnvPath . $outTranslationKitName . $revision;
			
			if (!(-d $translationKitPath))
			{
				$outTranslationKitName = $outTranslationKitName . $revision;
				last;
			}
		}
	}
	else
	{
		$outTranslationKitName = "TranslationKit";
	}
	
	return $outTranslationKitName;
}


#---------------------------------------------------------------------------------------------
#	GetUniqueTranslationKitPathFromLocEnv
#---------------------------------------------------------------------------------------------

sub GetUniqueTranslationKitPathFromLocEnv
{
	my ($inLocEnvPath) = @_;
	
	return $inLocEnvPath . GetUniqueTranslationKitFromLocEnv($inLocEnvPath) . "/";
}


#---------------------------------------------------------------------------------------------
#	GetLatestTranslationKitFromLocEnv
#---------------------------------------------------------------------------------------------

sub GetLatestTranslationKitFromLocEnv
{
	my ($inLocEnvPath) = @_;
	my $outTranslationKitName = "TranslationKit";
	
	my $locEnvName = AALocFileUtilities::GetDirectoryBaseName($inLocEnvPath);
	
	$locEnvName =~ m/^(.*?)_(.*?)_(.*?)_(.*?)_(.*?)_(.*?)$/;
	my ($locEnv, $projectName, $buildNumber, $locSubmitNumber, $countryCode, $localizer) = ($1, $2, $3, $4, $5, $6);
	
	if (IsLocEnv($locEnv))
	{
		my $dateString = `date "+%m%d%y"`;
		chomp($dateString);
		
		$translationKitNameTemp = "TransEnv_" . $countryCode . "_" . $projectName . "_" . $buildNumber . "_" . $dateString . "_";
		
		my $translationKitPath;
		
		for ($revision = 1; $revision < 100; $revision++)
		{
			$translationKitPath = $inLocEnvPath . $translationKitNameTemp . $revision;
			
			if (!(-d $translationKitPath))
			{
				$revision--;
				
				$outTranslationKitName = $translationKitNameTemp . $revision;
				last;
			}
		}
	}
	
	return $outTranslationKitName;
}


#---------------------------------------------------------------------------------------------
#	GetLatestTranslationKitPathFromLocEnv
#---------------------------------------------------------------------------------------------

sub GetLatestTranslationKitPathFromLocEnv
{
	my ($inLocEnvPath) = @_;
	
	return $inLocEnvPath . GetLatestTranslationKitFromLocEnv($inLocEnvPath) . "/";
}


#---------------------------------------------------------------------------------------------
#	GetTranslationKitSubmitFromLocEnv
#---------------------------------------------------------------------------------------------

sub GetTranslationKitSubmitFromLocEnv
{
	my ($inLocEnvPath) = @_;
	
	return "TranslationKitSubmit";
}


#---------------------------------------------------------------------------------------------
#	GetTranslationKitSubmitPathFromLocEnv
#---------------------------------------------------------------------------------------------

sub GetTranslationKitSubmitPathFromLocEnv
{
	my ($inLocEnvPath) = @_;
	
	return $inLocEnvPath . GetTranslationKitSubmitFromLocEnv($inLocEnvPath). "/";
}


#---------------------------------------------------------------------------------------------
#	GetUniqueLocEngDoneFromLocEnv
#---------------------------------------------------------------------------------------------

sub GetUniqueLocEngDoneFromLocEnv
{
	my ($inLocEnvPath) = @_;
	my $outLocEngDoneName = "LocEngDone_AG3Env";
	
	my $locEnvName = AALocFileUtilities::GetDirectoryBaseName($inLocEnvPath);
	
	$locEnvName =~ m/^(.*?)_(.*?)_(.*?)_(.*?)_(.*?)_(.*?)$/;
	my ($locEnv, $projectName, $buildNumber, $locSubmitNumber, $countryCode, $localizer) = ($1, $2, $3, $4, $5, $6);
	
	if (IsLocEnv($locEnv))
	{
		my $dateString = `date "+%m%d%y"`;
		chomp($dateString);
		
		my $locEngDonePath;
		
		for ($revision = 1; $revision < 100; $revision++)
		{
			$outLocEngDoneName = "LocEngDone_Env_" . $countryCode . "_" . $projectName . "_" . $buildNumber . "_" . $localizer . "_" . $dateString . "_" . $revision;
			
			$locEngDonePath = $inLocEnvPath . $outLocEngDoneName;
			
			if (!(-d $locEngDonePath))
			{
				last;
			}
		}
	}
	
	return $outLocEngDoneName;
}


#---------------------------------------------------------------------------------------------
#	GetUniqueLocEngDonePathFromLocEnv
#---------------------------------------------------------------------------------------------

sub GetUniqueLocEngDonePathFromLocEnv
{
	my ($inLocEnvPath) = @_;
	
	return $inLocEnvPath . GetUniqueLocEngDoneFromLocEnv($inLocEnvPath) . "/";
}


#---------------------------------------------------------------------------------------------
#	GetBackupFromLocEnv
#---------------------------------------------------------------------------------------------

sub GetBackupFromLocEnv
{
	my ($inLocEnvPath) = @_;
	my $outBackupName = "Backup";
	
	
	my $locEnvName = AALocFileUtilities::GetDirectoryBaseName($inLocEnvPath);
	
	$locEnvName =~ m/^(.*?)_(.*?)_(.*?)_(.*?)_(.*?)_(.*?)$/;
	my ($locEnv, $projectName, $buildNumber, $locSubmitNumber, $countryCode, $localizer) = ($1, $2, $3, $4, $5, $6);
	
	if (IsLocEnv($locEnv))
	{
		$outBackupName = $countryCode . "_" . $localizer . "_" . $locSubmitNumber . "_Pre#";
		
		my $backupPath;
		
		for ($revision = 1; $revision < 100; $revision++)
		{
			$backupPath = $inLocEnvPath . $outBackupName . $revision;
			
			if (!(-d $backupPath))
			{
				$outBackupName = $outBackupName . $revision;
				last;
			}
		}
	}
	
	return $outBackupName;
}


#---------------------------------------------------------------------------------------------
#	GetBackupPathFromLocEnv
#---------------------------------------------------------------------------------------------

sub GetBackupPathFromLocEnv
{
	my ($inLocEnvPath) = @_;
	
	return $inLocEnvPath . GetBackupFromLocEnv($inLocEnvPath) . "/";
}


#---------------------------------------------------------------------------------------------
#	CopyReportFromAG2LocEnv
#---------------------------------------------------------------------------------------------

sub CopyReportFromAG2LocEnv
{
	my ($inLocEnvPath, $inReportName, $inOpen) = @_;
	
	my $locEnvType = GetLocEnvTypeFromLocEnv($inLocEnvPath);
	my $appleGlotEnvPath = GetAppleGlotEnvPathFromLocEnv($inLocEnvPath);
	my $reportFolderPath = GetReportsPathFromLocEnv($inLocEnvPath);
	my $reportFileName;
	my $reportFilePath;
	
	
	if ($locEnvType == kConductorLocEnv)
	{
		$reportFileName = "GlotEnv" . $inReportName;
	}
	else
	{
		$reportFileName = AALocFileUtilities::GetDirectoryBaseName($appleGlotEnvPath) . $inReportName;
	}

	$reportFilePath = $reportFolderPath . $reportFileName;

	AALocFileUtilities::CreateFolderIfNotExist($reportFolderPath);
	AALocFileUtilities::CopyFile($appleGlotEnvPath . "_Logs/" . $reportFileName, $reportFilePath, kNotOpen);
	
	if ($inOpen == kOpen)
	{
		`open -a "AD Viewer" "$reportFilePath"`;
	}
}


#---------------------------------------------------------------------------------------------
#	GetComponentProjectName
#---------------------------------------------------------------------------------------------

sub GetComponentProjectName
{
	my ($inLocEnvPath, $inComponentName) = @_;
	my $outComponentProjectName = "";
	
	my $projectUSFolder = $inLocEnvPath . "Projects_US/";
	my $componentProjectFolder = $projectUSFolder . $inComponentName . "_Tier1_proj";
	
	
	if (-d $componentProjectFolder)
	{
		$outComponentProjectName = $inComponentName . "_Tier1_proj";
	}
	else
	{
		$componentProjectFolder = $projectUSFolder . $inComponentName . "_Tier2_proj";
		
		if (-d $componentProjectFolder)
		{
			$outComponentProjectName = $inComponentName . "_Tier2_proj";
		}
		else
		{
			$componentProjectFolder = $projectUSFolder . $inComponentName . "_Tier3_proj";
			
			if (-d $componentProjectFolder)
			{
				$outComponentProjectName = $inComponentName . "_Tier3_proj";
			}
		}
	}
	
	return $outComponentProjectName;
}


1;


#=============================================================================================
#									E N D   O F   F I L E
#=============================================================================================
