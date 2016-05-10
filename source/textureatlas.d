import objectivegl;
import freetype;

final class TextureAtlas_
{
	private this(){}
	public static @property instance()
	{
		import std.concurrency;
		__gshared TextureAtlas_ o;
		return initOnce!o(new TextureAtlas_);
	}
	
	// 1024 x 1024 pixels
	static immutable TextureSize = 1024;
	
	private Texture2D _texture;
	public @property texture() { return this._texture; }
	private Face face;
	
	class Rectangle
	{
		uint x, y, width, height;
		
		this(uint x, uint y, uint w, uint h)
		{
			this.x = x;
			this.y = y;
			this.width = w;
			this.height = h;
		}
	}
	class RegionNode
	{
		bool used = false;
		Rectangle rect;
		RegionNode right, bottom;
		
		this(uint x, uint y, uint w, uint h)
		{
			this.rect = new Rectangle(x, y, w, h);
		}
		alias rect this;
	}
	RegionNode regionRoot;
	struct CharacterData
	{
		float u1, v1, u2, v2;
		float width, height;
		float horiAdvance, vertAdvance;
		float xBearing, yBearing;
	}
	
	public void init()
	{
		this._texture = Texture2D.newEmpty(TextureSize, TextureSize, PixelFormat.Grayscale);
		this.regionRoot = new RegionNode(0, 0, TextureSize, TextureSize);
		
		this.face = new Face("resources/fonts/mplus-2c-regular.ttf");
		this.face.charSize = 10.0f;
	}
	
	private auto allocate(uint w, uint h)
	{
		RegionNode recursive(RegionNode current)
		{
			if(current is null) return null;
			if(!current.used)
			{
				if(current.rect.width >= w && current.rect.height >= h) return current;
			}
			auto child = recursive(current.right);
			return child !is null ? child : recursive(current.bottom);
		}
		
		auto node = recursive(this.regionRoot);
		if(node !is null)
		{
			// Mark as used, separate free regions, shrink to required size
			node.used = true;
			node.right = new RegionNode(node.x + w, node.y, node.width - w, node.height);
			node.bottom = new RegionNode(node.x, node.y + h, node.width, node.height - h);
			node.width = w;
			node.height = h;
			return node.rect;
		}
		else return null;	// failed to allocate
	}
	
	private CharacterData[dchar] uv_cache;
	
	public auto addCharacter(dchar chr)
	{
		import std.stdio, std.range, std.algorithm, std.string;
		
		if(chr in this.uv_cache) return this.uv_cache[chr];
		
		// writeln("Rendering character ", chr, "...");
		auto glyph = this.face.getRenderedCharacter(chr);
		// writeln("Face Baseline: ", this.face.baseline, "/Glyph Offsets: (", glyph.bitmap_left, ", ", glyph.bitmap_top, ")");
		// writeln("bitmap width: ", glyph.bitmap.width, "/rows: ", glyph.bitmap.rows);
		// writeln("linear advances: (", glyph.linearHoriAdvance / 65536.0f, ", ", glyph.linearVertAdvance / 65536.0f, ")");
		auto rect = this.allocate(glyph.bitmap.width + 1, glyph.bitmap.rows + 1);
		if(rect is null) throw new Exception("Unable locate character in texture atlas.");
		// writeln("placing bitmap on (", rect.x, ", ", rect.y, ")");
		this.uv_cache[chr] = CharacterData(cast(float)rect.x / TextureSize, cast(float)rect.y / TextureSize,
			cast(float)(rect.x + glyph.bitmap.width) / TextureSize, cast(float)(rect.y + glyph.bitmap.rows) / TextureSize,
			glyph.bitmap.width, glyph.bitmap.rows,
			glyph.linearHoriAdvance / 65536.0f, glyph.linearVertAdvance / 65536.0f,
			glyph.bitmap_left, this.face.baseline - glyph.bitmap_top);
		/*if(glyph.bitmap.rows >= 1)
		{
			writeln(glyph.bitmap.buffer[0 .. (glyph.bitmap.pitch * glyph.bitmap.rows)].map!(x => format("%02x", x)).chunks(glyph.bitmap.pitch).map!(x => x.join(" ")).join("\n"));
		}*/
		GLDevice.PixelStore[GL_UNPACK_ALIGNMENT] = 1;
		// GLDevice.PixelStore[GL_UNPACK_ROW_LENGTH] = glyph.bitmap.pitch;
		this.texture.update(rect.x, rect.y, glyph.bitmap.width, glyph.bitmap.rows, glyph.bitmap.buffer, PixelFormat.Grayscale);
		GLDevice.PixelStore[GL_UNPACK_ALIGNMENT] = 4;
		return this.uv_cache[chr];
	}
}
alias TextureAtlas = TextureAtlas_.instance;
