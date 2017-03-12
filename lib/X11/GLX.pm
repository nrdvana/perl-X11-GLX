package X11::GLX;
use strict;
use warnings;
use X11::Xlib 0.09;

# ABSTRACT - GLX API (OpenGL on X11)

our $VERSION= '0.00_03';

use Exporter 'import';
our %EXPORT_TAGS= (
# BEGIN GENERATED XS CONSTANT LIST
  const_cx_attr => [qw( GLX_SCREEN_EXT GLX_VISUAL_ID_EXT )],
  const_vis_attr => [qw( GLX_ALPHA_SIZE GLX_BLUE_SIZE GLX_DOUBLEBUFFER
    GLX_GREEN_SIZE GLX_RED_SIZE GLX_RGBA GLX_USE_GL )],
# END GENERATED XS CONSTANT LIST
# BEGIN GENERATED XS FUNCTION LIST
  fn_import_cx => [qw( glXFreeContextEXT glXGetContextIDEXT glXImportContextEXT
    glXQueryContextInfoEXT )],
  fn_std => [qw( glXChooseVisual glXCreateContext glXCreateGLXPixmap
    glXDestroyContext glXDestroyGLXPixmap glXMakeCurrent
    glXQueryExtensionsString glXQueryVersion glXSwapBuffers )],
# END GENERATED XS FUNCTION LIST
);
our @EXPORT_OK= map { @$_ } values %EXPORT_TAGS;
$EXPORT_TAGS{functions}= [ grep { /^glX'/ } @EXPORT_OK ];
$EXPORT_TAGS{constants}= [ grep { /^GLX/ } @EXPORT_OK ];
$EXPORT_TAGS{all}= \@EXPORT_OK;

require XSLoader;
XSLoader::load('X11::GLX', $VERSION);

BEGIN { @X11::GLX::Context::Imported::ISA= ('X11::GLX::Context'); }
require X11::GLX::Pixmap;

__END__

=head1 DESCRIPTION

This module acts as an extension to L<X11::Xlib>, providing the API that
sets up OpenGL on X11.  The L<OpenGL> perl module can provide some of this
API, but doesn't in it's default configuration.

This is the C-style API.  For something more friendly, see L<X11::GLX::DWIM>.

=head1 METHODS

=for Pod::Coverage GLX_SCREEN_EXT GLX_VISUAL_ID_EXT GLX_ALPHA_SIZE GLX_BLUE_SIZE GLX_DOUBLEBUFFER GLX_GREEN_SIZE GLX_RED_SIZE GLX_RGBA GLX_USE_GL

=head2 glXQueryVersion

  X11::GLX::glXQueryVersion($display, my ($major, $minor))
	or die "glXQueryVersion	failed";
  print "GLX Version $major.$minor\n";

=head2 glXQueryExtensionsString

  my $str= glXQueryExtensionsString($display, $screen_num);
  my $str= glXQueryExtensionsString($display); # default screen
  
Get a string of all the GL extensions available.

=head2 glXChooseVisual

  my $vis_info= glXChooseVisual($display, $screen, \@attributes);
  my $vis_info= glXChooseVisual($display, $screen);
  my $vis_info= glXChooseVisual($display); # default screen

This function picks an OpenGL-compatible visual.  C<@attributes> is an array
of integers (see GLX documentation).  The terminating "None" is added
automatically.  If undefined, this module uses a default of:

  [ GLX_USE_GL, GLX_RGBA, GLX_DOUBLEBUFFER,
    GLX_RED_SIZE, 8, GLX_GREEN_SIZE, 8, GLX_BLUE_SIZE, 8, GLX_ALPHA_SIZE, 8 ]

=head2 glXCreateContext

  my $context= glXCreateContext($display, $visual_info, $shared_with, $direct);

C<$visual_info> is an instance of L<XVisualInfo|X11::Xlib::XVisualInfo>, most
likely returned by L<glXChooseVisual>.

C<$shared_with> is an optional L<X11::GLX::GLXContext> with which to share
display lists, and possibly other objects like textures.  See L</Shared GL Contexts>.

C<$direct> is a boolean indicating whether you would like a direct rendering
context.  i.e. have the application directly open a handle to the graphics
hardware that bypasses X11 protocol.  You are not guaranteed to get a direct
context if setting it to true, and indeed won't if you are connected to a
remote X11 server.  However if you set it to false this call may fail entirely
if you are connected to a X11 server which has disabled indirect rendering.

=head2 glXMakeCurrent

  glXMakeCurrent($display, $drawable, $glcontext)
    or die "glXMakeCurrent failed";

Set the target drawable (window or GLX pixmap) to which this GL context should
render.  Note that pixmaps must have been created with L</glXCreateGLXPixmap>
and can't be just regular X11 pixmaps.

=head2 glXSwapBuffers

  glXSwapBuffers($display, $glxcontext)

For a double-buffered drawable, show the back buffer and begin rendering to
the former front buffer.

=head2 glXDestroyContext

  glXDestroyContext($display, $glxcontext);

Destroy a context created by glXCreateContext.  This destroys it on the server
side.

=head2 glXCreateGLXPixmap

  my $glxpixmap= glXCreateGLXPixmap($display, $visualinfo, $pixmap)

Create a new pixmap from an existing pixmap which has the extra GLX baggage
necessary to use it as a rendering target.

=head2 glXDestroyGLXPixmap

  glXDestroyGLXPixmap($display, $glxpixmap)

Free a GLX pixmap.  You need to call this function instead of the usual
XDestroyPixmap.

=head1 Extension GLX_EXT_import_context

These functions are only available if C<X11::GLX::glXQueryExtensionsString>
includes "GLX_EXT_import_context".  See L</Shared GL Contexts>.

=head2 glXGetContextIDEXT

  my $xid= glXGetContextIDEXT($glxcontext)

Returns the X11 display object ID of the GL context.  This XID can be passed
to L</glXImportContextEXT> by any other process to get a GLXContext pointer
in their address space for this context.

=head2 glXImportContextEXT

  my $glx_context= glXImportContextEXT($display, $context_xid);

Create a local GLXContext data structure that references a shared indirect
GLXContext on the X11 server.

=head2 glXFreeContextEXT

  glXFreeContextEXT($glx_context);

Free the context data structures created by L</glXImportContextEXT>.

=head2 glXQueryContextInfoEXT

  glXQueryContextInfoEXT($display, $glxcontext, $attr, my $attr_val)
	or die "glXQueryContextInfoEXT failed";

Retrieve the value of an attribute of the GLX Context.  The attribute is
returned in the final argument.  The return value is a boolean indicating
success.

Attributes:

  GLX_VISUAL_ID_EXT      - Returns the XID of the GLX Visual associated with ctx.
  GLX_SCREEN_EXT         - Returns the screen number associated with ctx.

=head1 Shared GL Contexts

Sometimes you want to let more than one thread or process access the same
OpenGL objects, like Display Lists, Textures, etc.
For threads, all you have to do is pass the first thread's context pointer to
glXCreateContext for the second thread.

For processes, it is more difficult.  To set it up, each process must create
an indirect context (to the same Display obviously), and the server and both
clients must support the extension C<GLX_EXT_import_context>.  Client #1
creates an indirect context, finds the ID, passes that to Client #2 via some
method, then client #2 imports the context, then creates a new context
shared with the imported one, then frees the imported one.  To make a long
story short, see test case C<03-import-context.t> for an example.

Note that many distros have started disabling indirect mode (as of 2016) for
OpenGL on Xorg, for security concerns.  You can enable it by passing "+iglx"
to the Xorg command line.  (finding where to specify the commandline for Xorg
can be an exercise in frustration... good luck.  On Linux Mint it is found in
/etc/X11/xinit/xserverrc.  The quick and dirty approach is to rename the Xorg
binary and stick a script in its place that exec's the original with the
desired command line.)

=cut
