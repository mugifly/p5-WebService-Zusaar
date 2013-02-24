use strict;
use warnings;
use ExtUtils::MakeMaker;

WriteMakefile(
    NAME                => 'WebService::Zussar',
    AUTHOR              => 'Masanori Ohgita <mp@ohgita.info>',
    VERSION_FROM        => 'lib/WebService/Zussar.pm',
    ABSTRACT_FROM       => 'lib/WebService/Zussar.pm',
    PL_FILES            => {},
    PREREQ_PM => {
        'Test::More' => 0,
        'version'    => 0,
    },
    dist                => { COMPRESS => 'gzip -9f', SUFFIX => 'gz', },
    clean               => { FILES => 'WebService-Zussar-*' },
);
