#!/usr/bin/env perl

use strict;
use warnings;

use Test::More tests => 1;
use Test::Exception;
use Term::VTerm;

{
    lives_ok { Term::VTerm->new; } 'new() method survived';

}


done_testing;
