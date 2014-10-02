#! /usr/bin/perl -w

use warnings;
use strict;

package AUM::Config;

my %cfg = (
	auth => { 
		user_name => 'lolpoil@openmailbox.org', 	
		passwd => '123456789' 
		},
	gogole	=> { 
			gogole_keywords => [ 'blonde',
								 'strasbourg',
								 'metal',
								 'rousse',
								 'tintin',
								 'coquine',
								 'paris' 
					],
			nbr_keywords => 3,
		},
	save_file => $^O eq 'MSWin32' ? 'AUM\\.save_file' : 'AUM/.save_file',
);

sub get_cfg { return %cfg; }

1;
