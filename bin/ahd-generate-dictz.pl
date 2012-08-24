#!/usr/bin/perl

use strict;
use String::ShellQuote;
chdir glob("~/external/ahd")
    or die 'Can not chdir "~/external/ahd"';

open(my $find_words_pipe, "-|", "find ?/ -type f")
    or die 'Can not open find program to find all the words';

sub debug(@) {
    print STDERR "@_\n";
}

open(my $dictz_file, ">", "ahd.dz")
    or die "Can not open ahd.dz";

my %word_def_info;
my %word_def_written;
my %word_file_map;

my $ascii_re = "^[\000-\177]+\$";
$ascii_re = qr($ascii_re);

sub get_normal_words($) 
{
    my $word = $_[0];
    unless ($word =~ m/$ascii_re/) {
	$word = shell_quote($word);
	chomp($word = qx(AsciiDammit.py $word));
    }
    return $word;
}

my %word_normal_map;
my %word_normal_lc_map;
while (<$find_words_pipe>) {
    chomp;
    my $word = substr($_, 6);
    $word_file_map{$word} = $_;
    my $normal = get_normal_words($word);
    if ($word ne $normal) {
	debug "$word => $normal";
	$word_normal_map{$word} = $normal;
    }
    $word_normal_lc_map{$word} = lc $normal;

}

foreach my $word (sort {$word_normal_lc_map{$a} cmp $word_normal_lc_map{$b}}  keys %word_file_map) {
    my $word_filename = $word_file_map{$word};

    debug "handling $word";
    
    open(my $word_file, "<", $word_filename)
	or die "Can not open $word_filename";
    
    my @word_defs = map {chomp; $_} <$word_file>;
    close $word_file;

    if (@word_defs > 1) {
	my $command = join(' ', 'file-remove-dup', @word_defs);
	@word_defs = split(' ', qx($command));
    }

    $word_def_info{$word} = [] unless exists $word_def_info{$word};
    foreach my $def_filename (@word_defs) {
	unless (exists $word_def_written{$def_filename}) {
	    $word_def_written{$def_filename} = [tell $dictz_file];
	    open(my $def_file, "<", $def_filename)
		or die "Can not open $def_filename";
	    my @def = <$def_file>;
	    close $def_file;
	    print $dictz_file @def;
	    push @{$word_def_written{$def_filename}}, tell($dictz_file);
	}
	push $word_def_info{$word}, @{$word_def_written{$def_filename}};
    }
}

foreach my $word (keys %word_normal_map) {
    my $normal = $word_normal_map{$word};
    $word_def_info{$normal} = [] unless exists $word_def_info{$normal};
    push $word_def_info{$normal}, @{$word_def_info{$word}};
}

open(my $idx_file, ">", "ahd.idx")
    or die "Can not open ahd.idx";

foreach my $word (sort {$word_normal_lc_map{$a} cmp $word_normal_lc_map{$b}} keys %word_def_info) {
    print $idx_file $word;
    print $idx_file pack("CC" . "N" x @{$word_def_info{$word}}, 0, @{$word_def_info{$word}}/2, @{$word_def_info{$word}});
}


