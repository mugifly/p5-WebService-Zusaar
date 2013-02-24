use strict;
use warnings;
use ExtUtils::MakeMaker;

WriteMakefile(
	NAME                => 'WebService::Zussar',
	AUTHOR              => 'Masanori Ohgita (http://ohgita.info)',
	VERSION_FROM        => 'lib/WebService/Zussar.pm',
	ABSTRACT_FROM       => 'lib/WebService/Zussar.pm',
	PL_FILES            => {},
	PREREQ_PM => {
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
	dist                => { COMPRESS => 'gzip -9f', SUFFIX => 'gz', },
	clean               => { FILES => 'WebService-Zussar-*' },
);
