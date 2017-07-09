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

// References:
// http://www.rhythmiccanvas.com/research/papers/worley.pdf
// http://glslsandbox.com/e#23237.0

#include "../hlsl.ispc"

float noise(float x, float y)
{
    return frac(sin(frac(sin(x) * (43.13311)) + y) * 31.0011);
}

static float worley(float x, float y)
{
    float d = 1e30;

    // For the 9 surrounding grid points
    for (int i = -1; i <= 1; ++i)
    {
        for (int j = -1; j <= 1; ++j)
        {
            // Floor our vec2 and add an offset to create our point
            float tpX = floor(x) + i;
            float tpY = floor(y) + j;

            // Minimum distance for this grid point
            float aX = x - tpX - noise(tpX, tpY);
            float aY = y - tpY - noise(tpX, tpY);

            // Keep the minimum (squared) distance
            d = min(d, aX*aX + aY*aY);
        }
    }

    return d;
}

float attenuate(float x)
{
    return 3.0f*exp(-4.0f*abs(2.5f*x - 1.0f));
}

float fworley(float x, float y)
{
    float a = attenuate(worley(x * 50.0f, y * 50.0f));
    float b = attenuate(worley(x * -10.0f, y * -10.0f));

    // Noise layers 
    return sqrt(sqrt(sqrt(a) * sqrt(sqrt(b))));
}

float4 worley(float2 uv)
{
    // Calculate an intensity
    float t = fworley(uv.x / 1500.0f, uv.y / 1500.0f);
    float s = saturate(attenuate(worley(uv.x / 1000.0f, uv.y / 1000.0f)));

    return float4(0.0f, 0.9f * t * t * s, 0.65f * t * s, 1.0f);
}

export void ispcMain(uniform float x0, uniform float y0, uniform float x1,
    uniform float y1, uniform int width, uniform int height,
    uniform float output[])
{
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

            // 0-1 normalization
            x = (x * nx + 0.5f) * width;
            y = (y * ny + 0.5f) * height;

            float4 c = worley(float2(x, y));

            int index = 3 * (j * width + i + programIndex);
            output[index + 0] = c.x;
            output[index + 1] = c.y;
            output[index + 2] = c.z;
        }
    }
}

