# ispc-smallpt
This folder contains an [ISPC](https://ispc.github.io/index.html) implementation of Kevin Beason's [smallpt](http://www.kevinbeason.com/smallpt/). [1]

<img src="https://github.com/zigguratvertigo/hlsl-to-ispc/blob/master/smallpt/Results/smallpt-ispc.png?raw=true">

This implementation uses my [HLSL-to-ISPC helper library](https://github.com/zigguratvertigo/hlsl-to-ispc) [2].

# ISPC
<i>ispc is a compiler for a variant of the C programming language, with extensions for "single program, multiple data" (SPMD) programming. Under the SPMD model, the programmer writes a program that generally appears to be a regular serial program, though the execution model is actually that a number of program instances execute in parallel on the hardware.</i> [4]

# Running
To run the sample, simply execute the provided binary. You can also recompile it via _hlsl-to-ispc.sln_.

# References
[1] Beason, Kevin. _smallpt_. [http://www.kevinbeason.com/smallpt/](http://www.kevinbeason.com/smallpt/) 

[2] Barré-Brisebois, Colin. <i>HLSL to ISPC: ispc-hlsl</i>. [https://github.com/zigguratvertigo/hlsl-to-ispc](https://github.com/zigguratvertigo/ispc-hlsl) 
