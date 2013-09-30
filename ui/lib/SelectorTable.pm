#########################################################################
#  File  : SelectorTable.pm                                             #
#  Authors: Terrence G. Fleury (tfleury@ncsa.uiuc.edu)                  #
#  This perl package is a subclass of a Qt QTable.  I had to subclass   #
#  QTable (rather than add a basic QTable in Designer) since I needed   #
#  control over the checkboxes and the sorting method.                  #
#  Authors: DongInn Kim (dikim@cs.indiana.edu)                          #
#  The new SelectorTable package is written with Qt TreeView which has  #
#  a lot better interface and look and easy to manage ordering the      #
#  columns in the PackageTable.                                         #
#########################################################################
#  This program is free software; you can redistribute it and/or modify
#  it under the terms of the GNU General Public License as published by
#  the Free Software Foundation; either version 2 of the License, or
#  (at your option) any later version.
#
#  This program is distributed in the hope that it will be useful,
#  but WITHOUT ANY WARRANTY; without even the implied warranty of
#  MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
#  GNU General Public License for more details.
#
#  You should have received a copy of the GNU General Public License
#  along with this program; if not, write to the Free Software
#  Foundation, Inc., 59 Temple Place, Suite 330, Boston, MA  02111-1307 USA
#
#  Copyright (c) 2003      The Board of Trustees of the University of Illinois.
#                          All rights reserved.
#  Copyright (c) 2005,2013 The Trustees of Indiana University.  
#                          All rights reserved.
#  Copyright (c) 2007-2009 Geoffroy Vallee <valleegr@ornl.gov>
#                          Oak Ridge National Laboratory
#                          All rights reserved.
#
# $Id$
#########################################################################


# The SelectorTable package provides the list of packages of the        #
# selected PackageSets and detail information of each package on the    #
# separated tabs (Description, Packagers, Conflicts, Summary).          #
#########################################################################
use strict;
use warnings;
use utf8;

package Qt::SelectorTable;
#use Qt;
use QtCore4;
use QtGui4;
use QtCore4::isa qw( Qt::Widget );
use QtCore4::slots
    populateTable => ['QString'],
    cellValueChanged => [ 'int', 'int' ];
use QtCore4::signals deactivate_package_set_combo => [];

use OSCAR::Database;
use OSCAR::Package;
use OSCAR::OpkgDB;
use OSCAR::PackageSet;
use OSCAR::OCA::OS_Detect;
use OSCAR::Utils;
use OSCAR::ODA_Defs;
use Carp;

my %options = ();
my @errors = ();
my $tablePopulated = 0;     # So we call populateTable only once
my $currSet;                # The name of the currently selected Package Set
my $packagesInstalled;      # Hash of packages with 'installed' bit set to 1
my $foundPackagesInstalled; # Has the above hash been calculated once?
my %scope = ();

my $table;
my $model;
my $filterColumnComboBox;
my %opkg_hashdata = ();

use vars qw ($last_ps);

#########################################################################
# create a treeview class to setup a sortfilterproxymodel               #
#########################################################################
sub NEW {
    shift->SUPER::NEW();
    my $proxyModel = Qt::SortFilterProxyModel();
    this->{proxyModel} = $proxyModel;
    $proxyModel->setDynamicSortFilter(1);
    $table = Qt::TreeView();
    this->{proxyView} = $table;
    $table->setRootIsDecorated(0);
    $table->setAlternatingRowColors(1);
    $table->setModel($proxyModel);
    $table->setSortingEnabled(1);
}

#########################################################################
# Subroutine: getModel                                                  #
# Parameters: super class                                               #
# Returns   : StandardItemModel                                         #
# Add a StandardItemModel to setup the PackageTable header              #
#########################################################################
sub getModel ($){
    my ($parent) = @_;
    $model = Qt::StandardItemModel(0, 4, $parent);
    #$model->setHeaderData(0, Qt::Horizontal(), Qt::Variant(Qt::Object::tr('Short Name')));
    $model->setHeaderData(0, Qt::Horizontal(), Qt::Variant(Qt::String('')));
    $model->setHeaderData(1, Qt::Horizontal(), Qt::Variant(Qt::String('Package Name')));
    $model->setHeaderData(2, Qt::Horizontal(), Qt::Variant(Qt::String('Class')));
    $model->setHeaderData(3, Qt::Horizontal(), Qt::Variant(Qt::String('Version')));
    this->{model} = $model;
    return $model;
}

#########################################################################
# Subroutine: setSourceModel                                            #
# Parameters: StandardItemModel                                         #
# Returns   : SortFilterProxyModel                                      #
# Add a StandardItemModel on top of the SortFilterProxyModel.           #
#########################################################################
sub setSourceModel {
    my ( $lmodel ) = @_;
    my $proxyModel = this->{proxyModel};
    my $proxyView = this->{proxyView};
    $proxyModel->setSourceModel($lmodel);
    $proxyView->setModel($lmodel);
    return $proxyView;
}

#########################################################################
# Subroutine: getPackageTable                                           #
# Parameters: None                                                      #
# Returns   : PackageTable (TreeView)                                   #
# Provide the prepared PackageTable for Selector                        #
#########################################################################
sub getPackageTable (){

    $table = Qt::TreeView();
    $table->setAlternatingRowColors(1);
    $model = this->{model};
    $table->setModel($model);
    return $table;
}

#########################################################################
# Subroutine: getLayout                                                 #
# Parameters: PackageTable                                              #
# Returns   : HBoxLayout                                                #
# Attach the PackageTable widget to HBoxLayout which is used for        #
# Selector Window.                                                      #
#########################################################################
sub getLayout ($){
    my $packageTable = shift;
    my $proxyLayout = Qt::HBoxLayout();
    $proxyLayout->addWidget($packageTable);
    return $proxyLayout;
}

# We do not have a clean way to clean the widget that displays OPKGs data so we
# simply deactivate the package set combo list when the user select a package
# set. For that, we emit a signal and treat the signal here. We use a signal
# because this object is the only one to have a pointer to the combo, the class
# dealing with the table object is in SelectorTable.pm.
sub do_deactivate_package_set_combo {
    packageSetComboBox->clear();
}

#########################################################################
# Subroutine: removeTable                                               #
# Parameters: None                                                      #
# Returns   : None                                                      #
# Clean up the PackageTable with the old contents and make the table    #
# ready for the new contents.                                           #
#########################################################################
sub removeTable{
    $model->removeRows(0,$model->rowCount());
}

#########################################################################
# Subroutine: addPackage                                                #
# Parameters: model, check, packageName, class, version                 #
# Returns   : None                                                      #
# Add a package to StanardItemModel with the given arguments.           #
#########################################################################
sub addPackage{
    my ( $model, $check, $pName, $class, $version) = @_;
    $model->insertRow(0);
    my $item0 = Qt::StandardItem();
    $item0->setCheckable(1);
    my $check_state = ($check?Qt::Checked():Qt::Unchecked());
    $item0->setCheckState($check_state);
    $model->setItem(0, 0, $item0);
    #$model->setData($model->index(0, 0), Qt::Variant($check));
    $model->setData($model->index(0, 1), Qt::Variant(Qt::String($pName)));
    $model->setData($model->index(0, 2), Qt::Variant(Qt::String($class)));
    $model->setData($model->index(0, 3), Qt::Variant(Qt::String($version)));
}

#########################################################################
#  Subroutine: populateTable                                            #
#  Parameter : Name of the selected package set                         #
#  Returns   : -1 if error, 0 else.                                     #
#  This subroutine should be called when you want to populate the       #
#  table, either from scratch, or a "refresh".  If this function has    #
#  never been called before, then it adds all of the packages and their #
#  corresponding info to the table.  Otherwise, it simply updates the   #
#  "checked" status for each package based on the currently selected    #
#  package set.   This slot is connected to the Package Set ComboBox    #
#  "activated" signal so that when a new package set is chosen, the     #
#  checkbox info is updated appropriately.                              #
#########################################################################
sub populateTable {
    my $passedText = shift;

    $last_ps = "";
    $currSet = ($passedText?$passedText:"Default");# The package set selected in the ComboBox
    my $success;         # Return result for database commands

    print STDERR "Current set: $currSet\n" if defined $passedText;
    print STDERR "Last set: $passedText\n" if defined $passedText;

    # If the selection is empty (it happens when Selector runs for the first
    # time), we just exit (thus the window appears quickly, especially if remote
    # repositories are used).
    if ($currSet eq "") {
        return;
    }

    # Check if we really need to update the table.
    if ($last_ps ne $passedText) {
        $last_ps = $currSet;

        # We get the list of OPKGs in the package set
        require OSCAR::PackagePath;
        my $distro = OSCAR::PackagePath::get_distro ();
        my $compat_distro = OSCAR::PackagePath::get_compat_distro ($distro);
        my @available_opkgs
            = OSCAR::PackageSet::get_list_opkgs_in_package_set ($currSet,
                                                                $compat_distro);

        # We get the current selection
        my %selection_data 
            = OSCAR::Database::get_opkgs_selection_data (@available_opkgs);

        my $rownum = 0;

        my ($location, $version);
        require OSCAR::RepositoryManager;
        my $rm = OSCAR::RepositoryManager->new (distro=>$distro);
        my @core_opkgs = OSCAR::Opkg::get_list_core_opkgs ();

        foreach my $opkg (@available_opkgs) {
            my ($rc, %opkg_data) = $rm->show_opkg ("opkg-$opkg");


            # Column 0 contains "short" names of packages
            #my $item = SelectorTableItem(this,Qt::TableItem::Never(), $opkg);
            #setItem($rownum, 0, $item);

            # Column 1 contains checkboxes
            my $checkbox = 0;
            if ($selection_data{$opkg} == OSCAR::ODA_Defs::SELECTED()) {
                $checkbox = 1;
            }

            # Column 2 contains the long names of packages
            print "$currSet: $opkg\n"; # if $options{debug};
            

            # Column 3 contains the "class" of packages
            my $opkg_class;
            if (OSCAR::Utils::is_element_in_array ($opkg, @core_opkgs) == 1) {
                $opkg_class = "Core";
                # Core OPKGs are always selected!
                $checkbox = 1;
            } else {
                $opkg_class = "Included";
            }

            # Column 4 contains the Location + Version
            #$location = $opkg_data{"opkg-$opkg"}{repository};
            $version = $opkg_data{"opkg-$opkg"}{version};
            addPackage($model, $checkbox, $opkg, $opkg_class, $version);

            $rownum++;
            $opkg_hashdata{$opkg} = \%opkg_data;
        }
        this->{numRows} = $rownum;
    }
    $table->sortByColumn(1, Qt::AscendingOrder());
    $table->resizeColumnToContents(0);
    $table->resizeColumnToContents(1);
    $table->resizeColumnToContents(2);

    return 0;
}

sub getNumRows(){
    return this->{numRows};
}

#########################################################################
# Subroutine: getPackageDetail                                          #
# Parameters: None                                                      #
# Returns   : None                                                      #
# Create a TabWidget and several tabs and then add the tabs to tabWidget#
# When the tabWidget is fully generated, the widget is added to the     #
# HBoyLayout so that it can show up on the Selector main window.        #
#########################################################################
sub getPackageDetail {
    my $tabWidget = Qt::TabWidget();
    this->{tabWidget} = $tabWidget;

    my $informationTab = Qt::TextEdit();
    $informationTab->setReadOnly(1);
    this->{informationTab} = $informationTab;
    my $packagerTab = Qt::TextEdit();
    $packagerTab->setReadOnly(1);
    this->{packagerTab} = $packagerTab;
    my $conflictsTab = Qt::TextEdit();
    $conflictsTab->setReadOnly(1);
    this->{conflictsTab} = $conflictsTab;
    my $summaryTab = Qt::TextEdit();
    $summaryTab->setReadOnly(1);
    this->{summaryTab} = $summaryTab;
    $tabWidget->addTab($informationTab, this->tr('Description'));
    $tabWidget->addTab($packagerTab, this->tr('Packager'));
    $tabWidget->addTab($conflictsTab, this->tr('Conflicts'));
    $tabWidget->addTab($summaryTab, this->tr('Summary'));

    my $mainLayout = Qt::HBoxLayout();
    $mainLayout->addWidget($tabWidget);
    return $mainLayout;
}

#########################################################################
# Subroutine: pushPkgDetailInfo                                         #
# Parameters: pkgName                                                   #
# Returns   : None                                                      #
# Fill up the tabs with the package information which is retrieved from #
# the opkg_hashdata. The Package detail information is paired with the  #
# its package name in the opkg_hashdata.                                #
# opkg_hashdata (key: pkgName, value: pkg detail information)           #
#########################################################################
sub pushPkgDetailInfo {
    my $pkgName = shift;

    my %opkg_hash = ();

    my $informationTab = this->{informationTab};
    my $packagerTab = this->{packagerTab};
    my $conflictsTab = this->{conflictsTab};
    my $summaryTab = this->{summaryTab};
   
    OSCAR::Utils::print_hash("","Opkg_hashdata", \%opkg_hashdata) if $options{debug};
    if (%opkg_hashdata and ((defined $pkgName) and ($pkgName ne ""))){
        my $pkg_hashref = $opkg_hashdata{$pkgName};
        %opkg_hash = %$pkg_hashref;
        OSCAR::Utils::print_hash("","Opkg_hash", \%opkg_hash) if $options{debug};
        setValue($informationTab, $opkg_hash{"opkg-$pkgName"}{'description'});
        setValue($packagerTab, $opkg_hash{"opkg-$pkgName"}{'packager'});
        setValue($conflictsTab, $opkg_hash{"opkg-$pkgName"}{'conflicts'});
        setValue($summaryTab, $opkg_hash{"opkg-$pkgName"}{'summary'});
    }else{
        setValue($informationTab, "");
        setValue($packagerTab, "");
        setValue($conflictsTab, "");
        setValue($summaryTab, "");
    }
}

#########################################################################
# Subroutine: setValue                                                  #
# Parameters: passedTab, value                                          #
# Returns   : None                                                      #
# The package detail information is saved to the passed tab (e.g.,      #
# Description, Packager, Conflicts, and Summary)                        #
# its package name in the opkg_hashdata.                                #
# opkg_hashdata (key: pkgName, value: pkg detail information)           #
#########################################################################
sub setValue {
    my ($passedTab, $value) = @_;
    print "passed value: $value\n" if $options{debug};
    $passedTab->clear();
    $passedTab->setText($value);
}

1;

