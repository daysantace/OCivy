-- OCivy
-- Copyleft (c) daysant 2024
-- This file is licensed under the terms of the Affero GPL v3.0-or-later.

local os = require("os")
local component = require("component")
local gpu = component.gpu
local w, h = gpu.getResolution()

local file = io.open("file.ocivy", "r")
if not file then
    print("OCivy: Could not open file")
    return
end

local lines = {}
while true do
    local line = file:read("*line")
    if not line then
        break
    end
    table.insert(lines, line)
end

file:close()

local function label(params)
    local x = tonumber(params.x) or 1
    local y = tonumber(params.y) or 1
    local text = params.text or "Hello, world!"
    gpu.set(x, y, text)
end

local functionMap = {
    label = label
}

local function parse(str)
    local result = {}

    local keywordPattern = "^%s*(%w+)"
    local keyword = str:match(keywordPattern)
    if keyword then
        result["keyword"] = keyword
    end

    local paramPattern = '(%w+)="([^"]+)"'
    for key, value in str:gmatch(paramPattern) do
        result[key] = value
    end

    return result
end

function updateScreen()
    gpu.fill(1, 1, w, h, " ")

    for _, line in ipairs(lines) do

        if line:match("^%s*$") or line:match("^%s*//") then
            goto skip
        end

        local parsedLine = parse(line)
        local keyword = parsedLine["keyword"]
        parsedLine["keyword"] = nil

        if keyword then
            local func = functionMap[keyword]
            if func then
                func(parsedLine)
            end
        end

        ::skip::
    end

    return
end

while true do
    updateScreen()
    os.sleep(0.1)
end