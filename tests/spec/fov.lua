local ROT = require 'src.rot'
local expect = require 'tests.expect' (assert)

ROT.FOV.PreciseShadowcasting = ROT.FOV.Precise
ROT.FOV.RecursiveShadowcasting = ROT.FOV.Recursive

local function xit () end
local function xdescribe () end

describe("FOV", function()
    local MAP8_RING0 = {
        "#####",
        "#####",
        "##@##",
        "#####",
        "#####"
    }

    local RESULT_MAP8_RING0 = {
        "     ",
        " ... ",
        " ... ",
        " ... ",
        "     "
    }

    local RESULT_MAP8_RING0_90_NORTH = {
        "     ",
        " ... ",
        "  .  ",
        "     ",
        "     "
    }

    local RESULT_MAP8_RING0_90_SOUTH = {
        "     ",
        "     ",
        "  .  ",
        " ... ",
        "     "
    }

    local RESULT_MAP8_RING0_90_EAST = {
        "     ",
        "   . ",
        "  .. ",
        "   . ",
        "     "
    }

    local RESULT_MAP8_RING0_90_WEST = {
        "     ",
        " .   ",
        " ..  ",
        " .   ",
        "     "
    }

    local RESULT_MAP8_RING0_180_NORTH = {
        "     ",
        " ... ",
        " ... ",
        "     ",
        "     "
    }

    local RESULT_MAP8_RING0_180_SOUTH = {
        "     ",
        "     ",
        " ... ",
        " ... ",
        "     "
    }

    local RESULT_MAP8_RING0_180_EAST = {
        "     ",
        "  .. ",
        "  .. ",
        "  .. ",
        "     "
    }

    local RESULT_MAP8_RING0_180_WEST = {
        "     ",
        " ..  ",
        " ..  ",
        " ..  ",
        "     "
    }

    local MAP8_RING1 = {
        "#####",
        "#...#",
        "#.@.#",
        "#...#",
        "#####"
    }

    local MAP8_PARTIAL = {
        "#####",
        "##..#",
        "#.@.#",
        "#...#",
        "#####"
    }

    local RESULT_MAP8_RING1 = {
        ".....",
        ".....",
        ".....",
        ".....",
        "....."
    }

    local buildLightCallback = function(map)
        local center = {0, 0}
        -- locate center
        for j = 1, #map do
            for i = 1, #map[j] do
                if map[j]:sub(i, i) == "@" then
                    center = {i, j}
                end
            end
        end

        -- XXX: initial argument added for lua version
        local result = function(_, x, y)
            local ch = map[y]:sub(x, x)
            return (ch ~= "#")
        end
        return result, center
    end

    local checkResult = function(fov, center, result, radius)
        local used = {}
        local callback = function(x, y, dist)
            expect(result[y]:sub(x, x)).toEqual(".")
            used[x..","..y] = 1
        end

        fov:compute(center[1], center[2], radius or 2, callback)
        -- io.write '\n'
        for j = 1, #result do
            -- io.write '\n'
            for i = 1, #result[j] do
                -- io.write(used[i..","..j] or 'x')
                if (result[j]:sub(i, i) == ".") then
                    expect(used[i..","..j]).NOT.toBeUndefined()
                end
            end
        end
    end

    local checkResult90Degrees = function(fov, dir, center, result)
        local used = {}
        local callback = function(x, y, dist)
            expect(result[y]:sub(x, x)).toEqual(".")
            used[x..","..y] = 1
        end

        fov:compute90(center[1], center[2], 2, dir, callback)
        for j = 1, #result do
            for i = 1, #result[j] do
                if (result[j]:sub(i, i) == ".") then
                    expect(used[i..","..j]).NOT.toBeUndefined()
                end
            end
        end
    end

    local checkResult180Degrees = function(fov, dir, center, result)
        local used = {}
        local callback = function(x, y, dist)
            expect(result[y]:sub(x, x)).toEqual(".")
            used[x..","..y] = 1
        end

        fov:compute180(center[1], center[2], 2, dir, callback)
        -- io.write '\n'
        for j = 1, #result do
            -- io.write '\n'
            for i = 1, #result[j] do
                -- io.write(used[i..","..j] or 'x')
                if (result[j]:sub(i, i) == ".") then
                    expect(used[i..","..j]).NOT.toBeUndefined()
                end
            end
        end
    end

    xdescribe("Discrete Shadowcasting", function()
        describe("8-topology", function()
            it("should compute visible ring0", function()
                local lightPasses, center = buildLightCallback(MAP8_RING0)
                local fov = ROT.FOV.DiscreteShadowcasting(lightPasses, {topology=8})
                checkResult(fov, center, RESULT_MAP8_RING0)
            end)
            it("should compute visible ring1", function()
                local lightPasses, center = buildLightCallback(MAP8_RING1)
                local fov = ROT.FOV.DiscreteShadowcasting(lightPasses, {topology=8})
                checkResult(fov, center, RESULT_MAP8_RING1)
            end)
        end)
    end)

    describe("Precise Shadowcasting", function()
        describe("8-topology", function()
            local topology = 8
            it("should compute visible ring0", function()
                local lightPasses, center = buildLightCallback(MAP8_RING0)
                local fov = ROT.FOV.PreciseShadowcasting(lightPasses, {topology=topology})
                checkResult(fov, center, RESULT_MAP8_RING0)
            end)
            it("should compute visible ring1", function()
                local lightPasses, center = buildLightCallback(MAP8_RING1)
                local fov = ROT.FOV.PreciseShadowcasting(lightPasses, {topology=topology})
                checkResult(fov, center, RESULT_MAP8_RING1)
            end)
            xit("should compute single visible target", function()
                local lightPasses, center = buildLightCallback(MAP8_RING1)
                local fov = ROT.FOV.PreciseShadowcasting(lightPasses, {topology=topology})
                local result = fov:computeSingle(center[1], center[2], 2, 0, 1)
                expect(result).toBe(1)
            end)
            xit("should compute single invisible target", function()
                local lightPasses, center = buildLightCallback(MAP8_RING0)
                local fov = ROT.FOV.PreciseShadowcasting(lightPasses, {topology=topology})
                local result = fov:computeSingle(center[1], center[2], 2, 0, 1)
                expect(result).toBe(0)
            end)
            xit("should compute single partially visible target", function()
                local lightPasses, center = buildLightCallback(MAP8_PARTIAL)
                local fov = ROT.FOV.PreciseShadowcasting(lightPasses, {topology=topology})
                local result = fov:computeSingle(center[1], center[2], 2, 0, 1)
                expect(result).toBe(0.5)
            end)
        end)
    end)

    describe("Recursive Shadowcasting", function()
        describe("8-topology", function()
            describe("360-degree view", function ()
                it("should compute visible ring0 in 360 degrees", function()
                    local lightPasses, center = buildLightCallback(MAP8_RING0)
                    local fov = ROT.FOV.RecursiveShadowcasting(lightPasses, {topology=8})
                    checkResult(fov, center, RESULT_MAP8_RING0)
                end)
                it("should compute visible ring1 in 360 degrees", function()
                    local lightPasses, center = buildLightCallback(MAP8_RING1)
                    local fov = ROT.FOV.RecursiveShadowcasting(lightPasses, {topology=8})
                    checkResult(fov, center, RESULT_MAP8_RING1)
                end)
            end)
            describe("180-degree view", function ()
                it("should compute visible ring0 180 degrees facing north", function()
                    local lightPasses, center = buildLightCallback(MAP8_RING0)
                    local fov = ROT.FOV.RecursiveShadowcasting(lightPasses, {topology=8})
                    checkResult180Degrees(fov, 1, center, RESULT_MAP8_RING0_180_NORTH)
                end)
                it("should compute visible ring0 180 degrees facing south", function()
                    local lightPasses, center = buildLightCallback(MAP8_RING0)
                    local fov = ROT.FOV.RecursiveShadowcasting(lightPasses, {topology=8})
                    checkResult180Degrees(fov, 5, center, RESULT_MAP8_RING0_180_SOUTH)
                end)
                it("should compute visible ring0 180 degrees facing east", function()
                    local lightPasses, center = buildLightCallback(MAP8_RING0)
                    local fov = ROT.FOV.RecursiveShadowcasting(lightPasses, {topology=8})
                    checkResult180Degrees(fov, 3, center, RESULT_MAP8_RING0_180_EAST)
                end)
                it("should compute visible ring0 180 degrees facing west", function()
                    local lightPasses, center = buildLightCallback(MAP8_RING0)
                    local fov = ROT.FOV.RecursiveShadowcasting(lightPasses, {topology=8})
                    checkResult180Degrees(fov, 7, center, RESULT_MAP8_RING0_180_WEST)
                end)
            end)
            describe("90-degree view", function ()
                it("should compute visible ring0 90 degrees facing north", function()
                    local lightPasses, center = buildLightCallback(MAP8_RING0)
                    local fov = ROT.FOV.RecursiveShadowcasting(lightPasses, {topology=8})
                    checkResult90Degrees(fov, 1, center, RESULT_MAP8_RING0_90_NORTH)
                end)
                it("should compute visible ring0 90 degrees facing south", function()
                    local lightPasses, center = buildLightCallback(MAP8_RING0)
                    local fov = ROT.FOV.RecursiveShadowcasting(lightPasses, {topology=8})
                    checkResult90Degrees(fov, 5, center, RESULT_MAP8_RING0_90_SOUTH)
                end)
                it("should compute visible ring0 90 degrees facing east", function()
                    local lightPasses, center = buildLightCallback(MAP8_RING0)
                    local fov = ROT.FOV.RecursiveShadowcasting(lightPasses, {topology=8})
                    checkResult90Degrees(fov, 3, center, RESULT_MAP8_RING0_90_EAST)
                end)
                it("should compute visible ring0 90 degrees facing west", function()
                    local lightPasses, center = buildLightCallback(MAP8_RING0)
                    local fov = ROT.FOV.RecursiveShadowcasting(lightPasses, {topology=8})
                    checkResult90Degrees(fov, 7, center, RESULT_MAP8_RING0_90_WEST)
                end)
            end)
        end)
    end)
    
    describe("Bresenham", function()
        describe("8-topology", function()
            it("should compute visible ring0", function()
                local lightPasses, center = buildLightCallback(MAP8_RING0)
                local fov = ROT.FOV.Bresenham(lightPasses, {topology=8})
                checkResult(fov, center, RESULT_MAP8_RING0, 3)
            end)
            it("should compute visible ring1", function()
                local lightPasses, center = buildLightCallback(MAP8_RING1)
                local fov = ROT.FOV.Bresenham(lightPasses, {topology=8})
                checkResult(fov, center, RESULT_MAP8_RING1, 3)
            end)
        end)
    end)
    
end)

