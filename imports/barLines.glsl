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
uniform vec4 instanceStepSize;

void main()
{
	color = commonColor;
	vec2 pos_i = pos + vec2(0.0f, gl_InstanceID * instanceStepSize.y);
	gl_Position = vec4(pos_i, 0.0f, 1.0f) * pixelScale - vec4(1.0f, 1.0f, 0.0f, 0.0f);
	gl_Position.x = pos.x;
}
