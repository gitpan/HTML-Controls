use Test::More tests => 1;

# This loads all widgets in one pass
BEGIN {
  use_ok('HTML::Controls');
}

diag( "Testing HTML::Controls $HTML::Controls::VERSION" );
