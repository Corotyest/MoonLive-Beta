local format = string.format

local class = require 'class'
local Component = require 'species/types/component'

-- Token Types should be a module that contain those, but for now it would be like this.
local TokenTypes = {
    bearer = 'Bearer'
}

local Token = class('Token', Component)
local getters, setters = Token.__getters, Token.__setters

function Token:__init()
    self.__token_types = TokenTypes

    local tokens = class 'Tokens'
    self.__tokens = tokens

    local superToken = {}
    self.__super_token = superToken

    self:__clone(superToken)

    -- self.__specials = specials
end

function Token:call(data)
    local len = self.__tokens:getn()
    local token = class(format('Token #%s', len), self.__super_token)
    token.__token_types = self.__token_types

    local specials = self.__specials
    for name, value in next, data do
        local itSpecial = specials and specials[name]
        if itSpecial then
            if type(itSpecial) == 'function' then
                itSpecial = itSpecial(self)
            end
            value = itSpecial
        end

        token['__' .. name] = value
    end

    token.id = token.__access_token

    return token
end

function Token:getTokenType()
    local types = self.__token_types
    if not types then
        return nil
    end

    return types[self.type]
end

function getters.type(self)
    return self.__token_type
end

function getters.access(self)
    return self.__access_token or self.id
end

return Token