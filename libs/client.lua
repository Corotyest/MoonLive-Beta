-- This is a provitional version of the Twitch Client.
-- I wont include the methods directly, for now.

local class = require 'class'
local Component = require 'species/types/component'

local client = class('Client', Component)
local getters, setters = client.__getters, client.__setters

local User = require 'species/user'()
local Token = require 'species/token'()

function client:__init()
    self.UNLOCKED = false
end

function client:call(data)
    if self.__exist_client == true then
        return error('cannot exist more than one client.', 2)
    end

    if self.UNLOCKED == true then
        for name, value in next, data do
            self[name] = value
        end
    end
end

function getters.clientId(self)
    return self.__client_id
end

function setters.clientId(self, id)
    self.__client_id = id
end

function getters.clientSecret(self)
    return self.__client_secret
end

function setters.clientSecret(self, secret)
    self.__client_secret = secret
end

return client