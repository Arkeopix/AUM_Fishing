#! /usr/bin/perl -w

use strict;
use WWW::Mechanize;

$ENV{ PERL_LWP_SSL_VERIFY_HOSTNAME } = 0;

my $mech = WWW::Mechanize->new();
my $url = 'https://www.adopteunmec.com';
my $pswd = 'your passwd here';
my $usrn = 'your mail here';
my $bait = 0;

$mech->get( $url );

print "Connecting to your profile...\n";

$mech->field( 'username', $usrn );
$mech->field( 'password', $pswd );
$mech->click_button( value => 'OK' );
$url = $mech->uri;

if ( $url eq 'https://www.adopteunmec.com/index?e=login' ) {
  print STDERR "connection failed, wrong username or password";
  exit -1;
}

print "Connected\nfetching /home page...\n";

$mech->get( $url );
my $res = $mech->content();

print "Fetched\n checking for valid profile URL...\n";

my @link_match;
if ( @link_match = $res =~ /https?:\/\/www\.adopteunmec\.com\/profile\/[0-9]+/g ) {
  foreach my $link ( @link_match ) {
    print "found: $link\n";

    if ( $mech->get( $link ) ) {
      $bait++;
    }
  }
}

print "successfully baited $bait girls, now you wait for some magick mail !\n";
exit 0;
