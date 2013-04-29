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
-- add js slice function
function table.slice (values,i1,i2)
	local res = {}
	local n = #values
	-- default values for range
	i1 = i1 or 1
	i2 = i2 or n
	if i2 < 0 then
		i2 = n + i2 + 1
	elseif i2 > n then
		i2 = n
	end
	if i1 < 1 or i1 > n then
		return {}
	end
	local k = 1
	for i = i1,i2 do
		res[k] = values[i]
		k = k + 1
	end
	return res
end
-- add js indexOf function
function table.indexOf(values,value)
	if values then
		for i=1,#values do
			if values[i] == value then return i end
		end
	end
	return 0
end

-- js splice
function table.splice(t, i, n, addTable)
    local removed = {}
    local tableSize = table.getn(t) -- Table size
    -- Lua 5.0 handling of vararg...
    local argNb = addTable and table.getn(addTable) or 0 -- Number of elements to insert
    -- Check parameter validity
    if i < 1 then i = 1 end
    if n < 0 then n = 0 end
    if i > tableSize then
        i = tableSize + 1 -- At end
        n = 0 -- Nothing to delete
    end
    if i + n  > tableSize then
        n = tableSize - i -- Adjust to number of elements at i
    end

    local argIdx = 1 -- i in addTable
    -- Replace min(n, argNb) entries
    for pos = i, i + math.min(n, argNb) - 1 do
        -- Copy removed entry
        table.insert(removed, t[pos])
        -- Overwrite entry
        t[pos] = addTable[argIdx]
        argIdx = argIdx + 1
    end
    argIdx = argIdx - 1
    -- If n > argNb, remove extra entries
    for i = 1, n - argNb do
        table.insert(removed, table.remove(t, i + argIdx))
    end
    -- If n < argNb, insert remaining new entries
    for i = argNb - n, 1, -1 do
        table.insert(t, i + n, addTable[argIdx + i])
    end
    return removed
end

-- asserts the type of 'theTable' is table
function isATable(theTable)
	assert(type(theTable)=='table', "bad argument #1 to 'random' (table expected got "..type(theTable)..")")
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
-- add js split function
function string:split(delim, maxNb)
    -- Eliminate bad cases...
    if string.find(self, delim) == nil then
        return { self }
    end
    local result = {}
    if delim == '' or not delim then
    	for i=1,#self do
    		result[i]=self:sub(i,i)
    	end
    	return result
    end
    if maxNb == nil or maxNb < 1 then
        maxNb = 0    -- No limit
    end
    local pat = "(.-)" .. delim .. "()"
    local nb = 0
    local lastPos
    for part, pos in string.gfind(self, pat) do
        nb = nb + 1
        result[nb] = part
        lastPos = pos
        if nb == maxNb then break end
    end
    -- Handle the last field
    if nb ~= maxNb then
        result[nb + 1] = string.sub(self, lastPos)
    end
    return result
end

function math.round(n, mult)
	mult = mult or 1
    return math.floor((n + mult/2)/mult) * mult
end

-- io.write(arg..'\n')
function write(str)
	io.write(str..'\n')
end
