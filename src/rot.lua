local ROTLOVE_PATH =({...})[1]:gsub("[%.\\/]rot$", "") .. '/'
local class  =require (ROTLOVE_PATH .. 'vendor/30log')

ROT=class {
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
}

require (ROTLOVE_PATH .. 'newFuncs')

--[[--------------------------------]]--
-- All RNG 'classes' and functions derived from RandomLua
--[[------------------------------------
RandomLua v0.3.1
Pure Lua Pseudo-Random Numbers Generator
Under the MIT license.
copyright(c) 2011 linux-man
--]]------------------------------------
ROT.RNG              = require (ROTLOVE_PATH .. 'rng')
ROT.RNG.Twister      = require (ROTLOVE_PATH .. 'twister')
ROT.RNG.LCG          = require (ROTLOVE_PATH .. 'lcg')
ROT.RNG.MWC          = require (ROTLOVE_PATH .. 'mwc')
--[[--------------------------------]]--

ROT.Display          = require (ROTLOVE_PATH .. 'display')
ROT.StringGenerator  = require (ROTLOVE_PATH .. 'stringGenerator')
ROT.EventQueue       = require (ROTLOVE_PATH .. 'eventQueue')
ROT.Scheduler        = require (ROTLOVE_PATH .. 'scheduler')
ROT.Scheduler.Simple = require (ROTLOVE_PATH .. 'simple')
ROT.Scheduler.Speed  = require (ROTLOVE_PATH .. 'speed')
ROT.Scheduler.Action = require (ROTLOVE_PATH .. 'action')
ROT.Engine           = require (ROTLOVE_PATH .. 'engine')
ROT.Map              = require (ROTLOVE_PATH .. 'map')
ROT.Map.Arena        = require (ROTLOVE_PATH .. 'arena')
ROT.Map.DividedMaze  = require (ROTLOVE_PATH .. 'dividedMaze')
ROT.Map.IceyMaze     = require (ROTLOVE_PATH .. 'iceyMaze')
ROT.Map.EllerMaze    = require (ROTLOVE_PATH .. 'ellerMaze')
ROT.Map.Cellular     = require (ROTLOVE_PATH .. 'cellular')
ROT.Map.Dungeon      = require (ROTLOVE_PATH .. 'dungeon')
ROT.Map.Feature      = require (ROTLOVE_PATH .. 'feature')
ROT.Map.Room         = require (ROTLOVE_PATH .. 'room')
ROT.Map.Corridor     = require (ROTLOVE_PATH .. 'corridor')
ROT.Map.Digger       = require (ROTLOVE_PATH .. 'digger')
ROT.Map.Uniform      = require (ROTLOVE_PATH .. 'uniform')
ROT.Map.Rogue        = require (ROTLOVE_PATH .. 'rogue')
ROT.Noise            = require (ROTLOVE_PATH .. 'noise')
ROT.Noise.Simplex    = require (ROTLOVE_PATH .. 'simplex')
ROT.FOV              = require (ROTLOVE_PATH .. 'fov')
ROT.FOV.Precise      = require (ROTLOVE_PATH .. 'precise')
ROT.Line             = require (ROTLOVE_PATH .. 'line')
ROT.Point            = require (ROTLOVE_PATH .. 'point')
ROT.FOV.Bresenham    = require (ROTLOVE_PATH .. 'bresenham')
ROT.Color            = require (ROTLOVE_PATH .. 'color')
ROT.Lighting         = require (ROTLOVE_PATH .. 'lighting')
ROT.Path             = require (ROTLOVE_PATH .. 'path')
ROT.Path.Dijkstra    = require (ROTLOVE_PATH .. 'dijkstra')
ROT.Path.AStar       = require (ROTLOVE_PATH .. 'astar')

return ROT

