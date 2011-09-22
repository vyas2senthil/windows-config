#!/usr/bin/env perl

use strict;
use Getopt::Long;

my $split_re = '\s+';
my $use_skeleton_re = 0;
GetOptions(
    "d=s" => \$split_re,
    "s!" => \$use_skeleton_re,
    );

$split_re = qr($split_re);

die "Error: we take exactly 2 arguments after the options: WORDS, SKELETON" unless @ARGV == 2;

my @words = split($split_re, shift @ARGV);
my $skeleton = shift @ARGV;

#for (@words) {
#    print STDERR "\nwords are $_\n";
#}

if ($use_skeleton_re) {
    $skeleton = ".*" . join(".*", split(//, $skeleton)) . ".*";
}

my $which = -1;

if ($skeleton =~ s/\.(\d+)$//) {
    $which = $1;
}

my $count = 0;

if ($skeleton =~ m/\s+/) {
    $skeleton =~ s/\\//g;
    for my $x (split(/\s+/, $skeleton)) {
	#print STDERR "\nskeleton is $x\n";
	@words = grep(m/$x/i, @words);
	#print STDERR "\nwords are @words\n";
    }
} else {
    @words = grep(m/$skeleton/i, @words);
}
my $match = @words;

if (0 <= $which and $which < @words) {
    print $words[$which] . "\n";
    exit;
}

my @sorted = sort (@words);
my ($first, @sorted) = @sorted;
my $is_prefix = 1;
for(@sorted) {
  if ($first ne substr($_, 0, length($first))) {
    $is_prefix = 0;
    last
  }
}

for (@words) {
  if ($match == 1) {
    print $_ . "\n";
  } else {
    if ($is_prefix) {
      print "$_\n";
    } else {
      printf "%d: %s\n", $count++, $_;
    }
  }    
}
