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

#include <math.h>

#define min(a,b) (((a) < (b)) ? (a) : (b))
#define max(a,b) (((a) > (b)) ? (a) : (b))
float frac(float f) { return f - floorf(f); }
float saturate(float f) { return max(min(f, 1.0f), 0.0f); }

float noise(float x, float y)
{
    return frac(sinf(frac(sinf(x) * (43.13311f)) + y) * 31.0011f);
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
            float tpX = floorf(x) + i;
            float tpY = floorf(y) + j;
            
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
    return 3.0f*expf(-4.0f*fabsf(2.5f*x - 1.0f));
}

float fworley(float x, float y)
{
    float a = attenuate(worley(x * 50.0f, y * 50.0f));
    float b = attenuate(worley(x * -10.0f, y * -10.0f));

    // Noise layers 
    return sqrtf(sqrtf(sqrtf(a) * sqrtf(sqrtf(b))));
}

void worley_serial(float x0, float y0, float x1, float y1,
    int width, int height, float output[])
{
    for (int j = 0; j < height; j++)
    {
        for (int i = 0; i < width; ++i)
        {
            // Calculate an intensity
            float t = fworley(i / 1500.0f, j / 1500.0f);
            float s = saturate(attenuate(worley(i / 1000.0f, j / 1000.0f)));

            int index = 3 * (j * width + i);
            output[index + 0] = 0.0f;
            output[index + 1] = 0.9f * t * t * s;
            output[index + 2] = 0.65f * t * s;
        }
    }
}