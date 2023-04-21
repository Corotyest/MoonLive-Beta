local format = string.format
local concat = table.concat

local class = require 'class'
local client = require 'client'()

local User = require 'species/user'()
local Token = require 'species/token'()
local Channel = require 'species/channel'()

local errors = require 'errors'
local emitter = require 'emitter'
local endpoints = require 'endpoints'

local json = require 'json'
local http = require 'coro-http'
local header = require 'http-header'
local websocket = require 'coro-websocket'

local encode = json.encode
local decode = json.decode

local request = http.request


local moonLive = class 'MoonLive'
moonLive.client = client
moonLive.welcomeSignal = emitter:createSignal 'WelcomeSignal'

local wsPoint = endpoints.webSocket
local baseOptions = websocket.parseUrl(wsPoint)

function moonLive:__init()
    self.__token_options = {
        client_id = 'id',
        client_secret = 'secret',

        grant_type = 'grantType'
    }

    self.__token_headers = header.toHeaders {
        ['Conntent-Type'] = 'application/x-www-form-urlencoded'
    }

    self.usersPath = endpoints.users.path .. '?login=%s'
    self.channelsPath = endpoints.channels.path .. '?broadcaster_id=%s'

    self.__ws_base_options = baseOptions
end

function moonLive:getTokenOptions()
    return class.clone(self.__token_options)
end

local function createBody(self, options, separator)
    local str = { }
    for index, option in next, self do
        local type1 = type(index)
        if options and type1 == 'number' then
            index = option
            option = options[option]
        end

        str[#str + 1] = format('%s=%s', index, option)
    end

    return concat(str, separator or '&')
end

function moonLive:requestToken()
    local clientObj = self.client
    local tokenOptions = self:getTokenOptions()

    for key, index in pairs(tokenOptions) do
        local value = clientObj[index]
        if not value then
            return nil, format('client.%s is missing', index)
        end

        tokenOptions[key] = value
    end

    local body = createBody(tokenOptions)
    local headers = self.__token_headers

    local response, payload = request('POST', endpoints.token, headers, body)

    local code = response.code
    if code ~= 200 then
        return nil, decode(payload).message
    end

    local data = decode(payload)
    local token = Token(data)()

    -- this is very provitional
    self.token = token

    return token
end

function moonLive:getUser(name)
    local type1 = type(name)
    if type1 ~= 'string' then
        return nil, format(error.arg, 1, 'getUser', 'string', type1)
    end

    local client = self.client
    if not client then return nil, 'self.client is missing' end

    local token = self.token
    if not token then return nil, 'self.token is missing' end

    local headers = header.toHeaders {
        ['client-id'] = client.id,
        authorization = token.authorization
    }

    local response, payload = request('GET', format(self.usersPath, name), headers)

    local code = response.code
    if code ~= 200 then
        return nil, response.reason
    end

    payload = decode(payload)
    local data = payload.data

    if not data or #data == 0 then
        return nil, 'no `data` from server.'
    end

    return User(data[1])()
end

function moonLive:getChannel(upload)
    local type1 = type(upload)
    if type1 ~= 'string' then
        if not class.isObject(upload) or upload.className:find 'User' ~= 1 then
            return nil, format(errors.arg, 1, 'getChannel', 'User/string', type1)
        end

        upload = upload.id
    end

    local client = self.client
    if not client then return nil, 'self.client is missing' end

    local token = self.token
    if not token then return nil, 'self.token is missing' end

    local headers = header.toHeaders {
        ['client-id'] = client.id,
        authorization = token.authorization
    }

    local response, payload = request('GET', format(self.channelsPath, upload), headers)

    local code = response.code
    if code ~= 200 then
        return nil, response.reason
    end

    payload = decode(payload)
    local data = payload.data

    if not data or #data == 0 then
        return nil, 'no `data` from server.'
    end

    return Channel(data[1])()
end

function moonLive:startEventsub()
    local welcomeSignal = self.welcomeSignal
    local response, readIter = websocket.connect(self.__ws_base_options)

    for chunk in readIter do
        if not chunk then
            goto continue
        end

        local lenght = chunk.len
        if lenght <= 0 then
            goto continue
        end

        local data = decode(chunk.payload)
        local meta, payload = data.metadata, data.payload

        local type = meta.message_type
        if type ~= 'session_welcome' then
            goto continue
        end

        local session = payload.session
        welcomeSignal:fire(session)

        ::continue::
    end
end

return moonLive