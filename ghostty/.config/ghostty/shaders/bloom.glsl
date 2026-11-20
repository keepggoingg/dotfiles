// Soft bloom: bright text glows slightly onto its surroundings.
const float RADIUS = 3.0;     // blur radius in pixels
const float STRENGTH = 0.22;  // glow amount
const float THRESHOLD = 0.35; // only pixels brighter than this glow

void mainImage(out vec4 fragColor, in vec2 fragCoord) {
    vec2 uv = fragCoord / iResolution.xy;
    vec4 base = texture(iChannel0, uv);
    vec3 glow = vec3(0.0);
    float total = 0.0;
    for (int x = -3; x <= 3; x++) {
        for (int y = -3; y <= 3; y++) {
            vec2 off = vec2(float(x), float(y)) * RADIUS / iResolution.xy;
            vec3 c = texture(iChannel0, uv + off).rgb;
            float lum = dot(c, vec3(0.299, 0.587, 0.114));
            float w = exp(-float(x * x + y * y) / 8.0);
            glow += c * smoothstep(THRESHOLD, 1.0, lum) * w;
            total += w;
        }
    }
    fragColor = vec4(base.rgb + glow / total * STRENGTH * 4.0, base.a);
}
