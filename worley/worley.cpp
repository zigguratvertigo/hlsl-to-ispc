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
/*
  Copyright (c) 2010-2014, Intel Corporation
  All rights reserved.

  Redistribution and use in source and binary forms, with or without
  modification, are permitted provided that the following conditions are
  met:

    * Redistributions of source code must retain the above copyright
      notice, this list of conditions and the following disclaimer.

    * Redistributions in binary form must reproduce the above copyright
      notice, this list of conditions and the following disclaimer in the
      documentation and/or other materials provided with the distribution.

    * Neither the name of Intel Corporation nor the names of its
      contributors may be used to endorse or promote products derived from
      this software without specific prior written permission.


   THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS "AS
   IS" AND ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED
   TO, THE IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A
   PARTICULAR PURPOSE ARE DISCLAIMED. IN NO EVENT SHALL THE COPYRIGHT OWNER
   OR CONTRIBUTORS BE LIABLE FOR ANY DIRECT, INDIRECT, INCIDENTAL, SPECIAL,
   EXEMPLARY, OR CONSEQUENTIAL DAMAGES (INCLUDING, BUT NOT LIMITED TO,
   PROCUREMENT OF SUBSTITUTE GOODS OR SERVICES; LOSS OF USE, DATA, OR
   PROFITS; OR BUSINESS INTERRUPTION) HOWEVER CAUSED AND ON ANY THEORY OF
   LIABILITY, WHETHER IN CONTRACT, STRICT LIABILITY, OR TORT (INCLUDING
   NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT OF THE USE OF THIS
   SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.
*/

#ifdef _MSC_VER
#define _CRT_SECURE_NO_WARNINGS
#define NOMINMAX
#pragma warning (disable: 4244)
#pragma warning (disable: 4305)
#endif

#include <cstdlib>
#include <stdio.h>
#include <algorithm>
#include "../timing.h"
#include "worley_ispc.h"
#include <string.h>
using namespace ispc;

extern void worley_serial(float x0, float y0, float x1, float y1,
    int width, int height, float output[]);


static float* buf;

static unsigned char clamp(float f)
{
    int i = (int)(f * 255.5);

    if (i < 0) i = 0;
    if (i > 255) i = 255;

    return (unsigned char)i;
}

/* Write a PPM image file with the image */
static void writePPM(int width, int height, const char *fn)
{
    FILE *fp = fopen(fn, "wb");
    fprintf(fp, "P6\n");
    fprintf(fp, "%d %d\n", width, height);
    fprintf(fp, "255\n");

    for (int i = 0; i < width*height; ++i)
    {
        float v = buf[i] * 255.f;
        if (v < 0) v = 0;
        if (v > 255) v = 255;
        for (int j = 0; j < 3; ++j)
            fputc((char)v, fp);
    }
    fclose(fp);
}

static void writeColorPPM(int width, int height, const char *fn)
{
    unsigned char* img = new unsigned char[width * height * 3];

    for (int y = 0; y < height; y++)
    {
        for (int x = 0; x < width; x++)
        {
            img[3 * (y * width + x) + 0] = clamp(buf[3 * (y * width + x) + 0]);
            img[3 * (y * width + x) + 1] = clamp(buf[3 * (y * width + x) + 1]);
            img[3 * (y * width + x) + 2] = clamp(buf[3 * (y * width + x) + 2]);
        }
    }

    FILE *fp = fopen(fn, "wb");
    if (!fp) {
        perror(fn);
        exit(1);
    }

    fprintf(fp, "P6\n");
    fprintf(fp, "%d %d\n", width, height);
    fprintf(fp, "255\n");
    fwrite(img, width * height * 3, 1, fp);
    fclose(fp);
    printf("Wrote image file %s\n", fn);

    delete[] img;
}

int main(int argc, char *argv[])
{
    static unsigned int test_iterations[] = { 3, 1 };
    unsigned int width = 1024;
    unsigned int height = 1024;
    float x0 = -10;
    float x1 = 10;
    float y0 = -10;
    float y1 = 10;

    if (argc > 1)
    {
        if (strncmp(argv[1], "--splits=", 8) == 0)
        {
            float splits = atof(argv[1] + 8);
            x0 = -splits / 2;
            x1 = splits / 2;
            y0 = -splits / 2;
            y1 = splits / 2;
        }
    }

    buf = new float[3 * width*height];

    //
    // Compute the image using the ispc implementation; report the minimum
    // time of n runs.
    //
    double minISPC = 1e30;
    for (unsigned int i = 0; i < test_iterations[0]; ++i)
    {
        reset_and_start_timer();
        ispcMain(x0, y0, x1, y1, width, height, buf);
        double dt = get_elapsed_mcycles();
        printf("@time of ISPC run:\t\t\t[%.3f] million cycles\n", dt);
        minISPC = std::min(minISPC, dt);
    }

    printf("[noise ispc]:\t\t\t[%.3f] million cycles\n", minISPC);
    writeColorPPM(width, height, "worley-ispc.ppm");

    // Clear out the buffer
    for (unsigned int i = 0; i < width * height; ++i)
        buf[i] = 0;

    // 
    // And run the serial implementation 3 times, again reporting the
    // minimum time.
    //
    double minSerial = 1e30;
    for (unsigned int i = 0; i < test_iterations[1]; ++i)
    {
        reset_and_start_timer();
        worley_serial(x0, y0, x1, y1, width, height, buf);
        double dt = get_elapsed_mcycles();
        printf("@time of serial run:\t\t\t[%.3f] million cycles\n", dt);
        minSerial = std::min(minSerial, dt);
    }

    printf("[noise serial]:\t\t\t[%.3f] million cycles\n", minSerial);
    writeColorPPM(width, height, "worley-serial.ppm");

    printf("\t\t\t\t(%.2fx speedup from ISPC)\n", minSerial / minISPC);

    delete[] buf;

    return 0;
}
