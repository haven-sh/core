local QBCore = exports['qb-core']:GetCoreObject()

local DiscordLink = "https://discord.gg/TEU_LINK_AQUI"
local IconURL = "https://i.imgur.com/TezCwF0.png"

local function GetCard(title, subtitle, steam, discord)
    return {
        type = "AdaptiveCard",
        version = "1.3",
        body = {{
            type = "Container",
            style = "emphasis",
            bleed = true,
            items = {{
                type = "TextBlock",
                text = "SERVER ACCESS CONTROL",
                weight = "Lighter",
                size = "Small",
                horizontalAlignment = "Center",
                isSubtle = true,
                spacing = "Large"
            }, {
                type = "Image",
                url = IconURL,
                horizontalAlignment = "Center",
                size = "Small",
                spacing = "ExtraLarge"
            }, {
                type = "TextBlock",
                text = title,
                size = "Large",
                weight = "Bolder",
                horizontalAlignment = "Center",
                spacing = "Large",
                color = "Attention"
            }, {
                type = "TextBlock",
                text = subtitle,
                wrap = true,
                horizontalAlignment = "Center",
                size = "Medium",
                isSubtle = true,
                spacing = "Medium"
            }, {
                type = "TextBlock",
                text = "STEAM: " .. (steam or "?") .. "  |  DISCORD: " .. (discord or "?"),
                size = "Small",
                horizontalAlignment = "Center",
                isSubtle = true,
                spacing = "ExtraLarge",
                fontType = "Monospace"
            }}
        }},
        actions = {{
            type = "Action.OpenUrl",
            title = "👉 Realizar Candidatura",
            url = DiscordLink
        }},
        ["$schema"] = "http://adaptivecards.io/schemas/adaptive-card.json"
    }
end

AddEventHandler('playerConnecting', function(name, setKickReason, deferrals)
    local src = source
    local identifiers = GetPlayerIdentifiers(src)
    local steam, discord, license

    deferrals.defer()
    Wait(50)
    deferrals.update("✨ A verificar estado da candidatura...")
    Wait(1000)

    for _, v in pairs(identifiers) do
        if string.find(v, "steam") then
            steam = v
        end
        if string.find(v, "discord") then
            discord = v
        end
        if string.find(v, "license") then
            license = v
        end
    end

    if not discord then
        deferrals.presentCard(GetCard("VINCULAR DISCORD",
            "O teu Discord não foi detetado.\nPor favor, abre o Discord e reinicia o FiveM.", (steam or "N/A"), "OFF"),
            function()
            end)
        return
    end

    local cleanDiscord = string.gsub(discord, "discord:", "")

    exports.oxmysql:execute('SELECT * FROM server_whitelist WHERE discord_id = ?', {cleanDiscord}, function(result)
        if result and result[1] then
            if license and (not result[1].license or result[1].license == "") then
                exports.oxmysql:execute('UPDATE server_whitelist SET license = ? WHERE discord_id = ?',
                    {license, cleanDiscord})
            end

            deferrals.update("✅ Candidatura Validada. Bem-vindo ao Haven Roleplay!")
            Wait(1000)
            deferrals.done()
        else
            print("^3[WL] Rejeitado (" .. name .. ") - Discord ID: " .. cleanDiscord .. "^0")

            deferrals.presentCard(GetCard("CANDIDATURA NECESSÁRIA", "Olá **" .. name ..
                "**.\n\nA tua conta Discord não está na nossa Whitelist.\nPara jogares, tens de ir ao canal de candidaturas.",
                (steam or "N/A"), cleanDiscord), function()
            end)
        end
    end)
end)
