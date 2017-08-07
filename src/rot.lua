local ROTLOVE_PATH = (...) .. '.'
local Class = require (ROTLOVE_PATH .. 'class')

local ROT = Class:extend('ROT', {
    DEFAULT_WIDTH =80,
    DEFAULT_HEIGHT=24,

    DIRS= {FOUR={
                { 0,-1},
                { 1, 0},
                { 0, 1},
                {-1, 0}
               },
           EIGHT={
                { 0,-1},
                { 1,-1},
                { 1, 0},
                { 1, 1},
                { 0, 1},
                {-1, 1},
                {-1, 0},
                {-1,-1}
               }
          }
})
package.loaded[...] = ROT

-- Concatenating assert function
-- see http://lua.space/general/assert-usage-caveat
function ROT.assert(pass, ...)
    if pass then
        return pass, ...
    elseif select('#', ...) > 0 then
        error(table.concat({...}), 2)
    else
        error('assertion failed!', 2)
    end
end

ROT.Class = Class

ROT.RNG = require (ROTLOVE_PATH .. 'rng')

-- bind a function to a class instance
function Class:bind (func)
    return function (...) return func(self, ...) end
end

-- get/set RNG instance for a class
-- used by maps, noise, dice, etc.
Class._rng = ROT.RNG
function Class:getRNG()
    return self._rng
end
function Class:setRNG(rng)
    self._rng = rng or ROT.RNG
    return self
end

require (ROTLOVE_PATH .. 'newFuncs')

ROT.Type = {} -- collection types tuned for various use cases
ROT.Type.PointSet    = require (ROTLOVE_PATH .. 'type.pointSet')
ROT.Type.Grid        = require (ROTLOVE_PATH .. 'type.grid')

ROT.Dice             = require (ROTLOVE_PATH .. 'dice')
ROT.Display          = require (ROTLOVE_PATH .. 'display')
ROT.TextDisplay      = require (ROTLOVE_PATH .. 'textDisplay')
ROT.StringGenerator  = require (ROTLOVE_PATH .. 'stringGenerator')
ROT.EventQueue       = require (ROTLOVE_PATH .. 'eventQueue')
ROT.Scheduler        = require (ROTLOVE_PATH .. 'scheduler')
ROT.Scheduler.Simple = require (ROTLOVE_PATH .. 'scheduler.simple')
ROT.Scheduler.Speed  = require (ROTLOVE_PATH .. 'scheduler.speed')
ROT.Scheduler.Action = require (ROTLOVE_PATH .. 'scheduler.action')
ROT.Engine           = require (ROTLOVE_PATH .. 'engine')
ROT.Map              = require (ROTLOVE_PATH .. 'map')
ROT.Map.Arena        = require (ROTLOVE_PATH .. 'map.arena')
ROT.Map.DividedMaze  = require (ROTLOVE_PATH .. 'map.dividedMaze')
ROT.Map.IceyMaze     = require (ROTLOVE_PATH .. 'map.iceyMaze')
ROT.Map.EllerMaze    = require (ROTLOVE_PATH .. 'map.ellerMaze')
ROT.Map.Cellular     = require (ROTLOVE_PATH .. 'map.cellular')
ROT.Map.Dungeon      = require (ROTLOVE_PATH .. 'map.dungeon')
ROT.Map.Feature      = require (ROTLOVE_PATH .. 'map.feature')
ROT.Map.Room         = require (ROTLOVE_PATH .. 'map.room')
ROT.Map.Corridor     = require (ROTLOVE_PATH .. 'map.corridor')
ROT.Map.Digger       = require (ROTLOVE_PATH .. 'map.digger')
ROT.Map.Uniform      = require (ROTLOVE_PATH .. 'map.uniform')
ROT.Map.Rogue        = require (ROTLOVE_PATH .. 'map.rogue')
ROT.Map.BrogueRoom   = require (ROTLOVE_PATH .. 'map.brogueRoom')
ROT.Map.Brogue       = require (ROTLOVE_PATH .. 'map.brogue')
ROT.Noise            = require (ROTLOVE_PATH .. 'noise')
ROT.Noise.Simplex    = require (ROTLOVE_PATH .. 'noise.simplex')
ROT.FOV              = require (ROTLOVE_PATH .. 'fov')
ROT.FOV.Precise      = require (ROTLOVE_PATH .. 'fov.precise')
ROT.FOV.Bresenham    = require (ROTLOVE_PATH .. 'fov.bresenham')
ROT.FOV.Recursive    = require (ROTLOVE_PATH .. 'fov.recursive')
ROT.Color            = require (ROTLOVE_PATH .. 'color')
ROT.Lighting         = require (ROTLOVE_PATH .. 'lighting')
ROT.Path             = require (ROTLOVE_PATH .. 'path')
ROT.Path.Dijkstra    = require (ROTLOVE_PATH .. 'path.dijkstra')
ROT.Path.DijkstraMap = require (ROTLOVE_PATH .. 'path.dijkstraMap')
ROT.Path.AStar       = require (ROTLOVE_PATH .. 'path.astar')
ROT.Text             = require (ROTLOVE_PATH .. 'text')

return ROT

