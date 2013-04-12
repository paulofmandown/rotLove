--ROTLOVE_PATH =({...})[1]:gsub("[%.\\/]rotLove$", "") .. '/'
--local class  =require (ROTLOVE_PATH .. 'vendor/30log')
local class  =require ('vendor/30log')
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

-- New Table Functions
-- returns random table element, nil if length is 0
function table.random(theTable)
	isATable(theTable)
	if #theTable==0 then return nil end
	return theTable[math.floor(math.random(#theTable))]
end
-- returns random valid index, nil if length is 0
function table.randomi(theTable)
	isATable(theTable)
	if #theTable==0 then return nil end
	return math.floor(math.random(#theTable))
end
-- randomly reorders the elements of the provided table and returns the result
function table.randomize(theTable)
	isATable(theTable)
	result={}
	while #theTable>0 do
		table.insert(result, table.remove(theTable, table.randomi(theTable)))
	end
	return result
end
-- asserts the type of 'theTable' is table
function isATable(theTable)
	assert(type(theTable)=='table', "bad argument #1 to 'random' (table expected got "..type..")")
end

-- New String functions
-- first letter capitalized
function string:capitalize()
	return self:sub(1,1):upper() .. self:sub(2)
end
-- returns string of length n consisting of only char c
function charNTimes(c, n)
	assert(#c==1, 'character must be a string of length 1')
	s=''
	for i=1,n and n or 2 do
		s=s..c
	end
	return s
end
-- left pad with c char, repeated n times
function string:lpad(c, n)
	s=charNTimes(c, n)
	return s..self
end
-- right pad with c char, repeated n times
function string:rpad(c, n)
	s=charNTimes(c, n)
	return self..s
end

-- Start FUN
