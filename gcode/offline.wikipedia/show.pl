#!/usr/bin/perl -w
use strict;

sub LooseEntities {
    $_ = $_[0];
    s/&lt;/</g;
    s/&gt;/>/g;
    s/&apos;/'/g;
    s/&quot;/"/g;
    s/&amp;/\&/g;
    return $_;
}

sub ShowTopic {
    my $foundLine = shift;
    open (my $pipe, "-|", "python", "/home/bhj/windows-config/gcode/wikipediaDumpReader-0.2.10/get_article.py", @_);
    open RESULT, ">/var/tmp/result";
    while(<$pipe>) {
        print RESULT $_;
    }

    system("cd ../mediawiki_sa/ && php5 testparser.php /var/tmp/result > /var/tmp/result.tmp");
    if (($? == -1) || ($? & 127) || ($? >> 8)) {
	print "#### mediawiki_sa parser failed! report to woc.fslab.de ####\n";
	open FALLBACK, ">/var/tmp/result.tmp";
	print FALLBACK "<html><head><title>woc.fslab.de parser failed - report it!</title></head>\n<body>\n";
	print FALLBACK "<h2>woc.fslab.de parser failed, please report this content (/var/tmp/result) to them!</h2>";
	open DATA, "/var/tmp/result";
	while(<DATA>) {
	    chomp;
	    print FALLBACK $_."<BR/>\n";
	}
	close DATA;
	print FALLBACK "</body>\n</html>\n";
	close FALLBACK;
    }

    open OUT, ">/var/tmp/result.html";
    open IN, "/var/tmp/result.tmp";
    while(<IN>) {
	if (/<body/) {
	    print OUT;
	    print OUT <<EOF;
<script type="text/javascript">
function DoSearch(form)
{
top.location='/searchbar/?data='+form.data.value;
}
</script>
<form name="SearchForm" onSubmit="DoSearch(this.form)" method="get" action="/searchbar">
Search for
<input type="text" name="data" size="50">
<input type="button" value="Submit" onclick="DoSearch(this.form)">
<br>
<hr>
</form>
EOF
	    print OUT "<H1>".$foundLine."</H1>\n";
	} else {
	    print OUT;
	}
    }
    close IN;
    close OUT;
}

die "Usage: $0  Article prev_block_num prev_block_byte prev_block_bit block_num block_byte block_bit block start len\n"
    unless @ARGV == 10;

ShowTopic(@ARGV);