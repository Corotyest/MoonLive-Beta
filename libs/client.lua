-- This is a provitional version of the Twitch Client.
-- I wont include the methods directly, for now.

local Component = require 'species/types/component'

local client = Component 'Client'
local getters, setters = client.__getters, client.__setters

function client:__init()
    self.UNLOCKED = false -- we don't really need this
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

function getters.grantType()
    return 'client_credentials'
end


function getters.secret(self)
    return self.__client_secret
end

function setters.secret(self, secret)
    self.__client_secret = secret
end

return client