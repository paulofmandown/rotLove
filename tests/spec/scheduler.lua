local ROT = require 'src.rot'
local expect = require 'tests.expect' (assert)

describe("Scheduler", function()

    describe("Simple", function()
        local S = ROT.Scheduler.Simple()
        local A1 = "A1"
        local A2 = "A2"
        local A3 = "A3"
        before_each(function() S:clear() end)

        it("should schedule actors evenly", function()
            S:add(A1, true)
            S:add(A2, true)
            S:add(A3, true)
            local result = {}
            for i = 1, 6 do table.insert(result, S:next()) end
            expect(result).toEqual({A1, A2, A3, A1, A2, A3})
        end)

        it("should schedule one-time events", function()
            S:add(A1, false)
            S:add(A2, true)
            local result = {}
            for i = 1, 4 do table.insert(result, S:next()) end
            expect(result).toEqual({A1, A2, A2, A2})
        end)

        it("should remove repeated events", function()
            S:add(A1, false)
            S:add(A2, true)
            S:add(A3, true)
            S:remove(A2)
            local result = {}
            for i = 1, 4 do table.insert(result, S:next()) end
            expect(result).toEqual({A1, A3, A3, A3})
        end)

        it("should remove one-time events", function()
            S:add(A1, false)
            S:add(A2, false)
            S:add(A3, true)
            S:remove(A2)
            local result = {}
            for i = 1, 4 do table.insert(result, S:next()) end
            expect(result).toEqual({A1, A3, A3, A3})
        end)

    end)

    describe("Speed", function()
        local S = ROT.Scheduler.Speed()
        local A = { getSpeed = function(self) return self.speed end }
        local A50 = setmetatable({}, { __index = A }) A50.speed = 50
        local A100a = setmetatable({}, { __index = A }) A100a.speed = 100
        local A100b = setmetatable({}, { __index = A }) A100b.speed = 100
        local A200 = setmetatable({}, { __index = A }) A200.speed = 200

        before_each(function() S:clear() end)

        it("should schedule same speed evenly", function()
            S:add(A100a, true)
            S:add(A100b, true)
            local result = {}
            for i = 1, 4 do table.insert(result, S:next()) end

            expect(result).toEqual({A100a, A100b, A100a, A100b})
        end)

        it("should schedule different speeds properly", function()
            S:add(A50, true)
            S:add(A100a, true)
            S:add(A200, true)
            local result = {}
            for i = 1, 7 do table.insert(result, S:next()) end
            expect(result).toEqual({A200, A100a, A200, A200, A50, A100a, A200})
        end)

        it("should schedule with initial offsets", function()
            S:add(A50, true, 1/300)
            S:add(A100a, true, 0)
            S:add(A200, true)
            local result = {}
            for i = 1, 9 do table.insert(result, S:next()) end
            expect(result).toEqual({A100a, A50, A200, A100a, A200, A200, A100a, A200, A50})
        end)

        it("should look up the time of an event", function()
            S:add(A100a, true)
            S:add(A50, true, 1/200)
            expect(S:getTimeOf(A50)).toEqual(1/200)
            expect(S:getTimeOf(A100a)).toEqual(1/100)
        end)

    end)

    describe("Action", function()
        local S = null
        local A1 = "A1"
        local A2 = "A2"
        local A3 = "A3"
        before_each(function() S = ROT.Scheduler.Action() end)

        it("should schedule evenly by default", function()
            S:add(A1, true)
            S:add(A2, true)
            S:add(A3, true)
            local result = {}
            for i = 1, 6 do table.insert(result, S:next()) end
            expect(result).toEqual({A1, A2, A3, A1, A2, A3})
        end)

        it("should schedule with respect to extra argument", function()
            S:add(A1, true)
            S:add(A2, true, 2)
            S:add(A3, true)
            local result = {}
            for i = 1, 6 do table.insert(result, S:next()) end
            expect(result).toEqual({A1, A3, A2, A1, A3, A2})
        end)

        it("should schedule with respect to action duration", function()
            S:add(A1, true)
            S:add(A2, true)
            S:add(A3, true)
            local result = {}

            table.insert(result, S:next())
            S:setDuration(10)

            table.insert(result, S:next())
            S:setDuration(5)

            table.insert(result, S:next())
            S:setDuration(1)
            expect(S:getTime()).toEqual(1)

            for i = 1, 3 do
                table.insert(result, S:next())
                S:setDuration(100) -- somewhere in the future
            end

            expect(result).toEqual({A1, A2, A3, A3, A2, A1})
        end)
    end)
end)

