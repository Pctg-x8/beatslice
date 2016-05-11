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
layout(std140) uniform InstanceTranslationArray
{
	vec4 offsets[2];
};

void main()
{
	color = commonColor;
	gl_Position = vec4(pos + offsets[gl_InstanceID].xy, 0.0f, 1.0f) * pixelScale * vec4(1.0f, -1.0f, 1.0f, 1.0f) - vec4(0.0f, -1.0f, 0.0f, 0.0f);
	gl_Position.x = pos.x;
}
