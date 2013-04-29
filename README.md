RogueLike Toolkit in Love
=========
Bringing [rot.js](http://ondras.github.io/rot.js/hp/) functionality to Love2D

Currently Implemented:

Display          - via [rlLove](https://github.com/paulofmandown/rlLove), only supports cp437 emulation rather than full font support.

rng              - via [RandmLua](http://love2d.org/forums/viewtopic.php?f=5&t=3424), doesn't support state export

String Generator - Direct Port from [rot.js](http://ondras.github.io/rot.js/hp/)

Map              - Arena, Divided/Icey/Eller Maze, Digger/Uniform/Rogue* Dungeons. Ported from [rot.js](http://ondras.github.io/rot.js/hp/).

Noise Generator  - Simplex Noise

FOV              - Bresenham Line based Ray Casting


Demos Folder
==========
In Demos/main.lua, uncomment the line for the demo you'd like to see.

Then, from the Demos directory in the shell, run `love .`


To-Do
==========
Maps     - Rogue (*still has a fail-state, need to pin down)

FOV      - Precise Shadow Casting

Color    - Currently only supplies values defined by [Ascii Panel](https://github.com/trystan/AsciiPanel). Need to add functions defined with [rot.js](http://ondras.github.io/rot.js/hp/).

Lighting

Path     - Dijkstra, AStar
