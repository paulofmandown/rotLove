local ROT = require 'src.rot'
local expect = require 'tests.expect' (assert)

describe("Color", function()
    describe("add", function()
        it("should add two colors", function()
            expect(ROT.Color.add({1,2,3}, {3,4,5})).toEqual({4,6,8})
        end)
        it("should add three colors", function()
            expect(ROT.Color.add({1,2,3}, {3,4,5}, {100,200,300})).toEqual({104,206,308})
        end)
        it("should add one color (noop)", function()
            expect(ROT.Color.add({1,2,3})).toEqual({1,2,3})
        end)

        it("should not modify first argument values", function()
            local c1 = {1,2,3}
            local c2 = {3,4,5}
            ROT.Color.add(c1, c2)
            expect(c1).toEqual({1,2,3})
        end)
    end)

    describe("add_", function()
        it("should add two colors", function()
            expect(ROT.Color.add_({1,2,3}, {3,4,5})).toEqual({4,6,8})
        end)
        it("should add three colors", function()
            expect(ROT.Color.add_({1,2,3}, {3,4,5}, {100,200,300})).toEqual({104,206,308})
        end)
        it("should add one color (noop)", function()
            expect(ROT.Color.add_({1,2,3})).toEqual({1,2,3})
        end)

        it("should modify first argument values", function()
            local c1 = {1,2,3}
            local c2 = {3,4,5}
            ROT.Color.add_(c1, c2)
            expect(c1).toEqual({4,6,8})
        end)
        it("should return first argument", function()
            local c1 = {1,2,3}
            local c2 = {3,4,5}
            local c3 = ROT.Color.add_(c1, c2)
            expect(c1).toBe(c3)
        end)
    end)

    describe("multiply", function()
        it("should multiply two colors", function()
            expect(ROT.Color.multiply({100,200,300}, {51,51,51})).toEqual({20,40,60})
        end)
        it("should multiply three colors", function()
            expect(ROT.Color.multiply({100,200,300}, {51,51,51}, {510,510,510})).toEqual({40,80,120})
        end)
        it("should multiply one color (noop)", function()
            expect(ROT.Color.multiply({1,2,3})).toEqual({1,2,3})
        end)
        it("should not modify first argument values", function()
            local c1 = {1,2,3}
            local c2 = {3,4,5}
            ROT.Color.multiply(c1, c2)
            expect(c1).toEqual({1,2,3})
        end)
        it("should round values", function()
            expect(ROT.Color.multiply({100,200,300}, {10, 10, 10})).toEqual({4,8,12})
        end)
    end)

    describe("multiply_", function()
        it("should multiply two colors", function()
            expect(ROT.Color.multiply_({100,200,300}, {51,51,51})).toEqual({20,40,60})
        end)
        it("should multiply three colors", function()
            expect(ROT.Color.multiply_({100,200,300}, {51,51,51}, {510,510,510})).toEqual({40,80,120})
        end)
        it("should multiply one color (noop)", function()
            expect(ROT.Color.multiply_({1,2,3})).toEqual({1,2,3})
        end)
        it("should modify first argument values", function()
            local c1 = {100,200,300}
            local c2 = {51,51,51}
            ROT.Color.multiply_(c1, c2)
            expect(c1).toEqual({20,40,60})
        end)
        it("should round values", function()
            expect(ROT.Color.multiply_({100,200,300}, {10, 10, 10})).toEqual({4,8,12})
        end)
        it("should return first argument", function()
            local c1 = {1,2,3}
            local c2 = {3,4,5}
            local c3 = ROT.Color.multiply_(c1, c2)
            expect(c1).toBe(c3)
        end)
    end)

    describe("fromString", function()
        it("should handle rgb() colors", function()
            expect(ROT.Color.fromString("rgb(10, 20, 33)")).toEqual({10, 20, 33})
        end)
        it("should handle #abcdef colors", function()
            expect(ROT.Color.fromString("#1a2f3c")).toEqual({26, 47, 60})
        end)
        it("should handle #abc colors", function()
            expect(ROT.Color.fromString("#ca8")).toEqual({204, 170, 136})
        end)
        it("should handle named colors", function()
            expect(ROT.Color.fromString("red")).toEqual({255, 0, 0})
        end)
        it("should not handle nonexistant colors", function()
            expect(ROT.Color.fromString("lol")).toEqual({0, 0, 0})
        end)
    end)

    describe("toRGB", function()
        it("should serialize to rgb", function()
            expect(ROT.Color.toRGB({10, 20, 30})).toEqual("rgb(10,20,30)")
        end)
        it("should clamp values to 0..255", function()
            expect(ROT.Color.toRGB({-100, 20, 2000})).toEqual("rgb(0,20,255)")
        end)
    end)

    describe("toHex", function()
        it("should serialize to hex", function()
            expect(ROT.Color.toHex({10, 20, 40})).toEqual("#0a1428")
        end)
        it("should clamp values to 0..255", function()
            expect(ROT.Color.toHex({-100, 20, 2000})).toEqual("#0014ff")
        end)
    end)

    describe("interpolate", function()
        it("should intepolate two colors", function()
            expect(ROT.Color.interpolate({10, 20, 40}, {100, 200, 300}, 0.1)).toEqual({19, 38, 66})
        end)
        it("should round values", function()
            expect(ROT.Color.interpolate({10, 20, 40}, {15, 30, 53}, 0.5)).toEqual({13, 25, 47})
        end)
        it("should default to 0.5 factor", function()
            expect(ROT.Color.interpolate({10, 20, 40}, {20, 30, 40})).toEqual({15, 25, 40})
        end)
    end)

    describe("interpolateHSL", function()
        it("should intepolate two colors", function()
            expect(ROT.Color.interpolateHSL({10, 20, 40}, {100, 200, 300}, 0.1)).toEqual({12, 33, 73})
        end)
    end)

    describe("randomize", function()
        it("should maintain constant diff when a number is used", function()
            local c = ROT.Color.randomize({100, 100, 100}, 100)
            expect(c[1]).toBe(c[2])
            expect(c[2]).toBe(c[3])
        end)
    end)

    describe("rgb2hsl and hsl2rgb", function()
        it("should correctly convert to HSL and back", function()
            local rgb = {
                {255, 255, 255},
                {0, 0, 0},
                {255, 0, 0},
                {30, 30, 30},
                {100, 120, 140}
            }

            while (rgb.length) do
                local color = rgb.pop()
                local hsl = ROT.Color.rgb2hsl(color)
                local rgb2 = ROT.Color.hsl2rgb(hsl)
                expect(rgb2).toEqual(color)
            end
        end)

        it("should round converted values", function()
            local hsl = {0.5, 0, 0.3}
            local rgb = ROT.Color.hsl2rgb(hsl)
            for i=1, #rgb do
                expect(math.floor(rgb[i] + 0.5)).toEqual(rgb[i])
            end
        end)
    end)
end)

