import freetype, objectivegl, textureatlas, shaderstock;
import std.algorithm, std.meta, std.typecons;

pure x(TexturedVertex v) { return v.pos[0]; }
pure y(TexturedVertex v) { return v.pos[1]; }
pure u(TexturedVertex v) { return v.uv[0]; }
pure v(TexturedVertex v) { return v.uv[1]; }
private pure makeTexturedRectangle(TexturedVertex v0, TexturedVertex v1)
{
	return [
		v0,
		TexturedVertex([v1.x, v0.y], [v1.u, v0.v]),
		TexturedVertex([v0.x, v1.y], [v0.u, v1.v]),
		TexturedVertex([v0.x, v1.y], [v0.u, v1.v]),
		TexturedVertex([v1.x, v0.y], [v1.u, v0.v]),
		v1
	];
}

struct StringVertices
{
	VertexArray vbuf;
	float width;
	
	void drawInstanced(int instanceCount)
	{
		this.vbuf.drawInstanced!GL_TRIANGLES(instanceCount);
	}
	
	static auto make(string text, float left = 0.0f, float top = 0.0f, ShaderProgram pg = ShaderStock.charRender)
	{
		TexturedVertex[] vts;
		immutable left_in = left;
		foreach(x; text.map!(x => TextureAtlas.addCharacter(x)))
		{
			vts ~= makeTexturedRectangle(
				TexturedVertex([left + x.xBearing, top + x.yBearing], [x.u1, x.v1]),
				TexturedVertex([left + x.xBearing + x.width, top + x.yBearing + x.height], [x.u2, x.v2])
			);
			left += x.horiAdvance;
		}
		return StringVertices(VertexArray.fromSlice(vts, pg), left - left_in);
	}
	static auto makeRightBase(string text, float right = 0.0f, float top = 0.0f, ShaderProgram pg = ShaderStock.charRender)
	{
		TexturedVertex[] vts;
		immutable right_in = right;
		foreach_reverse(c; text.map!(x => TextureAtlas.addCharacter(x)))
		{
			right -= c.horiAdvance;
			vts ~= makeTexturedRectangle(
				TexturedVertex([right + c.xBearing, top + c.yBearing], [c.u1, c.v1]),
				TexturedVertex([right + c.xBearing + c.width, top + c.yBearing + c.height], [c.u2, c.v2])
			);
		}
		return StringVertices(VertexArray.fromSlice(vts, pg), right_in - right);
	}
}

deprecated("Use StringVertices.make")
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
deprecated("Use StringVertices.makeRightBase")
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
