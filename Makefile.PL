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
		'Class::Accessor'			 => 0,
		'Data::Recursive::Encode'	 => 0,
		'DateTime::Format::ISO8601'	 => 0,
		'Hash::AsObject'				 => 0,
		'JSON'						 => 0,
		'LWP::UserAgent'				 => 0,
		'URI'						 => 0,

		'Test::Pod'		 			 => 0,
		'Test::Pod::Coverage'		 => 1.08,
		'File::Slurp'				 => 0,
		'FindBin'					 => 0,
		'Plack::Loader'				 => 0,
		'Test::TCP'					 => 0,
		'Test::Perl::Critic'			 => 0,


	},
	dist                => { COMPRESS => 'gzip -9f', SUFFIX => 'gz', },
	clean               => { FILES => 'WebService-Zussar-*' },
);
