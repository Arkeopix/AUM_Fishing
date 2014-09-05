#! /usr/bin/perl -w

use warnings;
use strict;

package AUM::Config;

my %cfg = (
	auth => { user_name => 'coucou123@openmailbox.org', passwd => '123456789' },
	gogole_keyword	=> 'blonde strasbourg metal', # list of keywords separated by a white space
);

sub get_cfg { return %cfg; }

1;