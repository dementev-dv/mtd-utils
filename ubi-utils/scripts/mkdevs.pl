#!/usr/bin/perl -w

#
# Author: Artem B. Bityutskiy <dedekind@oktetlabs.ru>
#
# A small scrip which creates UBI device nodes in /dev. UBI allocates
# major number dynamically, so the script looks at /proc/devices to find
# out UBI's major number.
#

# Create the control device as well if this UBI version supports them (were
# added sice Linux kernel 2.6.24)
my $ctrl = "/sys/class/misc/ubi_ctrl/dev";

if (-e "$ctrl") {
	open FILE, "<", $ctrl or die "Cannot open $ctrl file: $!\n";
	my $devnums = <FILE>;
	close FILE;

	$devnums =~ m/(\d+):(\d+)/;
	system("mknod /dev/ubi_ctrl c $1 $2");
}

my $proc = '/proc/devices';
my $regexp = '(\d+) (ubi\d+)$';

open FILE, "<", $proc or die "Cannot open $proc file: $!\n";
my @file = <FILE>;
close FILE;

foreach (@file) {
	next if not m/$regexp/g;
	print "found $2\n";

	system("rm -rf /dev/$2");
	system("mknod /dev/$2 c $1 0");

	for (my $i = 0; $i < 128; $i += 1) {
		system("rm -rf /dev/$2_$i");
		my $j = $i + 1;
		system("mknod /dev/$2_$i c $1 $j");
	}
}

