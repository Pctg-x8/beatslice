import objectivegl;

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
	
	public void init()
	{
		this._texture = Texture2D.newEmpty(TextureSize, TextureSize, PixelFormat.Grayscale);
	}
}
alias TextureAtlas = TextureAtlas_.instance;
