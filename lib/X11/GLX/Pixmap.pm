package X11::GLX::Pixmap;
use strict;
use warnings;
use parent 'X11::Xlib::Pixmap';

=head1 DESCRIPTION

Object representing a GLX Pixmap, which is built on top of an X pixmap.

=head1 ATTRIBUTES

Extends L<X11::Xlib::Pixmap> with:

=head2 x_pixmap

The X11 pixmap which this GLX pixmap is extending.

The GLX pixmap holds this reference to make sure the GLX pixmap is destroyed
before the X pixmap.

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
