package X11::GLX::Context::Imported;
require X11::GLX;
# ABSTRACT - Wrapper for GLXContext which were imported using glXImportContextEXT
1;
__END__

=head1 DESCRIPTION

A GLXContext imported using L<X11::GLX::glXImportContextEXT>, since it needs
special cleanup.

=cut
