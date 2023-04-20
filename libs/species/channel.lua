local format = string.format

local class = require 'class'
local Component = require 'species/types/component'

local call = class.events.call

local Channel = Component 'Channel'
local getters, setters = Channel.__getters, Channel.__setters

local props = { __getters = getters, __setters = setters }

function Channel:__init()
    local channel = class 'Channels'
    self.__channel = channel()
end

local function properties(channel)
    for name, type in pairs(props) do
        type:__clone(true, { protected = true }, channel[name])
    end
end

Channel[call] = function(self, data)
    local len = self.__channels.getn
    local channel = class(format('Channel #%s', len + 1))

    properties(channel)

    local specials = self.__specials
    for name, value in next, data do
        local itSpecial = specials and specials[name]
        if itSpecial then
            if type(itSpecial) == 'function' then
                itSpecial = itSpecial(self)
            end
            value = itSpecial
        end

        channel['__' .. name] = value
    end

    return channel
end


return Channel