--[[
    author = 'Corotyest'
    version = '0.1.0b-k'
]]

local wrap = coroutine.wrap
local format = string.format

local emitter = { }

---@class Signal
---@field private getSubscription function
local signal = { }

--- Wrap the `Subscribed` functions with `coroutine.wrap` to the current signal. <br>
--- If there is an error return nil and the error message.
---@vararg any
---@return nil, string?
function signal:fire(...)
    local listeners = self.__listeners
    if not listeners then
        return nil, '`self.__listeners` is nil'
    end

    for index, value in pairs(listeners) do
        local type1 = type(value)
        if type1 ~= 'function' then
            if type1 == 'table' then
                local callback = value.callback
                if value.synced then
                    callback(...)
                -- elseif value.once then
                --     self:function_that_remove_callback_connection()
                end
            end
        else
            local base = { wrap(value)(...) }
        end
    end
end

--- Subscribes a `function` to be fired with the signal. <br>
--- Returns the `Subscription` if there was no errors. <br>
--- → *This function invokes an error on failure, stopping the current thread*.
---@param callback function @The callback to be subscribed.
---@return Subscription
function signal:subscribe(callback)
    local type1 = type(callback)
    if type1 ~= 'function' then
        return error(format('attempt to connect type %s instead of function', type1), 2)
    end

    local listeners = self.__listeners
    if not listeners then
        return nil, '`self.__listeners` is nil'
    end

    local callbackId = #listeners+1
    listeners[callbackId] = callback

    return self.getSubscription and self:getSubscription(callbackId)
end

---@class Subscription
---@field private __subscribed boolean
local subscription = { }

--- Check if the current concurrency, i.e. the `Subscription` is active.
---@return boolean
function subscription:subscribed()
    return self.__subscribed == true
end

--- Unsubscribes a connected callback from being *fired*. <br>
--- Return nil on error, and the error message. <br>
--- Return the `Subscription` if there was no errors.
---@return nil | table, string?
function subscription:unsubscribe()
    if not self:subscribed() then
        return nil
    end

    local listeners = self.__listeners
    local callback_id = self.__callback_id
    if not listeners then
        return nil, '`self.__listeners` is nil'
    elseif not listeners[callback_id] then
        return nil, format('`self.__listeners[%d]` such callback does not exists', callback_id)
    end

    listeners[callback_id] = nil
    self.__subscribed = not self:subscribed()

    return self
end


local function pairsFn(table)
    return function(...) -- layer
        return function(self, index)
            return next(table, index)
        end
    end, table, nil
end


--- Creates a `Signal` that can connect various functions and at a time *fire* these or disconnect these.
---@param name string @The name of the `Signal`
---@return Signal
function emitter:createSignal(name)
    local signalMeta = {
        __index = signal,
        __pairs = pairsFn(signal),
        __tostring = function(self)
            return format('Signal %s', name)
        end,
        __metatable = {}
    }

    local signal = setmetatable({}, signalMeta)

    local listeners = { }
    signal.__listeners = listeners

    function signal:getSubscription(id)
        local subscription = emitter:createSubscription(name)
        subscription.__listeners = listeners
        subscription.__subscribed = true
        subscription.__callback_id = id

        return subscription
    end

    return signal
end

--- Creates a `Subscription` to disconnect a subscibed `Signal`.
---@param name string @The subscription name.
---@return Subscription
function emitter:createSubscription(name)
    return setmetatable({}, {
        __index = subscription,
        __pairs = pairsFn(subscription),
        __tostring = function()
            return format('Subscription %s', name)
        end,
        __metatable = {}
    })
end

return setmetatable({}, {
    __index = emitter,
    __pairs = pairsFn(emitter),
    __metatable = { }
})