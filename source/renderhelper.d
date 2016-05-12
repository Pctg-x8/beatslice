import objectivegl;
import bindingpoints;
import std.typecons;

final static class RenderHelper
{
	@disable this();
	
	static class Viewport
	{
		struct UniformBufferData
		{
			ShaderVec4 pixelScale;
		}
		
		private Tuple!(int, int, int, int) params_i;
		private Tuple!(float, float, float, float) params;
		private UniformBuffer!UniformBufferData uniformDataBuffer;
		public @property parameters() const { return this.params; }
		
		public this(float x, float y, float w, float h)
		{
			this.params = tuple(x, y, w, h);
			this.params_i = tuple(cast(int)x, cast(int)y, cast(int)w, cast(int)h);
			this.uniformDataBuffer = UniformBuffer!UniformBufferData.newStatic(UniformBufferData(
				[2.0f / this.params[0], 2.0f / this.params[1], 1.0f, 1.0f]));
		}
		public void relocate(float x, float y, float w, float h)
		{
			this.params = tuple(x, y, w, h);
			this.params_i = tuple(cast(int)x, cast(int)y, cast(int)w, cast(int)h);
			this.uniformDataBuffer.update(UniformBufferData([2.0f / w, 2.0f / h, 1.0f, 1.0f]));
		}
		
		public static @property current(Viewport vp)
		{
			glViewport(vp.params_i.expand);
			glScissor(vp.params_i.expand);
			GLDevice.BindingPoint[UniformBindingPoints.Viewport] = vp.uniformDataBuffer;
		}
	}
}
