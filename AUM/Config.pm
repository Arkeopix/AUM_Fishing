#! /usr/bin/perl -w

use warnings;
use strict;

package AUM::Config;

my %cfg = (
	auth => { user_name => 'lolpoil@openmailbox.org', passwd => '123456789' },
	gogole_keywords	=> 'blonde strasbourg metal', # list of keywords separated by a white space
	save_file => $^O eq 'MSWin32' ? 'AUM\\' : 'AUM/' . 'save_file.sav',
);

sub get_cfg { return %cfg; }

1;
