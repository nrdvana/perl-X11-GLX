package X11::GLX;
use strict;
use warnings;
use X11::Xlib;

# ABSTRACT - GLX API (OpenGL on X11)

our $VERSION= '0.00_00';

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

=for Pod::Coverage GLX_SCREEN_EXT GLX_VISUAL_ID_EXT GLX_ALPHA_SIZE GLX_BLUE_SIZE GLX_DOUBLEBUFFER GLX_GREEN_SIZE GLX_RED_SIZE GLX_RGBA GLX_USE_GL

=head3 glXQueryVersion

  X11::GLX::glXQueryVersion($display, my ($major, $minor))
	or die "glXQueryVersion	failed";
  print "GLX Version $major.$minor\n";

=head3 glXQueryExtensionsString

  my $str= glXQueryExtensionsString($display, $screen_num);
  my $str= glXQueryExtensionsString($display); # default screen
  
Get a string of all the GL extensions available.

=head3 glXChooseVisual

  my $vis_info= glXChooseVisual($display, $screen, \@attributes);
  my $vis_info= glXChooseVisual($display, $screen);
  my $vis_info= glXChooseVisual($display); # default screen

This function picks an OpenGL-compatible visual.  C<@attributes> is an array
of integers (see GLX documentation).  The terminating "None" is added
automatically.  If undefined, this module uses a default of:

  [ GLX_USE_GL, GLX_RGBA, GLX_DOUBLEBUFFER,
    GLX_RED_SIZE, 8, GLX_GREEN_SIZE, 8, GLX_BLUE_SIZE, 8, GLX_ALPHA_SIZE, 8 ]

=head3 glXCreateContext

  my $context= glXCreateContext($display, $visual_info, $shared_with, $direct);

C<$visual_info> is an instance of L<XVisualInfo|X11::Xlib::XVisualInfo>, most
likely returned by L<glXChooseVisual>.

C<$shared_with> is an optional L<X11::GLX::GLXContext> with which to share
display lists, and possibly other objects like textures.
This feature is somewhat of a niche use-case, either for sharing objects
between contexts owned by two threads of the same program, or to share objects
on indirect contexts (hosted by the X11 server) between two programs using
L</Extension GLX_EXT_import_context>.

C<$direct> is a boolean indicating whether you would like a direct rendering
context.  i.e. have the application directly open a handle to the graphics
hardware that bypasses X11 protocol.  You are not guaranteed to get a direct
context if setting it to true, and indeed won't if you are connected to a
remote X11 server.  However if you set it to false this call may fail entirely
if you are connected to a X11 server which has disabled indirect rendering.

=head3 glXMakeCurrent

  glXMakeCurrent($display, $drawable, $glcontext)
    or die "glXMakeCurrent failed";

Set the target drawable (window or GLX pixmap) to which this GL context should
render.  Note that pixmaps must have been created with L</glXCreateGLXPixmap>
and can't be just regular X11 pixmaps.

=head3 glXSwapBuffers

  glXSwapBuffers($display, $glxcontext)

For a double-buffered drawable, show the back buffer and begin rendering to
the former front buffer.

=head3 glXDestroyContext

  glXDestroyContext($display, $glxcontext);

Destroy a context created by glXCreateContext.  This destroys it on the server
side.

=head3 glXCreateGLXPixmap

  my $glxpixmap= glXCreateGLXPixmap($display, $visualinfo, $pixmap)

Create a new pixmap from an existing pixmap which has the extra GLX baggage
necessary to use it as a rendering target.

=head3 glXDestroyGLXPixmap

  glXDestroyGLXPixmap($display, $glxpixmap)

Free a GLX pixmap.  You need to call this function instead of the usual
XDestroyPixmap.

=head2 Extension GLX_EXT_import_context

These functions are only available if C<X11::GLX::glXQueryExtensionsString>
includes "GLX_EXT_import_context".

=head3 glXGetContextIDEXT

  my $xid= glXGetContextIDEXT($glxcontext)

Returns the X11 display object ID of the GL context.  This XID can be passed
to L</glXImportContextEXT> by any other process to get a GLXContext pointer
in their address space for this context.

=head3 glXImportContextEXT

  my $glx_context= glXImportContextEXT($display, $context_xid);

Create a local GLXContext data structure that references a shared indirect
GLXContext on the X11 server.

=head3 glXFreeContextEXT

  glXFreeContextEXT($glx_context);

Free the context data structures created by L</glXImportContextEXT>.

=head3 glXQueryContextInfoEXT

  glXQueryContextInfoEXT($display, $glxcontext, $attr, my $attr_val)
	or die "glXQueryContextInfoEXT failed";

Retrieve the value of an attribute of the GLX Context.  The attribute is
returned in the final argument.  The return value is a boolean indicating
success.

Attributes:

  GLX_VISUAL_ID_EXT      - Returns the XID of the GLX Visual associated with ctx.
  GLX_SCREEN_EXT         - Returns the screen number associated with ctx.

=cut
