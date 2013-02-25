use strict;
use warnings;
use Module::Build;

my $builder = Module::Build->new(
	module_name         => 'WebService::Zussar',
	license             => 'artistic2',
	dist_author         => 'Masanori Ohgita (http://ohgita.info)',
	dist_version_from   => 'lib/WebService/Zussar.pm',
	requires => {
		'Test::More'					 => 0,
		'version'					 => 0,
		'Carp'						 => 0,
		'Class::Accessor'			 => 0.34,
		'Data::Recursive::Encode'	 => 0.04,
		'DateTime::Format::ISO8601'	 => 0.08,
		'Hash::AsObject'				 => 0.13,
		'JSON'						 => 2.53,
		'LWP::UserAgent'				 => 6.04,
		'URI'						 => 1.60,

		'Test::Pod'		 			 => 0,
		'Test::Pod::Coverage'		 => 1.08,
		'File::Slurp'				 => 0,
		'FindBin'					 => 0,
		'Plack::Loader'				 => 1.00,
		'Test::TCP'					 => 1.18,
		'Test::Perl::Critic'			 => 1.02,
	},
	add_to_cleanup      => [ 'WebService-Zussar-*' ],
);

$builder->create_build_script();
