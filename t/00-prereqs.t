use Test::More;
plan skip_all => 'Set $ENV{DEVEL_TEST}=1 to force this test' unless $ENV{DEVEL_TEST};
eval "use Test::Prereq::Build";
plan skip_all => "Test::Prereq::Build required to test dependencies" if $@;
prereq_ok();
