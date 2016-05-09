import derelict.glfw3.glfw3;
import derelict.opengl3.gl3;
import beatslice;
import std.stdio;

void main()
{
	DerelictGL3.load();
	DerelictGLFW3.load();
	if(!glfwInit()) throw new Exception("GLFW initialization failed.");
	scope(exit) glfwTerminate();
	
	version(linux)
	{
		// For Intel Graphics(Forced to use OpenGL 3.3 Core Profile)
		glfwWindowHint(GLFW_CONTEXT_VERSION_MAJOR, 3);
		glfwWindowHint(GLFW_CONTEXT_VERSION_MINOR, 3);
		glfwWindowHint(GLFW_OPENGL_PROFILE, GLFW_OPENGL_CORE_PROFILE);
	}
	// glfwWindowHint(GLFW_DECORATED, GL_FALSE);
	
	Beatslice.main();
}
