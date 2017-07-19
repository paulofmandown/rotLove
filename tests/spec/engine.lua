local ROT = require 'src.rot'
local expect = require 'tests.expect' (assert)

describe("Engine", function()
    local RESULT = 0
    local E = nil
    local S = nil
    local A50 = {
        getSpeed = function() return 50 end,
        act = function() RESULT = RESULT + 1 end,
    }
    local A100 = {
        getSpeed = function() return 100 end,
        act = function() E:lock() end,
    }
    local A70 = {
        getSpeed = function() return 70 end,
        act = function() RESULT = RESULT + 1; S:add(A100) end,
    }

    before_each(function()
        RESULT = 0
        S = ROT.Scheduler.Speed()
        E = ROT.Engine(S)
    end)

    it("should stop when locked", function()
        S:add(A50, true)
        S:add(A100, true)

        E:start()
        expect(RESULT).toEqual(0)
    end)

    it("should run until locked", function()
        S:add(A50, true)
        S:add(A70, true)
        E:start()
        expect(RESULT).toEqual(2)
    end)

    it("should run only when unlocked", function()
        S:add(A70, true)

        E:lock()
        E:start()
        expect(RESULT).toEqual(0)
        E:start()
        expect(RESULT).toEqual(1)
    end)
end)

