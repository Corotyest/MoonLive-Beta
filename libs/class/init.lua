local class = require './class'
local enums, events = class.enums, class.events

local getters = { }
local setters = { }

local getName, setName = 'getter: %s', 'setter: %s'
local getted, setted = enums.getted, enums.setted

function __get(self, index)
    local get = getters[self]
    if not get then
        return nil
    end

    local propertie = get[index]
    if type(propertie) == 'function' then
        return getted, propertie(self, index)
    end
end

function __set(self, index, value)
    local set = setters[self]
    if not set then
        return nil
    end

    local propertie = set[index]
    if type(propertie) == 'function' then
        return setted, propertie(self, value, value)
    end
end

local classify = {
    get = true, set = true
}

return setmetatable({
    getters = getters,
    setters = setters,

    classify = classify,
}, {
    __index = class,
    __call = function(self, ...)
        local s, obj = pcall(class, ...)
        if not s then
            return error(obj, 2)
        end

        local id = self.getnOfClasses()
        local get, set = obj.__getters or (classify.get and class(getName:format(id))() or {}), obj.__setters or (classify.set and class(setName:format(id))() or {})
        obj.__getters, obj.__setters = get, set

        obj[events.get], obj[events.set] = __get, __set

        function class:init(...)
            getters[self], setters[self] = get, set

            if type(self.__init) == 'function' then
                return self:__init(...)
            end
        end

        return obj, get, set
    end
})