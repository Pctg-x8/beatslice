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

struct UniformColorData
{
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
	mixin(Readonly("rawVertices"));
	mixin(Readonly("pixelScaled"));
	
	public static void init()
	{
		// Vertices
		alias VertexShader = CompiledShader!Vertex;
		auto vertUnscaledShaderV = VertexShader.fromImportedSource!"vertUnscaled.glsl";
		auto vertUnscaledColorShaderV = VertexShader.fromImportedSource!"vertUnscaledColor.glsl";
		auto barLinesShaderV = VertexShader.fromImportedSource!"barLines.glsl";
		auto inputBoxShaderV = VertexShader.fromImportedSource!"inputBoxVS.glsl";
		auto placeholderShaderV = VertexShader.fromImportedSource!"placeholderVS.glsl";
		auto texturedShaderV = VertexShader.fromImportedSource!"textured.glsl";
		auto rawVerticesShaderV = VertexShader.fromImportedSource!"rawVertices.glsl";
		auto pixelScaledShaderV = VertexShader.fromImportedSource!"pixelScaled.glsl";
		// Fragments
		alias FragmentShader = CompiledShader!Fragment;
		auto colorizeShaderF = FragmentShader.fromSource!(ShaderType.Fragment, import("colorize.glsl"));
		auto graytextureColorizeShaderF = FragmentShader.fromSource!(ShaderType.Fragment, import("graytexture_colorize.glsl"));
		
		// Linked Shaders
		this.vertUnscaled = ShaderProgram.fromShaders!(SimpleVertex, vertUnscaledShaderV, colorizeShaderF);
		this.vertUnscaledColor = ShaderProgram.fromShaders!(ColorVertex, vertUnscaledColorShaderV, colorizeShaderF);
		this.barLines = ShaderProgram.fromShaders!(SimpleVertex, barLinesShaderV, colorizeShaderF);
		this.charRender = ShaderProgram.fromShaders!(TexturedVertex, texturedShaderV, graytextureColorizeShaderF);
		this.inputBoxRender = ShaderProgram.fromShaders!(SimpleVertex, inputBoxShaderV, colorizeShaderF);
		this.placeholderRender = ShaderProgram.fromShaders!(TexturedVertex, placeholderShaderV, graytextureColorizeShaderF);
		this.rawVertices = ShaderProgram.fromShaders!(SimpleVertex, rawVerticesShaderV, colorizeShaderF);
		this.pixelScaled = ShaderProgram.fromShaders!(SimpleVertex, pixelScaledShaderV, colorizeShaderF);
		
		// Block Binding
		foreach(x; [this.vertUnscaled, this.barLines, this.charRender, this.inputBoxRender, this.placeholderRender])
		{
			x.uniformBlocks.Viewport = UniformBindingPoints.Viewport;
			x.uniformBlocks.ColorData = UniformBindingPoints.ColorData;
		}
		this.vertUnscaledColor.uniformBlocks.Viewport = UniformBindingPoints.Viewport;
		foreach(x; [this.inputBoxRender, this.placeholderRender])
		{
			x.uniformBlocks.InstanceTranslationArray = UniformBindingPoints.InstanceTranslationArray;
		}
		this.rawVertices.uniformBlocks.ColorData = UniformBindingPoints.ColorData;
	}
}
