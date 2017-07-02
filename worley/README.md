# ispc-worley
This repository contains an [ISPC](https://ispc.github.io/index.html) implementation of <i>Worley Noise</i> [1], also known as cellular noise.

<img src="https://github.com/zigguratvertigo/ispc-worley/blob/master/worley.png" width=768 height=768>

Based on a set of irregular (or random) points, the distance to the closest point is approximated. [2]

When multiple octaves are combined, cellular-like behaviour is produced:

<img src="https://github.com/zigguratvertigo/ispc-worley/blob/master/worley-ispc.png" width=768 height=768>

A serial implementation is also provided, for comparison.

# ISPC
<i>ispc is a compiler for a variant of the C programming language, with extensions for "single program, multiple data" (SPMD) programming. Under the SPMD model, the programmer writes a program that generally appears to be a regular serial program, though the execution model is actually that a number of program instances execute in parallel on the hardware.</i> [4]

# Performance
On an i7-7700K @ 4.20GHz:
- Serial: 2255.734 million cycles
- ISPC: 272.316 million cycles

Overall, an 8.28x speedup from ISPC.

Additional optimizations are most likely possible, as this is a simple 1:1 conversion to ISPC. Performance will be revisited in the near future. For example, workload splitting can also be tweaked without changing the code (with --workloads=#). Finding the right number here can definitely change the performance metrics for the better.

# Running
To run the sample, simply execute the provided binary. 

In the event where you want to recompile, add this sample to the <i>examples</i> folder to the [ISPC codebase](https://github.com/ispc/ispc). If you don't feel like recompiling ISPC as well, you can also use the [pre-compiled ISPC binaries with the VS2015 solution](https://ispc.github.io/downloads.html) and again drop this sample in the <i>examples</i> folder.

# References
[1] Worley, Steven. "A Cellular Texture Basis Function", SIGGRAPH 1996, [Available Online](http://www.rhythmiccanvas.com/research/papers/worley.pdf) 

[2] Cozzi, Patrick and Riccio, Christophe. OpenGL Insights. CRC Press. pp. 113–115. 2012. [Available Online](https://books.google.com/books?id=CCVenzOGjpcC&pg=PA113)

[3] http://glslsandbox.com/e#23237.0

[4] ISPC, https://ispc.github.io/index.html
