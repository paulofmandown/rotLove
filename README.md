RogueLike Toolkit in Love
=========
Bringing [rot.js](http://ondras.github.io/rot.js/hp/) functionality to Love2D. The only modules that require Love2D are the display modules.

See [this page](http://paulofmandown.github.io/rotLove/) for a quick and dirty run down of all the functionality provided.

Included:

 * Display          - via [rlLove](https://github.com/paulofmandown/rlLove), only supports cp437 emulation
                      rather than full font support.
 * TextDisplay      - Text based display, accepts supplied fonts
 * RNG              - via [RandomLua](http://love2d.org/forums/viewtopic.php?f=5&t=3424).
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
 * Dice             - Roguelike based dice module ported from [RL-Dice](https://github.com/timothymtorres/RL-Dice).

Getting started
==========
`git clone git://github.com/paulofmandown/rotLove.git`

Add the contents of the src directory to lib/rotLove in your project and require the rot file.
```lua
ROT=require 'lib/rotLove/rot'
function love.load()
    f=ROT.Display()
    f:writeCenter('You did it!', math.floor(f:getHeight()/2))
end
function love.draw() f:draw() end
```

Examples
==========
rotLove has a number of demo projects in `examples/` that you can use to
get a feel for each API. To see a demo in action, run
```shell
    love . my-demo
```
from your shell.
