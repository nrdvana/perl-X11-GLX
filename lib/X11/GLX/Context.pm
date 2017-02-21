package X11::GLX::Context;
require X11::GLX;
# ABSTRACT - Opaque wrapper for GLXContext pointer
1;
__END__

=head1 DESCRIPTION

GLXContext is an opaque object used by the GLX API to reference the collection
of state used for OpenGL rendering, usually by one thread onto one X11 window.

This object has no methods, since the C<glX*> methods also require
a L<Display*|X11::Xlib> argument.  See L<X11::GLX::DWIM> for a convenient
object-oriented interface to GLX that performs the things you probably want
it to do.

=cut
