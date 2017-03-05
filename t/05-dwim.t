#! /usr/bin/env perl

use strict;
use warnings;
use Test::More;
use X11::Xlib;
use X11::GLX::DWIM;
use Log::Any::Adapter 'TAP';
use OpenGL ':all';

my $dwim= new_ok( 'X11::GLX::DWIM', [ gl_projection => {} ] );
$dwim->display;
$dwim->glx_context;
$dwim->target;

for (1..60) {
	$dwim->begin_frame;
	glLoadIdentity();
	glTranslated(0,0,10);
	glDisable(GL_TEXTURE_2D);
	glColor4d(1,1,1,1);
	glRotated($_*4, 1, 1, 1);
	cube();
	$dwim->end_frame;
}

my $cube_dlist;
sub cube {
	if ($cube_dlist) {
		glCallList($cube_dlist);
	} else {
		$cube_dlist= glGenLists(1);
		glNewList($cube_dlist, GL_COMPILE_AND_EXECUTE);
		glBegin(GL_QUADS);
		glTexCoord2d(0,0); glVertex3d(0,0,1); # front
		glTexCoord2d(1,0); glVertex3d(1,0,1);
		glTexCoord2d(1,1); glVertex3d(1,1,1);
		glTexCoord2d(0,1); glVertex3d(0,1,1);
		glTexCoord2d(0,0); glVertex3d(1,0,1); # right
		glTexCoord2d(1,0); glVertex3d(1,0,0);
		glTexCoord2d(1,1); glVertex3d(1,1,0);
		glTexCoord2d(0,1); glVertex3d(1,1,1);
		glTexCoord2d(0,0); glVertex3d(0,0,0); # back
		glTexCoord2d(1,0); glVertex3d(0,1,0);
		glTexCoord2d(1,1); glVertex3d(1,1,0);
		glTexCoord2d(0,1); glVertex3d(1,0,0);
		glTexCoord2d(0,0); glVertex3d(0,0,0); # left
		glTexCoord2d(1,0); glVertex3d(0,0,1);
		glTexCoord2d(1,1); glVertex3d(0,1,1);
		glTexCoord2d(0,1); glVertex3d(0,1,0);
		glTexCoord2d(0,0); glVertex3d(0,1,0); # top
		glTexCoord2d(1,0); glVertex3d(0,1,1);
		glTexCoord2d(1,1); glVertex3d(1,1,1);
		glTexCoord2d(0,1); glVertex3d(1,1,0);
		glTexCoord2d(0,0); glVertex3d(0,0,0); # bottom
		glTexCoord2d(1,0); glVertex3d(1,0,0);
		glTexCoord2d(1,1); glVertex3d(1,0,1);
		glTexCoord2d(0,1); glVertex3d(0,0,1);
		glEnd();
		glEndList();
	}
}

done_testing;
