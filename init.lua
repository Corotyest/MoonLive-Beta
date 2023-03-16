--- only a test

local api = 'https://api.twitch.tv/helix/eventsub/subscriptions/'
local socket = 'wss://eventsub-beta.wss.twitch.tv/ws'

local json = require 'json'
local emitter = require 'emitter'

local http = require 'coro-http'
local header = require 'http-header'
local websocket = require 'coro-websocket'

local encode = json.encode
local decode = json.decode
local welcomeSignal = emitter:createSignal 'WelcomeSignal'

-- p(websocket)
local baseOptions = websocket.parseUrl(socket)

local res, read, write = websocket.connect(baseOptions)


local tkn = {
    grant_type = 'client_credentials',
    'client_id',
    'client_secret',
}

local fmt_v, sep = '%s=%s', '&'

local function getToken(ops)
    local str = {}
    for index, value in pairs(tkn) do
        if type(index) == 'number' then
            index = value
            value = ops[value]
        end
        str[#str+1] = fmt_v:format(index, value)
    end
    
    str = table.concat(str, sep)
    local res, prop = http.request('POST', 'https://id.twitch.tv/oauth2/token', {
        { 'Content-Type', 'application/x-www-form-urlencoded' }
    }, str)

    local OK = res.code == 200
    return OK, not OK and res.reason or decode(prop)
end

local function getUser(ops, name)
    local headers = header.toHeaders(ops)
    local res, prop = http.request('GET', ('https://api.twitch.tv/helix/users?login=%s'):format(name), headers)

    prop = decode(prop)
    return res.code == 200, prop and prop.data[1]
end

-- getToken {
--     client_id = 'yycm39ixe2qhxlmuhzoyj9meopv4zt',
--     client_secret = 'fdk4hgbdarwqpo11nnt7kekpvhye6s'
-- }

--ygcnshg9nci5yjrncswukibgl8m1qx
local _, u = getUser({
    Authorization = 'Bearer ygcnshg9nci5yjrncswukibgl8m1qx',
    ['client-id'] = 'yycm39ixe2qhxlmuhzoyj9meopv4zt'
}, 'corotyest')

-- function u.getUserId(self)
--     return self.id
-- end

local function getChannel(ops, id)
    local headers = header.toHeaders(ops)
    local res, prop = http.request('GET', ('https://api.twitch.tv/helix/channels?broadcaster_id=%s'):format(id), headers)

    return decode(prop).data[1]
end

p(u)

local c = getChannel({
    Authorization = 'Bearer ygcnshg9nci5yjrncswukibgl8m1qx',
    ['client-id'] = 'yycm39ixe2qhxlmuhzoyj9meopv4zt',
}, u.id)

p(c)

welcomeSignal:subscribe(function(sessionId)
    local userid = u.id
    local headers = header.toHeaders {
        ['Content-Type'] = 'application/json'
    }
    local body = encode {
        type = 'stream.onlie',
        version = '1',
        condition = {
            broadcaster_user_id = userid
        },
        transport = {
            method = 'websocket',
            session_id = sessionId
        }
    }
    p(http.request('POST', api, headers, body))
end)

-- ::continue::
local function start()
    for chunck in read do
        if not chunck then
        goto continue
        end

        local lenght = chunck.len
        if lenght <= 0 then
            goto continue
        end

        p(chunck)
        local data = decode(chunck.payload)
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

start()

--