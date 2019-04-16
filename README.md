# lean-hap
Lean-HAP intends to provide a (super!) optimized version of The HAP stack - HAProxy, Apache and PHP7.

All (well, currently most) of the required packages are compiled locally with the most recent GCC version
using compiler optimization flags not commonly present in regular OS packages - also allowing module customization, and unbeatable performance.

# Why not just use the regular OS packages?
Short answer: Speed!
Packages provided by distros aim to be compatible with the most hardware possible. However, this implies a tradeoff with speed.
By compiling locally all the dependencies we can ensure that all the resources of your specific CPU will be used. 

# How are these claimed speed-ups implemented?
1) By always using the latest version of GCC, we take benefit of a vast number of code optimizations, and also we can enable most recent cpu capabilities (like AVX-512). These can bring huge benefits to performance.
We've seen over 70% speedups on SSL. Here's some detailed data: https://www.phoronix.com/scan.php?page=article&item=gcc-81-1280v5&num=1
2) Enable GCC further optimizations flags not often used by regular distros.
3) We aim, when possible, to statically compile everything \*we need\*, avoiding useless syscalls to load modules. 
4) Based off Alpine Linux, container size aims to be as small as possible.
5) Depedency libraries choices can also have some impact on performance. For instance, in HAProxy we use libslz instead of standard zlib to increase compression performance.

# Can I run this in Prod?
Only if you're brave enough. This is still under initial development.

# How do I start this thing?
"docker-compose up -d" should be enough to get you started.
