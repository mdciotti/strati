uniform float abberation;

vec4 effect(vec4 color, Image texture, vec2 texture_coords, vec2 screen_coords)
{
    vec2 offset = vec2(abberation, 0);

    vec4 red = texture2D(texture , texture_coords + offset);
    vec4 green = texture2D(texture, texture_coords);
    vec4 blue = texture2D(texture, texture_coords - offset);

    return vec4(red.r, green.g, blue.b, 1.0f);
}
