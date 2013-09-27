# Form implementation generated from reading ui file 'SelectorManageSets.ui'
#
# Created: Wed Oct 29 21:10:57 2003
#      by: The PerlQt User Interface Compiler (puic)
#
# Converted perlQt3 to perlQt4
# Date: Sun Sep 22 21:10:58 2013
#   by: DongInn Kim (dikim@cs.indiana.edu)
#
# Copyright (c) 2005, 2013 The Trustees of Indiana University.  
#                          All rights reserved.
#
# $Id$
#########################################################################
# Note that we do not use puic anymore to modify this file. This capability has
# been lost, therefore we directly modify this file.
#


use strict;
use utf8;


package Qt::SelectorManageSets;
use QtCore4;
use QtCore4::isa qw(Qt::Dialog);
use Data::Dumper;
use QtCore4::slots
    refreshPackageSetsListBox => [],
    createNewPackageSet => [],
    duplicateButton_clicked => [],
    renameButton_clicked => [],
    deleteButton_clicked => [],
    newCoreButton_clicked => [],
    newAllButton_clicked => [],
    doneButton_clicked => [],
    showEvent => [],
    packageSetsListBox_doubleClicked => ['QListBoxItem*'];
#use QtCore4::attributes qw(
#    $packageSetsListBox
#    duplicateButton
#    renameButton
#    deleteButton
#    newCoreButton
#    newAllButton
#    doneButton
#);

my $packageSetsListBox;
my $duplicateButton;
my $renameButton;
my $deleteButton;
my $newCoreButton;
my $newAllButton;
my $doneButton;

use lib "$ENV{OSCAR_HOME}/lib"; 
use OSCAR::Database;
use OSCAR::PackageSet;
use QtCore4::signals refreshPackageSets => [];
use Qt::SelectorUtils;

my %options = ();
my @errors = ();
sub uic_load_pixmap_SelectorManageSets
{
    my $pix = Qt::Pixmap();
    my $m = Qt::MimeSourceFactory::defaultFactory()->data(shift);

    if($m)
    {
        Qt::ImageDrag::decode($m, $pix);
    }

    return $pix;
}


sub NEW
{
    shift->SUPER::NEW(@_);

    resize(315,227);
    my $title = "Manage OSCAR Package Sets";
    this->setWindowTitle($title);
    my $SelectorManageSetsLayout = Qt::GridLayout();
    my $Layout116 = Qt::HBoxLayout();

    $packageSetsListBox = Qt::ListWidget();
    $packageSetsListBox->addItem(trUtf8("New Item"));
    $packageSetsListBox->setToolTip(trUtf8("List of all package sets"));
    $Layout116->addWidget($packageSetsListBox);

    my $Layout115 = Qt::VBoxLayout();

    $duplicateButton = Qt::PushButton();
    $duplicateButton->setText(trUtf8("D&uplicate"));
    $duplicateButton->setToolTip(trUtf8("Copy the selected package set to a new package set"));
    $Layout115->addWidget($duplicateButton);

    $renameButton = Qt::PushButton();
    $renameButton->setText(trUtf8("&Rename"));
    $renameButton->setToolTip(trUtf8("Rename the selected package set to a new name"));
    $Layout115->addWidget($renameButton);

    $deleteButton = Qt::PushButton();
    $deleteButton->setText(trUtf8("&Delete"));
    $deleteButton->setToolTip(trUtf8("Delete the selected package set"));
    $Layout115->addWidget($deleteButton);

    $newCoreButton = Qt::PushButton();
    $newCoreButton->setText(trUtf8("New &Core"));
    $newCoreButton->setToolTip(trUtf8("Create a new package set with just \"core\" packages"));
    $Layout115->addWidget($newCoreButton);

    $newAllButton = Qt::PushButton();
    $newAllButton->setText(trUtf8("New &All"));
    $newAllButton->setToolTip(trUtf8("Create a new package set with all packages"));
    $Layout115->addWidget($newAllButton);
    my $spacer = Qt::SpacerItem(0, 20, &Qt::SizePolicy::Minimum, &Qt::SizePolicy::Expanding);
    $Layout115->addItem($spacer);

    $doneButton = Qt::PushButton();
    $doneButton->setText(trUtf8("D&one"));
    $doneButton->setToolTip(trUtf8("Close this window"));
    $Layout115->addWidget($doneButton);
    $Layout116->addLayout($Layout115);

    $SelectorManageSetsLayout->addLayout($Layout116, 0, 0);

    Qt::Object::connect($duplicateButton, SIGNAL "clicked()", this, SLOT "duplicateButton_clicked()");
    Qt::Object::connect($renameButton, SIGNAL "clicked()", this, SLOT "renameButton_clicked()");
    Qt::Object::connect($deleteButton, SIGNAL "clicked()", this, SLOT "deleteButton_clicked()");
    Qt::Object::connect($doneButton, SIGNAL "clicked()", this, SLOT "doneButton_clicked()");
    # We have not found a solution to get the signal of "doubleClicked()" in ComboBox.
    #Qt::Object::connect($packageSetsListBox, SIGNAL "doubleClicked()", this, SLOT "packageSetsListBox_doubleClicked(QListBoxItem*)");
    Qt::Object::connect($newCoreButton, SIGNAL "clicked()", this, SLOT "newCoreButton_clicked()");
    Qt::Object::connect($newAllButton, SIGNAL "clicked()", this, SLOT "newAllButton_clicked()");

    this->setLayout($SelectorManageSetsLayout);
}


sub refreshPackageSetsListBox
{

#########################################################################
#  Subroutine: refreshPackageSetsListBox                                #
#  Parameters: None                                                     #
#  Returns   : Nothing                                                  #
#  This subroutine should be called anytime you need to refresh the     #
#  contents of the $packageSetsListBox.  For example, when you rename    #
#  a package set, delete a package set, or duplicate a package set, the #
#  list needs to be updated.  This subroutine also emits a signal to    #
#  let the main window know that the package set list has changed to    #
#  update its packageSetComboBox.                                       #
#########################################################################

    Qt::SelectorUtils::populatePackageSetList($packageSetsListBox);
    emit refreshPackageSets();
}

sub createNewPackageSet
{

#########################################################################
#  Subroutine: createNewPackageSet                                      #
#  Parameter : Name of the new package set                              #
#  Returns   : The (possibly modified) name of the new package set      #
#  This subroutine is called by "duplicate", "new core", and            #
#  "new all" to create a (unique) new package set.  The "suggested"     #
#  name is passed in.  We say "suggested" because we first check to     #
#  see if that name already exists in the list of package sets.  If so, #
#  we append "_copy" as many times as necessary to get a unique name.   #
#  Then we add this new package set name to the oda database.  Note     #
#  that we don't actually refresh the contents of the listbox.  You     #
#  MUST do that later on.                                               #
#########################################################################

  my $newSetName = shift;

  my $nameclash;
  do # Check for a unique name
    {
      $nameclash = 0;
      for (my $count = 0; $count < $packageSetsListBox->count(); $count++)
        {
          if (lc($packageSetsListBox->takeItem($count)->text()) eq lc($newSetName))
            { # Found the name in the list.  Append another "copy".
              $nameclash = 1;
              $newSetName .= "_copy";
            }
        }
    } while ($nameclash);
  
  # Add the new name to the database and to the ListBox
  my $success = OSCAR::Database::set_groups($newSetName, \%options, \@errors,undef);  
  Carp::carp("Could not do oda command 'set_groups $newSetName'") if 
    (!$success);

  return $newSetName;

}

sub duplicateButton_clicked
{

#########################################################################
#  Subroutine: duplicateButton_clicked                                  #
#  Parameters: None                                                     #
#  Returns   : Nothing                                                  #
#  This is called when the "Duplicate" button is clicked.  It finds     #
#  the item currently selected in the ListBox and creates a new package #
#  set named that same name with "_copy" appended.                      #
#########################################################################

  # Check to see if we actually have something selected in the listbox
  if ($packageSetsListBox->currentRow() >= 0)
    {
      #my $item = Qt::ListWidgetItem($packageSetsListBox);
      #my $lastSet = $item->toElement()->currentText();
      my $lastSet = $packageSetsListBox->currentItem()->text();
      my $newSet = $lastSet."_copy";
      my $currSet = createNewPackageSet($newSet);

      # Copy all of the packages listed in the old package set
      # over to the newly created package set.
      my @packagesInSet;
      my @results = ();
      my $success = OSCAR::Database::get_group_packages_with_groupname(
            $lastSet,\@results,\%options,\@errors);
      Carp::carp("Could not do oda command 'get_group_packages_with_groupname ".
        $lastSet . "'") if (!$success);
      print Dumper(@results) if $ENV{OSCAR_VERBOSE} ;
      @packagesInSet = map { $_->{package} } @results;
      foreach my $pack (@packagesInSet)
        {
          $success = OSCAR::Database::set_group_packages(
                $newSet, $pack, 2, \%options, \@errors);
          Carp::carp("Could not do oda command 'set_group_packages " .
            "$pack $newSet'") if (!$success);
        }

      # Finally, refresh the listbox with the new entry
      refreshPackageSetsListBox();
    }

}


#########################################################################
#  Subroutine: renameButton_clicked                                     #
#  Parameters: None                                                     #
#  Returns   : Nothing                                                  #
#  This is called when the "Rename" button is clicked.  It finds the    #
#  item currently selected in the ListBox and prompts the user for a    #
#  new name.  It then renames that item in the ListBox and in the oda   #
#  database.                                                            #
#########################################################################
sub renameButton_clicked
{
  # Check to see if we actually have something selected in the listbox
  if ($packageSetsListBox->currentRow() >= 0)
    {
      my $response;
      my $foundit;
      my $count;
      my $success;
      my $error = 0;
      my $ok = 0;
      my $currentStr = $packageSetsListBox->currentItem->text();
      my $outputstr = "Enter a new name for '$currentStr':";
      do # Keep prompting the user for a new name until success
        {
          $ok = 0;  # Was the OK button pressed, or the Cancel button?
          $error = 0;
          $response = Qt::InputDialog::getText(this, this->tr("Rename Package Set"),
                        $outputstr, Qt::LineEdit::Normal(), $currentStr, $ok);
          require OSCAR::Utils;
          $response = OSCAR::Utils::compactSpaces($response, 1, 0);
          $response =~ s/ /_/g; # Change spaces to underscores
          print "BABO OK: $ok\n";

          if (($ok) && (length($response) > 0))
            {
              # Check to see if the new string already exists
              $foundit = 0;
              for ($count=0; 
                   ($count < $packageSetsListBox->count()) && (!$foundit); 
                   $count++)
                {
                  $foundit = 1 if 
                    (lc($packageSetsListBox->takeItem($count)->text()) eq lc($response));
                }

              if ($foundit)
                {
                  $error = 1;
                  $outputstr = "Package Set '$response' already exists. \n" .
                               "Enter a new name for '" . 
                               $packageSetsListBox->currentText() . "':";
                }
              else
                {
                  my $selected = $currentStr;
                  print "BABO selected:response = ($selected : $response)\n"; 
                  $success = OSCAR::Database::rename_group($selected,
                            $response,
                            \%options,
                            \@errors);
                  $success = OSCAR::PackageSet::rename_package_set($selected, $response);
                  if ($success)
                    {
                      refreshPackageSetsListBox();
                    }
                  else
                    {
                      Carp::carp("Could not rename the package set" . 
                        "'rename_package_set $selected $response'");
                    }
                }
            }
          elsif ($ok) # BUT, the input string turned out to be empty
            { 
              $error = 1;
              $outputstr = "Please try again. \nEnter a new name for '".
                           $packageSetsListBox->currentText(). "':";
            }
        } while ($error);
    }

}


#########################################################################
#  Subroutine: deleteButton_clicked                                     #
#  Parameters: None                                                     #
#  Returns   : Nothing                                                  #
#  This is called when the "Delete" button is clicked.  It finds the    #
#  package set currently selected in the ListBox and removes it from    #
#  both the ListBox and the oda database.                               #
#########################################################################
sub deleteButton_clicked
{

  # Make sure that we have at least 2 items in the list 
  # and that at least one of them is selected.
  if (($packageSetsListBox->currentItem() >= 0) &&
      ($packageSetsListBox->count() > 1))
    { 
      my $selected = $packageSetsListBox->currentText();
      my $success = OSCAR::Database::delete_groups(
            $selected,\%options,\@errors);
      if ($success)
        {
          refreshPackageSetsListBox();
        }
      else 
        {
          Carp::carp("Could not do oda command 'delete_package_set $selected'");
        }
    }

}

#########################################################################
#  Subroutine: newCoreButton_clicked                                    #
#  Parameters: None                                                     #
#  Returns   : Nothing                                                  #
#  This is called when the "New Core" button is clicked.  It creates    #
#  a new package set named "Core" (with _copy appended as needed)       #
#  and adds only core packages to that set.                             #
#########################################################################
sub newCoreButton_clicked
{
  my $currSet = createNewPackageSet("new_Core");
  # Add all "core" packages to this set
  my $allPackages = SelectorUtils::getAllPackages();
  foreach my $pack (keys %{ $allPackages })
    {
      my $class = $allPackages->{$pack}{class};
      if ($class eq "core" || $class eq "Core")
        {
          my $success = OSCAR::Database::set_group_packages(
                $currSet, $pack, 2, \%options, \@errors);
          Carp::carp("Could not do oda command 'set_group_packages " .
            "$pack $currSet'") if (!$success);
        }
    }

  refreshPackageSetsListBox();

}

sub newAllButton_clicked
{

#########################################################################
#  Subroutine: newAllButton_clicked                                     #
#  Parameters: None                                                     #
#  Returns   : Nothing                                                  #
#  This is called when the "New All" button is clicked.  It creates     #
#  a new package set named "All" (with _copy appended as needed)        #
#  and adds ALL packages to that set.                                   #
#########################################################################

  my $currSet = createNewPackageSet("new_All");
  # Add all packages to this set
  my $allPackages = SelectorUtils::getAllPackages();
  foreach my $pack (keys %{ $allPackages })
    {
      my $success = OSCAR::Database::set_group_packages(
                $currSet,$pack,2,\%options,\@errors);
      Carp::carp("Could not do oda command 'set_group_packages " .
        "$pack $currSet'") if (!$success);
    }

  refreshPackageSetsListBox();

}

sub doneButton_clicked
{

#########################################################################
#  Subroutine: doneButton_clicked                                       #
#  Parameters: None                                                     #
#  Returns   : Nothing                                                  #
#  This is called when the "Done" button is clicked.  It 'hides'        #
#  the Manage Package Sets window so we don't have to create it again.  #
#########################################################################

  hide();

}

sub showEvent
{

#########################################################################
#  Subroutine: showEvent                                                #
#  Parameters: None                                                     #
#  Returns   : Nothing                                                  #
#  This is called when the Manage Package Sets window is shown.  It     #
#  rebuilds the items in the List box each time.                        #
#########################################################################

  refreshPackageSetsListBox();

}

sub packageSetsListBox_doubleClicked
{

#########################################################################
#  Subroutine: packageSetsListBox_doubleClicked                         #
#  Parameters: Pointer to the QListBoxItem that was clicked             #
#  Returns   : Nothing                                                  #
#  This gets called when the user double-clicks on one of the package   #
#  set's names in the ListBox.  It simply calls the "renameButton"      #
#  code to rename that item.                                            #
#########################################################################

  renameButton_clicked();

}

1;
