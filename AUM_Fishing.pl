#! /usr/bin/perl -w

use strict;
use warnings;
use WWW::Mechanize;
use AUM::Config;

$ENV{ PERL_LWP_SSL_VERIFY_HOSTNAME } = 0;

my %cfg = AUM::Config->get_cfg;
my $mech = WWW::Mechanize->new;
my $url = 'https://www.adopteunmec.com';
my $gogole_url = 'http://www.adopteunmec.com/gogole?q=' . $cfg{ gogole_keyword }; 
my $bait = 0;

print "$gogole_url\n";

$mech->get( $url );

print "Connecting to your profile...\n";

$mech->field( 'username', $cfg{ auth }{ user_name } );
$mech->field( 'password', $cfg{ auth }{ passwd } );
$mech->click_button( value => 'OK' );
$url = $mech->uri;

if ( $url eq 'https://www.adopteunmec.com/index?e=login' ) {
print STDERR "connection failed, wrong username or password";
	exit -1;
}

print "Connected\nfetching /home page...\n";

$mech->get( $url );
my $res = $mech->content;

print "Fetched\nchecking for valid profile URL...\n";

my @link_match_home = $res =~ /https?:\/\/www\.adopteunmec\.com\/profile\/[0-9]+/g;
#$mech->get( $gogole_url );
#$res = $mech->content;
my @link_match_gogole = $res =~ /https?:\/\/www\.adopteunmec\.com\/profile\/[0-9]+/g;
my @links = ( @link_match_home );#, @link_match_gogole );

foreach my $link ( @links ) {
	print "found: $link\n";

    if ( $mech->get( $link ) ) {
		$bait++;
	}
}

print "successfully baited $bait girls, now you wait for some magick mail !\n";
exit 0;