use strict;
use warnings;
use Module::Build;

my $builder = Module::Build->new(
    module_name         => 'WebService::Zussar',
    license             => 'artistic2',
    dist_author         => 'Masanori Ohgita <mp@ohgita.info>',
    dist_version_from   => 'lib/WebService/Zussar.pm',
    requires => {
        'Test::More' => 0,
        'version'    => 0,
    },
    add_to_cleanup      => [ 'WebService-Zussar-*' ],
);

$builder->create_build_script();
