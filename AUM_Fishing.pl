#! /usr/bin/perl -w

use strict;
use WWW::Mechanize;

$ENV{ PERL_LWP_SSL_VERIFY_HOSTNAME } = 0;

my $mech = WWW::Mechanize->new();
my $url = 'https://www.adopteunmec.com';
my $pswd = 'test123';
my $usrn = 'mendiej@openmailbox.org';
my $bait = 0;

$mech->get( $url );
print "$url\n";
$mech->field( 'username', $usrn );
$mech->field( 'password', $pswd );
$mech->click_button( value => 'OK' );
$url = $mech->uri;
print "$url\n";

if ( $url eq 'https://www.adopteunmec.com/index?e=login' ) {
  print STDERR "connection failed, wrong username or password";
  exit -1;
}

$mech->get( $url );
my $res = $mech->content();

my @link_match;
if ( @link_match = $res =~ /https?:\/\/www\.adopteunmec\.com\/profile\/[0-9]+/g ) {
  foreach my $link ( @link_match ) {
    print "$link\n";

    if ( $mech->get( $link ) ) {
      $bait++;
    }
  }
}

print "successfully baited $bait girls, now you wait for some magick mail !\n";
exit 0;
