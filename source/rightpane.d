import objectivegl;
import shaderstock, bindingpoints;
import textrender, renderhelper;

final class RightPane_
{
	private this(){}
	public static @property instance()
	{
		import std.concurrency;
		__gshared RightPane_ o;
		return initOnce!o(new RightPane_);
	}
	
	struct InstanceTranslationArrayData
	{
		ShaderVec4[2] offsets;
	}
	
	// Color constants
	alias BackgroundColor = HexColor!0xff303030;
	alias InputBorderColor = HexColor!0xff4080c0;
	alias InputFillColor = HexColor!0xff101010;
	alias TextColor = HexColor!0xffffffff;
	alias PlaceholderTextColor = HexColor!0x60ffffff;
	
	public uint width;
	private VertexArray border_vertices, fill_vertices;
	private UniformBuffer!InstanceTranslationArrayData instanceTranslationBuffer;
	private InstanceTranslationArrayData inputBoxPositions;
	private RenderHelper.Viewport vpPane, vpListBoxEntire, vpListBoxInner;
	private UniformBuffer!UniformColorData cdText;
	private StringVertices materialHeader;
	private VertexArray[2] button_border_vertices;
	
	public void init()
	{
		this.width = 150;
		this.button_border_vertices[0] = VertexArray.fromSlice([
			SimpleVertex([-8.0f, 8.0f]), SimpleVertex([-8.0f, 16.0f]), SimpleVertex([-32.0f, 16.0f]),
			SimpleVertex([-32.0f, 8.0f]), SimpleVertex([-8.0f, 8.0f])
		], ShaderStock.pixelScaled);
		
		this.instanceTranslationBuffer = UniformBuffer!InstanceTranslationArrayData.newStatic();
		this.inputBoxPositions.offsets[0] = [0.0f, 40.0f, 0.0f, 0.0f];
		this.inputBoxPositions.offsets[1] = [0.0f, 64.0f, 0.0f, 0.0f];
		this.instanceTranslationBuffer.update(this.inputBoxPositions);
		
		this.vpPane = new RenderHelper.Viewport(0.0f, 0.0f, 100.0f, 100.0f);
		this.vpListBoxEntire = new RenderHelper.Viewport(0.0f, 0.0f, 100.0f, 100.0f);
		this.vpListBoxInner = new RenderHelper.Viewport(0.0f, 0.0f, 100.0f, 100.0f);
		this.cdText = UniformBufferFactory.newStatic(UniformColorData([TextColor]));
		this.materialHeader = StringVertices.make("Materials: ", 8, 4);
		
		GLDevice.BindingPoint[UniformBindingPoints.InstanceTranslationArray] = this.instanceTranslationBuffer;
	}
	
	public void onResize(float x, float y, float w, float h)
	{
		this.vpPane.relocate(x, y, w, h);
		this.vpListBoxEntire.relocate(x + 8.0f, y + 8.0f, w - 16.0f, h - 32.0f);
		this.vpListBoxInner.relocate(x + 9.0f, y + 9.0f, w - 18.0f, h - 34.0f);
	}
	
	public void draw()
	{
		RenderHelper.Viewport.current = this.vpPane;
		glClearColor(BackgroundColor);
		glClear(GL_COLOR_BUFFER_BIT);
		
		ShaderStock.charRender.activate();
		GLDevice.BindingPoint[UniformBindingPoints.ColorData] = this.cdText;
		ShaderStock.charRender.uniforms.pixelOffset = [0.0f, 0.0f];
		this.materialHeader.drawInstanced(1);
		ShaderStock.pixelScaled.activate();
		
		RenderHelper.Viewport.current = this.vpListBoxEntire;
		glClearColor(InputBorderColor); glClear(GL_COLOR_BUFFER_BIT);
		RenderHelper.Viewport.current = this.vpListBoxInner;
		glClearColor(InputFillColor); glClear(GL_COLOR_BUFFER_BIT);
	}
	
	public bool inCursorTextRange(double x, double y)
	{
		return false;
	}
}
alias RightPane = RightPane_.instance;
