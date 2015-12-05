uniform float width;
uniform float height;
uniform vec2 dir;

// Weights and offsets for the Gaussian blur
uniform float px[10] = float[](0.0,1.0,2.0,3.0,4.0,5.0,6.0,7.0,8.0,9.0);
uniform float weight[10] = float[](0.133,0.126,0.106,0.081,0.055,0.033,0.018,0.009,0.004,0.001);

float luma(vec3 color)
{
    return 0.2126 * color.r + 0.7152 * color.g + 0.0722 * color.b;
}

vec4 effect(vec4 color, Image texture, vec2 texture_coords, vec2 screen_coords)
{
    // extract the bright parts
    // vec4 val = texture(RenderTex, texture_coords.xy);
    // return val * clamp(luma(val.rgb), 0.0, 1.0);

    vec4 sum = texture2D(texture, texture_coords.xy) * weight[0];
    vec2 delta = dir * vec2(2.0 / width, 2.0 / height);
    vec2 offset;

    for (int i = 1; i < 10; i++)
    {
        offset = px[i] * delta;
        sum += texture2D(texture, texture_coords.xy + offset) * weight[i];
        sum += texture2D(texture, texture_coords.xy - offset) * weight[i];
    }

    return sum;
}
