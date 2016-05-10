import derelict.glfw3.glfw3;
import objectivegl;
import shaderstock, bindingpoints, textureatlas, scoreview, rightpane;
import std.typecons;
import std.math, std.algorithm;

// object Beatslice
final class Beatslice_
{
	private this(){}
	public static @property instance()
	{
		import std.concurrency;
		__gshared Beatslice_ o;
		return initOnce!o(new Beatslice_);
	}
	
	// Color Constants
	alias background_color = HexColor!0xff303030;
	
	struct SceneCommonUniforms
	{
		float[4] pixelScale;
		float[4] commonColor;
	}
	
	enum PointingState
	{
		Free,
		ReadyForPaneResize,
		PaneResizing
	}
	
	GLFWwindow* pWindow;
	Tuple!(int, int) size;
	UniformBuffer!SceneCommonUniforms sceneCommonBuffer;
	GLFWcursor* cursorArrow, cursorHorzResize;
	PointingState pstate;
	VertexArray a_vts;
	
	private auto initFrame()
	{
		this.pWindow = glfwCreateWindow(640, 480, "beatslice", null, null);
		if(this.pWindow is null) throw new Exception("GLFW window creation failed.");
		glfwMakeContextCurrent(this.pWindow);
		DerelictGL3.reload();
		glfwSwapInterval(0);
		
		int w, h;
		glfwGetFramebufferSize(this.pWindow, &w, &h);
		this.size = tuple(w, h);
		
		this.cursorArrow = glfwCreateStandardCursor(GLFW_ARROW_CURSOR);
		this.cursorHorzResize = glfwCreateStandardCursor(GLFW_HRESIZE_CURSOR);
		this.pstate = PointingState.Free;
		
		return this;
	}
	private auto registerCallbacks()
	{
		pWindow.glfwSetWindowRefreshCallback(&Beatslice_.onRenderNative);
		pWindow.glfwSetFramebufferSizeCallback(&Beatslice_.onResizeFrameNative);
		pWindow.glfwSetCursorPosCallback(&Beatslice_.onCursorMoveNative);
		pWindow.glfwSetMouseButtonCallback(&Beatslice_.onMouseEventNative);
		return this;
	}
	public void main()
	{
		this.initFrame().registerCallbacks();
		ShaderStock.init();
		TextureAtlas.init();
		
		this.sceneCommonBuffer = UniformBuffer!SceneCommonUniforms.newStatic();
		GLDevice.BindingPoint[UniformBindingPoints.SceneCommon] = this.sceneCommonBuffer;
		ScoreView.init();
		
		TexturedVertex[] h_vts;
		float left = 8.0f;
		foreach(x; "Hello, world!".map!(x => TextureAtlas.addCharacter(x)))
		{
			h_vts ~= [
				TexturedVertex([left + x.xBearing, x.yBearing], [x.u1, x.v1]),
				TexturedVertex([left + x.xBearing, x.yBearing + x.height], [x.u1, x.v2]),
				TexturedVertex([left + x.xBearing + x.width, x.yBearing + x.height], [x.u2, x.v2]),
				TexturedVertex([left + x.xBearing + x.width, x.yBearing + x.height], [x.u2, x.v2]),
				TexturedVertex([left + x.xBearing, x.yBearing], [x.u1, x.v1]),
				TexturedVertex([left + x.xBearing + x.width, x.yBearing], [x.u2, x.v1])
			];
			left += x.horiAdvance;
		}
		this.a_vts = VertexArray.fromSlice(h_vts, ShaderStock.charRender);
		
		GLDevice.RasterizerState.Blending = true;
		GLDevice.RasterizerState.BlendFunc = BlendFunctions.Alpha;
		GLDevice.RasterizerState.ScissorTest = true;
		GLDevice.RasterizerState.BackCulling = false;
		while(!glfwWindowShouldClose(this.pWindow)) glfwWaitEvents();
	}
	
	static extern(C) void onRenderNative(GLFWwindow*) nothrow { try { Beatslice.onRender(); } catch(Throwable e) {} }
	static extern(C) void onResizeFrameNative(GLFWwindow*, int w, int h) nothrow { try { Beatslice.onResizeFrame(w, h); } catch(Throwable e) {} }
	static extern(C) void onCursorMoveNative(GLFWwindow*, double x, double y) nothrow { try { Beatslice.onCursorMove(x, y); } catch(Throwable e) {} }
	static extern(C) void onMouseEventNative(GLFWwindow*, int b, int a, int m) nothrow { try { Beatslice.onMouseEvent(b, a, m); } catch(Throwable e) {} }
	private void onResizeFrame(int w, int h)
	{
		this.size = tuple(w, h);
	}
	private void onCursorMove(double x, double y)
	{
		void updateCursor()
		{
			immutable diff = x - (this.size[0] - RightPane.width);
			if(abs(diff) <= 2.0f)
			{
				this.pWindow.glfwSetCursor(this.cursorHorzResize);
				this.pstate = PointingState.ReadyForPaneResize;
			}
			else
			{
				this.pWindow.glfwSetCursor(this.cursorArrow);
				this.pstate = PointingState.Free;
			}
		}
		void resizePane()
		{
			this.pWindow.glfwSetCursor(this.cursorHorzResize);
			RightPane.width = cast(int)max(this.size[0] - max(x, 32.0f), 32.0f);
			this.onRender();
		}
		
		final switch(this.pstate)
		{
		case PointingState.Free: case PointingState.ReadyForPaneResize:
			updateCursor(); break;
		case PointingState.PaneResizing:
			resizePane(); break;
		}
	}
	private void onMouseEvent(int button, int action, int modkeys)
	{
		if(action == GLFW_PRESS)
		{
			// Press Event
			if(this.pstate == PointingState.ReadyForPaneResize)
			{
				// Start Dragging
				this.pstate = PointingState.PaneResizing;
			}
		}
		else if(action == GLFW_RELEASE)
		{
			// Release Event
			if(this.pstate == PointingState.PaneResizing)
			{
				// End Dragging
				this.pstate = PointingState.ReadyForPaneResize;
			}
		}
	}
	// Render loop
	private void onRender()
	{
		static csu = SceneCommonUniforms([1.0f, 1.0f, 1.0f, 1.0f], [1.0f, 1.0f, 1.0f, 0.1875f]);
		
		csu.commonColor[3] = 0.1875f;
		csu.pixelScale[1] = 2.0f / this.size[1];
		
		csu.pixelScale[0] = 2.0f / (this.size[0] - RightPane.width);
		this.sceneCommonBuffer.update(csu);
		glViewport(0, 0, this.size[0] - RightPane.width, this.size[1]);
		glScissor(0, 0, this.size[0] - RightPane.width, this.size[1]);
		ScoreView.draw(this.size[0] - RightPane.width, this.size[1]);
		
		csu.pixelScale[0] = 2.0f / RightPane.width;
		this.sceneCommonBuffer.update(csu);
		glViewport(this.size[0] - RightPane.width, 0, RightPane.width, this.size[1]);
		glScissor(this.size[0] - RightPane.width, 0, RightPane.width, this.size[1]);
		RightPane.draw(this.size[1]);
		
		csu.commonColor[3] = 1.0f;
		this.sceneCommonBuffer.update(csu);
		ShaderStock.charRender.activate();
		GLDevice.TextureUnits[0] = TextureAtlas.texture;
		ShaderStock.charRender.uniforms.intex = 0;
		this.a_vts.drawInstanced!GL_TRIANGLES(1);
		
		// GLDevice.TextureUnits[0] = TextureAtlas.texture;
		
		glfwSwapBuffers(pWindow);
	}
}
alias Beatslice = Beatslice_.instance;