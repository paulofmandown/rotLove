RogueLike Toolkit in Love
=========
Bringing [rot.js](http://ondras.github.io/rot.js/hp/) functionality to Love2D. The only modules that require Love2D are the display modules.

See [this page](http://paulofmandown.github.io/rotLove/) for a quick and dirty run down of all the functionality provided.

Included:
```
 * Display          - via [rlLove](https://github.com/paulofmandown/rlLove), only supports cp437 emulation 
                      rather than full font support.
 * TextDisplay      - Text based display, accepts supplied fonts
 * RNG              - via [RandmLua](http://love2d.org/forums/viewtopic.php?f=5&t=3424). 
                      Multiply With Carry, Linear congruential generator, and Mersenne Twister. 
                      Extended with set/getState methods.
 * StringGenerator  - Direct Port from [rot.js](http://ondras.github.io/rot.js/hp/)
 * Map              - Arena, Divided/Icey/Eller Maze, Digger/Uniform/Rogue* Dungeons. 
                      Ported from [rot.js](http://ondras.github.io/rot.js/hp/).
 * Noise Generator  - Simplex Noise
 * FOV              - Bresenham Line based Ray Casting, Precise Shadow Casting
 * Color            - 147 Predefined colors; generate valid colors from string; add, multiply, or interpolate colors; 
                      generate a random color from a reference and set of standard deviations. 
                      (straight port from [rot.js](http://ondras.github.io/rot.js/hp/))
 * Path Finding     - Dijkstra and AStar pathfinding ported from [rot.js](http://ondras.github.io/rot.js/hp/).
 * Lighting         - compute light emission and blending, ported from [rot.js](http://ondras.github.io/rot.js/hp/).
```
Getting started
==========
`git clone git://github.com/paulofmandown/rotLove.git`

Add the rotLove folder/directory to your project and require the rotLove file.
```lua
ROT=require 'rotLove/rotLove'
function love.load()
    f=ROT.Display()
    f:writeCenter('You did it!', math.floor(f:getHeight()/2))
end
function love.draw() f:draw() end
```

Demos Folder
==========
In Demos/main.lua (you'll want the demos branch), uncomment the line for the demo you'd like to see.

Then, from the Demos directory in the shell, run `love .`
