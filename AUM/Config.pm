#! /usr/bin/perl -w

use warnings;
use strict;

package AUM::Config;

my %cfg = (
	auth => { user_name => 'arnmeyer@hotmail.fr', passwd => 'Pangea/poil.21' },
	gogole_keyword	=> [ 'blonde', 'strasbourg', 'metal'],
);

sub get_cfg { return %cfg; }

1;