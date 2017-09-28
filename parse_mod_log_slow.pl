#!/usr/bin/perl
#
# Copyright (C) 2012-2014 Cyril Bouthors <cyril@boutho.rs>
#
# This program is free software: you can redistribute it and/or modify it under
# the terms of the GNU General Public License as published by the Free Software
# Foundation, either version 3 of the License, or (at your option) any later
# version.
#
# This program is distributed in the hope that it will be useful, but WITHOUT
# ANY WARRANTY; without even the implied warranty of MERCHANTABILITY or FITNESS
# FOR A PARTICULAR PURPOSE. See the GNU General Public License for more details.
#
# You should have received a copy of the GNU General Public License along with
# this program. If not, see <http://www.gnu.org/licenses/>.
#

use constant;
# Only use when debugging because it can lead to 50% performance loss
# use diagnostics;
use sigtrap  qw(SEGV BUS);
use strict   qw(subs vars refs);
use subs     qw(afunc blurfl);
use warnings qw(all);
use sort     qw(stable _quicksort _mergesort);
use Text::CSV;

my ($usr_cpu, $sys_cpu, $host, $url);
my (%url_stats, %site_stats);

my $blacklist = '\.(jpg|png|css|js|ico)$';

while (<>) {

  # Example:
  # 289c:50d1cb67:1 [19/Dec/2012:15:12:55 +0100] elapsed: 0.01 cpu: 0.00(usr)/0.00(sys) pid: 10396 ip: 1.2.4.5 host: mysite.com:80 reqinfo: GET /index.php?foo=bar HTTP/1.1

    if(/^.*cpu: (.*)\(usr\)\/(.*)\(sys\).*host: (.*):.* reqinfo: (GET|POST|HEAD) (.*) HTTP.*$/)
    {
	$usr_cpu = $1;
	$sys_cpu = $2;

	$host = $3;
	$url = $5;

	next if($url =~ /$blacklist/);

	my $total_cpu = $usr_cpu + $sys_cpu;
	next if ($total_cpu == 0);

	if(!exists($url_stats{"$host$url"}))
	{
	    $url_stats{"$host$url"} =
	    {
		hits => 0,
		cpu  => 0,
	    }
	}

	if(!exists($site_stats{$host}))
	{
	    $site_stats{$host} =
	    {
		hits => 0,
		cpu  => 0,
	    }
	}

	$url_stats{"$host$url"}{hits}++;
	$url_stats{"$host$url"}{total_cpu} += $total_cpu;

	$site_stats{$host}{hits}++;
	$site_stats{$host}{total_cpu} += $total_cpu;

	# print "usr $usr_cpu sys $sys_cpu host $host total_cpu=$total_cpu url=$url\n";
    }
}

my $csv = Text::CSV->new({eol => "\r\n"})
    or die "Cannot use CSV: ".Text::CSV->error_diag();

open(FILE, '>', 'cpu-by-url.csv')
    or die "cpu-by-url.csv: $!";

# Print headers
$csv->combine(
    (
     'url',
     'total_cpu',
     'hits'
    ));
print FILE $csv->string();

# Print data
foreach my $key (keys %url_stats)
{
    $csv->combine(
	(
	 $key,
	 $url_stats{$key}{total_cpu},
	 $url_stats{$key}{hits},
	));
    print FILE $csv->string();
}

close FILE
    or die "cpu-by-url.csv: $!";

open(FILE, '>', 'cpu-by-site.csv')
    or die "cpu-by-site.csv: $!";


# Print headers
$csv->combine(
    (
     'url',
     'cpu',
     'hits'
    ));
print FILE $csv->string();

foreach my $key (keys %site_stats)
{
    $csv->combine(
	(
	 $key,
	 $site_stats{$key}{total_cpu},
	 $site_stats{$key}{hits},
	));
    print FILE $csv->string();
}

close FILE
    or die "cpu-by-site.csv: $!";
