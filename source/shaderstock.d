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
struct TexturedVertex
{
	@element("pos") float[2] pos;
	@element("uv") float[2] uv;
}

struct SceneCommonUniforms
{
	float[4] pixelScale;
	float[4] commonColor;
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
	mixin(Readonly("charRender"));
	mixin(Readonly("inputBoxRender"));
	mixin(Readonly("placeholderRender"));
	
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
		this.charRender = ShaderProgram.fromSources!(TexturedVertex,
			ShaderType.Vertex, import("textured.glsl"),
			ShaderType.Fragment, import("graytexture_colorize.glsl"));
		this.inputBoxRender = ShaderProgram.fromSources!(SimpleVertex,
			ShaderType.Vertex, import("inputBoxVS.glsl"),
			ShaderType.Fragment, import("colorize.glsl"));
		this.placeholderRender = ShaderProgram.fromSources!(TexturedVertex,
			ShaderType.Vertex, import("placeholderVS.glsl"),
			ShaderType.Fragment, import("graytexture_colorize.glsl"));
		
		// Block Binding
		this.vertUnscaled.uniformBlocks.Viewport = UniformBindingPoints.Viewport;
		this.vertUnscaled.uniformBlocks.ColorData = UniformBindingPoints.ColorData;
		this.vertUnscaledColor.uniformBlocks.Viewport = UniformBindingPoints.Viewport;
		this.barLines.uniformBlocks.Viewport = UniformBindingPoints.Viewport;
		this.vertUnscaled.uniformBlocks.ColorData = UniformBindingPoints.ColorData;
		this.charRender.uniformBlocks.Viewport = UniformBindingPoints.Viewport;
		this.vertUnscaled.uniformBlocks.ColorData = UniformBindingPoints.ColorData;
		this.inputBoxRender.uniformBlocks.Viewport = UniformBindingPoints.Viewport;
		this.vertUnscaled.uniformBlocks.ColorData = UniformBindingPoints.ColorData;
		this.inputBoxRender.uniformBlocks.InstanceTranslationArray = UniformBindingPoints.InstanceTranslationArray;
		this.placeholderRender.uniformBlocks.Viewport = UniformBindingPoints.Viewport;
		this.vertUnscaled.uniformBlocks.ColorData = UniformBindingPoints.ColorData;
		this.placeholderRender.uniformBlocks.InstanceTranslationArray = UniformBindingPoints.InstanceTranslationArray;
	}
}
