package X11::GLX::Context::Imported;
# All details are handled by XS or parent class
require X11::GLX::Context;

# ABSTRACT: Wrapper for GLXContext which were imported using glXImportContextEXT

=head1 DESCRIPTION

A GLXContext imported using L<X11::GLX::glXImportContextEXT>.
Imported contexts need special cleanup.

=cut

1;
