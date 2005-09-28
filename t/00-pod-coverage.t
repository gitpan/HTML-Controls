use Test::More;
plan skip_all => 'Set $ENV{DEVEL_TEST}=1 to force this test' unless $ENV{DEVEL_TEST};
eval "use Test::Pod::Coverage 1.04";
plan skip_all => "Test::Pod::Coverage 1.04 required for testing POD coverage"
	if $@;
all_pod_coverage_ok();
