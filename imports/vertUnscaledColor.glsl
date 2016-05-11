#version 150

in vec2 pos;
in vec4 color_v;
out vec4 color;
layout(std140) uniform Viewport
{
	vec4 pixelScale;
};

void main()
{
	color = color_v;
	gl_Position = vec4(pos, 0.0f, 1.0f) * pixelScale - vec4(1.0f, 0.0f, 0.0f, 0.0f);
	gl_Position.y = pos.y;
}
