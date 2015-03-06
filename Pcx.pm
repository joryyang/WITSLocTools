#####################################################################################################
#    $Id: Pcx.pm,v 1.15 2008/03/10 22:56:06 asaka1 Exp $
#     Class to contain pcx output for each entity (file or directory).
#
#    Created by kenji on Fri Jan 10 2002.
#    Copyright (c) 2002 Apple Computer Inc. All rights reserved.
#####################################################################################################

package Pcx;
require Exporter;
use Carp;
use Data::Dumper;

$ignore_case = sub {return ((lc $a) cmp(lc $b))};

our $VERSION = 1.01;           # Version number
our @ISA     = qw(Exporter);
our @EXPORT  = qw(
  rb
  indent
  fixURL
  ObtainTargetLocale
);

#----------------------------------------------------------------------------
#	Accessor methods (Using Closures or Autoloadinng doesn't work somehow.)
#----------------------------------------------------------------------------
sub _source
{
    my $self = shift;
    return $self->{"_source"};
}

sub _target
{
    my $self = shift;
    return $self->{"_target"};
}

sub _strings
{
    my $self = shift;
    return $self->{"_strings"};
}

sub _res_details
{
    my $self = shift;
    return $self->{"_res_details"};
}

sub _field
{
    my $self = shift;
    return $self->{"_field"};
}

sub _nib_hierarchy
{
    my $self = shift;
    return $self->{"_nib_hierarchy"};
}

sub _nib_class
{
    my $self = shift;
    return $self->{"_nib_class"};
}

sub _nib_connection
{
    my $self = shift;
    return $self->{"_nib_connection"};
}

sub _nib_connection_details
{
    my $self = shift;
    return $self->{"_nib_connection_details"};
}

sub _nib_object
{
    my $self = shift;
    return $self->{"_nib_object"};
}

sub _nib_object_details
{
    my $self = shift;
    return $self->{"_nib_object_details"};
}

sub _diff
{
    my $self = shift;
    return $self->{"_diff"};
}

sub _filed
{
    my $self = shift;
    return $self->{"_filed"};
}

sub _opendiff
{
    my $self = shift;
    return $self->{"_opendiff"};
}

#------------------------------------------------------
#	Object constructer
#------------------------------------------------------
sub new
{
    my $invocant = shift;
    my ($pair, $outref, $kind, $filterref, $metainfoRef) = @_;
    my ($h0, $h1, $h2, $h3, $h4, $h5);
    my $class = ref($invocant) || $invocant;
    my ($self, $key, $r, $nibkind);
    my @sourceAndTarget = split(/<-\/\/->/, $pair);
    my ($category, $entity, $attrs, $label, $result, $type, $id, $item, $offset);
    my $cat       = "new|changed|obsolete|identical";
    my $r_cat     = "data|name|attrs";
    my @mustfield = ("_kind", "_source", "_target", "_filter");
    my %tempDir;
    my $sharp = "#";
    my $temp  = ();
    my @str_changed_result;

    $self->{"_kind"}                             = $kind;
    $self->{"_source"}                           = $sourceAndTarget[0];
    $self->{"_target"}                           = $sourceAndTarget[1];
    $self->{"_filter"}                           = $filterref;
    $self->{"_nibItemLevelFilteringIsDoneByPCX"} = 1;
    $self->{"_resItemLevelFilteringIsDoneByPCX"} = 1;

    if ($metainfoRef->{$pair}->{"opendiff"})
    {
        $self->{"_opendiff"} = $metainfoRef->{$pair}->{"opendiff"};
    }

    foreach $r (@{$outref})
    {
        if ($r =~ m/^$sharp \[pcx:i:($cat):(file|dir):(finfo|dinfo):([^:]*):(\/\/->(.*)<-\/\/->(.*)<-\/\/){1}?:\] (.*)$/)
        {
            #--------------------------------------------
            # file/directory information compare result
            #--------------------------------------------
            $category = $1;
            $attrs    = $4;
            $result   = $8;

            next if (($attrs eq "cdate")      && $filterref->{"finfo_cdate"});
            next if (($attrs eq "mdate")      && $filterref->{"finfo_mdate"});
            next if (($attrs eq "unix")       && $filterref->{"finfo_unix"});
            next if (($attrs eq "type")       && $filterref->{"finfo_type"});
            next if (($attrs eq "creator")    && $filterref->{"finfo_creator"});
            next if (($attrs eq "flags")      && $filterref->{"finfo_flags"});
            next if (($attrs eq "ioFlAttrib") && $filterref->{"finfo_ioFlAttrib"});
            next if (($attrs eq "script")     && $filterref->{"finfo_script"});

            ${$self->{"_finfo"}->{$category}->{$attrs}} = $result;

        }
        elsif ($r =~ m/^$sharp \[pcx:i:($cat):(file|nib):str:(\/\/->(.*)<-\/\/->(.*)<-\/\/){1}?:\] (.*)$/ && (!$filterref->{"strings"} || next))
        {
            #----------------------------------------------------------------------------
            # .strings file or strings in nib (output of nibtool -L ...) compare result
            #----------------------------------------------------------------------------
            $category = $1;
            $result   = $6;

            @str_changed_result = split(/ \\ ===> \\ /, $result);
            $key = shift @str_changed_result;
            ${$self->{"_strings"}->{$category}->{$key}} = join(" \\ ===> \\ ", @str_changed_result);

        }
        elsif ($r =~ m/^$sharp \[pcx:i:($cat):nib:(hierarchy|class):(\/\/->(.*)<-\/\/->(.*)<-\/\/){1}?:\] $/ && (!$filterref->{"nib_class_hierachy"} || next))
        {
            #----------------------------------------------------------------------------
            # nib hierarchy/class compare result
            #----------------------------------------------------------------------------
            $category = $1;
            $nibkind  = $2;

            $self->{"_nib_" . $nibkind} = $category;

        }
        elsif ($r =~ m/^$sharp \[pcx:i:($cat):nib:connect:(\/\/->(.*)<-\/\/->(.*)<-\/\/){1}?:\] (.*)$/)
        {
            #----------------------------------------------------------------------------
            # nib connection compare result summary
            #----------------------------------------------------------------------------
            $category = $1;
            $result   = $5;
            if (!$filterref->{"nib_connect_summary"})
            {
                push(@{$self->{"_nib_connection"}->{$category}}, $result);
            }

            push(@{$temp->{"_nib_connection"}->{$category}}, $result);

        }
        elsif ($r =~ m/^$sharp \[pcx:i:($cat):nib:connect:(-?\d+.*):(.+):(\/\/->(.*)<-\/\/->(.*)<-\/\/){1}?:\] (.*)$/
            && (!$filterref->{"nib_connect_details"} || next))
        {
            #----------------------------------------------------------------------------
            # nib connection compare result details
            #----------------------------------------------------------------------------
            $self->{"_nibItemLevelFilteringIsDoneByPCX"} = "";
            $category                                    = $1;
            $id                                          = $2;
            $item                                        = $3;
            $result                                      = $7;

            next if (($item eq "Marker") && $filterref->{"nib_connect_Marker"});

            ${$temp->{"_nib_connection_details"}->{$id}->{$category}->{$item}} = $result;

        }
        elsif ($r =~ m/^$sharp \[pcx:i:($cat):nib:obj:(\/\/->(.*)<-\/\/->(.*)<-\/\/){1}?:\] (.*)$/)
        {
            #----------------------------------------------------------------------------
            # nib object compare result summary
            #----------------------------------------------------------------------------
            $category = $1;
            $result   = $5;

            if (!$filterref->{"nib_obj_summary"})
            {
                push(@{$self->{"_nib_object"}->{$category}}, $result);
            }

            push(@{$temp->{"_nib_object"}->{$category}}, $result);

        }
        elsif ($r =~ m/^$sharp \[pcx:i:($cat):nib:obj:(-?\d+.*):(.+):(\/\/->(.*)<-\/\/->(.*)<-\/\/){1}?:\] (.*)$/ && (!$filterref->{"nib_obj_details"} || next))
        {
            #----------------------------------------------------------------------------
            # nib object compare result details
            #----------------------------------------------------------------------------
            $self->{"_nibItemLevelFilteringIsDoneByPCX"} = "";
            $category                                    = $1;
            $id                                          = $2;
            $item                                        = $3;
            $result                                      = $7;

            next if (($item eq "frameRect")            && $filterref->{"nib_obj_frameRect"});
            next if (($item eq "contentRect")          && $filterref->{"nib_obj_contentRect"});
            next if (($item eq "title")                && $filterref->{"nib_obj_title"});
            next if (($item eq "stringValue")          && $filterref->{"nib_obj_stringValue"});
            next if (($item eq "cellSize")             && $filterref->{"nib_obj_cellSize"});
            next if (($item eq "width")                && $filterref->{"nib_obj_width"});
            next if (($item eq "intercellSpacing")     && $filterref->{"nib_obj_intercellSpacing"});
            next if (($item eq "font")                 && $filterref->{"nib_obj_font"});
            next if (($item eq "tag")                  && $filterref->{"nib_obj_tag"});
            next if (($item eq "label")                && $filterref->{"nib_obj_label"});
            next if (($item eq "alternateTitle")       && $filterref->{"nib_obj_alternateTitle"});
            next if (($item eq "titleWidth")           && $filterref->{"nib_obj_titleWidth"});
            next if (($item eq "maxWidth")             && $filterref->{"nib_obj_maxWidth"});
            next if (($item eq "textStorageAttribute") && $filterref->{"nib_obj_textStorageAttribute"});
            next if (($item eq "textStorageContent")   && $filterref->{"nib_obj_textStorageContent"});
            next if (($item eq "Name")                 && $filterref->{"nib_obj_Name"});
            next if (($item eq "controlTitle")         && $filterref->{"nib_obj_controlTitle"});
            next if (($item eq "helpTagText")          && $filterref->{"nib_obj_helpTagText"});
            next if (($item eq "controlSize")          && $filterref->{"nib_obj_controlSize"});
            next if (($item eq "titleFont")            && $filterref->{"nib_obj_titleFont"});
            next if (($item eq "iBFont")               && $filterref->{"nib_obj_iBFont"});
            next if (($item eq "NSFont")               && $filterref->{"nib_obj_NSFont"});
            next if (($item eq "textStorage")          && $filterref->{"nib_obj_textStorage"});
            next if (($item eq "maxSize")              && $filterref->{"nib_obj_maxSize"});
            next if (($item eq "minSize")              && $filterref->{"nib_obj_minSize"});

            # Obtain nib class (Assumption here is that nibtool prints "Class" value before "frameRect" value.)
            if (($filterref->{"nib_obj_tableView_frameRect"}) || ($filterref->{"nib_obj_outlineView_frameRect"}))
            {
                while (1)
                {
                    $nibObjectClass = ${$temp->{"_nib_object_details"}->{$id}->{"identical"}->{"Class"}};
                    last if ("$nibObjectClass");
                    $nibObjectClass = ${$temp->{"_nib_object_details"}->{$id}->{"new"}->{"Class"}};
                    last if ("$nibObjectClass");
                    $nibObjectClass = ${$temp->{"_nib_object_details"}->{$id}->{"obsolete"}->{"Class"}};
                    last if ("$nibObjectClass");
                    last;
                }
                next if (($nibObjectClass =~ m/NSTableView/)   && ($item eq "frameRect"));
                next if (($nibObjectClass =~ m/NSOutlineView/) && ($item eq "frameRect"));
            }

            ${$temp->{"_nib_object_details"}->{$id}->{$category}->{$item}} = $result;

        }
        elsif ($r =~ m/^$sharp \[pcx:i:unknown:file:diff:(\/\/->(.*)<-\/\/->(.*)<-\/\/){1}?:\] (.*)$/ && (!$filterref->{"diff"} || next))
        {
            #----------------------------------------------------------------------------
            # diff output (file level)
            #----------------------------------------------------------------------------
            $result = $4;

            push(@{$self->{"_diff"}}, $result);

        }
        elsif ($r =~ m/^$sharp \[pcx:i:changed:file:([RD]F):byte:(.+):(\/\/->(.*)<-\/\/->(.*)<-\/\/){1}?:\] (.*)$/ && (!$filterref->{"hexdump"} || next))
        {
            #----------------------------------------------------------------------------
            # hex dump result
            #----------------------------------------------------------------------------
            $attrs  = $1;
            $offset = $2;
            $result = $6;

            ${$self->{"_dump"}->{$attrs}->{$offset}} = $result;

        }
        elsif ($r =~ m/^$sharp \[pcx:i:($cat):file:res:type:(\/\/->(.*)<-\/\/->(.*)<-\/\/){1}?:\] (.*)$/)
        {
            #----------------------------------------------------------------------------
            # resource type compare result
            #----------------------------------------------------------------------------

            next;    # Nothing to do. Just ignore this.

        }
        elsif ($r =~ m/^$sharp \[pcx:i:($cat):file:res:id:(.*):(\/\/->(.*)<-\/\/->(.*)<-\/\/){1}?:\] (.*)$/)
        {
            #----------------------------------------------------------------------------
            # resource compare result summary
            #----------------------------------------------------------------------------
            $category = $1;
            $type     = $2;
            $id       = $6;

            if (!$filterref->{"res_summary"})
            {
                push(@{$self->{"_res"}->{$type}->{$category}}, $id);
            }

            push(@{$temp->{"_res"}->{$type}->{$category}}, $id);

        }
        elsif ($r =~ m/^$sharp \[pcx:i:($cat):file:res:($r_cat):([^:]*):([^:]*):(\/\/->(.*)<-\/\/->(.*)<-\/\/){1}?:\] (.*)$/
            && (!$filterref->{"res_details"} || next))
        {
            #----------------------------------------------------------------------------
            # resourc detailed compare result (data|name|attrs)
            #----------------------------------------------------------------------------
            $self->{"_resItemLevelFilteringIsDoneByPCX"} = "";
            $category                                    = $1;
            $entity                                      = $2;
            $type                                        = $3;
            $id                                          = $4;
            $result                                      = $8;

            next if ((($entity eq "attrs") || ($entity eq "name")) && ($result eq ""));

            next if (($entity eq "attrs") && $filterref->{"res_category_attrs"});
            next if (($entity eq "name")  && $filterref->{"res_category_name"});
            next if (($entity eq "data")  && $filterref->{"res_category_data"});

            ${$temp->{"_res_details"}->{$type}->{$id}->{$category}->{$entity}} = $result;

        }
        elsif ($r =~ m/^$sharp \[pcx:i:($cat):file:res:(data):(.+):([^:]*):([^:]*):(\/\/->(.*)<-\/\/->(.*)<-\/\/){1}?:\] (.*)$/
            && (!$filterref->{"res_details"} || next))
        {
            #----------------------------------------------------------------------------
            # resource data item level detailed compare result
            #----------------------------------------------------------------------------
            $self->{"_resItemLevelFilteringIsDoneByPCX"} = "";
            $category                                    = $1;
            $entity                                      = $2;
            $label                                       = $3;
            $type                                        = $4;
            $id                                          = $5;
            $result                                      = $9;

            $temp->{"_seen"}->{$type}->{$id}->{$entity}->{$category}->{$label} = 1;

            next if (($label =~ m/padding/i)         && $filterref->{"res_padding"});
            next if (($label =~ m/rect$/i)           && $filterref->{"res_rect"});
            next if (($label =~ m/str$/i)            && $filterref->{"res_str"});
            next if (($label =~ m/WidthHeight$/i)    && $filterref->{"res_ppob_WidthHeight"});
            next if (($label =~ m/LeftLocation$/i)   && $filterref->{"res_ppob_LeftLocation"});
            next if (($label =~ m/TopLocation$/i)    && $filterref->{"res_ppob_TopLocation"});
            next if (($label =~ m/TextTraitsID$/i)   && $filterref->{"res_ppob_TextTraitsID"});
            next if (($label =~ m/structure$/i)      && $filterref->{"res_ppob_structure"});
            next if (($label =~ m/_ctyp$/i)          && $filterref->{"res_ppob_ctyp"});
            next if (($label =~ m/TitleWidth$/i)     && $filterref->{"res_ppob_TitleWidth"});
            next if (($label =~ m/Binding$/i)        && $filterref->{"res_ppob_Binding"});
            next if (($label =~ m/_BehaviorFlags$/i) && $filterref->{"res_ppob_BehaviorFlags"});
            next if (($label =~ m/_Visible$/i)       && $filterref->{"res_ppob_Visible"});
            next if (($label =~ m/_Title$/i)         && $filterref->{"res_ppob_Title"});

            ${$temp->{"_res_details2"}->{$type}->{$id}->{$entity}->{$category}->{$label}} = $result;

        }
        elsif ($r =~ m/^$sharp \[pcx:i:(unknown):file:res:(data):(.+):([^:]*):([^:]*):(\/\/->(.*)<-\/\/->(.*)<-\/\/){1}?:\] (.*)$/
            && (!$filterref->{"res_details"} || next))
        {
            #----------------------------------------------------------------------------
            # resource data item level detailed compare result (diff output)
            #----------------------------------------------------------------------------
            $self->{"_resItemLevelFilteringIsDoneByPCX"} = "";
            $category                                    = $1;
            $entity                                      = $2;
            $label                                       = $3;
            $type                                        = $4;
            $id                                          = $5;
            $result                                      = $9;

            push(@{$temp->{"_res_details2"}->{$type}->{$id}->{$entity}->{$category}->{$label}}, $result);

        }
        elsif (ref($r) eq "HASH")
        {
            #----------------------------------------------------------------------------
            # dara/resource fork compare result
            #----------------------------------------------------------------------------
            foreach $key (keys %{$r})
            {
                if ($key =~ m/^DF/ && (!$filterref->{"file_binary_DF"} || next))
                {
                    $self->{"_data_fork"} = $r->{$key};
                }
                elsif ($key =~ m/^RF/ && (!$filterref->{"file_binary_RF"} || next))
                {
                    $self->{"_resource_fork"} = $r->{$key};
                }
                else
                {
                    $self->{"_data_or/and_resource_fork"} = $r->{$key};
                }
            }
        }
        else
        {
            #----------------------------------------------------------------------------
            # Unknow messages
            #----------------------------------------------------------------------------
            push(@{$self->{"_unknown"}}, $r);
        }
    }

    #----------------------------------------------------------
    #	Create official nib connection/object detailed record heare
    #----------------------------------------------------------
    if (!$filterref->{"nib_connect_details"})
    {
        foreach $h1 (keys %{$temp->{"_nib_connection"}})
        {    # $h1: summary category
            foreach $h2 (@{$temp->{"_nib_connection"}->{$h1}})
            {    # $h2: id
                foreach $h3 (keys %{$temp->{"_nib_connection_details"}->{$h2}})
                {    # $h3: detailed category
                    foreach $h4 (keys %{$temp->{"_nib_connection_details"}->{$h2}->{$h3}})
                    {    # $h4: item
                        $self->{"_nib_connection_details"}->{$h1}->{$h2}->{$h3}->{$h4} = $temp->{"_nib_connection_details"}->{$h2}->{$h3}->{$h4};
                    }
                }
            }
        }
    }

    if (!$filterref->{"nib_obj_details"})
    {
        foreach $h1 (keys %{$temp->{"_nib_object"}})
        {                # $h1: summary category
            foreach $h2 (@{$temp->{"_nib_object"}->{$h1}})
            {            # $h2: id
                foreach $h3 (keys %{$temp->{"_nib_object_details"}->{$h2}})
                {        # $h3: detailed category
                    foreach $h4 (keys %{$temp->{"_nib_object_details"}->{$h2}->{$h3}})
                    {    # $h4: item
                        $self->{"_nib_object_details"}->{$h1}->{$h2}->{$h3}->{$h4} = $temp->{"_nib_object_details"}->{$h2}->{$h3}->{$h4};
                    }
                }
            }
        }
    }

    #----------------------------------------------------------
    #	Create official resource detailed record heare
    #----------------------------------------------------------
    if (!$filterref->{"res_details"})
    {
        foreach $h1 (keys %{$temp->{"_res"}})
        {    # $h1: res type
            foreach $h2 (keys %{$temp->{"_res"}->{$h1}})
            {    # $h2: summary category
                foreach $h3 (@{$temp->{"_res"}->{$h1}->{$h2}})
                {    # $h3: res id
                    foreach $h4 (keys %{$temp->{"_res_details"}->{$h1}->{$h3}})
                    {    # $h4: resource entity category
                        foreach $h5 (keys %{$temp->{"_res_details"}->{$h1}->{$h3}->{$h4}})
                        {    # $h5: resource entity (attrs, name and data content)
                            if ($h5 eq "data")
                            {
                                if (    exists $temp->{"_res_details2"}
                                    and exists $temp->{"_res_details2"}->{$h1}
                                    and exists $temp->{"_res_details2"}->{$h1}->{$h3}
                                    and exists $temp->{"_res_details2"}->{$h1}->{$h3}->{$h5})
                                {
                                    foreach $h6 (keys %{$temp->{"_res_details2"}->{$h1}->{$h3}->{$h5}})
                                    {    # $h6: item category
                                        foreach $h7 (keys %{$temp->{"_res_details2"}->{$h1}->{$h3}->{$h5}->{$h6}})
                                        {    # $h7: item label
                                            if ((ref $temp->{"_res_details2"}->{$h1}->{$h3}->{$h5}->{$h6}->{$h7}) eq "SCALAR")
                                            {
                                                $self->{"_res_details"}->{$h1}->{$h2}->{$h3}->{$h4}->{$h5} = $temp->{"_res_details2"}->{$h1}->{$h3}->{$h5};
                                            }
                                            elsif ((ref $temp->{"_res_details2"}->{$h1}->{$h3}->{$h5}->{$h6}->{$h7}) eq "ARRAY")
                                            {
                                                $self->{"_res_details"}->{$h1}->{$h2}->{$h3}->{$h4}->{$h5} =
                                                  $temp->{"_res_details2"}->{$h1}->{$h3}->{$h5}->{$h6}->{$h7};
                                            }
                                        }
                                    }
                                }
                                else
                                {
                                    unless (exists $temp->{"_seen"}
                                        and exists $temp->{"_seen"}->{$h1}
                                        and exists $temp->{"_seen"}->{$h1}->{$h3}
                                        and exists $temp->{"_seen"}->{$h1}->{$h3}->{$h5})
                                    {
                                        $self->{"_res_details"}->{$h1}->{$h2}->{$h3}->{$h4}->{$h5} = $temp->{"_res_details"}->{$h1}->{$h3}->{$h4}->{$h5};
                                    }
                                }
                            }
                            else
                            {
                                $self->{"_res_details"}->{$h1}->{$h2}->{$h3}->{$h4}->{$h5} = $temp->{"_res_details"}->{$h1}->{$h3}->{$h4}->{$h5};
                            }
                        }
                    }
                }
            }
        }
    }

    #----------------------------------------------------------
    #	return the blessed hash
    #----------------------------------------------------------
    if ((scalar keys %{$self}) > (scalar @mustfield))
    {
        return bless $self, $class;
    }
    else
    {
        return undef;
    }
}

sub source
{
    my $self = shift;
    return $self->{"_source"};
}

#*************************************************************************************
# Print input strings to string buffer
#
#
#*************************************************************************************
sub printToBuffer
{
    my ($bufferRef, @input) = @_;
    map {${$bufferRef} .= $_} @input;
}

#*************************************************************************************
# Return entity type (file, nib, dir ...)
#
#
#*************************************************************************************
sub entityType
{
    my ($self) = @_;
    return $self->{'_kind'};
}

#*************************************************************************************
# Dump class contents
#
#
#*************************************************************************************
sub dump
{
    my ($self, $purl, $editor, $popen) = @_;
    my ($h0, $h1, $h2, $h3, $h4, $h5, $category, $id);
    my ($source, $target, $key, @str_changed_result);
    my ($header1, $header2, $header3, $header1_done, $header2_done, $header3_done, $count);
    my ($targetLocale);
    my $entityHeaderString = "";
    my $compResultString   = "";

    foreach $h1 (sort fieldOrder keys %{$self})
    {
        if ($h1 eq "_source")
        {
            if ($self->{$h1})
            {
                printToBuffer \$entityHeaderString, "#", "*" x 100, "\n", "#", &indent(1), '"', $self->{$h1}, '"', "\n";
            }
            else
            {
                printToBuffer \$entityHeaderString, "#", "*" x 100, "\n", "#", &indent(1), "\n";
            }
        }
        elsif ($h1 eq "_target")
        {
            if ($self->{$h1})
            {
                printToBuffer \$entityHeaderString, "#", &indent(1), '"', $self->{$h1}, '"', "\n", "#", "*" x 100, "\n";
            }
            else
            {
                printToBuffer \$entityHeaderString, "#", &indent(1), "\n", "#", "*" x 100, "\n";
            }

            # Print file URL
            if ($popen)
            {
                $targetLocale = &ObtainTargetLocale($self->{_source}, $self->{_target});
                &printFileURL($self, $targetLocale, \$entityHeaderString, $editor);
            }
        }
        elsif ($h1 eq "_finfo")
        {
            # file information compare result
            printToBuffer \$compResultString, &header($h1), "\n";
            foreach $h2 (sort keys %{$self->{$h1}})
            {
                printToBuffer \$compResultString, &indent(1), "*** ", $h2, " ***", "\n";
                foreach $h3 (sort keys %{$self->{$h1}->{$h2}})
                {
                    printToBuffer \$compResultString, &indent(2), $h3, ":", &rb(${$self->{$h1}->{$h2}->{$h3}}), "\n";
                }
            }
        }
        elsif ($h1 eq "_strings")
        {
            # .strings file or strings in nib (output of nibtool -L ...) compare result
            printToBuffer \$compResultString, &header($h1), "\n";
            foreach $h2 (sort keys %{$self->{$h1}})
            {
                printToBuffer \$compResultString, &indent(1), "*** ", $h2, " ***", "\n";
                if ($h2 eq "changed")
                {
                    my $strcount = scalar(keys %{$self->{$h1}->{$h2}});
                    my $i        = 1;
                    foreach $h3 (sort $ignore_case keys %{$self->{$h1}->{$h2}})
                    {
                        @str_changed_result = split(/ \\ ===> \\ /, ${$self->{$h1}->{$h2}->{$h3}});
                        ($source, $target) = @str_changed_result;
                        printToBuffer \$compResultString, &indent(2), $h3,     "\n";
                        printToBuffer \$compResultString, &indent(2), $source, "\n";
                        printToBuffer \$compResultString, &indent(2), $target, "\n";

                        if ($i++ < $strcount)
                        {
                            printToBuffer \$compResultString, &indent(2), &separator("", "-", 40, "\n");
                        }
                    }
                }
                else
                {
                    foreach $h3 (sort $ignore_case keys %{$self->{$h1}->{$h2}})
                    {
                        printToBuffer \$compResultString, &indent(2), $h3, " = ", ${$self->{$h1}->{$h2}->{$h3}}, "\n";
                    }
                }
            }
        }
        elsif (($h1 eq "_kind") || ($h1 eq "_filter"))
        {
            # Do nothing
        }
        elsif ($h1 eq "_nib_connection")
        {
            if (($self->{"_filter"}->{"nib_connect_details"}) || ($self->{"_nibItemLevelFilteringIsDoneByPCX"}))
            {
                printToBuffer \$compResultString, &header($h1), "\n";
                foreach $h2 (sort keys %{$self->{$h1}})
                {
                    printToBuffer \$compResultString, &indent(1), "*** ", $h2, " ***", "\n";
                    if (scalar @{$self->{$h1}->{$h2}} > 0)
                    {
                        printToBuffer \$compResultString, &indent(2);
                    }
                    foreach $h3 (sort {$a <=> $b} @{$self->{$h1}->{$h2}})
                    {
                        printToBuffer \$compResultString, $h3, " ";
                    }
                    printToBuffer \$compResultString, "\n";
                }
            }
            else
            {
                if (exists $self->{"_nib_connection_details"})
                {
                    printToBuffer \$compResultString, &header($h1), "\n";
                    foreach $h2 (sort keys %{$self->{$h1}})
                    {
                        $header1 = &indent(1) . "*** " . $h2 . " ***" . "\n";

                        $header1_done = 0;
                        $header2_done = 0;
                        $count        = 0;
                        foreach $h3 (sort {$a <=> $b} @{$self->{$h1}->{$h2}})
                        {
                            if (    (exists $self->{"_nib_connection_details"})
                                and (exists $self->{"_nib_connection_details"}->{$h2})
                                and (defined $self->{"_nib_connection_details"}->{$h2}->{$h3}))
                            {

                                if (!$header1_done)
                                {
                                    printToBuffer \$compResultString, $header1;
                                    $header1_done = 1;
                                }

                                if (!$header2_done)
                                {
                                    printToBuffer \$compResultString, &indent(2);
                                    $header2_done = 1;
                                }

                                printToBuffer \$compResultString, $h3, " ";
                                $count++;
                            }
                        }
                        if ($count > 0)
                        {
                            printToBuffer \$compResultString, "\n";
                        }
                    }
                }
            }
        }
        elsif ($h1 eq "_nib_object")
        {
            if (($self->{"_filter"}->{"nib_obj_details"}) || ($self->{"_nibItemLevelFilteringIsDoneByPCX"}))
            {
                printToBuffer \$compResultString, &header($h1), "\n";
                foreach $h2 (sort keys %{$self->{$h1}})
                {
                    printToBuffer \$compResultString, &indent(1), "*** ", $h2, " ***", "\n";
                    if (scalar @{$self->{$h1}->{$h2}} > 0)
                    {
                        printToBuffer \$compResultString, &indent(2);
                    }
                    foreach $h3 (sort {$a <=> $b} @{$self->{$h1}->{$h2}})
                    {
                        printToBuffer \$compResultString, $h3, " ";
                    }
                    printToBuffer \$compResultString, "\n";
                }
            }
            else
            {
                if (exists $self->{"_nib_object_details"})
                {
                    printToBuffer \$compResultString, &header($h1), "\n";
                    foreach $h2 (sort keys %{$self->{$h1}})
                    {
                        $header1 = &indent(1) . "*** " . $h2 . " ***" . "\n";

                        $header1_done = 0;
                        $header2_done = 0;
                        $count        = 0;
                        foreach $h3 (sort {$a <=> $b} @{$self->{$h1}->{$h2}})
                        {
                            if (    (exists $self->{"_nib_object_details"})
                                and (exists $self->{"_nib_object_details"}->{$h2})
                                and (defined $self->{"_nib_object_details"}->{$h2}->{$h3}))
                            {

                                if (!$header1_done)
                                {
                                    printToBuffer \$compResultString, $header1;
                                    $header1_done = 1;
                                }

                                if (!$header2_done)
                                {
                                    printToBuffer \$compResultString, &indent(2);
                                    $header2_done = 1;
                                }

                                printToBuffer \$compResultString, $h3, " ";
                                $count++;
                            }
                        }
                        if ($count > 0)
                        {
                            printToBuffer \$compResultString, "\n";
                        }
                    }
                }
            }
        }
        elsif (($h1 eq "_nib_connection_details") || ($h1 eq "_nib_object_details"))
        {
            printToBuffer \$compResultString, &header($h1), "\n";
            if ($purl)
            {
                $targetLocale = &ObtainTargetLocale($self->{_source}, $self->{_target});
            }

            foreach $h2 (sort keys %{$self->{"$h1"}})
            {
                printToBuffer \$compResultString, &indent(1), "*** ", $h2, " ***", "\n";
                foreach $h3 (sort {$a <=> $b} keys %{$self->{"$h1"}->{$h2}})
                {

                    printToBuffer \$compResultString, &indent(2), "--- ", $h3, " ---", "\n";
                    if ($purl)
                    {
                        &printNibURL($self, $h1, 2, $h3, $targetLocale, $h2, \$compResultString, $editor);
                    }

                    foreach $h4 (sort keys %{$self->{$h1}->{$h2}->{$h3}})
                    {
                        printToBuffer \$compResultString, &indent(3), "*** ", $h4, " ***", "\n";
                        foreach $h5 (sort keys %{$self->{$h1}->{$h2}->{$h3}->{$h4}})
                        {
                            if ($h4 eq "changed")
                            {
                                printToBuffer \$compResultString, &indent(4), "--- ", $h5, " ---", "\n";
                                ($source, $target) = split(/ \\ ===> \\ /, ${$self->{$h1}->{$h2}->{$h3}->{$h4}->{$h5}});
                                printToBuffer \$compResultString, &indent(5), $source, "\n";
                                printToBuffer \$compResultString, &indent(5), $target, "\n";
                            }
                            else
                            {
                                printToBuffer \$compResultString, &indent(4), $h5, ":";
                                printToBuffer \$compResultString, ${$self->{$h1}->{$h2}->{$h3}->{$h4}->{$h5}}, "\n";
                            }
                        }
                    }
                }
            }
        }
        elsif ($h1 eq "_diff")
        {
            printToBuffer \$compResultString, &header($h1), "\n";
            # Never sort as the output order is significant in diff output.
            foreach $h2 (@{$self->{$h1}})
            {
                printToBuffer \$compResultString, &indent(1), $h2, "\n";
            }

        }
        elsif ($h1 eq "_dump")
        {
            # hex dump
            printToBuffer \$compResultString, &header($h1), "\n";
            foreach $h2 (sort keys %{$self->{$h1}})
            {
                printToBuffer \$compResultString, &indent(1), "--- ", $h2, " ---", "\n";
                foreach $h3 (sort keys %{$self->{$h1}->{$h2}})
                {
                    printToBuffer \$compResultString, &indent(2), $h3, "\n";
                    ($source, $target) = split(/ \\ ===> \\ /, ${$self->{$h1}->{$h2}->{$h3}});
                    printToBuffer \$compResultString, &indent(3), $source, "\n";
                    printToBuffer \$compResultString, &indent(3), $target, "\n";
                }
            }
        }
        elsif ($h1 eq "_res")
        {
            if (($self->{"_filter"}->{"res_details"}) || ($self->{"_resItemLevelFilteringIsDoneByPCX"}))
            {
                printToBuffer \$compResultString, &header($h1), "\n";
                foreach $h2 (sort $ignore_case keys %{$self->{$h1}})
                {
                    printToBuffer \$compResultString, &indent(1), "--- ", $h2, " ---", "\n";
                    foreach $h3 (sort keys %{$self->{$h1}->{$h2}})
                    {
                        printToBuffer \$compResultString, &indent(2), "*** ", $h3, " ***", "\n";
                        if (scalar @{$self->{$h1}->{$h2}->{$h3}} > 0)
                        {
                            printToBuffer \$compResultString, &indent(3);
                        }
                        foreach $h4 (sort {$a <=> $b} @{$self->{$h1}->{$h2}->{$h3}})
                        {
                            printToBuffer \$compResultString, $h4, " ";
                        }
                        printToBuffer \$compResultString, "\n";
                    }
                }
            }
            else
            {
                if (exists $self->{"_res_details"})
                {
                    printToBuffer \$compResultString, &header($h1), "\n";
                    foreach $h2 (sort $ignore_case keys %{$self->{$h1}})
                    {
                        $header1_done = 0;
                        $header1      = &indent(1) . "--- " . $h2 . " ---" . "\n";
                        $count        = 0;
                        foreach $h3 (sort keys %{$self->{$h1}->{$h2}})
                        {
                            $header2      = &indent(2) . "*** " . $h3 . " ***" . "\n";
                            $header2_done = 0;
                            $header3_done = 0;
                            foreach $h4 (sort {$a <=> $b} @{$self->{$h1}->{$h2}->{$h3}})
                            {

                                if (    (exists $self->{"_res_details"})
                                    and (exists $self->{"_res_details"}->{$h2})
                                    and (exists $self->{"_res_details"}->{$h2}->{$h3})
                                    and (defined $self->{"_res_details"}->{$h2}->{$h3}->{$h4}))
                                {
                                    if (!$header1_done)
                                    {
                                        printToBuffer \$compResultString, $header1;
                                        $header1_done = 1;
                                    }

                                    if (!$header2_done)
                                    {
                                        printToBuffer \$compResultString, $header2;
                                        $header2_done = 1;
                                    }

                                    if (!$header3_done)
                                    {
                                        printToBuffer \$compResultString, &indent(3);
                                        $header3_done = 1;
                                    }

                                    printToBuffer \$compResultString, $h4, " ";
                                    $count++;
                                }
                            }
                            if ($count > 0)
                            {
                                printToBuffer \$compResultString, "\n";
                            }
                        }
                    }
                }
            }
        }
        elsif ($h1 eq "_res_details")
        {
            printToBuffer \$compResultString, &header($h1), "\n";
            # $h2: res type
            # $h3: summary category
            # $h4: res id
            # $h5: resource entity category
            # $h6: resource entity (attrs, name and data content)
            foreach $h2 (sort $ignore_case keys %{$self->{$h1}})
            {
                printToBuffer \$compResultString, &indent(1), "--- ", $h2, " ---", "\n";
                foreach $h3 (sort keys %{$self->{$h1}->{$h2}})
                {
                    printToBuffer \$compResultString, &indent(2), "*** ", $h3, " ***", "\n";
                    foreach $h4 (sort {$a <=> $b} keys %{$self->{$h1}->{$h2}->{$h3}})
                    {
                        printToBuffer \$compResultString, &indent(3), "--- ", "'", $h2, "'", "(", $h4, ")", " ---", "\n";
                        foreach $h5 (sort keys %{$self->{$h1}->{$h2}->{$h3}->{$h4}})
                        {
                            printToBuffer \$compResultString, &indent(4), "*** ", $h5, " ***", "\n";
                            foreach $h6 (sort keys %{$self->{$h1}->{$h2}->{$h3}->{$h4}->{$h5}})
                            {
                                printToBuffer \$compResultString, &indent(5), "--- ", $h6, " ---", "\n";
                                $h7 = $self->{$h1}->{$h2}->{$h3}->{$h4}->{$h5}->{$h6};
                                if ((ref $h7) eq "SCALAR")
                                {
                                    if ($h5 eq "changed")
                                    {
                                        if (${$h7} =~ m/ \\ ===> \\ /)
                                        {
                                            ($source, $target) = split(/ \\ ===> \\ /, ${$h7});
                                            printToBuffer \$compResultString, &indent(6), $source, " ===> ";
                                            printToBuffer \$compResultString, $target;
                                            if ($h6 eq "data")
                                            {
                                                printToBuffer \$compResultString, " bytes";
                                            }
                                            printToBuffer \$compResultString, "\n";
                                        }
                                        else
                                        {
                                            printToBuffer \$compResultString, &indent(6), ${$h7}, "\n";
                                        }
                                    }
                                    else
                                    {
                                        printToBuffer \$compResultString, &indent(6), ${$h7}, "\n";
                                    }
                                }
                                elsif ((ref $h7) eq "HASH")
                                {
                                    foreach $h8 (sort keys %{$h7})
                                    {
                                        printToBuffer \$compResultString, &indent(7), "*** ", $h8, " ***", "\n";
                                        foreach $h9 (sort keys %{$h7->{$h8}})
                                        {
                                            if ($h8 eq "changed")
                                            {
                                                printToBuffer \$compResultString, &indent(8), "--- ", $h9, " ---", "\n";
                                                ($source, $target) = split(/ \\ ===> \\ /, ${$h7->{$h8}->{$h9}});
                                                printToBuffer \$compResultString, &indent(9), $source, "\n";
                                                printToBuffer \$compResultString, &indent(9), $target, "\n";
                                            }
                                            else
                                            {
                                                printToBuffer \$compResultString, &indent(8), $h9, ":", ${$h7->{$h8}->{$h9}}, "\n";
                                            }
                                        }
                                    }
                                }
                                elsif ((ref $h7) eq "ARRAY")
                                {
                                    foreach $h8 (@{$h7})
                                    {
                                        printToBuffer \$compResultString, &indent(7), $h8, "\n";
                                    }
                                }
                            }
                        }
                    }
                }
            }

        }
        elsif ($h1 eq "_nibItemLevelFilteringIsDoneByPCX")
        {
            # Don't print this value because of internal use only.
        }
        elsif ($h1 eq "_resItemLevelFilteringIsDoneByPCX")
        {
            # Don't print this value because of internal use only.
        }
        elsif ($h1 eq "_opendiff")
        {
            # Don't print this value because of internal use only.
        }
        elsif ($h1 eq "_unknown")
        {
            printToBuffer \$compResultString, &header($h1), "\n";
            foreach $h2 (sort $ignore_case @{$self->{$h1}})
            {
                printToBuffer \$compResultString, $h2;
            }
        }
        else
        {
            printToBuffer \$compResultString, &header($h1), ":", $self->{$h1}, "\n";
        }
    }

    if ($compResultString =~ m/\S/s)
    {
        # Non white space characte exists.
        print $entityHeaderString;
        print $compResultString;
        return 1;
    }
    else
    {
        return "";
    }
}

sub fieldOrder
{
    my %fieldOrder = (
        "_kind"                   => 100,
        "_source"                 => 200,
        "_target"                 => 300,
        "_data_fork"              => 400,
        "_resource_fork"          => 500,
        "_finfo"                  => 600,
        "_res"                    => 620,
        "_res_details"            => 640,
        "_strings"                => 700,
        "_resource"               => 800,
        "_nib_class"              => 900,
        "_nib_hierarchy"          => 1000,
        "_nib_connection"         => 1050,
        "_nib_connection_details" => 1060,
        "_nib_object"             => 1070,
        "_nib_object_details"     => 1080,
        "_diff"                   => 1100,
        "_dump"                   => 1200,
        "_unknown"                => 2000,
    );

    return $fieldOrder{$a} <=> $fieldOrder{$b};
}

# Fix a URL
sub fixURL
{
    my $url = shift;

    # Replace a space with "%20".
    $url =~ s/ /\%20/g;

    return $url;
}

# Remove back slash fromm the separator generated by pcx.
sub rb
{
    my $out = shift;
    $out =~ s/ \\ ===> \\ / ===> /;
    return $out;
}

sub c2equal
{
    my $out = shift;
    $out =~ s/ \\ ===> \\ / = /;
    return $out;
}

sub indent
{
    my $level = shift;
    return "  " x $level;
}

sub separator
{
    my ($first, $char, $number, $last) = @_;
    return $first . $char x $number . $last;
}

sub header
{
    my ($title) = shift;
    return "_" . uc $title . "__";
}

#*************************************************************************************************************************
#	Print a file URL
#
#
#*************************************************************************************************************************
sub printFileURL
{
    my ($self, $targetLocale, $bufferRef, $editor) = @_;

    my ($oldLoc, $newLoc);
    my ($fixedURL);
    my ($quoteForURL_open, $quoteForURL_close, $openCommand, $needToFixURL);
    if ($editor eq "adviewer")
    {
        $quoteForURL_open  = "<";
        $quoteForURL_close = ">";
        $openCommand       = "";
        $needToFixURL      = "";
    }
    else
    {
        $openCommand       = "open ";
        $quoteForURL_open  = "\"";
        $quoteForURL_close = "\"";
        $needToFixURL      = 1;
    }

    # Determine the category
    my $compResult;
    if (($self->{"_source"}) && !($self->{"_target"}))
    {
        $compResult = "obsolete";
    }
    elsif (!($self->{"_source"}) && ($self->{"_target"}))
    {
        $compResult = "new";
    }
    else
    {
        $compResult = "identical";
    }

    #
    if ($compResult ne "new")
    {
        if   ($needToFixURL) {$fixedURL = &fixURL($self->{_source});}
        else                 {$fixedURL = $self->{_source}}
        printToBuffer $bufferRef, "", "", $openCommand, $quoteForURL_open, "file://localhost", $fixedURL, $quoteForURL_close, "\n";
    }

    if ($compResult ne "obsolete")
    {
        if   ($needToFixURL) {$fixedURL = &fixURL($self->{_target});}
        else                 {$fixedURL = $self->{_target}}
        printToBuffer $bufferRef, "", "", $openCommand, $quoteForURL_open, "file://localhost", $fixedURL, $quoteForURL_close, "\n";
    }

    # if a user compares _oldBase with _newBase, print urls for _oldLoc and _newLoc
    if ($targetLocale)
    {

        ($oldLoc = $self->{_source}) =~ s/\/_OldBase\//\/_OldLoc\//g;
        $oldLoc =~ s/\/(English|en|en_US)\.lproj\//\/$targetLocale\//g;

        ($newLoc = $self->{_target}) =~ s/\/_NewBase\//\/_NewLoc\//g;
        $newLoc =~ s/\/(English|en|en_US)\.lproj\//\/$targetLocale\//g;

        if ($compResult ne "new")
        {
            if   ($needToFixURL) {$fixedURL = &fixURL($oldLoc);}
            else                 {$fixedURL = $oldLoc}
            printToBuffer $bufferRef, "", "", $openCommand, $quoteForURL_open, "file://localhost", $fixedURL, $quoteForURL_close, "\n";
        }

        if ($compResult ne "obsolete")
        {
            if   ($needToFixURL) {$fixedURL = &fixURL($newLoc);}
            else                 {$fixedURL = $newLoc}
            printToBuffer $bufferRef, "", "", $openCommand, $quoteForURL_open, "file://localhost", $fixedURL, $quoteForURL_close, "\n";
        }
    }

}

#*************************************************************************************************************************
#	Print a nib URL
#
#
#*************************************************************************************************************************
sub printNibURL
{
    my ($self, $entityKind, $indentLevel, $id, $targetLocale, $compResult, $bufferRef, $editor) = @_;
    my ($oldLoc, $newLoc);
    my ($fixedURL);
    my ($quoteForURL_open, $quoteForURL_close, $openCommand, $needToFixURL);
    if ($editor eq "adviewer")
    {
        $quoteForURL_open  = "<";
        $quoteForURL_close = ">";
        $openCommand       = "";
        $needToFixURL      = "";
    }
    else
    {
        $openCommand       = "open ";
        $quoteForURL_open  = "\"";
        $quoteForURL_close = "\"";
        $needToFixURL      = 1;
    }

    # id is either (object id number) or (object id number, class name and description connected by "-").
    # What we need just a object id number.
    $id =~ m/^(\d+)/;
    $id = $1;

    if ($compResult ne "new")
    {
        if   ($needToFixURL) {$fixedURL = &fixURL($self->{_source});}
        else                 {$fixedURL = $self->{_source}}
        printToBuffer $bufferRef, &indent($indentLevel), " ", $openCommand, $quoteForURL_open, "nib:/", $fixedURL, "?", $id, $quoteForURL_close, "\n";
    }

    if ($compResult ne "obsolete")
    {
        if   ($needToFixURL) {$fixedURL = &fixURL($self->{_target});}
        else                 {$fixedURL = $self->{_target}}
        printToBuffer $bufferRef, &indent($indentLevel), " ", $openCommand, $quoteForURL_open, "nib:/", $fixedURL, "?", $id, $quoteForURL_close, "\n";
    }

    # if a user compares _oldBase with _newBase, print urls for _oldLoc and _newLoc
    if ($targetLocale)
    {

        ($oldLoc = $self->{_source}) =~ s/\/_OldBase\//\/_OldLoc\//g;
        $oldLoc =~ s/\/(English|en|en_US)\.lproj\//\/$targetLocale\//g;

        ($newLoc = $self->{_target}) =~ s/\/_NewBase\//\/_NewLoc\//g;
        $newLoc =~ s/\/(English|en|en_US)\.lproj\//\/$targetLocale\//g;

        if ($compResult ne "new")
        {
            if   ($needToFixURL) {$fixedURL = &fixURL($oldLoc);}
            else                 {$fixedURL = $oldLoc}
            printToBuffer $bufferRef, &indent($indentLevel), " ", $openCommand, $quoteForURL_open, "nib:/", $fixedURL, "?", $id, $quoteForURL_close, "\n";
        }

        if ($compResult ne "obsolete")
        {
            if   ($needToFixURL) {$fixedURL = &fixURL($newLoc);}
            else                 {$fixedURL = $newLoc}
            printToBuffer $bufferRef, &indent($indentLevel), " ", $openCommand, $quoteForURL_open, "nib:/", $fixedURL, "?", $id, $quoteForURL_close, "\n";
        }
    }

}

#*************************************************************************************
#	This logic is identical to the one in CompareNibObj.m
#       (pathToInfoNnibFileInLocalizedNibInNewLoc).
#		If you change the logic, you should change both this function and CompareNibObj.m.
#*************************************************************************************
sub ObtainTargetLocale
{
    my ($source, $target) = @_;
    my ($resources);
    my $lproj = "";

    if (($source =~ m/_OldBase/) && ($target =~ m/_NewBase/))
    {
        # Get target locale from newLoc
        ($resources = $target) =~ s/\/_NewBase\//\/_NewLoc\//g;
        $resources =~ m/^(.+?)\/(English|en|en_US)\.lproj\//;
        $resources = $1;
        unless (-d $resources)
        {
            return;
        }

        opendir(RESOURCES, $resources);
        my @lprojs = readdir RESOURCES;
        closedir RESOURCES;
        foreach (sort @lprojs)
        {
            # print $_, "\n";
            next if (-f $_);
            next if (m/(English|en|en_US)\.lproj/);
            if (m/^.+\.lproj$/)
            {
                $lproj = $_;
                last;
            }
        }

    }

    return $lproj;
}

#*************************************************************************************
# Create *.(nib|xib).iblockingrules files for changed nibs/xibs
#   rdar://problem/5394188> Need to integrate flidentifier output with new localization loc mode
#
#*************************************************************************************
sub createIblockingrulesFile
{
    my ($self) = @_;

    # Get path to the nib in _NewBase and _OldBase
    my $oldBaseNibPath = $self->{'_source'};
    my $newBaseNibPath = $self->{'_target'};
    return unless ($newBaseNibPath);

    my @changedOrNewIDs = ();
    foreach my $nibObject ('_nib_object')
    {
        next unless (exists $self->{$nibObject});
        foreach my $newOrChanged ('new', 'changed')
        {
            next unless (exists $self->{$nibObject}->{$newOrChanged});
            foreach my $id (@{$self->{$nibObject}->{$newOrChanged}})
            {
                # Id consists of object-id '-' class-name '-' label.
                # E.g., 14-NSTextField-Address
                if ($id =~ m{^(-?\d+)}x)
                {
                    my $object_id = $1;
                    push(@changedOrNewIDs, $object_id);
                }
            }
        }
    }

    # Return if there is no new/changed id.
    return if ((scalar @changedOrNewIDs) == 0);

    # Create .iblockingrules plist
    # The plist should be a sibling to the nib/xib file
    #   with the ".iblockingrules" extension attached.
    my %iblockingrules = ();

    $iblockingrules{'IBDefaultPropertyAccessControl'} = 'IBPropertyAccessControlLockAll';
    grep $iblockingrules{'IBObjectPropertyAccessControls'}->{$_} = 'IBPropertyAccessControlLockNone', @changedOrNewIDs;
    my $iblockingrulesDict = Foundation::objectRefFromPerlRef(\%iblockingrules);

    # Figure out the path
    my $newLocNibPath = $newBaseNibPath;
    my $targetLocale = &ObtainTargetLocale($oldBaseNibPath, $newBaseNibPath);
    unless ($targetLocale)
    {
        print STDERR "### Pcx.pm Error: failed to figure out target locale from $newBaseNibPath.\n";
        return;
    }
    $newLocNibPath =~ s{/_NewBase/}{/_NewLoc/}gx;
    $newLocNibPath =~ s{/(English|en|en_US)\.lproj/}{/$targetLocale/}gx;
    my $iblockingrulesFilePath = $newLocNibPath . '.iblockingrules';

    my $result = $iblockingrulesDict->writeToFile_atomically_($iblockingrulesFilePath, 1);
    unless ($result)
    {
        print STDERR "### Pcx.pm Error: failed to write $newLocNibPath.\n";
    }
}

1;

