# ispc-flower
This repository contains an [ISPC](https://ispc.github.io/index.html) implementation of the <i>Deform - Flower</i> shadertoy from [Inigo Quilez](https://www.shadertoy.com/view/4dX3Rn). [1]

<img src="https://github.com/zigguratvertigo/ispc-flower/blob/master/Results/flower-ispc.png?raw=true">

This implementation is part of a series of shaders that have been converted from HLSL/GLSL to ISPC using my [HLSL-to-ISPC helper library](https://github.com/zigguratvertigo/hlsl-to-ispc) [2].

# Shadertoy vs ISPC
### t = 7
<img src="https://github.com/zigguratvertigo/ispc-flower/blob/master/Results/flower.png?raw=true">

<u>ISPC:</u>
<img src="https://github.com/zigguratvertigo/ispc-flower/blob/master/Results/flower-ispc.png?raw=true">

# ISPC
<i>ispc is a compiler for a variant of the C programming language, with extensions for "single program, multiple data" (SPMD) programming. Under the SPMD model, the programmer writes a program that generally appears to be a regular serial program, though the execution model is actually that a number of program instances execute in parallel on the hardware.</i> [4]

# Running
To run the sample, simply execute the provided binary. 

In the event where you want to recompile, add this sample to the <i>examples</i> folder to the [ISPC codebase](https://github.com/ispc/ispc). If you don't feel like recompiling ISPC as well, you can also use the [pre-compiled ISPC binaries with the VS2015 solution](https://ispc.github.io/downloads.html) and again drop this sample in the <i>examples</i> folder.

# References
[1] Quilez, Inigo. _Deform - Flower_. Shadertoy. [https://www.shadertoy.com/view/4dX3Rn](https://www.shadertoy.com/view/4dX3Rn) 

[2] Barré-Brisebois, Colin. <i>HLSL to ISPC: ispc-hlsl</i>. [https://github.com/zigguratvertigo/hlsl-to-ispc](https://github.com/zigguratvertigo/hlsl-to-ispc) 
