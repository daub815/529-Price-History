# 529-Price-History
PA 529 Price History to CSV

Perl script that will scrap the list of available funds from [PA Investment Plan's website](https://www.mypa529ipaccount.com/patpl/fundperform/fundPricePerform.do) and the closing price for each day.  

Dependencies
- [WWW::Mechanize](http://search.cpan.org/~ether/WWW-Mechanize-1.74/lib/WWW/Mechanize.pm)
- [HTML::TableExtract](http://search.cpan.org/dist/HTML-TableExtract/lib/HTML/TableExtract.pm)
- [URI::URL](http://search.cpan.org/~rse/lcwa-1.0.0/lib/lwp/lib/URI/URL.pm)
- [URI::QueryParam](http://search.cpan.org/dist/URI/lib/URI/QueryParam.pm)
- [Class::Struct](http://search.cpan.org/~shay/perl-5.20.2/lib/Class/Struct.pm)
- [Data::Dumper](http://search.cpan.org/~smueller/Data-Dumper-2.154/Dumper.pm)
- [Text::Trim](http://search.cpan.org/~mattlaw/Text-Trim-1.02/lib/Text/Trim.pm)
- [HTML::LinkExtractor](http://search.cpan.org/~podmaster/HTML-LinkExtractor-0.13/LinkExtractor.pm)

The CSV is specifically to be imported into Quicken 2015 for Mac, but the important piece is the scraping and parsing.
