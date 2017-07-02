# HLSL-to-ISPC Utility Library
This repository contains a utility library with helper types and functions to provide similar syntax to [HLSL](https://msdn.microsoft.com/en-us/library/windows/desktop/bb509638(v=vs.85).aspx), but inside the [ISPC](https://ispc.github.io) programming environment.

This library is used by several projects listed below:

<table style="width:100%">
  <tr>
    <th><a href="https://github.com/zigguratvertigo/hlsl-to-ispc/tree/master/smallpt">smallpt</a></th>
    <th><a href="https://github.com/zigguratvertigo/hlsl-to-ispc/tree/master/mandelbrot">mandelbrot</a></th> 
  </tr>
  <tr>
    <td><img width=512 src="https://raw.githubusercontent.com/zigguratvertigo/hlsl-to-ispc/master/smallpt/Results/smallpt-ispc.png"></td>
    <td><img width=512 src="https://raw.githubusercontent.com/zigguratvertigo/hlsl-to-ispc/master/mandelbrot/Results/mandelbrotDistance-ispc-10s.png"></td>
  </tr>
  <tr>
    <th><a href="https://github.com/zigguratvertigo/hlsl-to-ispc/tree/master/flower">flower</a></th>
    <th><a href="https://github.com/zigguratvertigo/hlsl-to-ispc/tree/master/worley">worley</a></th> 
  </tr>
  <tr>
    <td><img width=512 src="https://raw.githubusercontent.com/zigguratvertigo/hlsl-to-ispc/master/flower/Results/flower-ispc.png"></td>
    <td><img width=512 src="https://raw.githubusercontent.com/zigguratvertigo/hlsl-to-ispc/master/worley/Results/worley-ispc-logo.png"></td> 
  </tr>
</table>

# Supported
- Vectors: float2/3/4, int2/3/4, bool2/3/4
- Matrices: float2x2/3x3/4x4
- HLSL [Intrinsics](https://msdn.microsoft.com/en-us/library/windows/desktop/ff471376(v=vs.85).aspx)
- (Basic) Texture2D sampling & addressing modes

# Usage
#include "hlsl.ispc" in your ISPC project files. You can also recompile all the projects via _hlsl-to-ispc.sln_.

# HLSL vs ISPC?
Since HLSL & GPU programming shares similar SPMD concepts as ISPC, it makes sense that a library could provide similar behaviour.

This library is meant to provide <i>good-enough</i> HLSL-like functionality in ISPC. Achieving high performance with ISPC requires more than simple code conversion. This library shouldn't be seen as be-all and end-all solution, but rather as a first step. ISPC has its own specificities, and it is vital to check the [programming guide](https://ispc.github.io/) to achieve performance. 

# Upcoming Features
More functionality to be added and overall behaviour to be improved.

- Additional work around ISPC-specifics
- Texture sampling emulation
- Unit testing of intrinsics
- Direct conversion of .HLSL files to .ISPC kernels (most likely a separate/parallel project)
- Support for GLSL intrinsics (maybe)
