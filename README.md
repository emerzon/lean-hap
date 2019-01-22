# leanphp7
LeanPHP7 intends to be a (very much) optimized version of PHP7, based off from Alpine, and build with GCC 8.2 with
agressive compiler optimization flags - Ready to be run as a docker image.


# How?
1) Always using latest GCC version in order to take advantage from code optimizations. This can lead up to 30% increase in performance!
2) Enable GCC further optimizations flags (-O3 or -Ofast)
3) Statically compile everything! While modular architecture is useful in some cases, it does add a (tiny) overhead.
By stitically compiling PHP binaries along with the modules you also benefit from optimizations from #1 and #2 which are 
normally not done in system shared libs.
4) Based off Alpine Linux, container size aims to be as small as possible.
