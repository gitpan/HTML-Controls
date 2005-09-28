
use strict;
use warnings;
use Module::Build;

my $builder = Module::Build
  ->new(
        module_name         => 'HTML::Controls',
        license             => 'perl',
        dist_name           => 'HTML-Controls',
        dist_abstract       => <<'END_ABSTRACT',
A library of controls/widgets to use in HTML forms to separate
'external' (i.e. in the HTML) representation from 'internal' (i.e. in
the program) representation.
END_ABSTRACT
        dist_author         => 'Gianni Ceccarelli <dakkar@thenautilus.net>',
        dist_version_from   => 'lib/HTML/Controls.pm',
        requires            => {
                                'Module::Pluggable::Fast' => 0,
                                'Template' => 2.14,
                                'Path::Class' => 0,
                                'Date::Parse' => 0,
                                'Regexp::Common' => 0,
                                'Carp' => 0,
                               },
        build_requires      => {
                                'Test::More' => 0,
                                'Test::Exception' => 0,
                                'Test::MockObject' => 0,
                                'Data::Dumper' => 0,
                               },
        add_to_cleanup      => [ 'HTML-Controls-*' ],
        create_makefile_pl  => 'traditional',
        create_packlist     => 1,
        recursive_test_files=> 1,
        sign                => 1,
);

# this hack is to allow Test::Prereq to work
$builder->add_build_element('wt') if $builder->isa('Module::Build');

$builder->create_build_script();
