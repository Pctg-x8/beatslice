import objectivegl;
import bindingpoints;

struct SimpleVertex
{
	@element("pos") float[2] pos;
}
struct ColorVertex
{
	@element("pos") float[2] pos;
	@element("color_v") float[4] color;
}

// Readonly Export
private string Readonly(string name)
{
	import std.string : format;
	
	return format(q{
		private static ShaderProgram %1$s_;
		public static @property %1$s() { return this.%1$s_; }
		private static @property %1$s(ShaderProgram p) { this.%1$s_ = p; }
	}, name);
}

// object ShaderStock
final static class ShaderStock
{
	mixin(Readonly("vertUnscaled"));
	mixin(Readonly("vertUnscaledColor"));
	mixin(Readonly("barLines"));
	
	public static void init()
	{
		this.vertUnscaled = ShaderProgram.fromSources!(SimpleVertex,
			ShaderType.Vertex, import("vertUnscaled.glsl"),
			ShaderType.Fragment, import("colorize.glsl"));
		this.vertUnscaledColor = ShaderProgram.fromSources!(ColorVertex,
			ShaderType.Vertex, import("vertUnscaledColor.glsl"),
			ShaderType.Fragment, import("colorize.glsl"));
		this.barLines = ShaderProgram.fromSources!(SimpleVertex,
			ShaderType.Vertex, import("barLines.glsl"),
			ShaderType.Fragment, import("colorize.glsl"));
		
		// Block Binding
		this.vertUnscaled.uniformBlocks.SceneCommon = UniformBindingPoints.SceneCommon;
		this.vertUnscaledColor.uniformBlocks.SceneCommon = UniformBindingPoints.SceneCommon;
		this.barLines.uniformBlocks.SceneCommon = UniformBindingPoints.SceneCommon;
	}
}
