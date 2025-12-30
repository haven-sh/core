local cocaineRecipes = {
    cokepowder = {
        tier1 = {
            take = {
                coca_leaf = 1
            },
            give = {
                coke = 1
            }
        },
        tier2 = {
            take = {
                coca_leaf = 1
            },
            give = {
                cokestagetwo = 1
            }
        },
        tier3 = {
            take = {
                coca_leaf = 1
            },
            give = {
                cokestagethree = 1
            }
        }
    },
    cutcoke = {
        tier1 = {
            take = {
                coke = 1,
                bakingsoda = 1
            },
            give = {
                loosecoke = 1
            }
        },
        tier2 = {
            take = {
                cokestagetwo = 1,
                bakingsoda = 1
            },
            give = {
                loosecokestagetwo = 1
            }
        },
        tier3 = {
            take = {
                cokestagethree = 1,
                bakingsoda = 1
            },
            give = {
                loosecokestagethree = 1
            }
        }
    },
    bagcoke = {
        tier1 = {
            take = {
                loosecoke = 1,
                empty_weed_bag = 1
            },
            give = {
                cokebaggy = 1
            }
        },
        tier2 = {
            take = {
                loosecokestagetwo = 1,
                empty_weed_bag = 1
            },
            give = {
                cokebaggystagetwo = 1
            }
        },
        tier3 = {
            take = {
                loosecokestagethree = 1,
                empty_weed_bag = 1
            },
            give = {
                cokebaggystagethree = 1
            }
        }
    }
}

local cocaineLocations = {
    MakePowder = {{
        loc = vector3(1086.20, -3195.30, -39.20),
        l = 1.0,
        w = 1.0,
        rot = 45.0,
        gang = ""
    }},
    CuttingCoke = {{
        loc = vector3(1095.61, -3195.62, -39.13),
        l = 1.0,
        w = 1.0,
        rot = 45.0,
        offset = vector3(-1.782227, 0.445068, -0.502701),
        rotation = vector3(0, 0, 0),
        gang = ""
    }},
    BaggingCoke = {{
        loc = vector3(1093.16, -3195.78, -39.19),
        l = 1.0,
        w = 1.0,
        rot = 45.0,
        offset = vector3(4.515137, 2.542969, -0.814194),
        rotation = vector3(0, 0, 180.0),
        gang = ""
    }},
    cokeTele = {{
        inside = vector3(1103.6936, -3195.9575, -38.9934),
        outside = vector3(198.1334, -1276.6287, 29.3252),
        spawnInside = vector3(1088.6718, -3187.9075, -38.9934),
        exitCoord = vector3(168.2139, -1270.4855, 29.1896),

        l = 1.0,
        w = 1.0,
        rot = 45.0,
        gang = ""
    }}
}

ps.registerCallback('md-drugs:server:GetCokeLocations', function()
    return cocaineLocations
end)

RegisterServerEvent('md-drugs:server:makepowder', function(num)
    local src = source
    if timeOut(src, 'md-drugs:server:makepowder') then
        return
    end

    if not ps.checkDistance(src, cocaineLocations.MakePowder[num].loc, 3.5) then
        ps.warn(ps.lang('Catches.notIn', ps.getPlayerName(src)), 'md-drugs:server:makepowder')
        return
    end

    local tier = 'tier1'
    if Config.TierSystem then
        local coke = tonumber(getRep(src, 'coke'))
        if coke > Config.Tier1 and coke <= Config.Tier2 then
            tier = 'tier2'
        elseif coke > Config.Tier2 then
            tier = 'tier3'
        end
    end

    if not ps.craftItem(src, cocaineRecipes['cokepowder'][tier]) then
        verifyHas(src, cocaineRecipes['cokepowder'][tier].take)
        return
    end
end)

RegisterServerEvent('md-drugs:server:cutcokeone', function(num)
    local src = source
    if timeOut(src, 'md-drugs:server:cutcokeone') then
        return
    end

    if not ps.checkDistance(src, cocaineLocations.CuttingCoke[num].loc, 2.5) then
        ps.notify(src, ps.lang('Catches.notIn'), 'error')
        return
    end

    local tier = 'tier1'
    if Config.TierSystem then
        local cokeTiers = {{
            item = 'coke',
            tier = 'tier1'
        }, {
            item = 'cokestagetwo',
            tier = 'tier2'
        }, {
            item = 'cokestagethree',
            tier = 'tier3'
        }}
        for _, v in ipairs(cokeTiers) do
            if ps.hasItem(src, v.item) then
                tier = v.tier
                break
            end
        end
    end

    if not ps.craftItem(src, cocaineRecipes['cutcoke'][tier]) then
        verifyHas(src, cocaineRecipes['cutcoke'][tier].take)
        return
    end
end)

RegisterServerEvent('md-drugs:server:bagcoke', function(num)
    local src = source
    if timeOut(src, 'md-drugs:server:bagcoke') then
        return
    end

    if not ps.checkDistance(src, cocaineLocations.BaggingCoke[num].loc, 2.5) then
        ps.notify(src, ps.lang('Catches.notIn'), 'error')
        return
    end

    local tier = 'tier1'
    if Config.TierSystem then
        local cokeTiers = {{
            item = 'loosecoke',
            tier = 'tier1'
        }, {
            item = 'loosecokestagetwo',
            tier = 'tier2'
        }, {
            item = 'loosecokestagethree',
            tier = 'tier3'
        }}
        for _, v in ipairs(cokeTiers) do
            if ps.hasItem(src, v.item) then
                tier = v.tier
                break
            end
        end

        if not ps.craftItem(src, cocaineRecipes['bagcoke'][tier]) then
            verifyHas(src, cocaineRecipes['bagcoke'][tier].take)
            return
        end
        AddRep(src, 'coke')
    else
        if not ps.craftItem(src, cocaineRecipes['bagcoke'][tier]) then
            verifyHas(src, cocaineRecipes['bagcoke'][tier].take)
            return
        end
    end
end)

local cokecut = {
    loosecokestagetwo = 2,
    loosecokestagethree = 3
}

for k, v in pairs(cokecut) do
    ps.createUseable(k, function(source, item)
        local src = source
        if not ps.hasItem(src, 'bakingsoda') then
            ps.notify(src, ps.lang('coke.needBakingSoda'), 'error')
            return
        end

        if ps.hasItem(src, item.name) then
            local check = ps.callback('md-drugs:client:uncuff', src, 'Cutting It Further')
            if not check then
                return
            end

            if ps.removeItem(src, k, 1) and ps.removeItem(src, 'bakingsoda', 1) then
                ps.addItem(src, 'loosecoke', v)
            end
        end
    end)
end
