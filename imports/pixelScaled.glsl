#version 150

in vec2 pos;
out vec4 color;
layout(std140) uniform Viewport
{
	vec4 pixelScale;
};
layout(std140) uniform ColorData
{
	vec4 commonColor;
};

void main()
{
	color = commonColor;
	gl_Position = vec4(pos, 0.0f, 1.0f) * pixelScale - vec4(1.0f, -1.0f, 0.0f, 0.0f);
}
