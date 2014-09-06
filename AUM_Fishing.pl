#! /usr/bin/perl -w

use strict;
use warnings;
use WWW::Mechanize::Firefox;
use AUM::Config;

$ENV{ PERL_LWP_SSL_VERIFY_HOSTNAME } = 0;

my %cfg = AUM::Config->get_cfg;
my $mech = WWW::Mechanize::Firefox->new;
my $url = 'https://www.adopteunmec.com';
my $bait = 0;
my $res;

sub connect_and_fetch {
	print "Connecting to your profile...\n";
	$mech->get( $url );
	$mech->field( '#mail', $cfg{ auth }{ user_name } );
	$mech->field( '#password', $cfg{ auth }{ passwd } );
	$mech->click_button( value => 'OK' );
	$url = $mech->uri;
	$mech->get( $url );

	if ( $url eq 'https://www.adopteunmec.com/index?e=login' ) {
		print STDERR "connection failed, wrong username or password";
		return undef;
	}
	print "Connected\n";

	print "Fetching home page\n";
	$res = $mech->content;
	print "Fetched\n";

	return 1;
}

sub get_link_home_page {
	my @link_match_home = $res =~ /https?:\/\/www\.adopteunmec\.com\/profile\/[0-9]+/g;
	return @link_match_home;
}

sub get_link_gogole {
	my $curr_url = $mech->uri;

	print "$curr_url\n";

	print "Preparing to use gogole search engine\n";
	$mech->field( 'q', $cfg{ gogole_keywords } );
	print "coucou\n";
	$mech->click_button( id => 'btn-submit' );

	$url = $mech->uri;
	$mech->get( $url );
	my $res = $mech->content;
	my @link_match_gogole = $res =~ /https?:\/\/www\.adopteunmec\.com\/profile\/[0-9]+/g;
	return @link_match_gogole;
}

if ( connect_and_fetch ) {
	my @links = ( get_link_home_page, get_link_gogole );
	foreach my $link ( @links ) {
		print "found: $link\n";

		if ( $mech->get( $link ) ) {
			$bait++;
		}
	}

	print "successfully baited $bait girls, now you wait for some magick mail !\nGoing to dsconnect you now...\n";
	$mech->get( 'http://www.adopteunmec.com/auth/logout' );
	print "Done ! Good-bye\n";
	undef $mech;
	exit 0;
} else {
	exit -1;
}
