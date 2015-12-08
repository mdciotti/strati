float luma(vec3 color)
{
    // return 0.2126 * color.r + 0.7152 * color.g + 0.0722 * color.b;
    // return 0.3 * color.r + 0.5 * color.g + 0.2 * color.b;
    return 1.0;
}

vec4 effect(vec4 color, Image texture, vec2 texture_coords, vec2 screen_coords)
{
    // extract the bright parts
    vec4 val = texture2D(texture, texture_coords.xy);
    return val * clamp(luma(val.rgb), 0.0, 1.0);
}
