#!/usr/bin/perl

use strict;

open(my $debug, ">", glob("~/.logs/java-get-imports.log"))
    or die "Can not open debug log file ~/.logs/java-get-imports.log";
sub debug(@) {
    print $debug "@_\n";
}

use String::ShellQuote;
use Getopt::Long;
chomp(my $code_dir = qx(find-code-reading-dir));
my %files_package;
my $verbose;
my $resolve;
GetOptions(
    "d=s" => \$code_dir,
    "v!"  => \$verbose,
    "r=s" => \$resolve,
    );

my $id_re = qr(\b[a-zA-Z_][a-zA-Z0-9_]*\b);
my $qualified_re = qr($id_re(?:\.$id_re)*\b);
my $connect_re = qr((?: |(?:\[\])+));
my %super_classes;

my @keywords = ("abstract", "assert", "boolean", "break", "byte",
	      "case", "catch", "char", "class", "const", "continue",
	      "default", "double", "else", "enum", "extends", "false",
	      "final", "finally", "float", "for", "goto", "if",
	      "implements", "import", "instanceof", "int",
	      "interface", "long", "native", "new", "null", "package",
	      "private", "protected", "public", "return", "short",
	      "static", "strictfp", "super", "switch", "synchronized",
	      "this", "throw", "throws", "transient", "true", "try",
	      "void", "volatile", "while" );

my $keywords = join('|', @keywords);
my $keywords_re = qr($keywords);
my %keywords;

map {$keywords{$_} = 1} @keywords;

my @modifiers = ('public', 'protected', 'private', 'static',
'abstract', 'final', 'native', 'synchronized', 'transient',
'volatile', 'strictfp');

my $modifiers = join('|', @modifiers);
my $modifier_re = qr($modifiers);

sub match_args($) 
{
    return 0;
}

my $package;
my %import_qualifieds;
my %wild_import_qualifieds;
my %refs;
my %defs;
my %import_simples;
my %simple_qualified_map;
my %var_type_map;

sub is_defined($)
{
    return $defs{$_[0]};
}

sub is_keyword($)
{
    return $keywords{$_[0]};
}

sub is_keyword_or_defined($)
{
    return (is_keyword($_[0]) or is_defined($_[0]));
}

sub type_it($$)
{
    debug "type it: $_[0] $_[1]";
    $defs{$_[0]} = 1;
    $refs{$_[1]} = 1;
    $var_type_map{$_[0]} = {} unless exists $var_type_map{$_[0]};
    $var_type_map{$_[0]}{$_[1]} = 1;
}

sub define_it($)
{
    debug "define_it $_[0]";
    $defs{$_[0]} = 1;
}

sub import_it($)
{
    my $q = $_[0];
    debug "import_it: $q";
    my $s = $q;
    $s =~ s/.*\.//;
    $import_qualifieds{$q} = 1;
    $import_simples{$s} = 1;
    $simple_qualified_map{$s} = $q;
}

my $working_file;
if (@ARGV != 1) {
    die "Usage: $0 JAVA_FILE";
}

$working_file = $ARGV[0];
chomp($working_file = qx(java-flatten-cache $working_file));
@ARGV = ($working_file);

if (not $code_dir) {
    die "code dir not found!";
} else {
    debug "code dir set to $code_dir";
    chdir $code_dir or die "can not chdir $code_dir";
}
    
while (<>) {
    debug "got $_";
    if (m/^package ($qualified_re);/) { #package
	$package = $1;
    } elsif (m/^import (?:static )?($qualified_re);/) { #import
	import_it($1);
    } elsif (m/^import (?:static )?($qualified_re)(?:\.\*);/) { #import
	$wild_import_qualifieds{$1} = 1;
    } elsif (m/(?:class|interface) ($id_re)(.*)\{/) { #class|interface
	define_it($1);
	my $class = $1;
	my $ext = $2;
	$super_classes{$class} = {} unless exists $super_classes{$class};
	while ($ext =~ m/($qualified_re)/g) {
	    next if $keywords{$1};
	    $refs{$1} = 1;
	    $super_classes{$class}{$1} = 1;	    
	}
    } elsif (m/new ($qualified_re)\((.*)\)\{/) { #anonymous class definition
	$refs{$1} = 1;
	match_args($2);
    } elsif (m/($qualified_re)$connect_re($id_re)\((.*)\)\{/) { #method definition
	debug "got method: $1 $2";
	type_it($2, $1);

	my $params = $3;
	$params =~ s/$modifier_re //g;
	while ($params =~ m/($qualified_re)(?:$connect_re|<$id_re>)($id_re)/g) {
	    type_it($2, $1);
	}
    } elsif (m/($qualified_re)$connect_re($id_re)\)/) { #arguments
	s/$modifier_re //g;
	my $line = $_;
	while ($line =~ m/($qualified_re)$connect_re($id_re)(?=,|\))/g) {
	    debug "got $1 $2";
	    type_it($2, $1);
	}
    } elsif (m/($qualified_re)(?:$connect_re|<$id_re>)($id_re)(,|=.*|;)/) { #var definition
	type_it($2, $1);
	my $assign = $3;
	while ($assign =~ m/($qualified_re)/g) {
	    $refs{$1} = 1;
	}
    } else {
	debug "not matched: $_";
	while (m/($qualified_re)=/g) {
	    define_it($1);
	}

	while (m/($qualified_re)/g) {
	    $refs{$1} = 1;
	}
    }
}

for my $def (keys %defs) {
}



sub get_default_packages($)
{
    my $package = $_[0];
    return unless $package;
    open(my $pipe, "-|", "grep-gtags -e $package -d $code_dir -t package -s -c")
	or die "can not open grep-gtags";

    while (<$pipe>) {
	m#/([^/]+)\.(?:java|aidl):.*# or next;
	import_it("$package.$1");
    }
    close($pipe);
}

sub get_wildcards($)
{
    my $import = $_[0];
    get_default_packages($import);
    $import =~ s/.*\.//;
    my %def_files;
    open(my $pipe, "-|", "grep-gtags -e $import -d $code_dir -s")
	or die "can not open grep-gtags";
    
    while (<$pipe>) {
	m#(.*?):# or next;
	$def_files{$1} = 1;
    }
    close $pipe;

    $import = shell_quote($import);
    for my $file (keys %def_files) {
	open(my $pipe, "-|", "global-ctags $import..* $code_dir/$file")
	    or die "can not open global-ctags";
	while (<$pipe>) {
	    my ($def) = split;
	    $def =~ s/.*\.//;
	    define_it($def);
	}
	close $pipe;
    }	
}

sub find_import_for($)
{
    my $def = $_[0];
    if (length($def) == 1) {
	print STDERR "$def: generics type parameter?\n";
	return 0;	    
    }
    return 0 unless $def;
    if ($def =~ m/\./) {
	our %import_quoted_map;
	$def =~ s/\..*//;
	return 0 if exists $import_quoted_map{$def};
	$import_quoted_map{$def} = 1;
    }
    debug "grep-gtags -e $def -d $code_dir -t 'class|interface' -s -p '\\.java|\\.aidl'";
    open(my $pipe, "-|", "grep-gtags -e $def -d $code_dir -t 'class|interface' -s -p '\\.java|\\.aidl'")
	or die "can not open grep-gtags";
    
    my @imports;
    while (<$pipe>) {
	m/^(.*?):.*?<(.*?)>/ or next;
	
	my ($file, $tag) = ($1, $2);
	my $package = $files_package{$file};
	unless ($package) {
	    chomp($package = qx(java-get-package $code_dir/$file));
	    $files_package{$file} = $package;
	}
	push @imports, "$package.$tag";
    }

    unless ($resolve) {
	our %printed_imports;
	my $deleted = 0;
	
	for (0..@imports) {
	    if ($printed_imports{$imports[$_]}) {
		delete $imports[$_];
		$deleted = 1;
	    } else {
		$printed_imports{$imports[$_]} = 1;
	    }
	}
	
	if (@imports == 1) {
	    print "import @imports\n";
	} elsif (@imports) {
	    print "import-multi @imports\n";
	} else {
	    print "can not import $def\n" unless $deleted;
	}
    }
}

get_default_packages($package);
get_default_packages("java.lang");
for my $wild (keys %wild_import_qualifieds) {
    get_wildcards($wild);
}


for my $ref (keys %refs) {
    my $ref_save = $ref;
    $ref =~ s/\..*//;
    unless (is_keyword_or_defined($ref)) {
	debug "need import: $ref";
	if ($import_simples{$ref}) {
	    $import_simples{$ref} ++;
	} elsif ($ref =~ m/^[A-Z]/) {
	    debug "find_import_for $ref_save\n";
	    find_import_for($ref_save);
	}
    }
}

if ($verbose) {
    for my $import (keys %import_simples) {
	debug "import $simple_qualified_map{$import} not used" if $import_simples{$import} == 1;
    }
}

sub prefix($)
{
    my ($s) = @_;
    $s =~ s/\..*//;
    return $s;
}

if ($resolve) {
    my $postfix = "";
    if ($resolve =~ m/\./) {
	$postfix = $resolve;
	$postfix =~ s/.*?(?=\.)//;
	debug "postfix is $postfix";
	$resolve =~ s/\..*//;
    }
    if ($simple_qualified_map{$resolve}) {
	print $simple_qualified_map{$resolve} . "$postfix";
    } elsif ($var_type_map{$resolve}) {
	for my $type (keys $var_type_map{$resolve}) {
	    my $prefix = prefix($type);
	    if ($simple_qualified_map{$prefix}) {
		print $simple_qualified_map{$prefix} . substr($type, length($prefix)) . "$postfix\n";
	    } else {
		print "$type$postfix\n";
	    }
	}
    }
}
