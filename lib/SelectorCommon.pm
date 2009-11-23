package OSCAR::SelectorCommon;

# $Id$
#
# Copyright (c) 2006-2009 Oak Ridge National Laboratory.
#                         All rights reserved.
#
# This file is a very simple selector that will select
# or unselect packages to be installed in OSCAR.  You can also
# print out the packages or a subset of packages to see which
# are currently selected.

BEGIN {
    if (defined $ENV{OSCAR_HOME}) {
        unshift @INC, "$ENV{OSCAR_HOME}/lib";
    }
}

use strict;
use vars qw(@EXPORT);
use base qw(Exporter);

use OSCAR::ODA_Defs;
use OSCAR::Opkg;
use OSCAR::PackagePath;
use OSCAR::RepositoryManager;
use OSCAR::Utils;

use Term::Complete;
use Carp;

use Data::Dumper;

@EXPORT = qw(
            printPackages
            processInput
            );


# Print the packages that match the specified class (core, included, third
# party, all) with their <status> <short package name> <class> <version>
sub printPackages ($$) {
    my ($class, $package_set) = @_;

    my %known_classes = ('all' => 1,
                         'core' => 2,
                         'included' => 3,
                         'third party' => 4 );

    if (!defined $class || $class eq "") {
        $class = "all";
    }

    if (!defined %known_classes->{$class}) {
        carp "ERROR: Unknown class $class\n".
             "Available class: core, included, third party, all\n";
        return -1;
    }

    # we currently assume we deal only with the local distro
    my $distro = OSCAR::PackagePath::get_distro();
    my $compat_distro = OSCAR::PackagePath::get_compat_distro ($distro);

    # We get the list of core packages, useful information to deal with 
    # selection
    my @core_opkgs = OSCAR::Opkg::get_list_core_opkgs();

    # Get a list of all the packages in the package set
    my @available_opkgs
        = OSCAR::PackageSet::get_list_opkgs_in_package_set($package_set,
                                                           $compat_distro); 
    my %selection_data
        = OSCAR::Database::get_opkgs_selection_data (@available_opkgs);

    # If we do not have yet selection data for some OPKGs, we assign the default
    # selection (selected for core OPKGs, unselected for others).
    foreach my $opkg (@available_opkgs) {
        if (!defined ($selection_data{$opkg})) {
            if (OSCAR::Utils::is_element_in_array ($opkg, @core_opkgs)) {
                $selection_data{$opkg} = OSCAR::ODA_Defs::SELECTED();
            } else {
                $selection_data{$opkg} = OSCAR::ODA_Defs::UNSELECTED();
            }
        }
    }

    $| = 1;

    my ($printStatus, $printPackage, $printClass, $printVersion);

    #Format to print out the package information
format STDOUT=
@|||||||||||@|||||||||||||||||@|||||||||||@||||||||||||||
$printStatus,  $printPackage,  $printClass, $printVersion
.

    OSCAR::Logger::oscar_log_subsection("List of packages");
        print "   Status           Name          Class        Version\n---------------------------------------------------------\n";
        foreach my $opkg (@available_opkgs) {
                my $rm = OSCAR::RepositoryManager->new (distro=>$distro);
                my ($rc, %output) = $rm->show_opkg ("opkg-$opkg");
                #Need to set up these variables to be printed out
                $printStatus = $selection_data{$opkg};
                # Now we translate in something the user can actually understand
                if ($printStatus == OSCAR::ODA_Defs::UNSELECTED()) {
                    $printStatus = "unselected";
                } elsif ($printStatus == OSCAR::ODA_Defs::SELECTED()) {
                    $printStatus = "selected";
                }
                $printPackage = $opkg;
                $printVersion = $output{"opkg-$opkg"}{version};
                $printVersion = "" if !defined $printVersion;
                $printClass   = $output{"opkg-$opkg"}{group};
                $printClass   = "" if !defined $printClass;

                #Print out the information
                write;
        }

        if (OSCAR::Database::set_opkgs_selection_data (%selection_data)) {
            carp "ERROR: Impossible to update selection data in ODA";
            return -1;
        }

        return;
}

# Return: 0 if success, -1 else.
sub select_opkg ($@) {
    my ($package_set, @response) = @_;

    if (!OSCAR::Utils::is_a_valid_string ($package_set)) {
        carp "ERROR: Invalid package set";
        return -1;
    }

    my $packagename = shift(@response);

    if(!$packagename) {
        print "Format: select [-q] package_name\n";
        return -1;
    }

    #If the user adds a -q flag, don't print out the verbose dialog
    my $quiet = 0;
    if($packagename eq "-q") {
        $quiet = 1;
        #Move the next arguement over to make parsing the command line easy
        $packagename = shift(@response);

        if(!$packagename) {
            print "Format: select [-q] package_name\n";
            return -1;
        }
    }

    # We get the list of OPKGs from the package set
    my $distro = OSCAR::PackagePath::get_distro ();
    my $compat_distro = OSCAR::PackagePath::get_compat_distro ($distro);
    my @opkgs = OSCAR::PackageSet::get_list_opkgs_in_package_set
        ($package_set, $compat_distro);

    # We make sure the OPKG exists
    if (!OSCAR::Utils::is_element_in_array ($packagename, @opkgs)) {
        print "Package $packagename not available\n" 
            unless $quiet;
        return -1;
    }

    print "Selecting $packagename from $package_set...\n";
    # We get the current selection data
    my %selection_data = OSCAR::Database::get_opkgs_selection_data (@opkgs);
    $selection_data{$packagename} = OSCAR::ODA_Defs::SELECTED();
    if (OSCAR::Database::set_opkgs_selection_data (%selection_data)) {
        carp "ERROR: Impossible to update selection data in ODA";
        return -1;
    }

    return 0;
}

sub unselect_opkg ($@) {
    my ($package_set, @response) = @_;

    # The user is trying unselect a package
    my $packagename = shift(@response);

    if(!$packagename) {
        print "Format: select [-q] package_name\n";
        return 1;
    }

    #If the user adds a -q flag, don't print out the verbose dialog
    my $quiet = 0;
    if($packagename eq "-q") {
        $quiet = 1;
        #Move the next arguement over to make parsing the command line easy
        $packagename = shift(@response);

        if(!$packagename) {
            print "Format: select [-q] package_name\n";
            return 1;
        }
    }

    # We get the list of OPKGs from the package set
    my $distro = OSCAR::PackagePath::get_distro ();
    my $compat_distro = OSCAR::PackagePath::get_compat_distro ($distro);
    my @opkgs = OSCAR::PackageSet::get_list_opkgs_in_package_set
        ($package_set, $compat_distro);

    # We make sure the OPKG exists
    if (!OSCAR::Utils::is_element_in_array ($packagename, @opkgs)) {
        print "Package $packagename not available\n" 
            unless $quiet;
        return -1;
    }

    # We also make sure the user does not want to unselect a core package
    my @core_opkgs = OSCAR::Opkg::get_list_core_opkgs();
    if (OSCAR::Utils::is_element_in_array ($packagename, @core_opkgs)) {
        print "Impossible to unselect a core OSCAR package\n";
        return -1;
    }

    print "Unselecting $packagename from $package_set...\n";
    my %selection_data = OSCAR::Database::get_opkgs_selection_data (@opkgs);
    $selection_data{$packagename} = OSCAR::ODA_Defs::UNSELECTED();
    if (OSCAR::Database::set_opkgs_selection_data (%selection_data)) {
        carp "ERROR: Impossible to update selection data in ODA";
        return -1;
    }

    return 0;
}


#Process the user's response from the prompt
sub processInput
{
    my $current_package_set = shift;
    #Change the response from a scalar to an array
    my @response = split(' ', shift);

    my $command = shift(@response);
    my $requested;

    #Get a list of all the packages
    my $allPackages = (); # TODO: FIXME

    #By default, ask for help
    if(!defined $command)
    {
        $command = "help";
    }

    #If the user is trying to select a package
    if($command eq "select") {
        select_opkg ($$current_package_set, @response);
    } elsif($command eq "unselect") {
        unselect_opkg ($$current_package_set, @response);
    } elsif($command eq "list") {
        # The user is trying to list the packages again
        my $class = shift(@response);

        # The default action if the selected class does not exist is to print
        # all of the packages
        if(!defined $class)
        {
            printPackages("all", $$current_package_set);
        }
        else
        {
            printPackages($class, $$current_package_set);
        }
    } elsif($command eq "quit" || $command eq "exit") {
        # The user is trying to quit the program
        # Everything should already have been taken care of so go ahead and move
        # on
        return 0;
    }
    #If the user wants to read in responses from a file
    elsif($command eq "file")
    {
        my $filename = shift(@response);

        if(!$filename) {
            print "Format: file file_name\n";
            return 1;
        }

        if (! -f $filename) {
            print "File $filename not found!\n";
            return 1;
        }

        open(FILE, $filename);
        #Read the file just like it is normal input from the keyboard
        #The file is not required to have a quit command in it
        while(<FILE>)
        {
            chomp $_;

            #Comment
            if(/^#/) {next;}

            #Empty line
            elsif(!$_) {next;}

            processInput($_);
        }
        exit 0;
    } elsif ( $command eq "\\q" ) {
        print "Force quit\n";
        exit 1;
    } elsif ( $command eq "set" ) {
        $$current_package_set = shift(@response);
        printPackages("all", $$current_package_set);
    } elsif ( $command eq "list_sets" ) {
        my @sets = OSCAR::PackageSet::get_package_sets ();
        print "Available package sets:\n";
        OSCAR::Utils::print_array (@sets);
    } else {
        # Default response is to print out the list of commands and their use
        print <<EOF
 list_sets: Display the list of available package sets
 set <package set>: Change the selected package set
 select <packageName> - Select a package to be installed
 \t-q - Quiet mode:  Don't print out verbose dialog
 unselect <packageName> - Unselect a package to prevent it from being installed
 \t-q - Quiet mode:  Don't print out verbose dialog
 list <class> - Lists the packages and their installation status, class, and version number
 file <filename> - Reads in commands from a file
 help - Prints this message
 quit/exit - Quits the selector and continues with the next step
 \\q - Force quit (as in ctrl-c)
EOF
    }

    return 1;
}
