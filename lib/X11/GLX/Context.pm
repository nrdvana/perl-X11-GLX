package X11::GLX::Context;

require X11::GLX; # all comes from XS.  don't need to load this file.

# ABSTRACT: Opaque wrapper for GLXContext pointer

=head1 DESCRIPTION

GLXContext is an opaque object used by the GLX API to reference the collection
of state used for OpenGL rendering, usually by one thread onto one X11 window.

The only method you can call on this object is "xid", since that is the only
GLX function that doesn't also require a handle to the display.

See L<X11::GLX::DWIM> for a convenient object-oriented interface to GLX that
performs the things you probably want it to do.

=head1 ATTRIBUTES

=head2 id

The X11 ID of the GLX context.  This is not available unless you have the
GLX_EXT_import_context extension.

=cut

1;
