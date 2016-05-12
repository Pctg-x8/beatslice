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
	alias InputFillColor = HexColor!0x40000000;
	alias TextColor = HexColor!0xffffffff;
	alias PlaceholderTextColor = HexColor!0x60ffffff;
	
	public uint width;
	private VertexArray border_vertices, fill_vertices;
	private UniformBuffer!InstanceTranslationArrayData instanceTranslationBuffer;
	private InstanceTranslationArrayData inputBoxPositions;
	private RenderHelper.Viewport vpPane;
	private UniformBuffer!UniformColorData cdText;
	private StringVertices materialHeader;
	private struct ListBoxData
	{
		UniformBuffer!UniformColorData borderColor, fillColor;
		VertexArray borderVertices, fillVertices;
		RenderHelper.Viewport vport;
	}
	private ListBoxData listbox;
	
	public void init()
	{
		this.width = 150;
		this.border_vertices = VertexArray.fromSlice([
			SimpleVertex([-1.0f, -1.0f]), SimpleVertex([-1.0f, 20.0f]),
			SimpleVertex([1.0f, 20.0f]), SimpleVertex([1.0f, 0.0f]), SimpleVertex([-1.0f, 0.0f])
		], ShaderStock.inputBoxRender);
		this.fill_vertices = VertexArray.fromSlice([
			SimpleVertex([-1.0f, 0.0f]), SimpleVertex([1.0f, 0.0f]), SimpleVertex([-1.0f, 20.0f]), SimpleVertex([1.0f, 20.0f])
		], ShaderStock.inputBoxRender);
		
		this.instanceTranslationBuffer = UniformBuffer!InstanceTranslationArrayData.newStatic();
		this.inputBoxPositions.offsets[0] = [0.0f, 40.0f, 0.0f, 0.0f];
		this.inputBoxPositions.offsets[1] = [0.0f, 64.0f, 0.0f, 0.0f];
		this.instanceTranslationBuffer.update(this.inputBoxPositions);
		
		this.vpPane = new RenderHelper.Viewport(0.0f, 0.0f, 100.0f, 100.0f);
		this.listbox.vport = new RenderHelper.Viewport(0.0f, 0.0f, 100.0f, 100.0f);
		this.cdText = UniformBufferFactory.newStatic(UniformColorData([TextColor]));
		this.materialHeader = StringVertices.make("Materials: ", 8, 4);
		this.listbox.borderVertices = VertexArray.fromSlice([
			SimpleVertex([-1.0f, -1.0f]), SimpleVertex([-1.0f, 1.0f]), SimpleVertex([1.0f, 1.0f]), SimpleVertex([1.0f, -1.0f]),
			SimpleVertex([-1.0f, -1.0f])
		], ShaderStock.rawVertices);
		this.listbox.fillVertices = VertexArray.fromSlice([
			SimpleVertex([-1.0f, -1.0f]), SimpleVertex([-1.0f, 1.0f]), SimpleVertex([1.0f, -1.0f]), SimpleVertex([1.0f, 1.0f])
		], ShaderStock.rawVertices);
		this.listbox.borderColor = UniformBufferFactory.newStatic(UniformColorData([InputBorderColor]));
		this.listbox.fillColor = UniformBufferFactory.newStatic(UniformColorData([InputFillColor]));
		
		GLDevice.BindingPoint[UniformBindingPoints.InstanceTranslationArray] = this.instanceTranslationBuffer;
	}
	
	public void onResize(float x, float y, float w, float h)
	{
		this.vpPane.relocate(x, y, w, h);
		this.listbox.vport.relocate(x + 8.0f, y + 8.0f, w - 16.0f, h - 32.0f);
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
		
		RenderHelper.Viewport.current = this.listbox.vport;
		ShaderStock.rawVertices.activate();
		GLDevice.BindingPoint[UniformBindingPoints.ColorData] = this.listbox.fillColor;
		this.listbox.fillVertices.drawInstanced!GL_TRIANGLE_STRIP(1);
		GLDevice.BindingPoint[UniformBindingPoints.ColorData] = this.listbox.borderColor;
		this.listbox.borderVertices.drawInstanced!GL_LINE_STRIP(1);
	}
	
	public bool inCursorTextRange(double x, double y)
	{
		return false;
	}
}
alias RightPane = RightPane_.instance;
