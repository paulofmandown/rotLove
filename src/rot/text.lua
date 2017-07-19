--- Text tokenization and breaking routines.
-- @module ROT.Text
local Text = {}

Text.RE_COLORS = "()(%%([bc]){([^}]*)})"

-- token types
Text.TYPE_TEXT = 0
Text.TYPE_NEWLINE = 1
Text.TYPE_FG = 2
Text.TYPE_BG = 3

--- Measure size of a resulting text block.
function Text.measure(str, maxWidth)
    local width, height = 0, 1
    local tokens = Text.tokenize(str, maxWidth)
    local lineWidth = 0

    for i = 1, #tokens do
        local token = tokens[i]
        if token.type == Text.TYPE_TEXT then
            lineWidth = lineWidth + #token.value
        elseif token.type == Text.TYPE_NEWLINE then
            height = height + 1
            width = math.max(width, lineWidth)
            lineWidth = 0
        end
    end
    width = math.max(width, lineWidth)

    return width, height
end

--- Convert string to a series of a formatting commands.
function Text.tokenize(str, maxWidth)
    local result = {}

    -- first tokenization pass - split texts and color formatting commands
    local offset = 1
    str:gsub(Text.RE_COLORS, function(index, match, type, name)
        -- string before
        local part = str:sub(offset, index - 1)
        if #part then
            result[#result + 1] = {
                type = Text.TYPE_TEXT,
                value = part
            }
        end

        -- color command
        result[#result + 1] = {
            type = type == "c" and Text.TYPE_FG or Text.TYPE_BG,
            value = name:gsub("^ +", ""):gsub(" +$", "")
        }

        offset = index + #match
        return ""
    end)

    -- last remaining part
    local part = str:sub(offset)
    if #part > 0 then
        result[#result + 1] = {
            type = Text.TYPE_TEXT,
            value = part
        }
    end

    return (Text._breakLines(result, maxWidth))
end

-- insert line breaks into first-pass tokenized data
function Text._breakLines(tokens, maxWidth)
    maxWidth = maxWidth or math.huge

    local i = 1
    local lineLength = 0
    local lastTokenWithSpace

    -- This contraption makes `break` work like `continue`.
    -- A `break` in the `repeat` loop will continue the outer loop.
    while i <= #tokens do repeat
        -- take all text tokens, remove space, apply linebreaks
        local token = tokens[i]
        if token.type == Text.TYPE_NEWLINE then -- reset
            lineLength = 0
            lastTokenWithSpace = nil
        end
        if token.type ~= Text.TYPE_TEXT then -- skip non-text tokens
            i = i + 1
            break -- continue
        end

        -- remove spaces at the beginning of line
        if lineLength == 0 then
            token.value = token.value:gsub("^ +", "")
        end

        -- forced newline? insert two new tokens after this one
        local index = token.value:find("\n")
        if index then
            token.value = Text._breakInsideToken(tokens, i, index, true)

            -- if there are spaces at the end, we must remove them
            -- (we do not want the line too long)
            token.value = token.value:gsub(" +$", "")
        end

        -- token degenerated?
        if token.value == "" then
            table.remove(tokens, i)
            break -- continue
        end

        if lineLength + #token.value > maxWidth then
        -- line too long, find a suitable breaking spot

            -- is it possible to break within this token?
            local index = 0
            while 1 do
                local nextIndex = token.value:find(" ", index+1)
                if not nextIndex then break end
                if lineLength + nextIndex > maxWidth then break end
                index = nextIndex
            end

            if index > 0 then -- break at space within this one
                token.value = Text._breakInsideToken(tokens, i, index, true)
            elseif lastTokenWithSpace then
                -- is there a previous token where a break can occur?
                local token = tokens[lastTokenWithSpace]
                local breakIndex = token.value:find(" [^ ]-$")
                token.value = Text._breakInsideToken(
                    tokens, lastTokenWithSpace, breakIndex, true)
                i = lastTokenWithSpace
            else -- force break in this token
                token.value = Text._breakInsideToken(
                    tokens, i, maxWidth-lineLength+1, false)
            end

        else -- line not long, continue
            lineLength = lineLength + #token.value
            if token.value:find(" ") then lastTokenWithSpace = i end
        end

        i = i + 1 -- advance to next token
    until true end
    -- end of "continue contraption"

    -- insert fake newline to fix the last text line
    tokens[#tokens + 1] = { type = Text.TYPE_NEWLINE }

    -- remove trailing space from text tokens before newlines
    local lastTextToken
    for i = 1, #tokens do
        local token = tokens[i]
        if token.type == Text.TYPE_TEXT then
            lastTextToken = token
        elseif token.type == Text.TYPE_NEWLINE then
            if lastTextToken then -- remove trailing space
                lastTextToken.value = lastTextToken.value:gsub(" +$", "")
            end
            lastTextToken = nil
        end
    end

    tokens[#tokens] = nil -- remove fake token

    return tokens
end

--- Create new tokens and insert them into the stream
-- @tparam table tokens
-- @tparam number tokenIndex Token being processed
-- @tparam number breakIndex Index within current token's value
-- @tparam boolean removeBreakChar Do we want to remove the breaking character?
-- @treturn string remaining unbroken token value
function Text._breakInsideToken(tokens, tokenIndex, breakIndex, removeBreakChar)
    local newBreakToken = {
        type = Text.TYPE_NEWLINE,
    }
    local newTextToken = {
        type = Text.TYPE_TEXT,
        value = tokens[tokenIndex].value:sub(
            breakIndex + (removeBreakChar and 1 or 0))
    }

    table.insert(tokens, tokenIndex + 1, newTextToken)
    table.insert(tokens, tokenIndex + 1, newBreakToken)

    return tokens[tokenIndex].value:sub(1, breakIndex - 1)
end

return Text

