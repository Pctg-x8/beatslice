import objectivegl;
import shaderstock, bindingpoints;

final class RightPane_
{
	private this(){}
	public static @property instance()
	{
		import std.concurrency;
		__gshared RightPane_ o;
		return initOnce!o(new RightPane_);
	}
	
	struct InstanceTranslationArrayUniforms
	{
		float[4][2] offsets;
	}
	
	// Color constants
	alias BackgroundColor = HexColor!0xff303030;
	alias InputBorderColor = HexColor!0xff4080c0;
	alias InputFillColor = HexColor!0x20000000;
	
	public uint width;
	private VertexArray border_vertices, fill_vertices;
	private UniformBuffer!SceneCommonUniforms sceneCommonBuffer;
	private UniformBuffer!InstanceTranslationArrayUniforms instanceTranslationBuffer;
	
	public void init()
	{
		this.width = 150;
		this.border_vertices = VertexArray.fromSlice([
			SimpleVertex([-1.0f, 0.0f]), SimpleVertex([-1.0f, 18.0f]),
			SimpleVertex([1.0f, 18.0f]), SimpleVertex([1.0f, 0.0f])
		], ShaderStock.inputBoxRender);
		this.fill_vertices = VertexArray.fromSlice([
			SimpleVertex([-1.0f, 0.0f]), SimpleVertex([1.0f, 0.0f]), SimpleVertex([-1.0f, 18.0f]), SimpleVertex([1.0f, 18.0f])
		], ShaderStock.inputBoxRender);
		
		this.sceneCommonBuffer = UniformBuffer!SceneCommonUniforms.newStatic();
		this.instanceTranslationBuffer = UniformBuffer!InstanceTranslationArrayUniforms.newStatic();
		InstanceTranslationArrayUniforms itau;
		itau.offsets[0] = [0.0f, 40.0f, 0.0f, 0.0f];
		itau.offsets[1] = [0.0f, 64.0f, 0.0f, 0.0f];
		this.instanceTranslationBuffer.update(itau);
		
		GLDevice.BindingPoint[UniformBindingPoints.InstanceTranslationArray] = this.instanceTranslationBuffer;
	}
	
	public void draw(int x, int y, int width, int height)
	{
		static scu = SceneCommonUniforms([1.0f, 1.0f, 1.0f, 1.0f], [1.0f, 1.0f, 1.0f, 1.0f]);
		
		glClearColor(BackgroundColor);
		glClear(GL_COLOR_BUFFER_BIT);
		
		scu.pixelScale[0] = 2.0f / (width - 68);
		scu.pixelScale[1] = 2.0f / height;
		GLDevice.BindingPoint[UniformBindingPoints.SceneCommon] = this.sceneCommonBuffer;
		
		glViewport(x + 60, y, width - 68, height);
		ShaderStock.inputBoxRender.activate();
		scu.commonColor = [InputFillColor];
		this.sceneCommonBuffer.update(scu);
		this.fill_vertices.drawInstanced!GL_TRIANGLE_STRIP(2);
		scu.commonColor = [InputBorderColor];
		this.sceneCommonBuffer.update(scu);
		this.border_vertices.drawInstanced!GL_LINE_LOOP(2);
		
		glViewport(x, y, width, height);
	}
}
alias RightPane = RightPane_.instance;
