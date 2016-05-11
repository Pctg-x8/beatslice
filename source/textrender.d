import freetype, objectivegl, textureatlas, shaderstock;
import std.algorithm, std.meta, std.typecons;

struct StringVertices
{
	VertexArray vbuf;
	float width;
	
	void drawInstanced(size_t instanceCount)
	{
		this.vbuf.drawInstanced!GL_TRIANGLES(instanceCount);
	}
}

auto makeStringVertices(string text, float left, float top, ShaderProgram pg = ShaderStock.charRender)
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
	return StringVertices(VertexArray.fromSlice(vts, pg), width_accum);
}
auto makeStringVerticesInv(string text, float left, float top)
{
	TexturedVertex[] vts; float width;
	AliasSeq!(vts, width) = makeStringVerticesInvRaw(text, left, top);
	return StringVertices(VertexArray.fromSlice(vts, ShaderStock.charRender), width);
}
auto makeStringVerticesInvRaw(string text, float left = 0, float top = 0)
{
	alias ReturnT = Tuple!(TexturedVertex[], float);
	
	TexturedVertex[] vts;
	float left_in = left;
	foreach_reverse(x; text.map!(x => TextureAtlas.addCharacter(x)))
	{
		left -= x.horiAdvance;
		
		immutable x1 = left + x.xBearing, x2 = x1 + x.width;
		immutable y1 = top + x.yBearing, y2 = y1 + x.height;
		vts ~= [
			TexturedVertex([x1, y1], [x.u1, x.v1]),
			TexturedVertex([x1, y2], [x.u1, x.v2]),
			TexturedVertex([x2, y1], [x.u2, x.v1]),
			TexturedVertex([x2, y1], [x.u2, x.v1]),
			TexturedVertex([x1, y2], [x.u1, x.v2]),
			TexturedVertex([x2, y2], [x.u2, x.v2]),
		];
	}
	return ReturnT(vts, left_in - left);
}
