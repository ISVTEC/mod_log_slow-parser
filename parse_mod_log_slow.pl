#!/usr/bin/perl
#
# Copyright (C) 2012 Cyril Bouthors <cyril@bouthors.org>
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
	$url_stats{"$host$url"}{cpu} += $total_cpu;

	$site_stats{$host}{hits}++;
	$site_stats{$host}{cpu} += $total_cpu;

	# print "usr $usr_cpu sys $sys_cpu host $host total_cpu=$total_cpu url=$url\n";
    }
}

print "==== URL STATS\n";
print "cpu, hits, url\n";
foreach my $key (keys %url_stats)
{
    print "$url_stats{$key}{cpu}, $url_stats{$key}{hits}, $key\n";
}

print "==== SITES STATS\n";
print "cpu, hits, site\n";
foreach my $key (keys %site_stats)
{
    print "$site_stats{$key}{cpu}, $site_stats{$key}{hits}, $key\n";
}
