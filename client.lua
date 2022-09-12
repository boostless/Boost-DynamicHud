local ped = nil
local PlayerData, data = nil, {}

local function GetMinimapAnchor()
    local minimap = {}
	local resX, resY = GetActiveScreenResolution()
	local aspectRatio = GetAspectRatio()
	local scaleX = 1/resX
	local scaleY = 1/resY
	local minimapRawX, minimapRawY
	SetScriptGfxAlign(string.byte('L'), string.byte('B'))
	if IsBigmapActive() then
		minimapRawX, minimapRawY = GetScriptGfxPosition(-0.003975, 0.022 + (-0.460416666))
		minimap.width = scaleX*(resX/(2.52*aspectRatio))
		minimap.height = scaleY*(resY/(2.3374))
	else
		minimapRawX, minimapRawY = GetScriptGfxPosition(-0.0045, 0.002 + (-0.188888))
		minimap.width = scaleX*(resX/(4*aspectRatio))
		minimap.height = scaleY*(resY/(5.674))
	end
	ResetScriptGfxAlign()
	minimap.leftX = minimapRawX
	minimap.rightX = minimapRawX+minimap.width
	minimap.topY = minimapRawY
	minimap.bottomY = minimapRawY+minimap.height
	minimap.X = minimapRawX+(minimap.width/2)
	minimap.Y = minimapRawY+(minimap.height/2)

	return {
        x = minimap.leftX+0.005,
        y = minimap.topY+0.014,
        height = minimap.height,
        right_x = minimap.rightX+0.005,
    }
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

    PlayerData = {
        job = playerData.job,
        accounts = playerData.accounts
    }

    SendNUIMessage({
        ui = 'init',
        show = true,
        data = GetMinimapAnchor()
    })

    SendNUIMessage({
        ui = 'updateInfo',
        data = getInfo()
    })
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

        PlayerData = {
            job = ESX.GetPlayerData().job,
            accounts = ESX.GetPlayerData().accounts
        }

        SendNUIMessage({
            ui = 'init',
            show = true,
            data = GetMinimapAnchor()
        })

        
        SendNUIMessage({
            ui = 'updateInfo',
            data = getInfo()
        })
    end
end)

-- Use this when changing res
RegisterCommand('fixui', function()
    SendNUIMessage({
        ui = 'init',
        show = true,
        data = GetMinimapAnchor()
    })
end)