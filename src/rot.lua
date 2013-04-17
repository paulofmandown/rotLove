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

ROT.Display = require (ROTLOVE_PATH .. 'display')

require (ROTLOVE_PATH .. 'rng')
ROT.RNG = { mwc=mwc(), lcg=lcg(), twister=twister()}
ROT.RNG.mwc:randomseed(os.time())
ROT.RNG.lcg:randomseed(os.time())
ROT.RNG.twister:randomseed(os.time())

ROT.StringGenerator = require (ROTLOVE_PATH .. 'stringGenerator')

return ROT
