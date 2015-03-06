#!/usr/bin/perl
#************************************************************************************
#	This script is to mask build number and country code in a tarball.
#
#************************************************************************************
# Only the argument is a full path to target directory which contains tarball(s).
$target = $ARGV[0];
unless (-d $target) {
	print STDERR "$target doesn't exist.\n";
	exit 1;
}

unless ($target =~ m/^\//) {
	print STDERR "$target is not a full path.\n";
	exit 1;
}


# Rename top level directory
# MailViewer_Tiger.8A417.01_LL_1.tgz.1
# MailViewer_Tiger.8A417.01_J_1.tgz.1
chdir $target;
opendir (DIR, $target);
foreach $dir (readdir (DIR)) {
	next if ($dir =~ m/^\./);
	next unless (-d $dir);

	@newName = ();
	if ($dir =~ m/^([A-Za-z0-9]+)_([A-Za-z0-9]+)\.([0-9A-Z]+)\.(\d+)_([A-Z]+)_(\d+)\.tgz\.(\d+)$/) {		
		push (@newName, $1 . '_' . $2); # MailViewer_Tiger
		push (@newName, $1 . '_' . $2 . '_'. $5); # MailViewer_Tiger_J
		push (@newName, $1 . '_' . $2 . '_'. $5 . '_' . $3 . '_' . $4 . '_' . $6); # MailViewer_Tiger_J_8A417_01.1
	
	} else {
		print "### Error: Could not parse $dir\n";
		next;
	}

	$renameDoneFlag = undef;
	foreach $newname (@newName) {
		if (rename($dir, $newname)) {
			&rename2ndLevelDir($target, $newname);
			$renameDoneFlag = 1;
			last;
		}
	}

	unless ($renameDoneFlag) {
		print STDERR "Failed to rename $dir\n";
	}	
}
closedir DIR;


exit 0;


# Rename 2nd level directory
# BR_MailViewer_Tiger.8A417.01_LL
# MailViewer_Tiger.8A417.01_J.tar.1
sub rename2ndLevelDir {
	my ($parentDir, $dirName) = @_;
	my $target = $parentDir . '/' . $dirName;
	my $newname;

	chdir $target;
	opendir (DIR2, $target);
	foreach my $dir (readdir (DIR2)) {
		next if ($dir =~ m/^\./);
		next unless (-d $dir);
	
		if ($dir =~ m/^(.+?)\./) {		
			$newname = $1;
			if (rename($dir, $newname)) {
				if ($newname =~ m/^BR_/) {
					&rename3rdLevelDir($target, $newname);
				}
			
			} else {
				print STDERR "Failed to rename $dir to $newname\n";
			}
		}
	}
	closedir DIR2;

	# Need to restore the current directory.
	chdir $parentDir;

}

# Rename 3rd level directory
# MailViewer_Tiger.8A417.01_LL.tar.1
# MailViewer_Tiger.8A417.01_J.tar.1
sub rename3rdLevelDir {
	my ($parentDir, $dirName) = @_;
	my $target = $parentDir . '/' . $dirName;
	my $newname;

	chdir $target;
	opendir (DIR3, $target);
	foreach my $dir (readdir (DIR3)) {
		next if ($dir =~ m/^\./);
		next unless (-d $dir);
	
		if ($dir =~ m/^(.+?)\./) {		
			$newname = $1;
			if (rename($dir, $newname)) {
				#
				&fixDirectoryStructure($target, $newname);
			} else {
				print STDERR "Failed to rename $dir to $newname\n";
			}
		}
	}
	closedir DIR3;

	# Need to restore the current directory.
	chdir $parentDir;

}


# If 3rd level directory contains a directory whose name is xxxx_Tierx_proj,
#	Strip out the directory and it's sub directories.
sub fixDirectoryStructure {
	my ($parentDir, $dirName) = @_;
		
	my $target = $parentDir . '/' . $dirName;
	my $rootDir = $target;
	chdir $target;
	opendir (DIR4, $target);
	my $brokenTar = undef;
	foreach my $dir (readdir (DIR4)) {
		next if ($dir =~ m/^\./);
		next unless (-d $dir);
		
		if ($dir =~ m/_Tier\d+_proj$/) { # e.g., Admin_Tier1_proj
			$brokenTar = $dir;
			last;
		}
	}
	closedir DIR4;

	if (defined $brokenTar) {
		my $target = $parentDir . '/' . $dirName . '/' . $brokenTar;
		my $deleteMeLater = $target;
		chdir $target;
		opendir (DIR5, $target);
		foreach my $dir (readdir (DIR5)) {
			next if ($dir =~ m/^\./);
			next unless (-d $dir);
			
			if ($dir =~ m/_Tier\d+/) {	# e.g., Admin_Tier1-8A162
				&copyWithDitto($rootDir, $target . '/' . $dir);
				last;
			}
		}
		closedir DIR5;
		
		# remove 
		my @command = ('rm', '-rf', $deleteMeLater);
		system @command;
	}

	# Need to restore the current directory.
	chdir $parentDir;

}


sub copyWithDitto {
	my ($tgtDir, $srcDir) = @_;
	# print STDOUT "$tgtDir, \t, $srcDir\n";
	
	my @command = ('ditto', '--rsrc', $srcDir, $tgtDir);
	system @command;
}

