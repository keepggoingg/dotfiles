// Cursor smear: when the cursor jumps, a tapered streak in the cursor colour
// stretches from the old position to the new one and fades out.
const float DURATION = 0.18; // seconds

float segDist(vec2 p, vec2 a, vec2 b) {
    vec2 pa = p - a, ba = b - a;
    float h = clamp(dot(pa, ba) / max(dot(ba, ba), 1e-4), 0.0, 1.0);
    return length(pa - ba * h);
}

void mainImage(out vec4 fragColor, in vec2 fragCoord) {
    vec4 base = texture(iChannel0, fragCoord / iResolution.xy);
    fragColor = base;

    float t = (iTime - iTimeCursorChange) / DURATION;
    if (t >= 1.0 || iCursorVisible.x < 0.5) return;

    // xy is the left/top corner, zw the size -> centre
    vec2 cur = iCurrentCursor.xy + vec2(0.5, -0.5) * iCurrentCursor.zw;
    vec2 prev = iPreviousCursor.xy + vec2(0.5, -0.5) * iPreviousCursor.zw;
    float dist = length(cur - prev);
    if (dist < iCurrentCursor.z * 1.5) return; // ignore normal typing

    float ease = 1.0 - pow(1.0 - t, 3.0);
    vec2 tail = mix(prev, cur, ease);          // tail catches up with the head

    // width tapers from full cursor height at the head to thin at the tail
    vec2 ba = cur - tail;
    float h = clamp(dot(fragCoord - tail, ba) / max(dot(ba, ba), 1e-4), 0.0, 1.0);
    float width = mix(0.15, 0.5, h) * iCurrentCursor.w;
    float d = segDist(fragCoord, tail, cur);
    float a = (1.0 - smoothstep(width - 1.0, width + 1.0, d)) * (1.0 - t) * 0.85;

    fragColor = vec4(mix(base.rgb, iCurrentCursorColor.rgb, a), base.a);
}
