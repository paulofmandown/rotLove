ROTLOVE_PATH =({...})[1]:gsub("[%.\\/]rot$", "") .. '/'
local class  =require (ROTLOVE_PATH .. 'vendor/30log')

ROT=class {
	DEFAULT_WIDTH =80,
	DEFAULT_HEIGHT=25,

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
		       },
		   SIX={
		   	    {-1,-1},
		   	    { 1,-1},
		   	    { 2, 0},
		   	    { 1, 1},
		   	    {-1, 1},
		   	    {-2, 0}
			   }
		  }
}

require (ROTLOVE_PATH .. 'newFuncs')
require (ROTLOVE_PATH .. 'vendor/RandomLua')

ROT.RNG              = { mwc=mwc(), lcg=lcg(), twister=twister()}
ROT.Display          = require (ROTLOVE_PATH .. 'display')
ROT.StringGenerator  = require (ROTLOVE_PATH .. 'stringGenerator')
ROT.EventQueue       = require (ROTLOVE_PATH .. 'eventQueue')
ROT.Scheduler        = require (ROTLOVE_PATH .. 'scheduler')
ROT.Scheduler.Simple = require (ROTLOVE_PATH .. 'simpleScheduler')
ROT.Scheduler.Speed  = require (ROTLOVE_PATH .. 'speedScheduler')
ROT.Scheduler.Action = require (ROTLOVE_PATH .. 'actionScheduler')
ROT.Engine           = require (ROTLOVE_PATH .. 'engine')

ROT.RNG.mwc:randomseed(os.time())
ROT.RNG.lcg:randomseed(os.time())
ROT.RNG.twister:randomseed(os.time())

return ROT
