#!/usr/bin/env perl

use strict;
use warnings;
use Test::More;
use Try::Tiny;
use X11::Xlib ':all';
use X11::GLX ':all';
use FindBin;
use lib "$FindBin::Bin/lib";
use X11::SandboxServer;

plan skip_all => 'Xcomposite client lib is not available'
    unless X11::Xlib->can('XCompositeVersion');

my $x= try { X11::SandboxServer->new(title => $FindBin::Script) };
plan skip_all => 'Need Xephyr to run compositor tests'
    unless defined $x;

my $client= $x->connection;
plan skip_all => 'Xcomposite not supported by server'
    unless $client->XCompositeQueryVersion;

my $ext= glXQueryExtensionsString($client);
plan skip_all => 'GLX_EXT_texture_from_pixmap not supported by server'
	unless $ext =~ /GLX_EXT_texture_from_pixmap/;

sub err(&) { my $code= shift; my $ret; { local $@= ''; eval { $code->() }; $client->flush_sync; $ret= $@; } $ret }

my ($root, $overlay, $region);
note "local Xc ver = ".X11::Xlib::XCompositeVersion." server Xc ver = ".join('.', $client->XCompositeQueryVersion);
is( err{ $root= $client->root_window }, '', 'get root window' );
note "root = $root";
is( err{ $client->XCompositeRedirectSubwindows($root, CompositeRedirectAutomatic) }, '', 'XCompositeRedirectSubwindows' );
is( err{ $client->XSelectInput($root, SubstructureNotifyMask) }, '', 'XSelectInput' );
is( err{ $overlay= $client->XCompositeGetOverlayWindow($root) }, '', 'XCompositeGetOverlayWindow' );
note "overlay = $overlay";

my $client2;
if ($ENV{TEST_APP}) {
	local $ENV{DISPLAY}= $x->display_string;
	open $client2, '|-', $ENV{TEST_APP} or die "open pipe from '$ENV{TEST_APP}': $!";
} else {
	$client2= X11::Xlib->new(connect => ':'.$x->display_string);
	$client2->new_window(x => 1, y => 1, width => 50, height => 50);
	$client2->flush;
}

my $start= time;
while (time - $start < 10) {
	while (my $e= $client->wait_event(timeout => 1)) {
		if ($e->type == CreateNotify) {
			my $w= $e->window;
			next if $w == $overlay;
			note "Window created: $w";
			$client->XGetWindowAttributes($w, my $attrs);
			next if $attrs->class == InputOnly;
			
		}
	}
	
}

done_testing;
