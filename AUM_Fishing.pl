#! /usr/bin/perl -w

use strict;
use warnings;
use WWW::Mechanize;
use AUM::Config;

$ENV{ PERL_LWP_SSL_VERIFY_HOSTNAME } = 0;

my %cfg = AUM::Config->get_cfg;
my $mech = WWW::Mechanize->new;
$mech->agent_alias( 'Windows Mozilla' );
my $url = 'https://www.adopteunmec.com';
my $bait = 0;

sub connect {
	my ( $mech ) = @_;

	print "Connecting to your profile...\n";
	$mech->get( $url );
	$mech->field( 'username', $cfg{ auth }{ user_name } );
	$mech->field( 'password', $cfg{ auth }{ passwd } );
	$mech->click_button( value => 'OK' );
	$url = $mech->uri;
	
	if ( $url eq 'https://www.adopteunmec.com/index?e=login' ) {
		print STDERR "connection failed, wrong username or password";
		return undef;
	}
	
	print "Connected\n";
	return 1;
}

sub get_link_home_page {
	my ( $mech ) = @_;

	print "Fetching home page\n";
	$mech->get( $url );
	my $res = $mech->content;
	print "Fetched\nchecking for valid profile URL...\n";
	my @link_match_home = $res =~ /https?:\/\/www\.adopteunmec\.com\/profile\/[0-9]+/g;
	return @link_match_home;
}

sub get_link_gogole {
	my ( $mech ) = @_;
	
	print "Preparing to use gogole search engine\n";
	$mech->field( 'q', $cfg{ gogole_keywords } );
	print "coucou\n";
	$mech->click_button( value => 'Valider' );
	
	$url = $mech->uri;
	$mech->get( $url );
	my $res = $mech->content;
	my @link_match_gogole = $res =~ /https?:\/\/www\.adopteunmec\.com\/profile\/[0-9]+/g;
	return @link_match_gogole;
}

if ( &connect( $mech ) ) {
	my @links = ( get_link_home_page( $mech ), get_link_gogole( $mech ) );
	foreach my $link ( @links ) {
		print "found: $link\n";

		#if ( $mech->get( $link ) ) {
		#	$bait++;
		#}
	}

	print "successfully baited $bait girls, now you wait for some magick mail !\n";
	exit 0;
} else {
	exit -1;
}