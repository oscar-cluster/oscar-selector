# Form implementation generated from reading ui file 'Selector.ui'
#
# Created: Wed Oct 29 21:10:58 2003
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

#########################################################################
# Main Selector application                                             #
#########################################################################
use strict;
use utf8;


package main;

use QtCore4;
use Qt::SelectorWindow;

sub main{
    my $a = Qt::Application(\@ARGV);
    my $w = Qt::SelectorWindow();
    $w->show();
    exit $a->exec();
}

main();
