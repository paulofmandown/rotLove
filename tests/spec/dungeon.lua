local ROT = require 'src.rot'
local expect = require 'tests.expect' (assert)

describe("Map.Dungeon", function()
    local names = { "Digger", "Uniform", "Brogue" }

    local buildDungeonTests = function(name)
        local ctor = ROT.Map[name]
        ROT.RNG:setSeed(123456)
        local map = ctor()
        map:create()
        local rooms = map:getRooms()
        local corridors = map:getCorridors()

        describe(name, function()
            it("should generate >0 rooms", function()
                expect(#rooms).toBeGreaterThan(0)
            end)

            it("all rooms should have at least one door", function()
                for i = 1, #rooms do
                    local room = rooms[i]
                    local doorCount = 0
                    room:create(function(x, y, value)
                        if value == 2 then doorCount = doorCount + 1 end
                    end)
                    expect(doorCount).toBeGreaterThan(0)
                end
            end)

            it("all rooms should have at least one wall", function()
                for i = 1, #rooms do
                    local room = rooms[i]
                    local wallCount = 0
                    room:create(function(x, y, value)
                        if value == 1 then wallCount = wallCount + 1 end
                    end)
                    expect(wallCount).toBeGreaterThan(0)
                end
            end)

            it("all rooms should have at least one empty cell", function()
                for i = 1, #rooms do
                    local room = rooms[i]
                    local emptyCount = 0
                    room:create(function(x, y, value)
                        if value == 0 then emptyCount = emptyCount + 1 end
                    end)
                    expect(emptyCount).toBeGreaterThan(0)
                end
            end)

            it("should generate >0 corridors", function()
                expect(#corridors).toBeGreaterThan(0)
            end)

            it("all corridors should have at least one empty cell", function()
                for i = 1, #corridors do
                    local corridor = corridors[i]
                    local emptyCount = 0
                    corridor:create(function(x, y, value)
                        if value == 0 then emptyCount = emptyCount + 1 end
                    end)
                    expect(emptyCount).toBeGreaterThan(0)
                end
            end)
        end)

    end

    while (#names > 0) do
        local name = names[#names]
        names[#names] = nil
        buildDungeonTests(name)
    end
end)

