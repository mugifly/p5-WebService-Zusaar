# Fetch test (Online)
use Test::More;
use strict;
use warnings;
use utf8;

use WebService::Zussar;

use DateTime::Format::ISO8601;
use File::Slurp qw//;
use FindBin;
use Plack::Loader;
use Test::TCP;
use Data::Dumper;

# Prepare the Expected patterns (It's same as a part of item values of Test API response)
my @expect_patterns = (
	{
		owner_nickname => '__papix__',
		catch => '囲め! ゆーすけべーさん!!',
		event_id => '489104'
	},
	{
		owner_nickname => 'Kansai Perl Mongers',
		catch => '関西のPerlユーザーによる、Perlユーザーのための集会',
		event_id => '476003'
	},
);

# Initialize a instance
my $obj = WebService::Zussar->new(encoding => 'utf8');
# Fetch events
$obj->fetch('events', keyword => 'Kansai.pm');
# Iterate a fetched events
while ( my $event = $obj->next ) {
	# Compare values of item, with Expected pattern
	my $ptn = shift @expect_patterns;
	foreach(keys %$ptn){
		is($event->$_, $ptn->{$_}, "Item > $_");
	}
}

# End
done_testing;