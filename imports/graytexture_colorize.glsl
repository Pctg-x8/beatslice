#version 140

in vec2 uv_frag;
in vec4 color_frag;
out vec4 color;
uniform sampler2D intex;

void main()
{
	float g = texture2D(intex, uv_frag).r;
	color.rgb = color_frag.rgb;
	// color.a = color_frag.a;
	color.a = color_frag.a * g;
}
