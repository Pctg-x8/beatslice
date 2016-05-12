public import derelict.freetype.ft;

import std.conv, std.string;

// Objective FreeType

final class Library_
{
	FT_Library lib;
	private this()
	{
		DerelictFT.load();
		auto err = FT_Init_FreeType(&this.lib);
		if(err != 0) throw new Exception("FreeType Error: " ~ err.to!string);
	}
	~this()
	{
		FT_Done_Library(this.lib);
	}
	public static @property instance()
	{
		import std.concurrency;
		__gshared Library_ o;
		return initOnce!o(new Library_);
	}
	
	public auto newFace(string path, FT_Long index, ref FT_Face face)
	{
		return this.lib.FT_New_Face(path.toStringz, index, &face);
	}
}
alias Library = Library_.instance;

final class Face
{
	FT_Face face;
	
	/// Iniialize FreeType Face Object
	public this(string path)
	{
		auto err = Library.newFace(path, 0, this.face);
		if(err != 0) throw new Exception("FreeType Error: " ~ err.to!string);
	}
	~this()
	{
		FT_Done_Face(this.face);
	}
	
	/// Set character size(point)
	public @property charSize(float height)
	{
		this.face.FT_Set_Char_Size(0, cast(FT_F26Dot6)(height * 64.0f), 100, 100);
	}
	/// Gets glyph by character code that rendered
	public auto getRenderedCharacter(dchar c)
	{
		this.face.FT_Load_Char(cast(FT_ULong)c, FT_LOAD_RENDER);
		return this.face.glyph;
	}
	/// Gets face's baseline in pixel
	public @property baseline()
	{
		return this.face.ascender * this.face.size.metrics.y_ppem / this.face.units_per_EM;
	}
}
