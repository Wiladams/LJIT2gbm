# LJIT2gbm
LuaJIT binding to the libgbm buffer management library
libgbm is a helper library that wraps some buffer creation calls, and backend management for libdrm based drawing.  It's not of much use by itself, but here is the binding nonetheless.

This code would live most beautifully as part of the LLUI project.  But, it might be more expedient to rewrite it in Lua so that it could be used without reliance on the library.

References
  https://github.com/robclark/libgbm

Packages
    Ubuntu - libgbm-dev
