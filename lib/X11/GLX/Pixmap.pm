package X11::GLX::Pixmap;

use strict;
use warnings;
use parent 'X11::Xlib::Pixmap';

# ABSTRACT: Object representing a GLX Pixmap

=head1 DESCRIPTION

GLX Pixmaps are built on top of a normal X pixmap by calling
L<X11::GLX/glXCreateGLXPixmap>, which attaches some buffers needed by OpenGL
and returns a new X11 resource ID.  The pixmap can then be a rendering target.

The pixmap must also be freed with L<X11::GLX/glXDestroyGLXPixmap>, which this
module handles.

=head1 ATTRIBUTES

Extends L<X11::Xlib::Pixmap> with:

=head2 x_pixmap

The X11 pixmap which this GLX pixmap is extending.

This GLX pixmap wrapper holds a reference to the X pixmap to make sure it
isn't destroyed until after the GLX pixmap.

=cut

sub x_pixmap { my $self= shift; if (@_) { $_->{x_pixmap}= shift; } $_->{x_pixmap} }

sub DESTROY {
    my $self= shift;
    if ($self->autofree && $self->xid) {
        X11::GLX::glXDestroyGLXPixmap($self->display, $self->xid);
        delete $self->{xid}; # make sure parent constructor doesn't run
    }
}

1;
