local moonLive = require './init'()

local client = moonLive.client

print(moonLive, client)


local token, msg = moonLive:requestToken()

print(token, 'message:', msg)

-- feel free to use these credentials and pretest the api.
client.id = 'yycm39ixe2qhxlmuhzoyj9meopv4zt'
client.secret = 'fdk4hgbdarwqpo11nnt7kekpvhye6s'

-- print(moonLive.clientId)

local token, msg = moonLive:requestToken()

print(token, msg)

print(token.authorization)

local user, msg = moonLive:getUser 'corotyest'
print(user, msg)

-- for k, v in user:__iter { raw = true } do
--     p(k, v)
-- end

print(user.id, user.__id)

local res, msg = moonLive:getChannel()
print(res, msg)

-- print(moonLive:getChannel(user))

-- local res, msg = moonLive:getChannel '0000000121212121212121212'
-- print(res, msg)

local channel = moonLive:getChannel(user)

print(channel, channel.name)