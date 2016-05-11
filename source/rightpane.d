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
	
	struct InstanceTranslationArrayData
	{
		ShaderVec4[2] offsets;
	}
	
	// Color constants
	alias BackgroundColor = HexColor!0xff303030;
	alias InputBorderColor = HexColor!0xff4080c0;
	alias InputFillColor = HexColor!0x20000000;
	alias TextColor = HexColor!0xffffffff;
	
	public uint width;
	private VertexArray border_vertices, fill_vertices;
	private UniformBuffer!SceneCommonUniforms sceneCommonBuffer;
	private UniformBuffer!InstanceTranslationArrayData instanceTranslationBuffer;
	private InstanceTranslationArrayData inputBoxPositions;
	
	public void init()
	{
		this.width = 150;
		this.border_vertices = VertexArray.fromSlice([
			SimpleVertex([-1.0f, -1.0f]), SimpleVertex([-1.0f, 18.0f]),
			SimpleVertex([1.0f, 18.0f]), SimpleVertex([1.0f, 0.0f]), SimpleVertex([-1.0f, 0.0f])
		], ShaderStock.inputBoxRender);
		this.fill_vertices = VertexArray.fromSlice([
			SimpleVertex([-1.0f, 0.0f]), SimpleVertex([1.0f, 0.0f]), SimpleVertex([-1.0f, 18.0f]), SimpleVertex([1.0f, 18.0f])
		], ShaderStock.inputBoxRender);
		
		this.sceneCommonBuffer = UniformBuffer!SceneCommonUniforms.newStatic();
		this.instanceTranslationBuffer = UniformBuffer!InstanceTranslationArrayData.newStatic();
		this.inputBoxPositions.offsets[0] = [0.0f, 40.0f, 0.0f, 0.0f];
		this.inputBoxPositions.offsets[1] = [0.0f, 64.0f, 0.0f, 0.0f];
		this.instanceTranslationBuffer.update(this.inputBoxPositions);
		
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
		this.border_vertices.drawInstanced!GL_LINE_STRIP(2);
		
		glViewport(x, y, width, height);
	}
	
	public bool inCursorTextRange(double x, double y)
	{
		if(y < 0) return false;
		
		pure vertInRange(double a, double b) { return a <= y && y <= b; }
		pure vertInInputBox(size_t idx) { return vertInRange(this.inputBoxPositions.offsets[idx][1], this.inputBoxPositions.offsets[idx][1] + 18.0); }
		if(vertInInputBox(0) || vertInInputBox(1))
		{
			if(60 <= x && x <= width - 8)
			{
				return true;
			}
		}
		return false;
	}
}
alias RightPane = RightPane_.instance;
