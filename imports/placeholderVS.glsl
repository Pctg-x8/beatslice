#version 150

in vec2 pos;
in vec2 uv;
out vec2 uv_frag;
out vec4 color_frag;
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
	color_frag = commonColor;
	uv_frag = uv;
	gl_Position = vec4(pos + offsets[gl_InstanceID].xy, 0.0f, 1.0f) * pixelScale * vec4(1.0f, -1.0f, 1.0f, 1.0f) - vec4(1.0f, -1.0f, 0.0f, 0.0f);
}
