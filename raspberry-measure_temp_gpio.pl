#!/usr/bin/env perl

use v5.12;
use strict;
use warnings;

use File::Slurp;
use LWP::UserAgent;

my %map = (
	1 => "28-000005fdb95b",
	2 => "28-000005fe0b1e",
	3 => "28-000005fe350a",
	4 => "28-000005fee542",
	5 => "28-000005ff1276",
	6 => "28-000005feac32",
	7 => "28-000005fee49b",
	8 => "28-000005fe15b2",
	9 => "28-000005feb7da",
	10 => "28-000005feab97",
	11 => "28-000005fe3224",
	12 => "28-000005fd6246",
	13 => "28-000005fd6706",
	14 => "28-000005fe3e94",
	15 => "28-000005ff4e9f",
	16 => "28-000005fdd11e",
	17 => "28-000005ff431a",
	18 => "28-000005ff8c54",
	19 => "28-000005ff5bf6",
	20 => "28-000005ff107c",
);

sub get_temp {
	my ($device) = @_;

	my $path = "/sys/bus/w1/devices/" . $device . "/w1_slave";

	return undef unless -f $path;

	my $data = read_file($path);

	if(not defined $data) {
		return undef;
	}

	if($data =~ /crc=.. NO/) {
		return undef;
	}

	if($data =~ /t=([0-9-]+)/) {
		return $1 / 1000;
	}

	return undef;
}

my $ua = LWP::UserAgent->new;

foreach my $id (sort {$a <=> $b} keys %map) {
	my $temp = get_temp($map{$id});

	unless(defined $temp) {
		next;
	}

	say "$id: $temp";

	my $req = HTTP::Request->new(POST => 'http://datenkrake.dyn.club.entropia.de:8086/db/temperatur/series?u=USERNAME&p=PASSWORD');
	#$req->content_type('application/json');
	$req->content_type('application/x-www-form-urlencoded');
	$req->content(<<"EOF");
[
	{
		"name": "node$id",
		"columns": ["value"],
		"points":  [[ $temp ]]
	}
]

EOF

	my $resp = $ua->request($req);
	unless($resp->is_success) {
		print $resp->content;
		die $resp->status_line;
	}
}
