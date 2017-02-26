#! /usr/bin/env perl

use strict;
use warnings;
use Test::More tests => 17;
use X11::Xlib;
use X11::GLX ':all';

ok( my $dpy= X11::Xlib->new, 'X11 connection' );

ok( glXQueryVersion($dpy, my ($major, $minor)), 'glXQueryVersion' );
ok( $major > 0 && $minor > 0, 'returned version' );
note "GLX Version $major.$minor";

ok( my $ext= glXQueryExtensionsString($dpy), 'glxQueryExtensionsString' );
note "GLX Extensions: $ext";

# TODO: add skip logic for whether these should exist, and whether we could get
#  a shared context
ok( my $vis= glXChooseVisual($dpy), 'glXChooseVisual' );
ok( my $cx= glXCreateContext($dpy, $vis, undef, 0), 'glXCreateContext' );
$dpy->XFlush;
ok( my $pix= $dpy->new_pixmap($dpy->screen, 50, 50, $vis->depth), 'XCreatePixmap' );
ok( my $glpix= glXCreateGLXPixmap($dpy, $vis, $pix), 'XCreateGLXPixmap' );
$dpy->XFlush;
ok( glXMakeCurrent($dpy, $glpix, $cx), 'glXMakeCurrent' );
ok( my $cx_id= glXGetContextIDEXT($cx), 'glXGetContextIDEXT' );
$dpy->XFlush;

defined ( my $pid= fork() ) or die "fork: $!";

if (!$pid) {
	bless $dpy, 'Nothing';
	bless $cx, 'Nothing';
	ok( my $dpy2= X11::Xlib->new, 'new X11::Xlib' );
	ok( my $remote_cx= glXImportContextEXT($dpy2, $cx_id), 'glXImportContextEXT' );
	isa_ok( $remote_cx, 'X11::GLX::Context::Imported', 'remote_cx' );
	isa_ok( $remote_cx, 'X11::GLX::Context', 'remote_cx' );
	is( glXQueryContextInfoEXT($dpy2, $remote_cx, GLX_VISUAL_ID_EXT, my $vis2), 0, 'glXQueryContextInfoEXT' );
	ok( $vis2, 'got a visual' ) or diag explain $vis2;
	$vis2= $vis2? $dpy2->visual_info($vis2) : $vis;
	ok( my $cx2= glXCreateContext($dpy2, $vis2, $remote_cx, 0), 'child glXCreateContext' );
	glXFreeContextEXT($remote_cx);
	glXDestroyContext($dpy2, $cx2);
}
wait;
glXDestroyContext($dpy, $cx);
