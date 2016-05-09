#version 150

in vec2 pos;
out vec4 color;
layout(std140) uniform SceneCommon
{
	vec4 pixelScale;
	vec4 commonColor;
};

void main()
{
	color = commonColor;
	gl_Position = vec4(pos, 0.0f, 1.0f) * pixelScale - vec4(1.0f, 0.0f, 0.0f, 0.0f);
	gl_Position.y = pos.y;
}
