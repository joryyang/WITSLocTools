#####################################################################################################
#    $Id: Pcxout.pm,v 1.14 2007/05/21 20:44:21 asaka1 Exp $
#     Wraper module to parse pcx out.
#
#    Created by kenji on Fri Jan 10 2002.
#    Copyright (c) 2002 Apple Computer Inc. All rights reserved.
#####################################################################################################

package Pcxout;
require Exporter;
use Pcx;

our @ISA    = qw(Exporter);
our @EXPORT = qw(
  Parse_pcxout
  @pcx_progress
  @pcx_nibtool_error
  @pcx_string_error
  @pcx_error
  @pcx_warning
  @pcx_unknown
  @pcx_metaInfo
  @pcx_debug
  @pcx_details
  %pcx_summary_file
  %pcx_summary_dir
  %pcx_summary_nib
  %pcx_map_nib_source_target
  %pcx_map_file_source_target
  %pcx_shell_scripts
  %pcx_arguments
  %pcx_action_scripts
  %actionScripts
);
our $VERSION = 1.02;    # Version number

#------------------------------------------------------------------------------------------
#	Parse pcx output
#------------------------------------------------------------------------------------------
sub Parse_pcxout
{
    my ($pcxout_ref, $user) = @_;
    my $category;
    my $info;
    my ($pair, $source, $target);
    my %details;
    my %temp;
    my ($c, $d, $f, $sf, $tf, $kind);
    my $cat    = "new|changed|obsolete|identical";
    my $cat2   = "new|obsolete|identical";
    my $entity = "file|dir|nib";
    my $sharp  = "#";
    my ($metainfoKind, $metainfo);
    my %pcx_metainfo = ();
    my $shellScript;
    my $shellScriptResult;
    my $key;
    my $value;
    my %filter                       = ();
    my @file_level_supplemental_info = ();

    @pcx_progress               = ();
    @pcx_nibtool_error          = ();
    @pcx_error                  = ();
    @pcx_warning                = ();
    @pcx_unknown                = ();
    @pcx_metaInfo               = ();
    @pcx_debug                  = ();
    @pcx_details                = ();
    %pcx_summary_file           = ();
    %pcx_summary_dir            = ();
    %pcx_summary_nib            = ();
    %pcx_map_nib_source_target  = ();
    %pcx_map_file_source_target = ();
    %pcx_shell_scripts          = ();
    %pcx_arguments              = ();
    %pcx_action_scripts         = ();

    %details_file = ();
    %details_dir  = ();
    %details_nib  = ();

    if ($user eq "localizer")
    {
        $filter{"subdir"}              = 1;
        $filter{"files_in_nibdir"}     = 1;
        $filter{"nibs_in_dir_summary"} = 1;
        $filter{"dir_details"}         = 1;
        $filter{"finfo_cdate"}         = 1;
        $filter{"finfo_mdate"}         = 1;
        $filter{"finfo_unix"}          = 1;
        $filter{"finfo_type"}          = 1;
        $filter{"finfo_creator"}       = 1;
        $filter{"finfo_flags"}         = 1;
        $filter{"finfo_ioFlAttrib"}    = 1;
        $filter{"finfo_script"}        = 1;
        $filter{"res_padding"}         = 1;
    }
    elsif ($user eq "verify")
    {
        $filter{"subdir"}                        = 0;
        $filter{"files_in_nibdir"}               = 1;
        $filter{"nibs_in_dir_summary"}           = 1;
        $filter{"dir_details"}                   = 1;
        $filter{"finfo_cdate"}                   = 1;
        $filter{"finfo_mdate"}                   = 1;
        $filter{"finfo_unix"}                    = 1;
        $filter{"finfo_type"}                    = 1;
        $filter{"finfo_creator"}                 = 1;
        $filter{"finfo_flags"}                   = 1;
        $filter{"finfo_ioFlAttrib"}              = 1;
        $filter{"finfo_script"}                  = 1;
        $filter{"res_padding"}                   = 1;
        $filter{"nib_obj_tableView_frameRect"}   = 1;
        $filter{"nib_obj_outlineView_frameRect"} = 1;
    }
    elsif ($user eq "nib_verify")
    {
        $filter{"subdir"}                        = 1;
        $filter{"files_in_nibdir"}               = 1;
        $filter{"nibs_in_dir_summary"}           = 1;
        $filter{"dir_details"}                   = 1;
        $filter{"finfo_cdate"}                   = 1;
        $filter{"finfo_mdate"}                   = 1;
        $filter{"finfo_unix"}                    = 1;
        $filter{"finfo_type"}                    = 1;
        $filter{"finfo_creator"}                 = 1;
        $filter{"finfo_flags"}                   = 1;
        $filter{"finfo_ioFlAttrib"}              = 1;
        $filter{"finfo_script"}                  = 1;
        $filter{"res_padding"}                   = 1;
        $filter{"nib_obj_tableView_frameRect"}   = 1;
        $filter{"nib_obj_outlineView_frameRect"} = 1;
        $filter{"nib_obj_frameRect"}             = 1;
        $filter{"nib_obj_stringValue"}           = 1;
        $filter{"nib_obj_title"}                 = 1;
        $filter{"nib_obj_alternateTitle"}        = 1;
        $filter{"nib_obj_contentRect"}           = 1;
        $filter{"nib_obj_cellSize"}              = 1;
        $filter{"nib_obj_intercellSpacing"}      = 1;
        $filter{"nib_obj_width"}                 = 1;
        $filter{"nib_connect_Marker"}            = 1;
        $filter{"nib_obj_label"}                 = 1;
        $filter{"file_details"}                  = 1;
        $filter{"file_binary_DF"}                = 1;
        $filter{"file_binary_RF"}                = 1;
        $filter{"nib_obj_titleWidth"}            = 1;
        $filter{"nib_obj_maxWidth"}              = 1;
        $filter{"nib_obj_textStorageAttribute"}  = 1;
        $filter{"nib_obj_textStorageContent"}    = 1;
        $filter{"nib_obj_Name"}                  = 1;
        $filter{"nib_obj_controlTitle"}          = 1;
        $filter{"nib_obj_font"}                  = 1;
        $filter{"nib_obj_helpTagText"}           = 1;
        $filter{"nib_obj_controlSize"}           = 1;
        $filter{"nib_obj_titleFont"}             = 1;
        $filter{"nib_obj_iBFont"}                = 1;
        $filter{"nib_obj_NSFont"}                = 1;
        $filter{"nib_obj_textStorage"}           = 1;
        $filter{"nib_obj_maxSize"}               = 1;
        $filter{"nib_obj_minSize"}               = 1;
    }
    elsif ($user =~ m/^0x(.+)$/i)
    {
        &Init_filter(\%filter, $1);
    }
    else
    {
        &Init_filter(\%filter, "00000000000000000000");
    }

    foreach (@{$pcxout_ref})
    {
        if (m/^$sharp \[pcx:e:nibtool:/ && (!$filter{"nib_error"} || next))
        {
            # nibtool error message
            push(@pcx_nibtool_error, $_);
        }
        elsif (m/^$sharp \[pcx:e:(.*)NSParseErrorException/)
        {
            # string file error message
            push(@pcx_string_error, $_);
        }
        elsif (m/^$sharp \[pcx:e:/ && (!$filter{"error"} || next))
        {
            # error message
            push(@pcx_error, $_);
        }
        elsif (m/^$sharp \[pcx:p:/ && (!$filter{"progress"} || next))
        {
            # progress message
            s/\[.+?\] //;
            push(@pcx_progress, $_);
        }
        elsif (m/^$sharp \[pcx:w:/ && (!$filter{"warning"} || next))
        {
            # warning message
            push(@pcx_warning, $_);
        }
        elsif (m/^$sharp \[pcx:i:($cat2):dir:\] (.*)$/ && (!$filter{"dir_summary"} || next))
        {
            #-------------------------------
            # directory level summary info
            #-------------------------------
            $category = $1;
            $info     = $2;
            next if (($info =~ m/(.+)\.nib$/) && $filter{"nibs_in_dir_summary"});
            $temp{$category}->{$info}++;
        }
        elsif (m/^$sharp \[pcx:m:file:summary:(.*):(\/\/->(.*)<-\/\/->(.*)<-\/\/){1}?:\] (.*)$/)
        {
            #---------------------------------------------------------
            # Supplemental information for file level summary report
            #-------------------------------------------------------------
            my $supplemental_info = $1;
            $source = $3;    # source parent directory
            $target = $4;    # target parent directory
            $f      = $5;    # file

            $file_level_supplemental_info{$source . $target}->{$f} = $supplemental_info;

        }
        elsif (m/^$sharp \[pcx:i:($cat):file:(([DR]F|\*\*):(res_map:)?)?(\/\/->(.*)<-\/\/->(.*)<-\/\/){1}?:\] (.*)$/ && (!$filter{"file_summary"} || next))
        {
            #---------------------------
            # file level summary info
            #---------------------------
            $category = $1;
            $f_kind   = $3;
            $meta     = $4;
            $source   = $6;    # source parent directory
            $target   = $7;    # target parent directory
            $f        = $8;

            if ($filter{"files_in_nibdir"})
            {
                if (($source =~ m/(.+)\.[nx]ib$/) && ($f =~ m/^(classes|objects|keyedobjects|info)\./))
                {
                    # Skip files in a .nib directory
                    next;
                }
                if (($target =~ m/(.+)\.[nx]ib$/) && ($f =~ m/^(classes|objects|keyedobjects|info)\./))
                {
                    # Skip files in a .nib directory
                    next;
                }
            }

            # Add supplemental inforation if it exists.
            my $supplemental_info = "";
            if (exists $file_level_supplemental_info{$source . $target}->{$f})
            {
                $supplemental_info = $file_level_supplemental_info{$source . $target}->{$f};
            }

            my $bothSourceAndTargetInFilePath = undef;
            if ($f =~ m/<-\/\/->/)
            {
                ($sf, $tf) = split(/ <-\/\/-> /, $f);
                $bothSourceAndTargetInFilePath = defined;
            }
            else
            {
                $sf = $tf = $f;
            }

            if ($target)
            {
                $target .= "/" . $tf;
            }
            else
            {
                $target = $tf;
            }

            if ($source)
            {
                $source .= "/" . $sf;
            }
            else
            {
                $source = $sf;
            }

            if ($category eq "new")
            {
                push(@{$pcx_summary_file{$category}}, $supplemental_info . $target);
            }
            elsif ($category eq "obsolete")
            {
                push(@{$pcx_summary_file{$category}}, $supplemental_info . $source);
            }
            else
            {
                if ($meta)
                {
                    $metaInnfo = $4;
                    chop $meta;
                    $kind .= "_" . $meta;
                    #if ($sf eq $tf) {
                    unless (defined $bothSourceAndTargetInFilePath)
                    {
                        push(@{$pcx_summary_file{$category}->{$supplemental_info . $source}}, $f_kind);
                    }
                    else
                    {
                        push(@{$pcx_summary_file{$category}->{$supplemental_info . $source . " <-//-> " . $target}}, $f_kind);
                    }
                }
                else
                {
                    # if ($sf eq $tf) {
                    unless (defined $bothSourceAndTargetInFilePath)
                    {
                        push(@{$pcx_summary_file{$category}->{$supplemental_info . $source}}, $f_kind);
                    }
                    else
                    {
                        push(@{$pcx_summary_file{$category}->{$supplemental_info . $source . " <-//-> " . $target}}, $f_kind);
                    }
                }

                $pcx_map_file_source_target{$source} = $target;
            }

            if (!$filter{"details"} && $f_kind)
            {
                # Rmove leading ./
                $source =~ s/^\.\///;
                $target =~ s/^\.\///;
                push(@{$details_file{$source . "<-//->" . $target}}, {$f_kind => $category});
            }
        }
        elsif (m/^$sharp \[pcx:i:($cat):nib:(\/\/->(.*)<-\/\/->(.*)<-\/\/){1}?:\] (.*)$/ && (!$filter{"nib_summary"} || next))
        {
            #---------------------------
            # nib summary info
            #---------------------------
            $category = $1;
            $source   = $3;    # source parent directory
            $target   = $4;    # target parent directory
            $nibdir   = $5;    # nib directory

            if ($category eq "new")
            {
                push(@{$pcx_summary_nib{$category}}, $target . "\/" . $nibdir);
            }
            elsif ($category eq "obsolete")
            {
                push(@{$pcx_summary_nib{$category}}, $source . "\/" . $nibdir);
            }
            else
            {
                push(@{$pcx_summary_nib{$category}}, $source . "\/" . $nibdir);
                $pcx_map_nib_source_target{$source . "\/" . $nibdir} = $target . "\/" . $nibdir;
            }
        }
        elsif (m/^$sharp \[pcx:i:(.+):($entity):(.*)(\/\/->(.*)<-\/\/->(.*)<-\/\/){1}?:\] (.*)$/ && (!$filter{"details"} || next))
        {
            #-----------------------------------------------------------
            # Pass the other detailed information messages to Pcx.pm
            #-----------------------------------------------------------
            $kind   = $2;
            $pair   = $4;
            $source = $5;
            $target = $6;
            $info   = $7;

            if ($filter{"files_in_nibdir"})
            {
                if ($source =~ m/(.+)\.nib\/([^\/]+)$/)
                {
                    $f = $2;
                    if ($f =~ m/^(classes|objects|keyedobjects|info)\./)
                    {
                        # Skip files in a .nib directory
                        next;
                    }
                }
                if ($target =~ m/(.+)\.nib\/([^\/]+)$/)
                {
                    $f = $2;
                    if ($f =~ m/^(classes|objects|keyedobjects|info)\./)
                    {
                        # Skip files in a .nib directory
                        next;
                    }
                }
            }

            if (($kind eq "file") && (!$filter{"file_details"} || next))
            {
                push(@{$details_file{$source . "<-//->" . $target}}, $_);
            }
            elsif (($kind eq "dir") && (!$filter{"dir_details"} || next))
            {
                push(@{$details_dir{$source . "<-//->" . $target}}, $_);
            }
            elsif (($kind eq "nib") && (!$filter{"nib_details"} || next))
            {
                push(@{$details_nib{$source . "<-//->" . $target}}, $_);
            }
            else
            {
                push(@pcx_unknown, $_);
            }
        }
        elsif (m/^$sharp \[pcx:m:summaryOpendiff:\] (.*)$/)
        {
            #-----------------------------------------------------------
            # Shell script to be executed in fpcx.
            #-----------------------------------------------------------
            $shellScript = $1;
            push(@{$pcx_shell_scripts{"summaryOpendiff"}}, [split(/ \\ ===> \\ /, $shellScript)]);

        }
        elsif (m/^$sharp \[pcx:m:mapping:(.+):(.+):(\/\/->(.*)<-\/\/->(.*)<-\/\/){1}?:\] (.*)$/)
        {
            #-----------------------------------------------------------
            # File/directory name mapping info.
            #-----------------------------------------------------------
            push(@pcx_metaInfo, $_);

        }
        elsif (m/^$sharp \[pcx:m:RunShellTool:(.+):\] (.*)$/)
        {
            #-----------------------------------------------------------
            # Action shell scripts
            #-----------------------------------------------------------
            $shellScript       = $1;
            $shellScriptResult = $2;
            push(@{$actionScripts{$shellScript}}, $shellScriptResult);

        }
        elsif (m/^$sharp \[pcx:m:(.+):(\/\/->(.*)<-\/\/->(.*)<-\/\/){1}?:\] (.*)$/)
        {
            #-----------------------------------------------------------
            # Meta information such as opendiff command
            #-----------------------------------------------------------
            $metainfoKind = $1;
            $pair         = $2;
            $source       = $3;    # source file
            $target       = $4;    # target file
            $metainfo     = $5;

            $source =~ s/^\.\///;
            $target =~ s/^\.\///;

            $pcx_metainfo{$source . "<-//->" . $target}->{$metainfoKind} = [split(/ \\ ===> \\ /, $metainfo)];
        }
        elsif (m/^$sharp \[pcx:a:(.+):\] (.*)$/)
        {
            #-----------------------------------------------------------
            # pcx arguments
            #-----------------------------------------------------------
            $key                 = $1;
            $value               = $2;
            $pcx_arguments{$key} = $value;

        }
        elsif (m/^$sharp \[pcx:s:($cat):($entity):\] (.*)$/)
        {
            #-----------------------------------------------------------
            # action scripts
            #-----------------------------------------------------------
            $category = $1;
            $kind     = $2;
            $script   = $3;
            push(@{$pcx_action_scripts{$kind}->{$category}}, $script);

        }
        elsif (!$filter{"unknown"})
        {
            #-----------------------------
            # Unknown
            #-----------------------------
            push(@pcx_unknown, $_);
        }
    }

    #------------------------------------------------------------------------------
    # Construct @pcx_summary_dir containing summary info for directory.
    #	Supress sub directories as they are overwhelming.
    #------------------------------------------------------------------------------
    foreach $category (keys %temp)
    {
        foreach $info (keys %{$temp{$category}})
        {
            if ($filter{"subdir"})
            {
                if ($info =~ m/(.+)\/[^\/]+/)
                {
                    $parent = $1;
                    if (exists $temp{$category}->{$parent})
                    {
                        next;
                    }
                }
            }
            push(@{$pcx_summary_dir{$category}}, $info);
        }
    }

    #------------------------------------------------------------------------------
    # Construct Pcx objects containing detailed info for each file/directory/nib.
    #------------------------------------------------------------------------------
    foreach (sort keys %details_file)
    {
        push(@pcx_details, (Pcx->new($_, $details_file{$_}, "file", \%filter, \%pcx_metainfo) || next));
    }

    foreach (sort keys %details_dir)
    {
        push(@pcx_details, (Pcx->new($_, $details_dir{$_}, "dir", \%filter, \%pcx_metainfo) || next));
    }

    foreach (sort keys %details_nib)
    {
        push(@pcx_details, (Pcx->new($_, $details_nib{$_}, "nib", \%filter, \%pcx_metainfo) || next));
    }
}

#****************************************************************************************
#	Initialize filtering options hash
#
#
#
#****************************************************************************************
sub Init_filter
{
    my %filter_mask = (
        0  => "subdir",
        1  => "nib_error",
        2  => "error",
        3  => "warning",
        4  => "progress",
        5  => "dir_summary",
        6  => "file_summary",
        7  => "nib_summary",
        8  => "files_in_nibdir",
        9  => "nibs_in_dir_summary",
        10 => "details",
        11 => "unknown",
        12 => "dir_details",
        13 => "file_details",
        14 => "nib_details",
        15 => "finfo_cdate",
        16 => "finfo_mdate",
        17 => "finfo_unix",
        18 => "strings",
        19 => "diff",
        20 => "hexdump",
        21 => "res_rect",
        22 => "res_str",
        23 => "nib_class_hierachy",
        24 => "nib_connect_summary",
        25 => "nib_connect_details",
        26 => "nib_obj_summary",
        27 => "nib_obj_details",
        28 => "nib_obj_stringValue",
        29 => "nib_obj_tag",
        30 => "nib_obj_frameRect",
        31 => "nib_obj_contentRect",
        32 => "nib_obj_cellSize",
        33 => "nib_obj_intercellSpacing",
        34 => "nib_obj_font",
        35 => "nib_obj_title",
        36 => "nib_obj_alternateTitle",
        37 => "nib_obj_label",
        38 => "res_summary",
        39 => "res_details",
        40 => "res_padding",
        41 => "res_ppob_WidthHeight",
        42 => "res_ppob_LeftLocation",
        43 => "res_ppob_TopLocation",
        44 => "res_ppob_structure",
        45 => "res_ppob_ctyp",
        46 => "res_ppob_TitleWidth",
        47 => "res_ppob_Binding",
        48 => "res_ppob_BehaviorFlags",
        49 => "res_ppob_Visible",
        50 => "res_ppob_Title",
        51 => "res_category_attrs",
        52 => "res_category_name",
        53 => "res_category_data",
        54 => "finfo_type",
        55 => "finfo_creator",
        56 => "finfo_flags",
        57 => "finfo_ioFlAttrib",
        58 => "finfo_script",
        59 => "nib_obj_tableView_frameRect",
        60 => "nib_connect_Marker",
        61 => "nib_obj_width",
        62 => "file_binary_DF",
        63 => "file_binary_RF",
        64 => "nib_obj_titleWidth",
        65 => "nib_obj_maxWidth",
        66 => "nib_obj_textStorageAttribute",
        67 => "nib_obj_textStorageContent",
        68 => "nib_obj_Name",
        69 => "nib_obj_controlTitle",
        70 => "nib_obj_helpTagText",
        71 => "nib_obj_controlSize",
        72 => "nib_obj_titleFont",
        73 => "nib_obj_iBFont",
        74 => "nib_obj_NSFont",
        75 => "nib_obj_textStorage",
        76 => "nib_obj_maxSize",
        77 => "nib_obj_minSize",
        78 => "nib_obj_outlineView_frameRect",
        79 => "reserved-10",
    );

    my ($filterRef, $param) = @_;
    my ($temp, $bit_string, $i);

    $temp = pack("H*", $param);
    $bit_string = unpack("B*", $temp);

    $i = 0;
    foreach (split(//, $bit_string))
    {
        # print $i, "\t", $_, "\n";
        $filterRef->{$filter_mask{$i}} = $_;
        $i++;
    }

}

1;

__DATA__
Sample output format of pcx as of 6/9/2001
--------------------------------------------------------------------------------
	directory level information
--------------------------------------------------------------------------------
# [pcx:i:new:dir:] /Users/kenji/b4/TextEdit.app/Contents/new folder in b4
# [pcx:i:obsolete:dir:] /Users/kenji/b3/TextEdit.app/Contents/Resources/obsolete folder in b3
# [pcx:i:identical:dir:] /Users/kenji/b3/TextEdit.app/Contents/Resources

--------------------------------------------------------------------------------
	file level information
--------------------------------------------------------------------------------
# [pcx:i:new:file://->/Users/kenji/b3/TextEdit.app/Contents<-//->/Users/kenji/b4/TextEdit.app/Contents<-//:] PkgInfo
# [pcx:i:obsolete:file://->/Users/kenji/b3/TextEdit.app/Contents/MacOS<-//->/Users/kenji/b4/TextEdit.app/Contents/MacOS<-//:] TextEdit
# [pcx:i:identical:file://->/Users/kenji/b3/TextEdit.app/Contents<-//->/Users/kenji/b4/TextEdit.app/Contents<-//:] Info.plist
# [pcx:i:identical:file:DF://->/Users/kenji/b3/TextEdit.app/Contents/Resources/Japanese.lproj<-//->/Users/kenji/b4/TextEdit.app/Contents/Resources/Japanese.lproj<-//:] Credits.rtf
# [pcx:i:changed:file:DF://->/Users/kenji/b3/TextEdit.app/Contents/Resources/English.lproj<-//->/Users/kenji/b3/TextEdit.app/Contents/Resources/Japanese.lproj<-//:] Credits.rtf
# [pcx:i:changed:file:RF://->/Volumes/ln/System Folder/Help/Mac Help/ln/pgs<-//->/Volumes/ln 1/System Folder/Help/Mac Help/ln/pgs<-//:] lnAbtCP.htm
# [pcx:i:identical:file:DF://->/Volumes/ln/System Folder/Help/Mac Help/ln/pgs<-//->/Volumes/ln 1/System Folder/Help/Mac Help/ln/pgs<-//:] lnAbtMc.htm

--------------------------------------------------------------------------------
	hex dump
--------------------------------------------------------------------------------
# [pcx:i:changed:file:DF:byte:0015DBD8://->/Users/kenji/w3<-//->/Users/kenji/w4<-//:] 7420 6D61 7463 682E 5C22 5C6E 2229 3B0D [t match.\"\n");.] \ ===> \ 3030 3131 3232 3333 3434 3535 3636 3737 [0011223344556677]
# [pcx:i:changed:file:RF:byte:00000005://->/Users/kenji/w3<-//->/Users/kenji/w4<-//:] 69 [i] \ ===> \ 6A [j]

--------------------------------------------------------------------------------
	.strings file
--------------------------------------------------------------------------------
# [pcx:i:new:file:str://->/Users/kenji/us/Localizable.strings<-//->/Users/kenji/j/Localizable.strings<-//:] "Quit" = "Quit"
# [pcx:i:obsolete:file:str://->/Users/kenji/us/Localizable.strings<-//->/Users/kenji/j/Localizable.strings<-//:] "Abort" = "Abort"
# [pcx:i:changed:file:str://->/Users/kenji/us/Localizable.strings<-//->/Users/kenji/j/Localizable.strings<-//:] "File system error" \ ===> \ "File system error."
# [pcx:i:identical:file:str://->/Users/kenji/us/Localizable.strings<-//->/Users/kenji/j/Localizable.strings<-//:] "UNTITLED" = "New Note"

--------------------------------------------------------------------------------
	nib
--------------------------------------------------------------------------------
# [pcx:i:changed:nib://->/Users/kenji/TextEdit.app/Contents/Resources/English.lproj/Document.nib<-//->/Users/kenji/TextEdit.app/Contents/Resources/Japanese.lproj/Document.nib<-//:] Document.nib
# [pcx:i:identical:nib:obj://->/Users/kenji/TextEdit.app/Contents/Resources/English.lproj/Edit.nib<-//->/Users/kenji/TextEdit.app/Contents/Resources/Japanese.lproj/Edit.nib<-//:] 1
# [pcx:i:identical:nib:obj:1:className://->/Users/kenji/TextEdit.app/Contents/Resources/English.lproj/Edit.nib<-//->/Users/kenji/TextEdit.app/Contents/Resources/Japanese.lproj/Edit.nib<-//:] "NSApplication"
# [pcx:i:changed:nib:obj://->/Users/kenji/TextEdit.app/Contents/Resources/English.lproj/Edit.nib<-//->/Users/kenji/TextEdit.app/Contents/Resources/Japanese.lproj/Edit.nib<-//:] 4
# [pcx:i:changed:nib:obj:4:title://->/Users/kenji/TextEdit.app/Contents/Resources/English.lproj/Edit.nib<-//->/Users/kenji/TextEdit.app/Contents/Resources/Japanese.lproj/Edit.nib<-//:] "US" \ ===> \ "Loc"

# [pcx:i:changed:nib:connect://->/Users/kenji/Clock.app/Contents/Resources/English.lproj/Clock2.nib<-//->/Users/kenji/TextEdit.app/Contents/Resources/English.lproj/Clock2.nib<-//:] 189
# [pcx:i:changed:nib:connect:189:Source://->/Users/kenji/Clock.app/Contents/Resources/English.lproj/Clock2.nib<-//->/Users/kenji/TextEdit.app/Contents/Resources/English.lproj/Clock2.nib<-//:] "1" \ ===> \ "155"

# [pcx:i:changed:nib:hierarchy://->/Users/kenji/Clock.app/Contents/Resources/English.lproj<-//->/Users/kenji/TextEdit.app/Contents/Resources/English.lproj<-//:] 
# [pcx:i:changed:nib:class://->/Users/kenji/Clock.app/Contents/Resources/English.lproj<-//->/Users/kenji/TextEdit.app/Contents/Resources/English.lproj<-//:] 

--------------------------------------------------------------------------------
	resource
--------------------------------------------------------------------------------
# [pcx:i:new:file:res:type://->/Users/kenji/us/Localized.rsrc<-//->/Users/kenji/j/Localized.rsrc<-//:] 2pth
# [pcx:i:obsolete:file:res:type://->/Users/kenji/us/Localized.rsrc<-//->/Users/kenji/j/Localized.rsrc<-//:] KbSc
# [pcx:i:identical:file:res:type://->/Users/kenji/us/Localized.rsrc<-//->/Users/kenji/j/Localized.rsrc<-//:] DBLS


# [pcx:i:changed:file:res:id:WIND://->/Users/kenji/Resources/English.lproj/Localized.rsrc<-//->/Users/kenji/Resources/Japanese.lproj/Localized.rsrc<-//:] 1205

# [pcx:i:changed:file:res:data:WIND:1402://->/Users/kenji/Resources/English.lproj/Localized.rsrc<-//->/Users/kenji/Resources/Japanese.lproj/Localized.rsrc<-//:] 
# [pcx:i:changed:file:res:size:MENU:128://->/Users/kenji/Resources/English.lproj/Localized.rsrc<-//->/Users/kenji/Resources/Japanese.lproj/Localized.rsrc<-//:] 36 \ ===> \ 39
# [pcx:i:changed:file:res:name:hfdr:-5696://->/Users/kenji/us/Localized.rsrc<-//->/Users/kenji/j/Localized.rsrc<-//:] Finder balloon help res \ ===> \ Resource name differs.
# [pcx:i:changed:file:res:attrs:hfdr:-5696://->/Users/kenji/us/Localized.rsrc<-//->/Users/kenji/j/Localized.rsrc<-//:] Purgeable \ ===> \ Purgeable Locked Preload

# [pcx:i:changed:file:res:data:string:STR :4100://->/Volumes/920-FNDR-MACS/_NewUS/Finder<-//->/Volumes/920-FNDR-MACS/_NewLoc/Finder<-//:] US_String \ ===> \ Loc_String

--------------------------------------------------------------------------------
	nibtool error message
--------------------------------------------------------------------------------
# [pcx:e:nibtool:->/Applications/Mail.app/Contents/Resources/English.lproj/ActivityViewEntry.nib<-//:] 2001-10-01 13:56:41.624 nibtool[638] Could not find image named `stopSign'.

--------------------------------------------------------------------------------
	file information in both Mac and Unix world
--------------------------------------------------------------------------------
# [pcx:i:changed:file:finfo:unix://->/Users/kenji/u/Remote Access<-//->/Users/kenji/j/Remote Access<-//:] "-rwxrwxrwx 1 kenji staff" \ ===> \ "-rwxrwxrwx 4 kenji staff"
# [pcx:i:changed:file:finfo:mdate://->/Users/kenji/u/Remote Access<-//->/Users/kenji/j/Remote Access<-//:] "2001/11/4 10:17:56" \ ===> \ "2001/11/4 10:17:54"
# [pcx:i:identical:file:finfo:ResFileAttrs://->1<-//->2<-//:] 0

--------------------------------------------------------------------------------
	diff tool output
--------------------------------------------------------------------------------
# [pcx:i:unknown:file:text://->/Users/kenji/Desktop/old<-//->/Users/kenji/Desktop/new<-//:] 17a32
# [pcx:i:unknown:file:text://->/Users/kenji/Desktop/old<-//->/Users/kenji/Desktop/new<-//:] > CD-R drive manufacturers often use several different mechanisms in the same CD-R product.


--------------------------------------------------------------------------------
	progress information
--------------------------------------------------------------------------------
# [pcx:p:start:] 2001-11-11 09:53:03 +0900 (pcx /Users/kenji/LocToolsX/pcx /Users/kenji/e /Applications/Clock.app/Contents/ -pnew -p)
# [pcx:p:end:] 2001-11-11 09:53:15 +0900 (Elapsed time: 00:00:11)


--------------------------------------------------------------------------------
	pcx arguments
--------------------------------------------------------------------------------
# [pcx:a:sh:] 1
# [pcx:a:source:] /Users/kenji
# [pcx:a:target:] /Users/kenji


--------------------------------------------------------------------------------
	action scripts
--------------------------------------------------------------------------------
# [pcx:s:changed:file:] diff '/Users/kenji/x/c' '/Users/kenji/y/c'


--------------------------------------------------------------------------------
	Shell scripts result
--------------------------------------------------------------------------------
# [pcx:m:RunShellTool:/usr/bin/diff /Users/kenji/x/.DS_Store /Users/kenji/y/.DS_Store:] Binary files /Users/kenji/x/.DS_Store and /Users/kenji/y/.DS_Store differ
# [pcx:m:RunShellTool:/usr/bin/diff /Users/kenji/x/c /Users/kenji/y/c:] 1c1
# [pcx:m:RunShellTool:/usr/bin/diff /Users/kenji/x/c /Users/kenji/y/c:] < kenji
# [pcx:m:RunShellTool:/usr/bin/diff /Users/kenji/x/c /Users/kenji/y/c:] ---
# [pcx:m:RunShellTool:/usr/bin/diff /Users/kenji/x/c /Users/kenji/y/c:] > asaka


--------------------------------------------------------------------------------
	Supplemental information for file level summary report
	This is mainly used for eps file diffing.
--------------------------------------------------------------------------------
# [pcx:m:file:summary:<<< Please review (high confidence). >>>://->/Users/kenji/Desktop/Graphic_Version_Diff/old<-//->/Users/kenji/Desktop/Graphic_Version_Diff/new<-//:] VDF.508.SCART.eps <-//-> ttt VDF.508.SCART.eps
# [pcx:m:file:summary:<<< Please review (high confidence). >>>://->/Users/kenji/Desktop/Graphic_Version_Diff/old<-//->/Users/kenji/Desktop/Graphic_Version_Diff/new<-//:] VOR.500.VoiceOverSetup.eps <-//-> ttt VOR.500.VoiceOverSetup.eps

