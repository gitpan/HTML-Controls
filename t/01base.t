#!/usr/bin/perl
use Test::More tests=>2;

BEGIN {use_ok('HTML::Controls')}

ok(HTML::Controls->controls(),'carica cosi');
