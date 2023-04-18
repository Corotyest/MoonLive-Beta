local class = require 'class'

local component = class 'Component'
local getters, setters = component.__getters, component.__setters

function getters.id(self)
    return self.__id
end

function setters.id(self, value)
    self.__id = value
end

return component