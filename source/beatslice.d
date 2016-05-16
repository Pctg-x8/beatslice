import derelict.glfw3.glfw3;
import objectivegl, textrender, renderhelper;
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
	
	enum PointingState
	{
		Free,
		ReadyForPaneResize,
		PaneResizing
	}
	
	private GLFWwindow* pWindow;
	private Tuple!(int, int) size;
	private GLFWcursor* cursorArrow, cursorHorzResize, cursorTextRange;
	private PointingState pstate;
	private RenderHelper.Viewport vpEntire;
	
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
		this.cursorTextRange = glfwCreateStandardCursor(GLFW_IBEAM_CURSOR);
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
		
		ScoreView.init();
		RightPane.init();
		
		this.vpEntire = new RenderHelper.Viewport(0.0f, 0.0f, 100.0f, 100.0f);
		
		this.onResizeFrame(this.size.expand);
		GLDevice.RasterizerState.Blending = true;
		GLDevice.RasterizerState.BlendFunc = BlendFunctions.Alpha;
		GLDevice.RasterizerState.ScissorTest = true;
		GLDevice.RasterizerState.BackCulling = false;
		GLDevice.RasterizerState.DepthTest = false;
		GLDevice.RasterizerState.DepthClamp = false;
		while(!glfwWindowShouldClose(this.pWindow)) glfwWaitEvents();
	}
	
	static extern(C) void onRenderNative(GLFWwindow*) nothrow { try { Beatslice.onRender(); } catch(Throwable e) {} }
	static extern(C) void onResizeFrameNative(GLFWwindow*, int w, int h) nothrow { try { Beatslice.onResizeFrame(w, h); } catch(Throwable e) {} }
	static extern(C) void onCursorMoveNative(GLFWwindow*, double x, double y) nothrow { try { Beatslice.onCursorMove(x, y); } catch(Throwable e) {} }
	static extern(C) void onMouseEventNative(GLFWwindow*, int b, int a, int m) nothrow { try { Beatslice.onMouseEvent(b, a, m); } catch(Throwable e) {} }
	private void onResizeFrame(int w, int h)
	{
		this.size = tuple(w, h);
		this.vpEntire.relocate(0.0f, 0.0f, w, h);
		RightPane.onResize(w - RightPane.width, 0.0f, RightPane.width, h);
	}
	// Render loop
	private void onRender()
	{
		// static csu = SceneCommonUniforms([1.0f, 1.0f, 1.0f, 1.0f], [1.0f, 1.0f, 1.0f, 0.1875f]);
		
		RenderHelper.Viewport.current = this.vpEntire;
		// csu.commonColor = [1.0f, 1.0f, 1.0f, 0.1875f];
		// this.sceneCommonBuffer.update(csu);
		ScoreView.draw(this.size[1]);
		
		RightPane.draw();
		
		glfwSwapBuffers(pWindow);
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
				if(RightPane.inCursorTextRange(x - (this.size[0] - RightPane.width), y))
				{
					this.pWindow.glfwSetCursor(this.cursorTextRange);
				}
				else
				{
					this.pWindow.glfwSetCursor(this.cursorArrow);
				}
				this.pstate = PointingState.Free;
			}
		}
		void resizePane()
		{
			this.pWindow.glfwSetCursor(this.cursorHorzResize);
			RightPane.width = cast(int)max(this.size[0] - max(x, 96.0f), 96.0f);
			RightPane.onResize(this.size[0] - RightPane.width, 0.0f, RightPane.width, this.size[1]);
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
}
alias Beatslice = Beatslice_.instance;