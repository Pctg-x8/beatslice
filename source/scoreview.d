import objectivegl;
import shaderstock;
import std.range, std.algorithm, std.typecons;

struct Windows(Source) if(isForwardRange!Source)
{
	private size_t _size;
	private Source _src;
	
	this(Source src, size_t windowSize)
	{
		this._src = src;
		this._size = windowSize;
	}
	@property auto front()
	{
		assert(!empty);
		return this._src.save.take(this._size);
	}
	void popFront()
	{
		assert(!empty);
		this._src.popFront();
	}
	
	static if(hasLength!Source)
	{
		@property bool empty() { return this._src.length < this._size; }
	}
	else enum empty = false;
	
	@property typeof(this) save()
	{
		return typeof(this)(this._src.save, this._size);
	}
}
Windows!Source windows(Source)(Source src, size_t windowSize)
{
	return Windows!Source(src, windowSize);
}

final class ScoreView_
{
	static immutable LANE_WIDTH_BASE = 24.0f;
	
	private this() {}
	public static @property instance()
	{
		import std.concurrency;
		__gshared ScoreView_ o;
		return initOnce!o(new ScoreView_);
	}
	
	// Design Parameters
	static immutable TRACK_HDR_SIZE = 48;
	
	// Color Constants
	alias BackgroundColor = HexColor!0xff202020;
	
	private VertexArray separator, background, barline;
	private float laneWidths_;
	public @property laneWidths() { return this.laneWidths_; }
	
	private static auto makeVertices(size_t ext)
	{
		import std.stdio;
		
		immutable ScratchColor = [HexColor!0x18ff0000];
		immutable WhiteColor = [HexColor!0x18ffffff];
		immutable BlueColor = [HexColor!0x180000ff];
		immutable BackBMPColor = [HexColor!0x1800c000];
		immutable BackColor = [HexColor!0x18c00000];
		
		immutable widths = [1.5f, 1.0f, 0.875f, 1.0f, 0.875f, 1.0f, 0.875f, 1.0f].chain((1.0f).repeat(3 + ext)).array;
		auto colors = [ScratchColor, WhiteColor, BlueColor, WhiteColor, BlueColor, WhiteColor, BlueColor, WhiteColor]
			.chain(BackBMPColor.repeat(3), BackColor.repeat(ext));
		
		auto lefts = widths.scanl!((x, y) => x + y)(0.0f).map!(x => x * LANE_WIDTH_BASE + 16.0f);
		return tuple(lefts.save.map!(x => [
			SimpleVertex([x, -1.0f]), SimpleVertex([x, 1.0f])
		]).array.join, lefts.save.windows(2).zip(colors).map!(x => [
			ColorVertex([x[0][0], -1.0f], x[1][0 .. 4]), ColorVertex([x[0][1] - 1.0f, -1.0f], x[1][0 .. 4]), ColorVertex([x[0][0], 1.0f], x[1][0 .. 4]),
			ColorVertex([x[0][1] - 1.0f, -1.0f], x[1][0 .. 4]), ColorVertex([x[0][1] - 1.0f, 1.0f], x[1][0 .. 4]), ColorVertex([x[0][0], 1.0f], x[1][0 .. 4])
		]).array.join);
	}
	public void init()
	{
		auto vertices = makeVertices(8);
		this.laneWidths_ = vertices[0].back.pos[0] - vertices[0].front.pos[0];
		this.separator = VertexArray.fromSlice(vertices[0], ShaderStock.vertUnscaled);
		this.background = VertexArray.fromSlice(vertices[1], ShaderStock.vertUnscaledColor);
		this.barline = VertexArray.fromSlice([SimpleVertex([-1.0f, 0.0f]), SimpleVertex([1.0f, 0.0f])], ShaderStock.barLines);
	}
	
	public void draw(int width, int height)
	{
		glClearColor(BackgroundColor); glClear(GL_COLOR_BUFFER_BIT);
		ShaderStock.vertUnscaledColor.activate(); this.background.drawInstanced!GL_TRIANGLES(1);
		ShaderStock.vertUnscaled.activate(); this.separator.drawInstanced!GL_LINES(1);
		if(height > TRACK_HDR_SIZE)
		{
			glViewport(16, 0, cast(int)this.laneWidths, height);
			ShaderStock.barLines.activate(); this.drawBarlines(height - TRACK_HDR_SIZE);
		}
	}
	
	public void drawBarlines(int editor_height)
	{
		GLDevice.Vertices = ScoreView.barline;
		ShaderStock.barLines.uniforms.instanceStepSize = [0.0f, 14.0f, 0.0f, 0.0f];
		glDrawArraysInstanced(GL_LINES, 0, 2, editor_height / 14 + 1);
		ShaderStock.barLines.uniforms.instanceStepSize = [0.0f, 14.0f * 4.0f, 0.0f, 0.0f];
		glDrawArraysInstanced(GL_LINES, 0, 2, editor_height / (14 * 4) + 1);
		ShaderStock.barLines.uniforms.instanceStepSize = [0.0f, 14.0f * 16.0f, 0.0f, 0.0f];
		glDrawArraysInstanced(GL_LINES, 0, 2, editor_height / (14 * 16) + 1);
	}
}
alias ScoreView = ScoreView_.instance;

/// Algorithm::Iteration scanl
// scanl :: (a -> b -> a) -> [b] -> a -> [a]
// scanl f y [x1, x2, ...] = [y, y `f` x1, y `f` x1 `f` x2, ...]
pure A[] scanl(alias F, A, B)(immutable(B)[] range, A init)
{
	pure A[] impl(A current, immutable(B)[] range)
	{
		return range.empty ? [] : [F(current, range.front)] ~ impl(F(current, range[0]), range[1 .. $]);
	}
	return range.empty ? [] : [init] ~ impl(init, range);
}
