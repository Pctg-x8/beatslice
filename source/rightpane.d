import objectivegl;

final class RightPane_
{
	private this(){}
	public static @property instance()
	{
		import std.concurrency;
		__gshared RightPane_ o;
		return initOnce!o(new RightPane_);
	}
	
	// Color constants
	alias BackgroundColor = HexColor!0xff303030;
	
	public auto width = 150;
	
	public void draw(int height)
	{
		glClearColor(BackgroundColor);
		glClear(GL_COLOR_BUFFER_BIT);
	}
}
alias RightPane = RightPane_.instance;
