use 5.012;
use strict;
use warnings FATAL => 'all';
use Module::Build;

my $class = Module::Build->subclass(code => <<'SUBCLASS');
sub ACTION_authortest {
    my ($self) = @_;
    
    $self->depends_on('build');
    $self->depends_on('distmeta');
    
    $self->test_files( qw< t xt > );
    $self->recursive_test_files(1);
    
    $self->depends_on('test');
    
    return;
}

sub ACTION_distdir {
    my ($self) = @_;
    
    $self->depends_on('authortest');
    
    return $self->SUPER::ACTION_distdir();
}
SUBCLASS

my $builder = $class->new(
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
        'Test::MockObject' => 0,
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
