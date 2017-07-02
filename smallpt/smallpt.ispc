/*
    MIT License

    Copyright(c) 2017 Colin Barré-Brisebois

    Permission is hereby granted, free of charge, to any person obtaining a copy
    of this software and associated documentation files(the "Software"), to deal
    in the Software without restriction, including without limitation the rights
    to use, copy, modify, merge, publish, distribute, sublicense, and / or sell
    copies of the Software, and to permit persons to whom the Software is
    furnished to do so, subject to the following conditions :

    The above copyright notice and this permission notice shall be included in all
    copies or substantial portions of the Software.

    THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
    IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
    FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT.IN NO EVENT SHALL THE
    AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
    LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
    OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
    SOFTWARE.
*/

//
// ISPC implementation of Kevin Beason's smallpt: www.kevinbeason.com/smallpt/
// Also greatly inspired by Zavie's Shadertoy implementation: https://www.shadertoy.com/view/4sfGDB
// Uses my HLSL-to-ISPC helper library: https://github.com/zigguratvertigo/hlsl-to-ispc
// 

#include "../hlsl.ispc"

#define SAMPLES 256
#define MAXDEPTH 4
#define DIFF 0
#define SPEC 1
#define REFR 2
#define NUM_SPHERES 9

float rand(RNGState& rngstate)
{
    return frandom(&rngstate);
}

struct Ray 
{ 
    float3 o;
    float3 d;
};

struct Sphere 
{
    float r;
    float3 p, e, c;
    int refl;
};

Sphere CreateSphere(float r, float3 p, float3 e, float3 c, int refl)
{
    Sphere s = { r, p, e, c, refl };
    return s;
}

Ray CreateRay(float3 o, float3 d)
{
    Ray r = { o, d };
    return r;
}

const static uniform Sphere spheres[NUM_SPHERES] =
{
    { 1e5,  { -1e5 + 1., 40.8, 81.6 },   { 0., 0, 0 },      { .75, .25, .25},   DIFF },
    { 1e5,  { 1e5 + 99., 40.8, 81.6 },   { 0., 0, 0 },      { .25, .25, .75},   DIFF },
    { 1e5,  { 50., 40.8, -1e5 },         { 0., 0, 0 },      { .75, .75, .75},   DIFF },
    { 1e5,  { 50., 40.8, 1e5 + 170. },   { 0., 0, 0 },      { 0., 0, 0},        DIFF },
    { 1e5,  { 50., -1e5, 81.6 },         { 0., 0, 0 },      { .75, 0.75, 0.75}, DIFF },
    { 1e5,  { 50., 1e5 + 81.6, 81.6 },   { 0., 0, 0 },      { .75, 0.75, 0.75}, DIFF },
    { 16.5, { 27., 16.5, 47. },          { 0., 0, 0 },      { 1.0, 1.0, 1.0 },  SPEC },
    { 16.5, { 73., 16.5, 78. },          { 0., 0, 0 },      { 0.7, 1.0, 0.9 },  REFR },
    { 600., { 50., 681.33, 81.6 },       { 12., 12, 12 },   { 0., 0, 0 },       DIFF },
};

float intersect(Sphere s, Ray r)
{
    float3 op = s.p - r.o;
    float t;
    float epsilon = 1e-3;
    float b = dot(op, r.d);
    float det = b * b - dot(op, op) + s.r * s.r;

    if (det < 0.) 
        return 0.; 
    else 
        det = sqrt(det);
    
    return (t = b - det) > epsilon ? t : ((t = b + det) > epsilon ? t : 0.);
}

int intersect(Ray r, float& t, Sphere& s, int avoid)
{
    int id = -1;
    t = 1e5;
    s = spheres[0];

    for (int i = 0; i < NUM_SPHERES; ++i)
    {
        Sphere S = spheres[i];
        float d = intersect(S, r);
        if (i != avoid && d != 0. && d < t) 
        { 
            t = d; 
            id = i; 
            s = S; 
        }
    }

    return id;
}

float3 jitter(float3 d, float phi, float sina, float cosa)
{
    float3 w = normalize(d);
    float3 u = normalize(cross(w.yzx, w));
    float3 v = cross(w, u);
    return (u*cos(phi) + v*sin(phi)) * sina + w * cosa;
}

float3 radiance(Ray r, RNGState& rngstate)
{
    float3 acc = 0;
    float3 mask = 1;
    int id = -1;

    for (int depth = 0; depth < MAXDEPTH; ++depth)
    {
        float t;
        Sphere obj;

        if ((id = intersect(r, t, obj, id)) < 0) 
            break;

        float3 x = t * r.d + r.o;
        float3 n = normalize(x - obj.p);
        float3 nl = n * -sign(dot(n, r.d));

        if (obj.refl == DIFF)
        {
            float r2 = rand(rngstate);
            float3 d = jitter(nl, 2.*PI*rand(rngstate), sqrt(r2), sqrt(1. - r2));
            float3 e = 0;
            float E = 1;
            acc += mask * obj.e * E + mask * obj.c * e;
            mask *= obj.c;
            r = CreateRay(x, d);
        }
        else if (obj.refl == SPEC)
        {
            acc += mask * obj.e;
            mask *= obj.c;
            r = CreateRay(x, reflect(r.d, n));
        }
        else
        {
            float a = dot(n, r.d);
            float ddn = abs(a);
            float nc = 1.;
            float nt = 1.5;
            float nnt = (a > 0) ? nt / nc : nc / nt;

            float cos2t = 1. - nnt*nnt*(1. - ddn*ddn);
            r = CreateRay(x, reflect(r.d, n));

            if (cos2t > 0.)
            {
                float3 tdir = r.d*nnt + sign(a)*n*(ddn*nnt + sqrt(cos2t));
                tdir = normalize(tdir);

                float R0 = (nt - nc)*(nt - nc) / ((nt + nc)*(nt + nc));
                float c = (a > 0) ? 1 - dot(tdir, n) : 1 - ddn;
                float Re = R0 + (1. - R0)*c*c*c*c*c;
                float P = .25 + .5*Re;
                float RP = Re / P;
                float TP = (1. - Re) / (1. - P);

                if (rand(rngstate) < P)
                {
                    mask *= RP;
                }
                else
                {
                    mask *= obj.c*TP;
                    r = CreateRay(x, tdir);
                }
            }
        }
    }
    return acc;
}

export void smallpt_ispc(uniform float x0, uniform float y0, uniform float x1,
    uniform float y1, uniform int width, uniform int height,
    uniform float output[])
{
    uniform int sY = y0;
    RNGState rngstate;
    seed_rng(&rngstate, programIndex + (sY << (programIndex & 15)));

    uniform float nx = 1.0f / (x1 - x0);
    uniform float ny = 1.0f / (y1 - y0);
    uniform float dx = (x1 - x0) / width;
    uniform float dy = (y1 - y0) / height;

    for (uniform int j = 0; j < height; j++)
    {
        for (uniform int i = 0; i < width; i += programCount)
        {
            float x = x0 + (i + programIndex) * dx;
            float y = y0 + j * dy;

            // 0-1 Normalization
            x = (x * nx + 0.5f);
            y = 1.0f - (y * ny + 0.5f);

            // -1 to 1
            float2 p = -1.0f + 2.0f * Float2(x, y);
            p.x *= (float)width / (float)height;

            float2 uv = p;
            float3 camPos = float3(50., 40.8, 169.);
            float3 cz = normalize(float3(50., 40., 81.6) - camPos);
            float3 cx = float3(1., 0., 0.);
            float3 cy = normalize(cross(cx, cz));
            cx = cross(cz, cy);
            float3 color = 0;

            for (int k = 0; k < SAMPLES; ++k)
            {
                color += radiance(CreateRay(camPos, normalize(0.53135 * (width / height*uv.x * cx + uv.y * cy) + cz)), rngstate);
            }

            float3 fragColor = pow(saturate(color / SAMPLES), 1.0f/2.2f);

            int index = 3 * (j * width + i + programIndex);
            output[index + 0] = fragColor.x;
            output[index + 1] = fragColor.y;
            output[index + 2] = fragColor.z;
        }
    }
}
