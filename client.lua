local ped = nil
local PlayerData, data = nil, {}

local function GetMinimapAnchor()
    local safezone = GetSafeZoneSize()
    local safezone_x = 1.0 / 20.0
    local safezone_y = 1.0 / 20.0
    local aspect_ratio = GetAspectRatio(0)
    local res_x, res_y = GetActiveScreenResolution()
    local xscale = 1.0 / res_x
    local yscale = 1.0 / res_y
    local Minimap = {}
    Minimap.width = xscale * (res_x / (4 * aspect_ratio))
    Minimap.height = yscale * (res_y / 5.674)
    Minimap.left_x = xscale * (res_x * (safezone_x * ((math.abs(safezone - 1.0)) * 10)))
    Minimap.bottom_y = 1.0 - yscale * (res_y * (safezone_y * ((math.abs(safezone - 1.0)) * 10)))
    Minimap.right_x = Minimap.left_x + Minimap.width
    Minimap.top_y = Minimap.bottom_y - Minimap.height
    Minimap.x = Minimap.left_x
    Minimap.y = Minimap.top_y
    return Minimap
end

local function getInfo()
    data[#data+1] = {
        name = 'job',
        value = PlayerData.job.label .. ' - ' .. PlayerData.job.grade_label
    }
    for i=1, #PlayerData.accounts, 1 do
        local account = PlayerData.accounts[i]
        data[#data+1] = {
            name = account.name,
            value = account.money
        }
    end
    PlayerData = nil
    return data
end

-- Events

RegisterNetEvent('esx:setAccountMoney', function(account)
    for i=1, #data, 1 do
        if data[i].name == account.name then
            data[i].value = account.money
            break
        end
    end

    SendNUIMessage({
        ui = 'updateInfo',
        data = data
    })
end)

RegisterNetEvent('esx:setJob', function(job)
    for i=1, #data, 1 do
        if data[i].name == 'job' then
            data[i].value = job.label .. ' - ' .. job.grade_label
            break
        end
    end

    SendNUIMessage({
        ui = 'updateInfo',
        data = data
    })
end)

RegisterNetEvent('esx:playerLoaded', function(playerData)
    Wait(100)
    ped = PlayerPedId()
    local anchor = GetMinimapAnchor()

    PlayerData = {
        job = playerData.job,
        accounts = playerData.accounts
    }

    SendNUIMessage({
        ui = 'init',
        show = true,
        data = {x = anchor.x, y = anchor.y,height = anchor.height, right_x = anchor.right_x}
    })

    SendNUIMessage({
        ui = 'updateInfo',
        data = getInfo()
    })
    anchor = nil
end)

AddEventHandler('esx_status:onTick', function(data)
    local status = {}

    for i=1, #data, 1 do
        status[#status + 1] = {
            name = data[i].name,
            percent = data[i].percent
        }
    end

    status[#status + 1] = {
        percent = GetEntityHealth(ped) - 100 > 0 and GetEntityHealth(ped) - 100 or 0,
        name = 'health'
    }
    status[#status + 1] = {
        percent = GetPedArmour(ped),
        name = 'armor'
    }
    SendNUIMessage({
        ui = 'updateStatus',
        data = status
    })

    if IsPauseMenuActive() then
        SendNUIMessage({
            ui = 'show',
            show = false,
        }) 
    else
        SendNUIMessage({
            ui = 'show',
            show = true,
        }) 
    end
end)

-- End events

CreateThread(function()
    if ESX.PlayerLoaded then
        Wait(100)
        ped = PlayerPedId()
        local anchor = GetMinimapAnchor()

        PlayerData = {
            job = ESX.GetPlayerData().job,
            accounts = ESX.GetPlayerData().accounts
        }

        SendNUIMessage({
            ui = 'init',
            show = true,
            data = {x = anchor.x, y = anchor.y,height = anchor.height, right_x = anchor.right_x}
        })

        
        SendNUIMessage({
            ui = 'updateInfo',
            data = getInfo()
        })
        anchor = nil
    end
end)

-- Use this when changing res
RegisterCommand('fixui', function()
    local anchor = GetMinimapAnchor()
    SendNUIMessage({
        ui = 'init',
        show = true,
        data = {x = anchor.x, y = anchor.y,height = anchor.height, right_x = anchor.right_x}
    })
    anchor = nil
end)