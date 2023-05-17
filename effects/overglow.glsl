uniform vec2 dir;
uniform float blurScale;
uniform float blurStrength;
uniform int blurRadius;
uniform vec2 texelSize;

float Gaussian(float x, float variance)
{
    return (1.0 / sqrt(2.0 * 3.141592 * variance)) * exp(-((x * x) / (2.0 * variance)));
}

vec4 degamma(vec4 color) {
    vec4 result;
    result.r = pow(color.r, 2.2);
    result.g = pow(color.g, 2.2);
    result.b = pow(color.b, 2.2);
    return result;
}

vec4 gamma(vec4 color) {
    vec4 result;
    result.r = pow(color.r, 1.0 / 2.2);
    result.g = pow(color.g, 1.0 / 2.2);
    result.b = pow(color.b, 1.0 / 2.2);
    return result;
}

vec4 effect(vec4 color, Image texture, vec2 texture_coords, vec2 screen_coords)
{
    // Calculated values
    float variance = float(blurRadius) * 0.333;
    variance *= variance;
    float strength = 1.0 - blurStrength;

    // Iteration values
    float weight = Gaussian(0, variance);
    vec4 sum = degamma(texture2D(texture, texture_coords.xy)) * weight;
    vec2 offset;
    float x;

    for (int i = 1; i < blurRadius; i++)
    {
        x = float(i);
        offset = x * dir * texelSize * blurScale;
        weight = Gaussian(x * strength, variance);
        sum += degamma(texture2D(texture, texture_coords.xy + offset)) * weight;
        sum += degamma(texture2D(texture, texture_coords.xy - offset)) * weight;
    }

    sum.a = 1.0;
    return gamma(clamp(sum, 0.0, 1.0));
}
