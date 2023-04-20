local class = require 'class'

local component = class 'Component'()
local getters, setters = component.__getters, component.__setters

local props = {
    __getters = getters,
    __setters = setters
}

component[class.events.call] = function(self, element, ...)
    local obj = element
    if not class.isClass(element) then
        obj = class(element, ...)
    end

    for name, property in pairs(props) do
        property:__clone(true, { protected = true }, obj[name])
    end

    return obj
end

function getters.id(self)
    return self.__id
end

function setters.id(self, value)
    self.__id = value
end

return component