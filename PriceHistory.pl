use strict;
use WWW::Mechanize;
use HTML::TableExtract;
use URI::URL;
use URI::QueryParam;
use Class::Struct;
use Data::Dumper;
use Text::Trim;
use HTML::LinkExtractor;
use Getopt::Long;
use warnings;

struct( Price => [
	date => '$',
	closing => '$'
]);

struct( Portfolio => [
	name => '$',
	id => '$',
	fundUrl => '$',
	historyUrl => '$',
	prices => '@'
]);

my $startDate = '';
my $endDate = '';

my $result = GetOptions(
				"startDate=s" => \$startDate,
				"endDate=s" => \$endDate);

my $baseUrl = URI::URL->new("https://www.mypa529ipaccount.com/");
my $fundsUrl = URI::URL->new_abs("/patpl/fund/pricePerformance.cs", $baseUrl);
my $fundHistoryUrl = URI::URL->new_abs("/patpl/fund/priceHistory.cs", $baseUrl);
my $mech = WWW::Mechanize->new();
print "Getting funds from $fundsUrl\n";
$mech->get($fundsUrl)
		or die ("Unable to retrieve the portfolio prices.");

my $headers = [ 'Name' ];
my $te = HTML::TableExtract->new( keep_html => 1, headers => $headers );
$te->parse($mech->content());
my $table = $te->first_table_found;
my @portfolios = ();
foreach ($table->rows)
{
	my $link = trim($_->[0]);
	my $le = new HTML::LinkExtractor();
	$le->strip(1);
	$le->parse(\$link);
	foreach my $link (@{ $le->links })
	{
		my $name = $$link{_TEXT};
		my $url = $$link{href};

		my $portfolio = Portfolio->new();
		$portfolio->name($name);
		$portfolio->fundUrl(URI::URL->new_abs($url, $baseUrl));
		$portfolio->id($portfolio->fundUrl->query_param("fundId"));
		$portfolio->historyUrl(URI::URL->new_abs($fundHistoryUrl));
		$portfolio->historyUrl->query_form(fundId=>$portfolio->id, startDate=>$startDate, endDate=>$endDate);

		my $historyUrl = $portfolio->historyUrl;
		print "Getting history for fund '$name' from $historyUrl\n";
		$mech->get($portfolio->historyUrl);

		$mech->submit_form(
			form_name => 'upForm',
			with_fields =>
			{
				fundId => $portfolio->id,
				startDate => $startDate,
				endDate => $endDate
			}
		);

		$headers = ['Date', 'Price'];
		$te = HTML::TableExtract->new( keep_html => 1, headers => $headers );
		$te->parse($mech->content());
		$table = $te->first_table_found;

		my @prices = ();
		my $firstRow = 1;
		my $max;
		my $min;
		my $total = 0;
		open PriceCsvFile, ">$name.csv" or die $!;
		print PriceCsvFile "Date,Close,Open,High,Low,Volume\n";
		foreach my $row ($table->rows)
		{
			# Each cell contains a span with the header, so search for the date.
			$row->[0] =~ /(\d{1,2}\/\d{1,2}\/\d{2,4})/;
			my $date = $1;

			# Each cell contains a span with the header, so search for the closing value.
			$row->[1] =~ /\$(\d{0,3}.\d{2})/;
			my $closing = $1;
			$total += $closing;

			my $price = Price->new();
			$price->date($date);
			$price->closing($closing);

			if ($firstRow == 1) {
					$max = $price;
					$min = $price;
					$firstRow = 0;
			}
			else {
				if ($price->closing > $max->closing) {
					$max = $price;
				}

				if ($price->closing < $min->closing) {
					$min = $price;
				}
			}

			push(@prices, $price);
			push($portfolio->prices, $price);
			print PriceCsvFile $price->date, ',', $price->closing, ",,,,\n";
		}
		close PriceCsvFile;

		my $avg = $total / scalar @prices;

		print "  $name\n";
		print "    Min: ${\$min->closing} on ${\$min->date}\n";
		print "    Max: ${\$max->closing} on ${\$max->date}\n";
		print "    Avg: $avg\n";

		push(@portfolios, $portfolio);
	}
}

print "Done\n";