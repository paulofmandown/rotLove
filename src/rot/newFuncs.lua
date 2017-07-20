local ROT = require((...):gsub(('.[^./\\]*'):rep(1) .. '$', ''))

-- asserts the type of 'theTable' is table
local function isATable(theTable)
    ROT.assert(type(theTable)=='table', "bad argument #1 to 'random' (table expected got ",type(theTable),")")
end

-- returns string of length n consisting of only char c
local function charNTimes(c, n)
    ROT.assert(#c==1, 'character must be a string of length 1')
    local s=''
    for _=1,n and n or 2 do
        s=s..c
    end
    return s
end

-- New Table Functions
-- returns random table element, nil if length is 0
function table.random(theTable)
    isATable(theTable)
    if #theTable==0 then return nil end
    return theTable[math.floor(ROT.RNG:random(#theTable))]
end
-- returns random valid index, nil if length is 0
function table.randomi(theTable)
    isATable(theTable)
    if #theTable==0 then return nil end
    return math.floor(ROT.RNG:random(#theTable))
end
-- randomly reorders the elements of the provided table and returns the result
function table.randomize(theTable)
    isATable(theTable)
    local result={}
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
    if type(value)=='table' then return table.indexOfTable(values, value) end
    return 0
end

-- extended for use with tables of tables
function table.indexOfTable(values, value)
    if type(value)~='table' then return 0 end
    for k,v in ipairs(values) do
        if #v==#value then
            local match=true
            for i=1,#v do
                if v[i]~=value[i] then match=false end
            end
            if match then return k end
        end
    end
    return 0
end

-- New String functions
-- first letter capitalized
function string:capitalize()
    return self:sub(1,1):upper() .. self:sub(2)
end
-- left pad with c char, repeated n times
function string:lpad(c, n)
    c=c and c or '0'
    n=n and n or 2
    local s=''
    while #s < n-#self do s=s..c end
    return s..self
end
-- right pad with c char, repeated n times
function string:rpad(c, n)
    c=c and c or '0'
    n=n and n or 2
    local s=''
    while #s < n-#self do s=s..c end
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

