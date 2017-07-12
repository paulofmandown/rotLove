-- Some of Jasmine's API mapped onto Busted. Makes tests easier to port.
return function (assert)
    return function (a)
        return {
            toEqual = function (b) return assert.are.same(b, a) end,
            toBe = function (b) return assert.are.equal(b, a) end,
        }
    end
end

