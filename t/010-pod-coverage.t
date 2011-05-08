#!/usr/bin/env perl

use strict;
use warnings;

use Test::More;

if ( not $ENV{TEST_AUTHOR} ) {
    my $msg = 'Author test.  Set $ENV{TEST_AUTHOR} to a true value to run.';
    plan( skip_all => $msg );
}

eval "use Test::Pod::Coverage 1.04"; ## no critic (ProhibitStringyEval)
plan skip_all => "Test::Pod::Coverage 1.04 required for testing POD coverage" if $@;

all_pod_coverage_ok
  (
   {
    also_private => [
                     # ..
                    ]
   }
  );
