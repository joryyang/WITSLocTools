##*****************************************************************************
##
##  Project Name:	AALocCommand
##     File Name:	AAXliffUtilities
##		Author:	Stanley Au-Yeung
##		 Date:	Saturday, August 30, 2008
##
##   Description:	What it does...
##
##						   Copyright Apple Inc.
##						   All rights reserved.
##
##*****************************************************************************
##				      A U T H O R   I D E N T I T Y
##*****************************************************************************
##
##	Initials	Name
##	--------	-----------------------------------------------
##	SA			Stanley Au-Yeung (stanleyauyeung@asia.apple.com)
##
##*****************************************************************************
##				     R E V I S I O N   H I S T O R Y
##*****************************************************************************
##
##	Date		Time	Author	Description
##	--------	-----	------	---------------------------------------------
##	02/03/09	12:00	SA		Comment out binmode to fix TMX generation problem
##	08/30/08	12:00	SA		Original version
##
##*****************************************************************************

package AAXliffUtilities;

#=============================================================================================
#	Modules Used
#=============================================================================================

use utf8;
use File::Path;
use File::Find;
use File::stat;
use File::Spec;
use File::Copy;
use File::Basename;

use AALocUtilities;
use AALocFileUtilities;

# binmode(STDIN,  ":utf8");
# binmode(STDOUT, ":utf8");


#=============================================================================================
#	Xliff Utilities
#=============================================================================================

#---------------------------------------------------------------------------------------------
#	XliffToWGAD
#---------------------------------------------------------------------------------------------

%char_entities =
(
	"\x09" => '&#9;',
	"\x0a" => '&#10;',
	"\x0d" => '&#13;',
	'&' => '&amp;',
	'<' => '&lt;',
	'>' => '&gt;',
	'"' => '&quot;',
);

sub _escape
{
	my($string) = @_;

	$string =~ s/([\x09\x0a\x0d&<>"])/$char_entities{$1}/ge;
	
	return $string;
}


sub XliffToWGAD
{
	my($inXliffFilePath) = @_;
	
	$filePathWithoutSuffix = $inXliffFilePath;
	$filePathWithoutSuffix =~ m/(.*)\.(.*)/;
	$filePathWithoutSuffix = $1;

	my $outWGFilePath = $filePathWithoutSuffix . ".wg";
	my $outADFilePath = $filePathWithoutSuffix . ".ad";

	$projectName = $filePathWithoutSuffix;
	$projectName =~ m/(.*)\/(.*)/;
	$projectName = $2;
	
	@dates = localtime( time() );

	#-------------------------------------------------------------------------------------
	#	Write WG header
	#-------------------------------------------------------------------------------------
	
	# open (WGFILE, ">$outWGFilePath") || die "Can't open $outWGFilePath for wg output.\n";
	open WGFILE, ">:utf8", $outWGFilePath || die "Can't open $outWGFilePath for wg output.\n";
	
	print  WGFILE "<\?xml version=\"1.0\" encoding=\"UTF-8\"\?>\n";
	printf WGFILE ("<!-- Created by AALocCommand at %02d/%02d/%04d %02d:%02d:%02d                           -->\n",
						$dates[4] + 1, $dates[3], $dates[5] + 1900, $dates[2], $dates[1], $dates[0]);
	print  WGFILE "<!-- ". "="x70 . " -->\n";
	
	print  WGFILE "<Proj>\n";
	print  WGFILE "<ProjName>$projectName<\/ProjName>\n";
	print  WGFILE "\n";
	
	
	#-------------------------------------------------------------------------------------
	#	Write AD header
	#-------------------------------------------------------------------------------------
	
	# open (ADFILE, ">$outADFilePath") || die "Can't open $outADFilePath for ad output.\n";
	open ADFILE, ">:utf8", $outADFilePath || die "Can't open $outADFilePath for ad output.\n";
	
	print  ADFILE "<\?xml version=\"1.0\" encoding=\"UTF-8\"\?>\n";
	printf ADFILE ("<!-- Created by AALocCommand at %02d/%02d/%04d %02d:%02d:%02d                           -->\n",
	$dates[4] + 1, $dates[3], $dates[5] + 1900, $dates[2], $dates[1], $dates[0]);
	print  ADFILE "<!-- ". "="x70 . " -->\n";
	
	print  ADFILE "<Proj>\n";
	print  ADFILE "<ProjName>$projectName<\/ProjName>\n";
	print  ADFILE "\n";

	
	#-------------------------------------------------------------------------------------
	#
	#-------------------------------------------------------------------------------------

	# xliff file node example.
	# <file origin="InternetPref/English.lproj/cocoa.xib.strings" source-language="en" target-language="ja" datatype="strings">
	
	my $parser	= XML::LibXML->new();
	my $xliffDoc = $parser->parse_file($inXliffFilePath);
	
	my @fileNodes = $xliffDoc->getElementsByTagName('file');
	
	foreach my $fileNode (@fileNodes)
	{
		my $wgHeaderPrinted = 0;
		my $adHeaderPrinted = 0;

		
		my $originNode = $fileNode->getAttributeNode('origin');
		my $language = $fileNode->getAttributeNode('target-language')->textContent();
		
		$language = $AALocUtilities::kTMX2AGLanguageCode{$language};
		
		unless ($originNode)
		{
			printf STDERR "### [XliffToWGAD] error: No 'origin' attribute in $inXliffFilePath \n";
			next;
		}
		
		my $origin = $originNode->textContent();
		
		# Move to <body> nodes
		my @bodyNodes = $fileNode->getChildrenByTagName('body');
		if ( ( scalar @bodyNodes ) != 1 )
		{
			printf STDERR "### [XliffToWGAD] error: 0 or more than 1 <body> in $nibPath in $inXliffFilePath \n";
			next;
		}
		
		# Process each <trans-unit> node
		my @transUnitNodes = $bodyNodes[0]->getChildrenByTagName('trans-unit');
		foreach my $transUnitNode (@transUnitNodes)
		{
			
			# Get object id from 'id' attribute
			# <trans-unit id="36.title">
			my $idNode = $transUnitNode->getAttributeNode('id');
			unless ( $idNode )
			{
				printf STDERR "### [XliffToWGAD] error: No 'id' attribute in $nibPath in $inXliffFilePath \n";
				next;
			}
			
			my $id = $idNode->textContent();
			$id =~ m/^(-?\d+)/;
			$id = $1;
			
			# Get translation status from 'state' attribute
			# <target state="signed-off" state-qualifier="id-match">ccc</target>
			my @targetNodes = $transUnitNode->getChildrenByTagName('target');
			if ( ( scalar @targetNodes ) != 1 )
			{
				printf STDERR "### [XliffToWGAD] error: 0 or more than 1 <target> for $id in $nibPath in $inXliffFilePath \n";
				print STDERR Dumper( \@targetNodes );
				next;
			}
			
			my $stateNode = $targetNodes[0]->getAttributeNode('state');
			unless ( $stateNode )
			{
				printf STDERR "### [XliffToWGAD] error: No 'state' attribute for $id in $nibPath in $inXliffFilePath \n";
				next;
			}
			
			my $state = $stateNode->textContent();
			
			
			my $stateOrigin = "";
			my $stateOriginNode = $targetNodes[0]->getAttributeNode('state-origin');
			if ( $stateOriginNode )
			{
				$stateOrigin = $stateOriginNode->textContent();
			}

			
			my $targetString = _escape($targetNodes[0]->textContent());

			
			my @sourceNodes = $transUnitNode->getChildrenByTagName('source');
			my $sourceString = _escape($sourceNodes[0]->textContent());
			
			# print "$state - $sourceString\n";
			# print "$targetString\n\n";
			
			if ($state eq "new" || $stateOrigin eq "needs-review-translation" || $stateOrigin eq "new")
			{
				if ($wgHeaderPrinted == 0)
				{
					print  WGFILE "<!-- ". " "x70 . " -->\n";
					printf WGFILE ( "<!--    %-64s    -->\n", $origin );
					print  WGFILE "<!-- ". " "x70 . " -->\n";
					print  WGFILE "<File>\n";
					print  WGFILE "<Filepath>$origin<\/Filepath>\n\n";
					
					$wgHeaderPrinted = 1;
				}
				
				if ($state eq "new")
				{
					$stateOrigin = "new";
				}
				
				print  WGFILE "<TextItem>\n";
				print  WGFILE "<Description>Description<\/Description>\n";
				print  WGFILE "<Position>Position<\/Position>\n";
				print  WGFILE "<TranslationSet>\n\n";
				print  WGFILE ("\t<base loc=\"en\"            >$sourceString<\/base>\n");
				print  WGFILE ("\t<tran loc=\"$language\" origin=\"$stateOrigin\">$targetString<\/tran>\n\n");
				print  WGFILE "<\/TranslationSet>\n";
				print  WGFILE "<\/TextItem>\n\n";
			}
			else
			{
				if ($adHeaderPrinted == 0)
				{
					print  ADFILE "<!-- ". " "x70 . " -->\n";
					printf ADFILE ( "<!--    %-64s    -->\n", $origin );
					print  ADFILE "<!-- ". " "x70 . " -->\n";
					print  ADFILE "<File>\n";
					print  ADFILE "<Filepath>$origin<\/Filepath>\n\n";
					
					$adHeaderPrinted = 1;
				}

				print  ADFILE "<TextItem>\n";
				print  ADFILE "<Description>Description<\/Description>\n";
				print  ADFILE "<Position>Position<\/Position>\n";
				print  ADFILE "<TranslationSet>\n\n";
				print  ADFILE ("\t<base loc=\"en\"            >$sourceString<\/base>\n");
				print  ADFILE ("\t<tran loc=\"$language\" origin=\"\">$targetString<\/tran>\n\n");
				print  ADFILE "<\/TranslationSet>\n";
				print  ADFILE "<\/TextItem>\n\n";
			}
		}
		
		
		if ($wgHeaderPrinted == 1)
		{
			print WGFILE "</File>\n\n";
		}

		if ($adHeaderPrinted == 1)
		{
			print ADFILE "</File>\n\n";
		}
	}
	
	
	#-------------------------------------------------------------------------------------
	#	Write WG footer
	#-------------------------------------------------------------------------------------
	
	print WGFILE "</Proj>\n\n";
	close (WGFILE);
	
	
	#-------------------------------------------------------------------------------------
	#	Write AD footer
	#-------------------------------------------------------------------------------------
	
	print ADFILE "</Proj>\n\n";
	close (ADFILE);
}


#---------------------------------------------------------------------------------------------
#	XliffFolderToWGAD
#---------------------------------------------------------------------------------------------

sub XliffFolderToWGAD
{
	my($inXliffFolderPath) = @_;
	
	
	#-----------------------------------------------------------------------------------------
	#	Check input path
	#-----------------------------------------------------------------------------------------
	
	if (!(-d "$inXliffFolderPath"))
	{
		AALocUtilities::PrintLog("\n### ERROR: The specified folder $inXliffFolderPath doesn't exist.\n");
		return;
	}
	
	
	#-----------------------------------------------------------------------------------------
	#
	#-----------------------------------------------------------------------------------------

	chomp(@searchResult = `find "$inXliffFolderPath" -type f | grep ".xliff" | grep -v ".DS_Store"`);
	
	foreach $file (@searchResult)
	{
		$filename = $file;
		$filename =~ s/$inXliffFolderPath//;
		
		AALocUtilities::PrintLog("Converting $filename\n");
		XliffToWGAD($file);
	}
}	




1;




#=============================================================================================
#									E N D   O F   F I L E
#=============================================================================================
