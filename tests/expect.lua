-- Some of Jasmine's API mapped onto Busted. Makes tests easier to port.
return function (assert)
    return function (a)
        return {
            toEqual = function (b) return assert.are.same(b, a) end,
            toBe = function (b) return assert.are.equal(b, a) end,
            toBeGreaterThan = function (b) return assert.is_true(a > b) end,
            toBeLessThan = function (b) return assert.is_true(a < b) end,
            NOT = {
                toEqual = function (b) return assert.are_not.same(b, a) end,
                toBe = function (b) return assert.are_not.equal(b, a) end,
                toBeGreaterThan = function (b) return assert.is_not(a > b) end,
                toBeLessThan = function (b) return assert.is_not(a < b) end,
            }
        }
    end
end

