local format = string.format

local class = require 'class'
local Component = require 'species/types/component'

local User = class('User', Component)
local getters, setters = User.__getters, User.__setters

function User:__init()
    local users = class 'Users'
    self.__users = users

    local superUser = {}
    self.__super_user = superUser

    self:__clone(superUser)

    local specials = {}

    function specials.type() end;
    function specials.broadcaster_type() end;

    self.__specials = specials
end

function User:call(data)
    local len = self.__users:getn()
    local user = class(format('User #%s', len), self.__super_user)

    local specials = self.__specials
    for name, value in next, data do
        local itSpecial = specials[name]
        if itSpecial then
            if type(itSpecial) == 'function' then
                itSpecial = itSpecial(self)
            end
            value = itSpecial
        end

        user['__' .. name] = value
    end

    return user
end

function getters.name(self)
    return self.__login
end

function getters.displayName(self)
    return self.__display_name
end

function getters.picture(self)
    return self.__profile_image_url
end

function getters.banner(self)
    return self.__offline_image_url
end

function getters.views(self)
    return self.__view_count
end

function getters.description(self)
    return self.__description
end

function getters.broadcaster(self)
    return self.__broadcaster
end

return User