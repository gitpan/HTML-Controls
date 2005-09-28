use Test::More;
plan skip_all => 'Set $ENV{DEVEL_TEST}=1 to force this test' unless $ENV{DEVEL_TEST};
eval "use Test::Pod 1.14";
plan skip_all => "Test::Pod 1.14 required for testing POD"
	if $@;
all_pod_files_ok();
