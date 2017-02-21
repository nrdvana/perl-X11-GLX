#! /usr/bin/env perl

use strict;
use warnings;
use Test::More;

use_ok('X11::GLX');
use_ok('X11::GLX::DWIM');

my $x= X11::GLX::DWIM->new->visualinfo;
use DDP;
p $x;

done_testing;
