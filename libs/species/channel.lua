local format = string.format

local class = require 'class'
local Component = require 'species/types/component'

local call = class.events.call

local Channel = Component 'Channel'
local getters, setters = Channel.__getters, Channel.__setters

local props = { __getters = getters, __setters = setters }

function Channel:__init()
    local channels = class 'Channels'
    self.__channels = channels()
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

    self.id = self.__broadcaster_id

    return channel
end

function getters.name(self)
    return self.__broadcaster_login
end

function getters.displayName(self)
    return self.__broadcaster_name
end

function getters.gameId(self)
    return self.__game_id
end

function getters.gameName(self)
    return self.__game_name
end

function getters.title(self)
    return self.__title
end

function getters.delay(self)
    return self.__delay
end

function getters.language(self)
    return self.__broadcaster_language
end

function getters.tags(self)
    return self.__tags
end

return Channel