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

// An ISPC implementation of IQ's mandelbrot distance (https://www.shadertoy.com/view/lsX3W4), using my HLSL to ISPC helpers
//
// Pretty much out of the box converted the GLSL code to my HLSL-like frontend (https://github.com/zigguratvertigo/ispc-hlsl),
// which then gets compiled through ISPC.

export void noise_ispc(uniform float x0, uniform float y0, uniform float x1,
    uniform float y1, uniform int width, uniform int height,
    uniform float output[])
{
    uniform float nx = 1.0f / (x1 - x0);
    uniform float ny = 1.0f / (y1 - y0);
    uniform float dx = (x1 - x0) / width;
    uniform float dy = (y1 - y0) / height;

    // hardcode the time for the purpose of this single-frame image
    uniform float iGlobalTime = 10.0f;

    for (uniform int j = 0; j < height; j++)
    {
        for (uniform int i = 0; i < width; i += programCount)
        {
            float x = x0 + (i + programIndex) * dx;
            float y = y0 + j * dy;

            // 0-1 Normalization
            x = (x * nx + 0.5f);
            y = 1.0f - (y * ny + 0.5f);

            float2 p = -1.0f + 2.0f * Float2(x, y);
            p.x *= (float)width / (float)height;

            // animation	
            float tz = 0.5 - 0.5*cos(0.225*iGlobalTime);
            float zoo = pow(0.5, 13.0*tz);
            float2 c = Float2(-0.05, .6805) + p*zoo;

            // iterate
            float di = 1.0;
            float2 z = Float2(0.0);
            float m2 = 0.0;
            float2 dz = Float2(0.0);
            for (int k = 0; k < 300; k++)
            {
                if (m2 > 1024.0) { di = 0.0; break; }

                // Z' -> 2·Z·Z' + 1
                dz = 2.0*Float2(z.x*dz.x - z.y*dz.y, z.x*dz.y + z.y*dz.x) + Float2(1.0, 0.0);

                // Z -> Z² + c			
                z = Float2(z.x*z.x - z.y*z.y, 2.0*z.x*z.y) + c;

                m2 = dot(z, z);
            }

            // distance	
            // d(c) = |Z|·log|Z|/|Z'|
            float d = 0.5*sqrt(dot(z, z) / dot(dz, dz))*log(dot(z, z));
            if (di > 0.5) d = 0.0;

            // do some soft coloring based on distance
            d = clamp(pow(4.0*d / zoo, 0.2), 0.0, 1.0);

            int index = 3 * (j * width + i + programIndex);
            output[index + 0] = d;
            output[index + 1] = d;
            output[index + 2] = d;
        }
    }
}