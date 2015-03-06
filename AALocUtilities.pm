##*****************************************************************************
##
##  Project Name:	AALocCommand
##     File Name:	AALocUtilities
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
##	05/23/12	12:00	SA		Fixed VN lproj issue (vn -> vi)
##	05/20/12	12:00	SA		Support ID/VN/MY/CA
##	08/30/08	01:00	SA		kLprojLongForm and kLprojShortForm added English
##	08/14/08	09:00	SA		Fixed kAGLanguageCode2TMX of pt_PT (pt_PT to pt-PT)
##	05/10/08	12:00	SA		Original version
##
##*****************************************************************************

package AALocUtilities;


#=============================================================================================
#
#=============================================================================================

%kLprojLongForm = (
es_MX => 'es_MX',
English => 'English',
en => 'English',
en_GB => 'en_GB',
Japanese => 'Japanese',
ja => 'Japanese',
French => 'French',
fr => 'French',
German => 'German',
de => 'German',
Dutch => 'Dutch',
nl => 'Dutch',
Italian => 'Italian',
it => 'Italian',
Spanish => 'Spanish',
es => 'Spanish',
zh_CN => 'zh_CN',
ko => 'ko',
zh_TW => 'zh_TW',
sv => 'sv',
da => 'da',
no => 'no',
fi => 'fi',
pt => 'pt',
pt_PT => 'pt_PT',
pl => 'pl',
ru => 'ru',
ar => 'ar',
hr => 'hr',
cs => 'cs',
el => 'el',
he => 'he',
hu => 'hu',
ro => 'ro',
sk => 'sk',
tr => 'tr',
uk => 'uk',
th => 'th',
ca => 'ca',
id => 'id',
vi => 'vi',
ms => 'ms'
);

%kLprojShortForm = (
English => 'en',
en => 'en',
en_GB => 'en_GB',
Japanese => 'ja',
ja => 'ja',
French => 'fr',
fr => 'fr',
German => 'de',
de => 'de',
Dutch => 'nl',
nl => 'nl',
Italian => 'it',
it => 'it',
Spanish => 'es',
es => 'es',
zh_CN => 'zh_CN',
ko => 'ko',
zh_TW => 'zh_TW',
sv => 'sv',
da => 'da',
no => 'no',
fi => 'fi',
pt => 'pt',
pt_PT => 'pt_PT',
pl => 'pl',
ru => 'ru',
ar => 'ar',
hr => 'hr',
cs => 'cs',
el => 'el',
he => 'he',
hu => 'hu',
ro => 'ro',
sk => 'sk',
tr => 'tr',
uk => 'uk',
th => 'th',
ca => 'ca',
id => 'id',
vi => 'vi',
ms => 'ms'
);

%kWG2LprojLanguageCode = (
en_GB => 'en_GB',
ja => 'Japanese',
fr => 'French',
de => 'German',
nl => 'Dutch',
it => 'Italian',
es => 'Spanish',
zh_CN => 'zh_CN',
ko => 'ko',
zh_TW => 'zh_TW',
sv => 'sv',
da => 'da',
no => 'no',
fi => 'fi',
pt_BR => 'pt',
pt_PT => 'pt_PT',
pl => 'pl',
ru => 'ru',
ar => 'ar',
hr => 'hr',
cs => 'cs',
el => 'el',
he => 'he',
hu => 'hu',
ro => 'ro',
sk => 'sk',
tr => 'tr',
uk => 'uk',
th => 'th',
ca => 'ca',
id => 'id',
vi => 'vi',
ms => 'ms'
);

%kCountryCode2Tier = (
B => '1',
J => '1',
FU => '1',
D => '1',
N => '1',
T => '1',
E => '1',
CH => '1',
KH => '2',
TA => '2',
S => '2',
DK => '2',
H => '2',
K => '2',
BR => '2',
RS => '2',
PO => '2',
PL => '2',
AB => '3',
CR => '3',
CZ => '3',
GR => '3',
HB => '3',
MG => '3',
RO => '3',
SL => '3',
TU => '3',
UA => '3',
TH => '3',
CA => '3',
ID => '3',
VN => '3',
MY => '3',
);

%kLprojLanguageCode2CountryCode = (
'en_GB' => B,
'Japanese' => J,
'jp' => J,
'French' => FU,
'fr' => FU,
'German' => D,
'de' => D,
'Dutch' => N,
'nl' => N,
'Italian' => T,
'it' => T,
'Spanish' => E,
'es' => E,
'zh_CN' => CH,
'ko' => KH,
'zh_TW' => TA,
'sv' => S,
'da' => DK,
'no' => H,
'fi' => K,
'pt' => BR,
'ru' => RS,
'pt_PT' => PO,
'pl' => PL,
'ar' => AB,
'hr' => CR,
'cs' => CZ,
'el' => GR,
'he' => HB,
'hu' => MG,
'ro' => RO,
'sk' => SL,
'tr' => TU,
'uk' => UA,
'th' => TH,
'ca' => CA,
'id' => ID,
'vi' => VN,
'ms' => MY
);

%kCountryCode2LprojLanguageCode = (
B => 'en_GB',
J => 'Japanese',
FU => 'French',
D => 'German',
N => 'Dutch',
T => 'Italian',
E => 'Spanish',
CH => 'zh_CN',
KH => 'ko',
TA => 'zh_TW',
S => 'sv',
DK => 'da',
H => 'no',
K => 'fi',
BR => 'pt',
RS => 'ru',
PO => 'pt_PT',
PL => 'pl',
AB => 'ar',
CR => 'hr',
CZ => 'cs',
GR => 'el',
HB => 'he',
MG => 'hu',
RO => 'ro',
SL => 'sk',
TU => 'tr',
UA => 'uk',
TH => 'th',
CA => 'ca',
ID => 'id',
VN => 'vi',
MY => 'ms'
);

%kCountryCode2AGLanguageCode = (
B => 'en_GB',
J => 'ja',
FU => 'fr',
D => 'de',
N => 'nl',
T => 'it',
E => 'es',
CH => 'zh_CN',
KH => 'ko',
TA => 'zh_TW',
S => 'sv',
DK => 'da',
H => 'no',
K => 'fi',
BR => 'pt_BR',
RS => 'ru',
PO => 'pt_PT',
PL => 'pl',
AB => 'ar',
CR => 'hr',
CZ => 'cs',
GR => 'el',
HB => 'he',
MG => 'hu',
RO => 'ro',
SL => 'sk',
TU => 'tr',
UA => 'uk',
TH => 'th',
CA => 'ca',
ID => 'id',
VN => 'vi',
MY => 'ms'
);

%kCountryCode2URLCC = (
J => 'jp',
FU => 'fr',
D => 'de',
N => 'nl',
T => 'it',
E => 'es',
CH => 'cn',
KH => 'kr',
TA => 'tw',
S => 'se',
DK => 'dk',
H => 'no',
K => 'fi',
RS => 'ru',
PO => 'pt',
PL => 'pl',
AB => 'ar',
CR => 'hr',
CZ => 'cs',
GR => 'el',
HB => 'he',
MG => 'hu',
RO => 'ro',
SL => 'sk',
TU => 'tr',
UA => 'uk',
TH => 'th',
CA => 'ca',
ID => 'id',
VN => 'vi',
MY => 'ms'
);

%kAGLanguageCode2TMX = (
'en_GB' => 'en_GB',
'ja' => 'ja',
'fr' => 'fr',
'de' => 'de',
'nl' => 'nl',
'it' => 'it',
'es' => 'es',
'zh_CN' => 'zh-CN',
'ko' => 'ko',
'zh_TW' => 'zh-TW',
'sv' => 'sv',
'da' => 'da',
'no' => 'no',
'fi' => 'fi',
'pt_BR' => 'pt-BR',
'ru' => 'ru',
'pt_PT' => 'pt-PT',
'pl' => 'pl',
'ar' => 'ar',
'hr' => 'hr',
'cs' => 'cs',
'el' => 'el',
'he' => 'he',
'hu' => 'hu',
'ro' => 'ro',
'sk' => 'sk',
'tr' => 'tr',
'uk' => 'uk',
'th' => 'th',
'ca' => 'ca',
'id' => 'id',
'vi' => 'vi',
'ms' => 'ms'
);


%kTMX2AGLanguageCode = (
'en_GB' => 'en_GB',
'ja' => 'ja',
'fr' => 'fr',
'de' => 'de',
'nl' => 'nl',
'it' => 'it',
'es' => 'es',
'zh-CN' => 'zh_CN',
'ko' => 'ko',
'zh-TW' => 'zh_TW',
'sv' => 'sv',
'da' => 'da',
'no' => 'no',
'fi' => 'fi',
'pt-BR' => 'pt_BR',
'ru' => 'ru',
'pt-PT' => 'pt_PT',
'pl' => 'pl',
'ar' => 'ar',
'hr' => 'hr',
'cs' => 'cs',
'el' => 'el',
'he' => 'he',
'hu' => 'hu',
'ro' => 'ro',
'sk' => 'sk',
'tr' => 'tr',
'uk' => 'uk',
'th' => 'th',
'ca' => 'ca',
'id' => 'id',
'vi' => 'vi',
'ms' => 'ms'
);

# Script Codes

%kLprojLanguageCode2ScriptCode = (
'en_GB'   => 0,
'French'   => 0,
'fr'       => 0,
'German'   => 0,
'de'       => 0,
'Japanese' => 1,
'jp'       => 1,
'Dutch'    => 0,
'nl'       => 0,
'Italian'  => 0,
'it'       => 0,
'Spanish'  => 0,
'es'       => 0,
'zh_TW'    => 2,
'zh_CN'    => 25,
'ko'       => 3,
'da'       => 0,
'sv'       => 0,
'fi'       => 0,
'no'       => 0,
'pt'       => 0,
'ru'       => 7,
'pt_PT'    => 0,
'pl'       => 29,
'ar'       => 4,
'hr'       => 0,
'cs'       => 29,
'el'       => 0,
'he'       => 5,
'hu'       => 29,
'ro'       => 0,
'sk'       => 29,
'tr'       => 0,
'uk'       => 7,
'th'       => 21,
'ca'       => 0,
'id'       => 0,
'vi'       => 30,
'ms'       => 0
);


# Language Codes

%kLprojLanguageCode2LanguageCode = (
'French'   => 1,
'fr'       => 1,
'German'   => 2,
'de'       => 2,
'Japanese' => 11,
'jp'       => 11,
'Dutch'    => 4,
'nl'       => 4,
'Italian'  => 3,
'it'       => 3,
'Spanish'  => 6,
'es'       => 6,
'zh_TW'    => 19,
'zh_CN'    => 33,
'ko'       => 23,
'da'       => 7,
'sv'       => 5,
'fi'       => 13,
'no'       => 9,
'pt'       => 8,
'ru'       => 32,
'pt_PT'    => 8,
'pl'       => 25,
'ar'       => 12,
'hr'       => 18,
'cs'       => 38,
'el'       => 14,
'he'       => 10,
'hu'       => 26,
'ro'       => 37,
'sk'       => 39,
'tr'       => 17,
'uk'       => 45,
'th'       => 22,
'ca'       => 130,
'id'       => 81,
'vi'       => 80,
'ms'       => 83
);


# Region Codes

%kLprojLanguageCode2RegionCode = (
'French'   => 1,
'fr'       => 1,
'German'   => 3,
'de'       => 3,
'Japanese' => 14,
'jp'       => 14,
'Dutch'    => 5,
'nl'       => 5,
'Italian'  => 4,
'it'       => 4,
'Spanish'  => 8,
'es'       => 8,
'zh_TW'    => 53,
'zh_CN'    => 52,
'ko'       => 51,
'da'       => 9,
'sv'       => 7,
'fi'       => 17,
'no'       => 12,
'pt'       => 71,
'ru'       => 49,
'pt_PT'    => 10,
'pl'       => 42,
'ar'       => 16,
'hr'       => 68,
'cs'       => 56,
'el'       => 20,
'he'       => 13,
'hu'       => 43,
'ro'       => 39,
'sk'       => 57,
'tr'       => 24,
'uk'       => 62,
'th'       => 54,
'ca'       => 73,
'id'       => 1,
'vi'       => 97,
'ms'       => 1
);

%kLprojLanguageCode2Charset = (
'en_GB'    => 'x-mac-roman',
'French'   => 'x-mac-roman',
'fr'       => 'x-mac-roman',
'German'   => 'ISO-8859-1',
'de'       => 'ISO-8859-1',
'Japanese' => 'Shift_JIS',
'jp'       => 'Shift_JIS',
'Dutch'    => 'x-mac-roman',
'nl'       => 'x-mac-roman',
'Italian'  => 'x-mac-roman',
'it'       => 'x-mac-roman',
'Spanish'  => 'x-mac-roman',
'es'       => 'x-mac-roman',
'zh_TW'    => 'big5',
'zh_CN'    => 'gb2312',
'ko'       => 'euc-kr',
'da'       => 'x-mac-roman',
'sv'       => 'x-mac-roman',
'fi'       => 'x-mac-roman',
'no'       => 'x-mac-roman',
'pt'       => 'x-mac-roman',
'ru'       => 'x-mac-roman',
'pt_PT'    => 'x-mac-roman',
'pl'       => 'x-mac-roman',
'ar'       => 'x-mac-roman',
'hr'       => 'x-mac-roman',
'cs'       => 'x-mac-roman',
'el'       => 'x-mac-roman',
'he'       => 'x-mac-roman',
'hu'       => 'x-mac-roman',
'ro'       => 'x-mac-roman',
'sk'       => 'x-mac-roman',
'tr'       => 'x-mac-roman',
'uk'       => 'x-mac-roman',
'th'       => 'x-mac-roman',
'ca'       => 'x-mac-roman',
'id'       => 'x-mac-roman',
'vi'       => 'x-mac-roman',
'ms'       => 'x-mac-roman'
);

%kLprojLanguageCode2LangFont = (
'en_GB'    => 'Lucida Grande',
'French'   => 'Lucida Grande',
'fr'       => 'Lucida Grande',
'German'   => 'Lucida Grande',
'de'       => 'Lucida Grande',
'Japanese' => 'Lucida Grande',
'jp'       => 'Lucida Grande',
'Dutch'    => 'Lucida Grande',
'nl'       => 'Lucida Grande',
'Italian'  => 'Lucida Grande',
'it'       => 'Lucida Grande',
'Spanish'  => 'Lucida Grande',
'es'       => 'Lucida Grande',
'zh_TW'    => 'LiHei Pro',
'zh_CN'    => 'STHeiti',
'ko'       => 'AppleGothic',
'da'       => 'Lucida Grande',
'sv'       => 'Lucida Grande',
'fi'       => 'Lucida Grande',
'no'       => 'Lucida Grande',
'pt'       => 'Lucida Grande',
'ru'       => 'Lucida Grande',
'pt_PT'    => 'Lucida Grande',
'pl'       => 'Lucida Grande',
'ar'       => 'Lucida Grande',
'hr'       => 'Lucida Grande',
'cs'       => 'Lucida Grande',
'el'       => 'Lucida Grande',
'he'       => 'Lucida Grande',
'hu'       => 'Lucida Grande',
'ro'       => 'Lucida Grande',
'sk'       => 'Lucida Grande',
'tr'       => 'Lucida Grande',
'uk'       => 'Lucida Grande',
'th'       => 'Lucida Grande',
'ca'       => 'Lucida Grande',
'id'       => 'Lucida Grande',
'vi'       => 'Lucida Grande',
'ms'       => 'Lucida Grande'
);

%kLprojLanguageCode2XMLLangFont = (
'en_GB'    => 'Lucida Grande',
'French'   => 'Lucida Grande',
'fr'       => 'Lucida Grande',
'German'   => 'Lucida Grande',
'de'       => 'Lucida Grande',
'Japanese' => 'Lucida Grande',
'jp'       => 'Lucida Grande',
'Dutch'    => 'Lucida Grande',
'nl'       => 'Lucida Grande',
'Italian'  => 'Lucida Grande',
'it'       => 'Lucida Grande',
'Spanish'  => 'Lucida Grande',
'es'       => 'Lucida Grande',
'zh_TW'    => 'LiHei Pro, Apple LiGothic',
'zh_CN'    => 'STHeiti, Hei',
'ko'       => 'AppleGothic',
'da'       => 'Lucida Grande',
'sv'       => 'Lucida Grande',
'fi'       => 'Lucida Grande',
'no'       => 'Lucida Grande',
'pt'       => 'Lucida Grande',
'ru'       => 'Lucida Grande',
'pt_PT'    => 'Lucida Grande',
'pl'       => 'Lucida Grande',
'ar'       => 'Lucida Grande',
'hr'       => 'Lucida Grande',
'cs'       => 'Lucida Grande',
'el'       => 'Lucida Grande',
'he'       => 'Lucida Grande',
'hu'       => 'Lucida Grande',
'ro'       => 'Lucida Grande',
'sk'       => 'Lucida Grande',
'tr'       => 'Lucida Grande',
'uk'       => 'Lucida Grande',
'th'       => 'Lucida Grande',
'ca'       => 'Lucida Grande',
'id'       => 'Lucida Grande',
'vi'       => 'Lucida Grande',
'ms'       => 'Lucida Grande'
);




#=============================================================================================
#	Loc Utilities
#=============================================================================================

sub PrintLog
{
	my ($inMessage) = @_;
	
	print STDERR "$inMessage";
}


sub PrintToReport
{
	my ($inMessage) = @_;
	
	print STDOUT "$inMessage";
}


#---------------------------------------------------------------------------------------------
#	GetLprojFromFilePath
#---------------------------------------------------------------------------------------------

sub GetLprojFromFilePath
{
	my ($inFullFilePath) = @_;
	$outLproj = "English";
	
	
	$inFullFilePath =~ m/(.*)\/(.*).lproj\//;	
	$outLproj = $2;
	
	return $outLproj;
}


#---------------------------------------------------------------------------------------------
#	GetEnglishPathFromLocPath
#---------------------------------------------------------------------------------------------

sub GetEnglishPathFromLocPath
{
	my ($inFullFilePath) = @_;
	
	my $outEnglishPath = $inFullFilePath;
	my $lprojFromPath = GetLprojFromFilePath($inFullFilePath);
	
	$outEnglishPath =~ s/$lprojFromPath.lproj/English.lproj/;
	
	if (!(-e $outEnglishPath))
	{
		$outEnglishPath = $inFullFilePath;
		$outEnglishPath =~ s/$lprojFromPath.lproj/en.lproj/;
	}
	
	return $outEnglishPath;
}




1;




#=============================================================================================
#									E N D   O F   F I L E
#=============================================================================================
