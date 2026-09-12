--!strict
-- ReplicatedStorage/NumberFormat.lua or StarterPlayerScripts/NumberFormat.lua
-- Utility to format numbers into compact abbreviations (e.g. 1.2K, 3.4M, 5.6B).

local NumberFormat = {}

local SUFFIXES = { "", "K", "M", "B", "T", "Qa", "Qi", "Sx", "Sp", "Oc", "No", "Dc" }

function NumberFormat.format(num: number): string
    if num == 0 then return "0" end
    if num < 1000 then
        return string.format("%.0f", num)
    end

    local exp = math.floor(math.log10(num) / 3)
    local index = math.min(exp + 1, #SUFFIXES)
    local scaled = num / (10 ^ ((index - 1) * 3))

    if scaled >= 100 then
        return string.format("%.0f%s", scaled, SUFFIXES[index])
    elseif scaled >= 10 then
        return string.format("%.1f%s", scaled, SUFFIXES[index])
    else
        return string.format("%.2f%s", scaled, SUFFIXES[index])
    end
end

return NumberFormat
