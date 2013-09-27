# Form implementation generated from reading ui file 'Selector.ui'
#
# Created: Wed Oct 29 21:10:58 2003
#      by: The PerlQt User Interface Compiler (puic)
#
# Converted perlQt3 to perlQt4
# Date: Sun Sep 22 21:10:58 2013
#   by: DongInn Kim (dikim@cs.indiana.edu)
#
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

package Qt::SelectorWindow;

use QtCore4;
use QtGui4;
use QtCore4::isa qw(Qt::Widget);
use QtCore4::debug qw(ambiguous);

use Qt::SelectorTable;
use lib "$ENV{OSCAR_HOME}/lib";
use OSCAR::Opkg;
use OSCAR::ODA_Defs;
use OSCAR::Utils;

use QtCore4::slots
    init => [],
    parseCommandLine => [],
    refreshPackageSetComboBox => [],
    aboutButton_clicked => [],
    manageSetsButton_clicked => [],
    makePackageTable => [],
    cancelButton_clicked => [],
    okButton_clicked => [],
    cancelButton_clicked => [],
    updateTextBox => [],
    rowSelectionChanged => [],
    do_deactivate_package_set_combo => [];


use Qt::SelectorUtils;
use Qt::SelectorManageSets;
#use Qt::SelectorImages;
#use Qt::SelectorAbout;
use lib "$ENV{OSCAR_HOME}/lib"; 
use OSCAR::Database;
use Getopt::Long;
use Carp;

my %options = ();
my @errors = ();

#########################################################################
#  Create SelectorWindow UI for selector.                               #
#  Call the createSelectorPage to create all the necessary UI widgets   #
#  on the selector window.                                              #
#  Once the widget is created and added to the SelectorWindow class,    #
#  setup the slot to follow up with the given signals/events on the     #
#  the selector window.                                                 #
#########################################################################
sub NEW
{
    shift->SUPER::NEW(@_);

    resize(621,493);
    print STDERR "Setting caption...\n" if $options{debug};
    my $title = 'OSCAR Package Selector';
    createSelectorPage($title);
    this->setWindowTitle($title);

    print STDERR "Starting the second step of the initialization...\n" 
        if $options{debug};
    init();
}

#########################################################################
#  Subroutine: init                                                     #
#  Parameters: None                                                     #
#  Returns   : Nothing                                                  #
#  This code gets called after the widget is created but before it gets #
#  displayed.  This is so we can populate the packageSetComboBox and    #
#  the packageTable, as well as any other setup work.                   #
#########################################################################
sub init {

    print STDERR "Widget created but not yet displayed, finishing ".
                 "initialization...\n" if $options{debug};

    # Create the form windows for SelectorAbout and SelectorManageSets
    print STDERR "Create the form windows for SelectorAbout and ".
                 "SelectorManageSets\n" if $options{debug};
    #this->{aboutForm} = Qt::SelectorAbout();
    this->{manageSetsForm} = Qt::SelectorManageSets();

    # Set up the SIGNALS / SLOTS connections
    print STDERR "Set up the SIGNALS / SLOTS connections\n" if $options{debug};
    Qt::Object::connect(this->{manageSetsButton}, SIGNAL 'clicked()', 
                        this, SLOT 'manageSetsButton_clicked()');
    #Qt::Object::connect(this->{aboutButton}, SIGNAL "clicked()", this, SLOT "aboutButton_clicked()");
    Qt::Object::connect(this->{packageSetComboBox}, 
                        SIGNAL 'currentIndexChanged(int)',
                        this,
                        SLOT 'makePackageTable()');
    Qt::Object::connect(this->{ptSelectionModel}, SIGNAL 'currentRowChanged(const QModelIndex &, const QModelIndex &)',
                        this, SLOT 'rowSelectionChanged()');
    #Qt::Object::connect(packageTable, SIGNAL 'deactivate_package_set_combo()',
    #                    this, SLOT 'do_deactivate_package_set_combo()');

    print STDERR "Setting the signals...\n" if $options{debug};
    Qt::Object::connect(this->{okButton}, SIGNAL "clicked()", this, SLOT "okButton_clicked()");
    print STDERR "Setting the signals...\n" if $options{debug};
    Qt::Object::connect(this->{cancelButton}, SIGNAL "clicked()", this, SLOT "cancelButton_clicked()");

    # Populate the Package Set ComboBox / packageTable
    refreshPackageSetComboBox();
}

#########################################################################
#  Subroutine: createSelectorPage                                       #
#  Parameters: title                                                    #
#  Returns   : Nothing                                                  #
#  The actual widget creation happens here.                             #
#  - Title Label                                                        #
#  - PackageSets ComboBox                                               #
#  - ManageSet Button                                                   #
#  - PackageTable TreeView                                              #
#  - Package detail TabWidget                                           #
#  - OK and Exit Button                                                 #
#########################################################################
sub createSelectorPage {
    my $title = shift;

    my $mainLayout = Qt::HBoxLayout();

    my $titleLayout = Qt::VBoxLayout();
    my $psLayout = Qt::HBoxLayout();
    my $okButtonLayout = Qt::HBoxLayout();
    my $cancelButtonLayout = Qt::VBoxLayout();

    my $titleLabel = Qt::Label();
    this->{titleLabel} = $titleLabel;
    my $labelFont = $titleLabel->font();
    $labelFont->setFamily('Helvetica [Urw]');
    $labelFont->setPointSize(24);
    $labelFont->setBold(1);
    $labelFont->setItalic(1);
    $titleLabel->setFont($labelFont);
    $titleLabel->setFrameShape(&Qt::Label::NoFrame);
    $titleLabel->setFrameShadow(&Qt::Label::Plain);
    $titleLabel->setText(trUtf8("OSCAR Package Selector"));
    $titleLabel->setAlignment(Qt::AlignCenter());
    $titleLayout->addWidget($titleLabel);


    print STDERR "Setting the package set label...\n" if $options{debug};
    my $packLabel = Qt::Label();
    my $packLabel_font = $packLabel->font();
    $packLabel_font->setFamily("Helvetica [Urw]");
    $packLabel_font->setPointSize(14);
    $packLabel_font->setBold(1);
    $packLabel->setFont($packLabel_font);
    $packLabel->setText(trUtf8("Package Set:"));
    $psLayout->addWidget($packLabel);

    print STDERR "Setting the package set combo...\n" if $options{debug};
    my $packageSetComboBox = Qt::ComboBox();
    this->{packageSetComboBox} = $packageSetComboBox;
    $packageSetComboBox->setPalette(Qt::Palette(Qt::Color(0, 85, 255)));
    my $packageSetComboBox_font = $packageSetComboBox->font();
    $packageSetComboBox_font->setFamily("Helvetica [Urw]");
    $packageSetComboBox_font->setPointSize(14);
    $packageSetComboBox_font->setBold(1);
    $packageSetComboBox->setFont($packageSetComboBox_font);
    $packageSetComboBox->setToolTip(trUtf8("Display the packages in this package set"));
    $psLayout->addWidget($packageSetComboBox);

    #print STDERR "Setting the 'About' button of the OSCAR Selector...\n" if $options{debug};
    #$aboutForm = Qt::SelectorAbout();

    my $manageSetsButton = Qt::PushButton();
    this->{manageSetsButton} = $manageSetsButton;
    $manageSetsButton->setText(trUtf8("&Manage Sets"));
    $manageSetsButton->setToolTip(trUtf8("Add, delete, and rename package sets"));
    $psLayout->addWidget($manageSetsButton);


    print STDERR "Setting the package table...\n" if $options{debug};
    my $packageTable = Qt::SelectorTable();
    this->{packageTable} = $packageTable;
    my $packageModel = this->{packageTable}->getModel($packageTable);
    this->{packageModel} = $packageModel;
    my $newTable = this->{packageTable}->setSourceModel($packageModel);
    this->{ptSelectionModel} = $newTable->selectionModel();
    my $packageLayout = this->{packageTable}->getLayout($newTable);

    my $pkgDetailLayout = this->{packageTable}->getPackageDetail();

    print STDERR "Setting the ok button...\n" if $options{debug};
    my $okButton = Qt::PushButton();
    this->{okButton} = $okButton;
    my $okButton_font = $okButton->font();
    $okButton_font->setFamily("Helvetica [Urw]");
    $okButton_font->setPointSize(14);
    $okButton->setFont($okButton_font);
    $okButton->setText(trUtf8("&OK"));
    $okButton->setToolTip(trUtf8("OK the OSCAR Package Selector"));
    $okButtonLayout->addWidget($okButton);

    print STDERR "Setting the exit button...\n" if $options{debug};
    my $cancelButton = Qt::PushButton();
    this->{cancelButton} = $cancelButton;
    my $cancelButton_font = $cancelButton->font();
    $cancelButton_font->setFamily("Helvetica [Urw]");
    $cancelButton_font->setPointSize(14);
    $cancelButton->setFont($cancelButton_font);
    $cancelButton->setText(trUtf8("&Cancel"));
    $cancelButton->setToolTip(trUtf8("Exit the OSCAR Package Selector without saving"));
    $cancelButtonLayout->addWidget($cancelButton);

    $titleLayout->addLayout($psLayout);
    $titleLayout->addLayout($packageLayout);
    $titleLayout->addLayout($pkgDetailLayout);
    $titleLayout->addLayout($okButtonLayout);
    $okButtonLayout->addLayout($cancelButtonLayout);
    $mainLayout->addLayout($titleLayout);
    this->setLayout($mainLayout);
}

sub refreshPackageSetComboBox
{

#########################################################################
#  Subroutine: refreshPackageSetComboBox                                #
#  Parameters: None                                                     #
#  Returns   : Nothing                                                  #
#  This is called to repopulate the drop-down combo box listing all of  #
#  the package sets available.  It refreshes the contents of the list   #
#  and then refreshes the contents of the table if the selected item    #
#  is no longer available (due to deletion or rename).                  #
#########################################################################

  # Save the "currently" selected item in the combobox (if anything)
  my $packageSetComboBox = this->{packageSetComboBox};
  my $lastText = $packageSetComboBox->itemData($packageSetComboBox->currentIndex())->toString();
  print "packageSet current: $lastText\n" if $options{debug};
  $lastText = "Default" if ($lastText eq "");
  # Rebuild the list of items in the combobox
  Qt::SelectorUtils::populatePackageSetList($packageSetComboBox);
  # Try to reselect the previously selected item if it still exists
  my $foundit = 0;
  if (length $lastText > 0)
    {
      for (my $count = 0; 
           ($count < $packageSetComboBox->count()) && (!$foundit);
           $count++)
        {
            if ($packageSetComboBox->findText($lastText))
            {
              $foundit = 1;
              $packageSetComboBox->setCurrentIndex($count);
            }
        }
    }

  # If the previously selected item was deleted or renamed (or never 
  # existed, like at startup), then we have a different item selected
  # in the packageSetComboBox and we need to refresh the information in 
  # the table for the newly selected package set in that combo box. 
  if($foundit){
     emit $packageSetComboBox->setCurrentIndex(
             $packageSetComboBox->findText($lastText));
  }else{
     emit $packageSetComboBox->setCurrentIndex(0);
  }

}

#########################################################################
#  Subroutine: makePackageTable                                         #
#  Parameters: None                                                     #
#  Returns   : Nothing                                                  #
#  This is a slot invoked when the PackageSets ComboBox is selected     #
#  with the different package sets.                                     #
#  Currently we have only "Default" and "Experimental" Package sets     #
#  Provided.                                                            #
#########################################################################
sub makePackageTable(){
    my $packageSetComboBox = this->{packageSetComboBox};
    my $lastText = $packageSetComboBox->currentText();

    Qt::SelectorTable::removeTable();

    Qt::SelectorTable::populateTable($lastText);
}

sub manageSetsButton_clicked
{
#########################################################################
#  Subroutine: manageSetsButton_clicked                                 #
#  Parameters: None                                                     #
#  Returns   : Nothing                                                  #
#  When the "Manage Sets" button is clicked, show the Manage Package    #
#  Sets form.                                                           #
#########################################################################

  this->{manageSetsForm}->show();

}

#########################################################################
#  Subroutine: okButton_clicked                                         #
#  Parameters: None                                                     #
#  Returns   : Nothing                                                  #
#  When the okButton is clicked, quit the application.                  #
#########################################################################
sub okButton_clicked () {
    # If the GUI is running as the 'Updater', then we need to go through
    # the list of all packages and find out which ones are selected.

    my $success;  # Return code for database commands
    my %selection_data;
    my $selection_value;

    my $packageModel = this->{packageModel};
    for (my $row = 0; $row < $packageModel->rowCount(); $row++) {
        my $package = $packageModel->item($row,1)->text();
        my $checked = $packageModel->item($row,0)->checkState();

        # We translate the selection in values that ODA understands
        if ($checked == Qt::Checked()) {
            $selection_value = OSCAR::ODA_Defs::SELECTED();
        } else {
            $selection_value = OSCAR::ODA_Defs::UNSELECTED();
        }

        # We add the OPKG and its selection value into the hash
        $selection_data{$package} = $selection_value;
    }

    if (OSCAR::Database::set_opkgs_selection_data (%selection_data)) {
        carp "ERROR: Impossible to update selection data in ODA";
        return undef;
    }

    Qt::Application::exit();
}

#########################################################################
#  Subroutine: cancelButton_clicked                                     #
#  Parameters: None                                                     #
#  Returns   : Nothing                                                  #
#  When the cancelButton is clicked, quit the application.              #
#########################################################################
sub cancelButton_clicked () {

    print "Do nothing!\n";
    Qt::Application::exit();
}

#########################################################################
#  Subroutine: rowSelectedChanged                                       #
#  Parameters: None                                                     #
#  Returns   : Nothing                                                  #
#  This slot get called when a new row is selected in the packageTable. #
#  We update the four text boxes at the bottom of the window:           #
#  information (description), provides, requires, and conflicts.        #
#########################################################################
sub rowSelectionChanged () {
    my $index = this->{ptSelectionModel}->currentIndex(); # Qt::ModelIndex
    my $item = $index->row();
    my $packageModel = this->{packageModel};
    my $data =  $packageModel->data($packageModel->index($item, 1, Qt::ModelIndex()))->toString();
    print "New row selected: $data!\n" if $options{debug};
    this->{packageTable}->pushPkgDetailInfo($data);
}


1;
