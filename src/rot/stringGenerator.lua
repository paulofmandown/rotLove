--- Random String Generator.
-- Learns from provided strings, and generates similar strings.
-- @module ROT.StringGenerator
local ROT = require((...):gsub(('.[^./\\]*'):rep(1) .. '$', ''))
local StringGenerator = ROT.Class:extend("StringGenerator")

--- Constructor.
-- Called with ROT.StringGenerator:new()
-- @tparam table options A table with the following fields:
    -- @tparam[opt=false] boolean options.words Use word mode
    -- @tparam[opt=3] int options.order Number of letters/words to be used as context
    -- @tparam[opt=0.001] number options.prior A default priority for characters/words
function StringGenerator:init(options)
    self._options = {words=false,
                     order=3,
                     prior=0.001
                    }
    self._boundary=string.char(0)
    self._suffix  =string.char(0)
    self._prefix  ={}
    self._priorValues={}
    self._data    ={}
    if options then
        for k,v in pairs(options) do
            self._options[k]=v
        end
    end
    for _=1,self._options.order do
        table.insert(self._prefix, self._boundary)
    end
    self._priorValues[self._boundary]=self._options.prior
end

--- Remove all learned data
function StringGenerator:clear()
    self._data={}
    self._priorValues={}
end

--- Generate a string
-- @treturn string The generated string
function StringGenerator:generate()
    local result={self:_sample(self._prefix)}
    while result[#result] ~= self._boundary do
        table.insert(result, self:_sample(result))
    end
    table.remove(result)
    return table.concat(result)
end

--- Observe
-- Learn from a string
-- @tparam string s The string to observe
function StringGenerator:observe(s)
    local tokens = self:_split(s)
    for i=1,#tokens do
        self._priorValues[tokens[i]] = self._options.prior
    end
    local i=1
    for _,v in pairs(self._prefix) do
        table.insert(tokens, i, v)
        i=i+1
    end
    table.insert(tokens, self._suffix)
    for i=self._options.order,#tokens-1 do
        local context=table.slice(tokens, i-self._options.order+1, i)
        local evt    = tokens[i+1]
        for j=1,#context do
            local subcon=table.slice(context, j)
            self:_observeEvent(subcon, evt)
        end
    end
end

--- get Stats
-- Get info about learned strings
-- @treturn string Number of observed strings, number of contexts, number of possible characters/words
function StringGenerator:getStats()
    local parts={}
    local prC=0
    for _ in pairs(self._priorValues) do
        prC = prC + 1
    end
    prC=prC-1
    table.insert(parts, 'distinct samples: '..prC)
    local dataC=0
    local evtCount=0
    for k,_ in pairs(self._data) do
        dataC=dataC+1
        for _,_ in pairs(self._data[k]) do
            evtCount=evtCount+1
        end
    end
    table.insert(parts, 'dict size(cons): '..dataC)
    table.insert(parts, 'dict size(evts): '..evtCount)
    return table.concat(parts, ', ')
end

function StringGenerator:_split(str)
    return str:split(self._options.words and " " or "")
end

function StringGenerator:_join(arr)
    return table.concat(arr, self._options.words and " " or "")
end

function StringGenerator:_observeEvent(context, event)
    local key=self:_join(context)
    if not self._data[key] then
        self._data[key] = {}
    end
    if not self._data[key][event] then
        self._data[key][event] = 0
    end
    self._data[key][event]=self._data[key][event]+1
end
function StringGenerator:_sample(context)
    context   =self:_backoff(context)
    local key =self:_join(context)
    local data=self._data[key]
    local avail={}
    if self._options.prior then
        for k,_ in pairs(self._priorValues) do
            avail[k] = self._priorValues[k]
        end
        for k,_ in pairs(data) do
            avail[k] = avail[k]+data[k]
        end
    else
        avail=data
    end
    return self:_pickRandom(avail)
end

function StringGenerator:_backoff(context)
    local ctx = {}
    for i=1,#context do ctx[i]=context[i] end
    if #ctx > self._options.order then
        while #ctx > self._options.order do table.remove(ctx, 1) end
    elseif #ctx < self._options.order then
        while #ctx < self._options.order do table.insert(ctx,1,self._boundary) end
    end
    while not self._data[self:_join(ctx)] and #ctx>0 do
        ctx=table.slice(ctx, 2)
    end

    return ctx
end

function StringGenerator:_pickRandom(data)
    local total =0
    for k,_ in pairs(data) do
        total=total+data[k]
    end
    local rand=self._rng:random()*total
    local i=0
    for k,_ in pairs(data) do
        i=i+data[k]
        if (rand<i) then
            return k
        end
    end
end

return StringGenerator
