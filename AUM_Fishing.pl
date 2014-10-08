#! /usr/bin/perl -w

use strict;
use warnings;
use IO::File;
use WWW::Mechanize::Firefox;
use AUM::Config;

$ENV{ PERL_LWP_SSL_VERIFY_HOSTNAME } = 0;
$SIG{ INT } = \&clean_disconnect;

my %cfg = AUM::Config->get_cfg;
my $mech = WWW::Mechanize::Firefox->new( launch => 'firefox' );
my $url = 'https://www.adopteunmec.com';
my $bait = 0;
my $res;

sub clean_disconnect {
	print "Going to disconnect you now...\n";
	$mech->get( 'http://www.adopteunmec.com/auth/logout' );
	print "Done ! Good-bye\n";
	undef $mech;
	exit 0;
}

sub connect_and_fetch {
	print "Connecting to your profile...\n";
	$mech->get( $url );
	$mech->field( '#mail', $cfg{ auth }{ user_name } );
	$mech->field( '#password', $cfg{ auth }{ passwd } );
	$mech->click_button( value => 'OK' );
	$url = $mech->uri;
	$mech->get( $url );

	if ( $url eq 'https://www.adopteunmec.com/index?e=login' ) {
	  print STDERR "connection failed, wrong username or password or already logged in";
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

sub gogole_randomize {
	my ( $keywords, $nbr ) = @_;
	
	my $ret = '';
	for my $i ( 0 .. $nbr ) {
		my $word = @$keywords[ rand( @$keywords ) ];
		$ret = $ret . ' ' . $word if $ret !~ /$word/;
	}
	return $ret;
}

sub get_link_gogole {
	my $curr_url = $mech->uri;

	print "Preparing to use gogole search engine\n";
	my $gogole_string = gogole_randomize( $cfg{ gogole }{ gogole_keywords }, $cfg{ gogole }{ nbr_keywords } );
	$mech->field( 'q', $gogole_string);
	$mech->click_button( id => 'btn-submit' );

#	$url = $mech->uri;
#	$mech->get( $url );
	my $res = $mech->content;
	my @link_match_gogole = $res =~ /https?:\/\/www\.adopteunmec\.com\/profile\/[0-9]+/g;
	return @link_match_gogole;
}

sub timestamp_nok {
	my ( @result ) = @_;
	chomp $result[0];
	$result[0] =~ /(?<timestamp>[0-9]+)/;
	my $timestamp = $+{ timestamp };
	my $diff = time - $timestamp;
	if ( time - $timestamp > 86400 ) { #24heures = 86400 sec
		qx( perl -i.bak -pe "s/^\Q$result[0]\E\$//g" $cfg{ save_file } );
		qx( perl -i.bak -pe "s{^\\s*\n\$}{}" $cfg{ save_file } );
		return 1;
	}
	return 0;
}

sub update_file {
	my ( $results, $link ) = @_;

	if ( !@$results || timestamp_nok( @$results ) ) {
		my $fh = IO::File->new( '+>>' . $cfg{ save_file } )
			|| die  "could not open file: $!";
			$fh->print( time . ' ' . $link . "\n" );
		$fh->close;
		return 1;
	}
	return undef;
}

sub ping_profile {
	my ( $results, $link ) = @_;
	
	if ( !@$results && $mech->get( $link ) ) {
		print "pinging $link\n";
		$bait++;
		return 1;
	}
	print "not pinging\n";
	return undef;
}

sub search_file {
  my ( $link, $sub ) = @_;

	my @results;
	if ( $^O eq 'MSWin32' ) {
		@results = qx( findstr $link $cfg{ save_file } );
		return $sub->( \@results, $link );
	} else {
		@results = qx( grep $link $cfg{ save_file } );
		return $sub->( \@results, $link );
	}
}

if ( connect_and_fetch ) {
	my @links = ( get_link_home_page, get_link_gogole );
	foreach my $link ( @links ) {
		if ( search_file( $link, \&ping_profile ) ) {
			search_file( $link, \&update_file );
		}
	}
	print "successfully baited $bait girls, now you wait for some magick mail !\n";
	clean_disconnect;
} else {
	exit -1;
}
