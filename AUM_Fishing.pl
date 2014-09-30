#! /usr/bin/perl -w

use strict;
use warnings;
use IO::File;
use WWW::Mechanize::Firefox;
use AUM::Config;

$ENV{ PERL_LWP_SSL_VERIFY_HOSTNAME } = 0;
$SIG{ INT } = \&clean_disconnect;

my %cfg = AUM::Config->get_cfg;
my $mech = WWW::Mechanize::Firefox->new;
my $url = 'https://www.adopteunmec.com';
my $bait = 0;
my $res;

sub clean_disconnect {
	print "Going to dsconnect you now...\n";
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
	$mech->click_button( id => 'btn-submit' );

	$url = $mech->uri;
	$mech->get( $url );
	my $res = $mech->content;
	my @link_match_gogole = $res =~ /https?:\/\/www\.adopteunmec\.com\/profile\/[0-9]+/g;
	return @link_match_gogole;
}

sub timestamp_nok {
	my ( @result ) = @_;
	print "##### TIMESTAMP_NOK #######\n";
	chomp $result[0];
	print "\tresult = [@result]\n";
	$result[0] =~ /(?<timestamp>[0-9]+)/;
	my $timestamp = $+{ timestamp };
	my $diff = time - $timestamp;
	print "\ttime = " . time . " - timestamp = $timestamp = $diff\n";
	if ( time - $timestamp > 86400 ) { #24heures = 86400 sec
		print "\ttimestamp nok\n";
		if ( $^O eq 'MSWin32' ) {
			qx( perl -i.bak -pe "s/^\Q$result[0]\E\$//g" $cfg{ save_file } );
			qx( perl -i.bak -pe "s{^\\s*\n\$}{}" $cfg{ save_file } );
		} else {
			qx( sed -i '/$result[0]/Id' $cfg{ save_file });
		}
		print "##### TIMESTAMP_NOK 1 #######\n";
		return 1;
	}
	print "##### TIMESTAMP_NOK 0 #######\n\n";
	return 0;
}

sub update_file {
	my ( $results, $link ) = @_;

	print "link = $link\n";
	if ( !@$results || timestamp_nok( @$results ) ) {
		my $fh = IO::File->new( '+>>' . $cfg{ save_file } )
			|| die  "could not open file: $!";
			print "writing " . time . ' ' . "$link\n";
			$fh->print( time . ' ' . $link . "\n" );
		$fh->close;
	}
}

sub search_file {
  my ( $links, $sub ) = @_;

	my @results;
	foreach my $link ( @$links ) {
		if ( $^O eq 'MSWin32' ) {
			@results = qx( findstr $link $cfg{ save_file } );
			$sub->( \@results, $link );
		} else {
			@results = qx( grep $link $cfg{ save_file } );
			$sub->( \@results, $link );
		}
	}
	return @results;
}

if ( connect_and_fetch ) {
	my @links = ( get_link_home_page, get_link_gogole );
	# foreach my $link ( @links ) {
		# if ( $mech->get( $link ) ) {
			# $bait++;
		# }
	# }
	search_file( \@links, \&update_file );
	print "successfully baited $bait girls, now you wait for some magick mail !\n";
	clean_disconnect;
} else {
	exit -1;
}
