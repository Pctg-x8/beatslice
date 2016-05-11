import objectivegl;
import bindingpoints;

final class RenderHelper_
{
	private this() {}
	public static @property instance()
	{
		import std.concurrency;
		__gshared RenderHelper_ o;
		return initOnce!o(new RenderHelper_);
	}
	
	struct ViewportData
	{
		ShaderVec4 pixelScale;
	}
	
	private ShaderVec4 viewportSize;
	private UniformBuffer!ViewportData vpDataBuffer;
	private ViewportData vpData;
	
	public void init()
	{
		this.vpDataBuffer = UniformBuffer!ViewportData.newStatic();
		this.vpData.pixelScale = [1.0f, 1.0f, 1.0f, 1.0f];
		this.vpDataBuffer.update(this.vpData);
		
		GLDevice.BindingPoint[UniformBindingPoints.SceneCommon] = this.vpDataBuffer;
	}
	
	public @property viewport(ShaderVec4 sizev4)
	{
		this.viewportSize = sizev4;
		glViewport(cast(int)sizev4[0], cast(int)sizev4[1], cast(int)sizev4[2], cast(int)sizev4[3]);
		glScissor(cast(int)sizev4[0], cast(int)sizev4[1], cast(int)sizev4[2], cast(int)sizev4[3]);
		
		this.vpData.pixelScale[0 .. 1] = 2.0f / sizev4[2 .. 3];
		this.vpDataBuffer.update(this.vpData);
	}
}
alias RenderHelper = RenderHelper_.instance;
