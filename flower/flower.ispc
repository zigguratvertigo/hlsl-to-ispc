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
#include "../hlsl.ispc"

// An ISPC implementation of IQ's "Deform - flower" shadertoy (https://www.shadertoy.com/view/4dX3Rn), using my HLSL to ISPC helpers
//
// Pretty much out of the box converted the GLSL code to my HLSL-like frontend (https://github.com/zigguratvertigo/ispc-hlsl),
// which then gets compiled through ISPC.

export void flower_ispc(uniform float x0, uniform float y0, uniform float x1,
    uniform float y1, uniform int width, uniform int height,
    uniform float output[])
{
    uniform float nx = 1.0f / (x1 - x0);
    uniform float ny = 1.0f / (y1 - y0);
    uniform float dx = (x1 - x0) / width;
    uniform float dy = (y1 - y0) / height;

    // hardcode the time for the purpose of this single-frame image
    uniform float iGlobalTime = 7.0f;

    uniform float2 iResolution = Float2(width, height);

    for (uniform int j = 0; j < height; j++)
    {
        for (uniform int i = 0; i < width; i += programCount)
        {
            float x = x0 + (i + programIndex) * dx;
            float y = y0 + j * dy;

            // 0-1 Normalization
            x = (x * nx + 0.5f);
            y = 1.0f - (y * ny + 0.5f);

            float2 fragCoord = float2(x, y) * iResolution;

            float2 p = (2.0*fragCoord - iResolution) / min(iResolution.y, iResolution.x);

            float a = atan2(p.x, p.y);
            float r = length(p)*(0.8 + 0.2*sin(0.3*iGlobalTime));

            float w = cos(2.0*iGlobalTime - r*2.0);
            float h = 0.5 + 0.5*cos(12.0*a - w*7.0 + r*8.0 + 0.7*iGlobalTime);
            float d = 0.25 + 0.75*pow(h, 1.0*r)*(0.7 + 0.3*w);

            float f = sqrt(1.0 - r / d)*r*2.5;
            f *= 1.25 + 0.25*cos((12.0*a - w*7.0 + r*8.0) / 2.0);
            f *= 1.0 - 0.35*(0.5 + 0.5*sin(r*30.0))*(0.5 + 0.5*cos(12.0*a - w*7.0 + r*8.0));

            float3 col = float3(f,
                f - h*0.5 + r*.2 + 0.35*h*(1.0 - r),
                f - h*r + 0.1*h*(1.0 - r));
            col = clamp(col, 0.0, 1.0);

            float3 bcol = lerp(0.5*float3(0.8, 0.9, 1.0), Float3(1.0), 0.5 + 0.5*p.y);
            col = lerp(col, bcol, smoothstep(-0.3, 0.6, r - d));

            int index = 3 * (j * width + i + programIndex);
            output[index + 0] = col.x;
            output[index + 1] = col.y;
            output[index + 2] = col.z;
        }
    }
}