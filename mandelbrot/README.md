# ispc-mandelbrot
This repository contains an [ISPC](https://ispc.github.io/index.html) implementation of the <i>Mandelbrot</i> set fractal [1], based on [Inigo Quilez's distance estimation](https://www.shadertoy.com/view/lsX3W4) [2]. 

<img src="https://github.com/zigguratvertigo/ispc-mandelbrot/blob/master/Results/mandelbrotDistance-ispc.png?raw=true">

This implementation is part of a series of shaders that have been converted from HLSL/GLSL to ISPC using my [HLSL-to-ISPC helper library](https://github.com/zigguratvertigo/hlsl-to-ispc) [3].

<i>Note: The ISPC examples contain an [implementation of the Mandelbrot set](https://ispc.github.io/example.html), though Inigo Quilez's distance-based approach undeniably looks better.</i>

# Shadertoy vs ISPC
### t = 0
<img src="https://github.com/zigguratvertigo/ispc-mandelbrot/blob/master/Results/mandelbrotDistance.png?raw=true">

<u>ISPC:</u>
<img src="https://github.com/zigguratvertigo/ispc-mandelbrot/blob/master/Results/mandelbrotDistance-ispc.png?raw=true">

### t = 10
<img src="https://github.com/zigguratvertigo/ispc-mandelbrot/blob/master/Results/mandelbrotDistance-10s.png?raw=true">

<u>ISPC:</u>
<img src="https://github.com/zigguratvertigo/ispc-mandelbrot/blob/master/Results/mandelbrotDistance-ispc-10s.png?raw=true">

# ISPC
<i>ispc is a compiler for a variant of the C programming language, with extensions for "single program, multiple data" (SPMD) programming. Under the SPMD model, the programmer writes a program that generally appears to be a regular serial program, though the execution model is actually that a number of program instances execute in parallel on the hardware.</i> [4]

# Performance
<i>TODO: Add ISPC vs serial performance numbers here.</i>

# Running
To run the sample, simply execute the provided binary. 

In the event where you want to recompile, add this sample to the <i>examples</i> folder to the [ISPC codebase](https://github.com/ispc/ispc). If you don't feel like recompiling ISPC as well, you can also use the [pre-compiled ISPC binaries with the VS2015 solution](https://ispc.github.io/downloads.html) and again drop this sample in the <i>examples</i> folder.

# References
[1] Mandelbrot, Benoit. _Les Objects Fractals: Forme, Hasard et Dimension_, 1975.

[2] Quilez, Inigo. _Mandelbrot Distance_. Shadertoy. [https://www.shadertoy.com/view/lsX3W4](https://www.shadertoy.com/view/lsX3W4) 

[3] Barré-Brisebois, Colin. <i>HLSL to ISPC: ispc-hlsl</i>. [https://github.com/zigguratvertigo/hlsl-to-ispc](https://github.com/zigguratvertigo/hlsl-to-ispc) 
