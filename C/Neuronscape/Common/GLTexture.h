#ifndef _GLTexture_
#define _GLTexture_
 
// include OpenGL
#ifdef __WXMAC__
#include "OpenGL/gl.h"
#else
//#include <GL/gl.h>
#endif
 
#ifdef __WXMAC__
#include "OpenGL/gl.h"
#else
//#include <GL/gl.h>
#endif
#include <wx/wx.h>
#include <wx/image.h>
#include <wx/glcanvas.h>

#include <GL/glu.h>

#include <cmath>
#include <stdint.h>

#include "GLUtilities.h"

class GLTexture
{
public:
    GLTexture();
    GLTexture(wxString path);
	~GLTexture(); 
	/*
	 * it is preferable to use textures that are a power of two. this loader will automatically
	 * resize texture to be a power of two, filling the remaining areas with black.
	 * width/height are the width of the actual loaded image.
	 * textureWidth/Height are the total width of the texture, including black filling.
	 * tex_coord_x/y are the texture coord parameter you must give OpenGL when rendering
	 * to get only the image, without the black filling.
	 */
	GLuint* getID();
    void load(wxString path);

private:
	GLuint* loadImage(wxString path, int* imageWidth, int* imageHeight, int* textureWidth, int* textureHeight);

	GLuint* ID;	
	int width, height, textureWidth, textureHeight;
    float tex_coord_x, tex_coord_y;
};
  
#endif 
