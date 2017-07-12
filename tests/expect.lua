-- Some of Jasmine's API mapped onto Busted. Makes tests easier to port.


local function gt (_, args) return args[1] > args[2] end
local function lt (_, args) return args[1] < args[2] end

return function (assert)
    assert:register("assertion", "gt", gt, "assertion.gt.positive", "assertion.gt.negative")
    assert:register("assertion", "lt", lt, "assertion.lt.positive", "assertion.lt.negative")
    return function (a)
        return {
            toEqual = function (b) return assert.is.same(b, a) end,
            toBe = function (b) return assert.is.equal(b, a) end,
            toBeGreaterThan = function (b) return assert.gt(a, b) end,
            toBeLessThan = function (b) return assert.lt(a, b) end,
            NOT = {
                toEqual = function (b) return assert.Not.same(b, a) end,
                toBe = function (b) return assert.Not.equal(b, a) end,
                toBeGreaterThan = function (b) return assert.Not.gt(a, b) end,
                toBeLessThan = function (b) return assert.Not.lt(a, b) end,
            }
        }
    end
end

