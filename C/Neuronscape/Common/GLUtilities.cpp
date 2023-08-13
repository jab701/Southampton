#include "GLUtilities.h"

void GLErrorProcess()
{
	switch (glGetError())
	{
	case GL_INVALID_ENUM:
		wxLogError("GL_INVALID_ENUM");
		break;
	case GL_INVALID_VALUE:
		wxLogError("GL_INVALID_VALUE");
		break;
	case GL_INVALID_OPERATION:
		wxLogError("GL_INVALID_OPERATION");
		break;
	case GL_NO_ERROR:
		break;
	case GL_STACK_OVERFLOW:
		wxLogError("GL_STACK_OVERFLOW");
		break;
	case GL_STACK_UNDERFLOW:
		wxLogError("GL_STACK_UNDERFLOW");
		break;
	case GL_OUT_OF_MEMORY:
		wxLogError("GL OUT OF MEMORY");
		break;
	}
}