local ROT = require 'src.rot'
local expect = require 'tests.expect' (assert)

local function xdescribe () end

-- used to adjust table of rot.js 0-based numbers to 1-based
local function toString(t) return table.concat(t, ',') end 
local function inc(t)
    for i = 1, #t do t[i] = t[i] + 1 end
    t.toString = toString
    return t
end

describe("Path", function()
    --[[
    /**
     * ........
     * A###.###
     * ..B#.#X#
     * .###.###
     * ....Z...
     */
     ]]
    local MAP48 = { -- transposed
        { 0, 0, 0, 0, 0 },    
        { 0, 1, 0, 1, 0 },    
        { 0, 1, 0, 1, 0 },    
        { 0, 1, 1, 1, 0 },    
        { 0, 0, 0, 0, 0 },
        { 0, 1, 1, 1, 0 },
        { 0, 1, 0, 1, 0 },
        { 0, 1, 1, 1, 0 }
    }
    
    local PASSABLE_CALLBACK_48 = function(x, y)
        if (x<1 or y<1 or x>#MAP48 or y>#MAP48[1]) then return false end
        return (MAP48[x][y] == 0)
    end

    local A = inc { 0, 1 }
    local B = inc { 2, 2 }
    local Z = inc { 4, 4 }
    local X = inc { 6, 2 }
    local PATH = { toString = toString }
    local PATH_CALLBACK = function(x, y)
        PATH[#PATH + 1] = x
        PATH[#PATH + 1] = y
    end

    --[[
    /*
     * . . A # . B
     *  . # # . .
     * . . # . . .
     *  # . . # .
     * X # # # Z .
     */
     ]]
    local MAP6 = { -- transposed
        { 0, nil, 0, nil, 0 },
        { nil, 0, nil, 1, nil },
        { 0, nil, 0, nil, 1 },
        { nil, 1, nil, 0, nil },
        { 0, nil, 1, nil, 1 },
        { nil, 1, nil, 0, nil },
        { 1, nil, 0, nil, 1 },
        { nil, 0, nil, 1, nil },
        { 0, nil, 0, nil, 0 },
        { nil, 0, nil, 0, nil },
        { 0, nil, 0, nil, 0 }
    }

    local A6 = inc { 4, 0 }
    local B6 = inc { 10, 0 }
    local Z6 = inc { 8, 4 }
    local X6 = inc { 0, 4 }
    
    local PASSABLE_CALLBACK_6 = function(x, y)
        if (x<1 or y<1 or x>#MAP6 or y>5) then return false end
        return (MAP6[x][y] == 0)
    end

    local VISITS = 0
    local PASSABLE_CALLBACK_VISIT = function(x, y)
        VISITS = VISITS + 1
        return true
    end
    
    before_each(function()
        PATH = { toString = toString }
        VISITS = 0
    end)
    
    
    describe("Dijkstra", function()
        describe("8-topology", function()
            local PATH_A = inc { 0, 1, 0, 2, 0, 3, 1, 4, 2, 4, 3, 4, 4, 4 }
            local PATH_B = inc { 2, 2, 1, 2, 0, 3, 1, 4, 2, 4, 3, 4, 4, 4 }
            local dijkstra = ROT.Path.Dijkstra(Z[1], Z[2], PASSABLE_CALLBACK_48, {topology=8})
            
            it("should compute correct path A", function()
                dijkstra:compute(A[1], A[2], PATH_CALLBACK)
                expect(PATH:toString()).toEqual(PATH_A:toString())
            end)

            it("should compute correct path B", function()
                dijkstra:compute(B[1], B[2], PATH_CALLBACK)
                expect(PATH:toString()).toEqual(PATH_B:toString())
            end)

            it("should survive non-existant path X", function()
                dijkstra:compute(X[1], X[2], PATH_CALLBACK)
                expect(#PATH).toEqual(0)
            end)
        end) -- 8-topology

        describe("4-topology", function()
            local PATH_A = inc { 0, 1, 0, 2, 0, 3, 0, 4, 1, 4, 2, 4, 3, 4, 4, 4 }
            local PATH_B = inc { 2, 2, 1, 2, 0, 2, 0, 3, 0, 4, 1, 4, 2, 4, 3, 4, 4, 4 }
            local dijkstra = ROT.Path.Dijkstra(Z[1], Z[2], PASSABLE_CALLBACK_48, {topology=4})
            
            it("should compute correct path A", function()
                dijkstra:compute(A[1], A[2], PATH_CALLBACK)
                expect(PATH:toString()).toEqual(PATH_A:toString())
            end)

            it("should compute correct path B", function()
                dijkstra:compute(B[1], B[2], PATH_CALLBACK)
                expect(PATH:toString()).toEqual(PATH_B:toString())
            end)

            it("should survive non-existant path X", function()
                dijkstra:compute(X[1], X[2], PATH_CALLBACK)
                expect(#PATH).toEqual(0)
            end)
        end) -- 4-topology

        xdescribe("6-topology", function()
            local PATH_A = inc { 4, 0, 2, 0, 1, 1, 2, 2, 3, 3, 5, 3, 6, 2, 8, 2, 9, 3, 8, 4 }
            local PATH_B = inc { 10, 0, 9, 1, 8, 2, 9, 3, 8, 4 }
            local dijkstra = ROT.Path.Dijkstra(Z6[1], Z6[2], PASSABLE_CALLBACK_6, {topology=6})
            
            it("should compute correct path A", function()
                dijkstra:compute(A6[1], A6[2], PATH_CALLBACK)
                expect(PATH:toString()).toEqual(PATH_A:toString())
            end)

            it("should compute correct path B", function()
                dijkstra:compute(B6[1], B6[2], PATH_CALLBACK)
                expect(PATH:toString()).toEqual(PATH_B:toString())
            end)

            it("should survive non-existant path X", function()
                dijkstra:compute(X6[1], X6[2], PATH_CALLBACK)
                expect(#PATH).toEqual(0)
            end)
        end) -- 6-topology

    end) -- dijkstra

    describe("A*", function()
        describe("8-topology", function()
            local PATH_A = inc { 0, 1, 0, 2, 0, 3, 1, 4, 2, 4, 3, 4, 4, 4 }
            local PATH_B = inc { 2, 2, 1, 2, 0, 3, 1, 4, 2, 4, 3, 4, 4, 4 }
            local astar = ROT.Path.AStar(Z[1], Z[2], PASSABLE_CALLBACK_48, {topology=8})
            
            it("should compute correct path A", function()
                astar:compute(A[1], A[2], PATH_CALLBACK)
                expect(PATH:toString()).toEqual(PATH_A:toString())
            end)

            it("should compute correct path B", function()
                astar:compute(B[1], B[2], PATH_CALLBACK)
                expect(PATH:toString()).toEqual(PATH_B:toString())
            end)

            it("should survive non-existant path X", function()
                astar:compute(X[1], X[2], PATH_CALLBACK)
                expect(#PATH).toEqual(0)
            end)

            it("should efficiently compute path",function()
                local open_astar = ROT.Path.AStar(1,1, PASSABLE_CALLBACK_VISIT)
                open_astar:compute(51,1, PATH_CALLBACK)
                expect(VISITS).toEqual(400)
            end)
        end) -- 8-topology

        describe("4-topology", function()
            local PATH_A = inc { 0, 1, 0, 2, 0, 3, 0, 4, 1, 4, 2, 4, 3, 4, 4, 4 }
            local PATH_B = inc { 2, 2, 1, 2, 0, 2, 0, 3, 0, 4, 1, 4, 2, 4, 3, 4, 4, 4 }
            local astar = ROT.Path.AStar(Z[1], Z[2], PASSABLE_CALLBACK_48, {topology=4})
            
            it("should compute correct path A", function()
                astar:compute(A[1], A[2], PATH_CALLBACK)
                expect(PATH:toString()).toEqual(PATH_A:toString())
            end)

            it("should compute correct path B", function()
                astar:compute(B[1], B[2], PATH_CALLBACK)
                expect(PATH:toString()).toEqual(PATH_B:toString())
            end)

            it("should survive non-existant path X", function()
                astar:compute(X[1], X[2], PATH_CALLBACK)
                expect(#PATH).toEqual(0)
            end)
        end) -- 4-topology

        xdescribe("6-topology", function()
            local PATH_A = inc { 4, 0, 2, 0, 1, 1, 2, 2, 3, 3, 5, 3, 6, 2, 8, 2, 9, 3, 8, 4 }
            local PATH_B = inc { 10, 0, 9, 1, 8, 2, 9, 3, 8, 4 }
            local astar = ROT.Path.AStar(Z6[1], Z6[2], PASSABLE_CALLBACK_6, {topology=6})
            
            it("should compute correct path A", function()
                astar:compute(A6[1], A6[2], PATH_CALLBACK)
                expect(PATH:toString()).toEqual(PATH_A:toString())
            end)

            it("should compute correct path B", function()
                astar:compute(B6[1], B6[2], PATH_CALLBACK)
                expect(PATH:toString()).toEqual(PATH_B:toString())
            end)

            it("should survive non-existant path X", function()
                astar:compute(X6[1], X6[2], PATH_CALLBACK)
                expect(#PATH).toEqual(0)
            end)
        end) -- 6-topology

    end) -- A*


    describe("DijkstraMap", function()
        
        local function stringify (dm)
            local t = {}
            for y=1,dm._dimensions.h do
                for x=1,dm._dimensions.w do
                    t[#t + 1] = tostring(dm._map[x][y]):sub(1,1)
                end
                t[#t + 1] = '\n'
            end
            local result = table.concat(t)
            -- print(result)
            return result
        end
        
        local function makePath (dm, topology)
            PATH = { toString = toString }
            local x, y = Z[1], Z[2]
            local dx, dy = dm:dirTowardsGoal(x, y, topology)
            if dx then
                table.insert(PATH, 1, y) table.insert(PATH, 1, x)
            end
            while dx do
                x, y = x + dx, y + dy
                table.insert(PATH, 1, y) table.insert(PATH, 1, x)
                dx, dy = dm:dirTowardsGoal(x, y, topology)
            end
        end
        
        local dm = ROT.DijkstraMap(A[1], A[2], 8, 5, PASSABLE_CALLBACK_48)
        local PATH_A8 = inc { 0, 1, 0, 2, 0, 3, 1, 4, 2, 4, 3, 4, 4, 4 }
        local PATH_A4 = inc { 0, 1, 0, 2, 0, 3, 0, 4, 1, 4, 2, 4, 3, 4, 4, 4 }

        it("should compute correct map A", function()
            dm:compute()
            expect(stringify(dm)).toEqual [[
11234567
0iii4iii
112i5iii
2iii6iii
33456789
]]
        end)
        
        it("should compute correct path A, 8-topology", function()
            makePath(dm, 8)
            expect(PATH:toString()).toEqual(PATH_A8:toString())
        end)
        
        it("should compute correct path A, 4-topology", function()
            makePath(dm, 4)
            expect(PATH:toString()).toEqual(PATH_A4:toString())
        end)
        
        local dm = ROT.DijkstraMap(B[1], B[2], 8, 5, PASSABLE_CALLBACK_48)
        local PATH_B8 = inc { 2, 2, 1, 2, 0, 3, 1, 4, 2, 4, 3, 4, 4, 4 }
        local PATH_B4 = inc { 2, 2, 1, 2, 0, 2, 0, 3, 0, 4, 1, 4, 2, 4, 3, 4, 4, 4 }

        it("should compute correct map B", function()
            dm:compute()
            expect(stringify(dm)).toEqual [[
33456789
2iii6iii
210i7iii
2iii6iii
33456789
]]
        end)
        
        it("should compute correct path B, 8-topology", function()
            makePath(dm, 8)
            expect(PATH:toString()).toEqual(PATH_B8:toString())
        end)
        
        it("should compute correct path B, 4-topology", function()
            makePath(dm, 4)
            expect(PATH:toString()).toEqual(PATH_B4:toString())
        end)
        
        local dm = ROT.DijkstraMap(X[1], X[2], 8, 5, PASSABLE_CALLBACK_48)

        it("should compute correct map X", function()
            dm:compute()
            expect(stringify(dm)).toEqual [[
iiiiiiii
iiiiiiii
iiiiii0i
iiiiiiii
iiiiiiii
]]
        end)
        
        it("should survive non-existant path X, 8-topology", function()
            makePath(dm, 8)
            expect(#PATH).toEqual(0)
        end)
        
        it("should survive non-existant path X, 4-topology", function()
            makePath(dm, 4)
            expect(#PATH).toEqual(0)
        end)

    end) -- DijkstraMap
    
end) -- path

