import freetype, objectivegl, textureatlas, shaderstock;
import std.algorithm;

struct StringVertices
{
	VertexArray vbuf;
	float width;
}

auto makeStringVertices(string text, float left, float top)
{
	TexturedVertex[] vts;
	float width_accum = 0.0f;
	foreach(x; text.map!(x => TextureAtlas.addCharacter(x)))
	{
		vts ~= [
			TexturedVertex([left + x.xBearing,				top + x.yBearing],				[x.u1, x.v1]),
			TexturedVertex([left + x.xBearing,				top + x.yBearing + x.height],	[x.u1, x.v2]),
			TexturedVertex([left + x.xBearing + x.width,	top + x.yBearing + x.height],	[x.u2, x.v2]),
			TexturedVertex([left + x.xBearing + x.width,	top + x.yBearing + x.height],	[x.u2, x.v2]),
			TexturedVertex([left + x.xBearing,				top + x.yBearing],				[x.u1, x.v1]),
			TexturedVertex([left + x.xBearing + x.width,	top + x.yBearing],				[x.u2, x.v1])
		];
		left += x.horiAdvance;
		width_accum += x.horiAdvance;
	}
	return StringVertices(VertexArray.fromSlice(vts, ShaderStock.charRender), width_accum);
}
auto makeStringVerticesInv(string text, float left, float top)
{
	TexturedVertex[] vts;
	float width_accum = 0.0f;
	foreach_reverse(x; text.map!(x => TextureAtlas.addCharacter(x)))
	{
		left -= x.horiAdvance;
		vts ~= [
			TexturedVertex([left + x.xBearing,				top + x.yBearing],				[x.u1, x.v1]),
			TexturedVertex([left + x.xBearing,				top + x.yBearing + x.height],	[x.u1, x.v2]),
			TexturedVertex([left + x.xBearing + x.width,	top + x.yBearing + x.height],	[x.u2, x.v2]),
			TexturedVertex([left + x.xBearing + x.width,	top + x.yBearing + x.height],	[x.u2, x.v2]),
			TexturedVertex([left + x.xBearing,				top + x.yBearing],				[x.u1, x.v1]),
			TexturedVertex([left + x.xBearing + x.width,	top + x.yBearing],				[x.u2, x.v1])
		];
		width_accum += x.horiAdvance;
	}
	return StringVertices(VertexArray.fromSlice(vts, ShaderStock.charRender), width_accum);
}
