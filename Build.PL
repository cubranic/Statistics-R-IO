use 5.012;
use strict;
use warnings FATAL => 'all';
use Module::Build;

my $builder = Module::Build->new(
    module_name         => 'Statistics::R::IO',
    license             => 'GPL_3',
    dist_author         => q{Davor Cubranic <cubranic@stat.ubc.ca>},
    dist_version_from   => 'lib/Statistics/R/IO.pm',
    release_status      => 'stable',
    configure_requires => {
        'Module::Build' => 0,
        'Software::License' => 0,
    },
    build_requires => {
        'Test::More' => 0,
        'Test::Fatal' => 0,
    },
    requires => {
        'perl' => 5.012,
        'Carp' => 0,
        'Moo' => 0,
        'namespace::clean' => 0,
        #'ABC'              => 1.6,
        #'Foo::Bar::Module' => 5.0401,
    },
    add_to_cleanup     => [ 'Statistics-R-IO-*' ],
    create_makefile_pl => 'traditional',
);

$builder->create_build_script();
