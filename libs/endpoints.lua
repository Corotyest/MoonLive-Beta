local format = string.format

-- Current API endpoint with version 5.
local apiEndpoint = 'https://api.twitch.tv/helix/%s'

local endpoints = {
    chat = {
        'chatters', 'settings', 'announcements', 'shoutouts', 'color',
        emotes = {
            'global', 'set'
        },
        badges = {
            'global',
        }
    },
    bits = {
        'leaderboard', 'cheermotes', 'extensions'
    },
    tags = {
        'streams'
    },
    clips = {},
    games = {
        'top'
    },
    goals = {},
    raids = {},
    polls = {},
    teams = {
        'channel'
    },
    users = {
        'follows', 'blocks',
        extensions = {
            'list'
        }
    },
    search = {
        'categories', 'channels'
    },
    videos = {},
    charity = {
        'campaigns', 'donations'
    },
    streams = {
        'key', 'followed', 'markers', 'tags'
    },
    eventsub = {
        'subscriptions'
    },
    channels = {
        'commercial', 'editors', 'followed', 'followers', 'vips'
    },
    schedule = {
        'icalendar', 'settings', 'segment'
    },
    whispers = {},
    analytics = {
        'extensions', 'games'
    },
    hypetrain = {
        'events'
    },
    extensions = {
        'transactions', 'configurations', 'required_configuration', 'pubsub', 'live',
        jwt = {
            'secrets'
        }
    },
    moderation = {},
    soundtrack = {

    },
    predictions = {},
    entitlements = {},
    subscriptions = {},
    channels_points = {},
}

local function getn(table)
    local n = 0
    for _ in pairs(table) do n = n + 1 end
    return n
end

local function extend(table, parent)
    parent = parent or ''

    local copy = { }
    for name, path in next, table do
        ::redefine::
        local typeV = type(path)
        if typeV == 'table' then
            if getn(path) ~= 0 then
                copy[name] = extend(path, parent .. name .. '/')
            else
                path = name
                goto redefine
            end
        elseif typeV == 'string' then
            copy[path] = format(apiEndpoint, parent .. path)
        end
    end

    return copy
end

endpoints = extend(endpoints)
endpoints.api = apiEndpoint

return endpoints