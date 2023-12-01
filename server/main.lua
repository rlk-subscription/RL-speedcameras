local QBCore = exports['qb-core']:GetCoreObject()

local UseWebHook = false
local Webhook = "" --webhook 

local function sendToDiscord(title, message, color)
    if UseWebHook then
	if Webhook == "" then
	    print("you have no webhook, create one on discord [https://discord.com/developers/applications] and place this server.lua (Webhook)")
	else
	    if message == nil or message == '' then return end
	    LogArray = {
		{
		    ["color"] = color,
		    ["title"] = title,
		    ["description"] = "Time: **"..os.date('%Y-%m-%d %H:%M:%S').."**",
		    ["fields"] = {
			{
			    ["name"] = Lang:t('discord.vehicle'),
			    ["value"] = message
			}
		    },
		    ["footer"] = {
			["text"] = "RL-speedcameras by RL-Subscription",
			["icon_url"] = "https://cdn.discordapp.com/attachments/1154839390355456032/1180252807903838208/coding_crop.png?ex=657cbf15&is=656a4a15&hm=c86e1bedc473e9cc8d53448b2b5d04b11eaa47fae84b3c64ea23a67de2e0e718&",
		    }
		}
	    }
	    PerformHttpRequest(Webhook , function(err, text, headers) end, 'POST', json.encode({username = "SpeedCam", embeds = LogArray}), { ['Content-Type'] = 'application/json' })
	end
    end
end

RegisterServerEvent('RL-speedcameras:PayFine')
AddEventHandler('RL-speedcameras:PayFine', function(source, plate, kmhSpeed, maxSpeed, amount, vehicleModel, radarStreet, displaymph, data)
    local platePrefix = string.upper(string.sub(plate, 0, 4))
    local _source = source
    local color = Config.orange
    local title = "Speed Cam"
    local speed = kmhSpeed - maxSpeed
    local Player = QBCore.Functions.GetPlayer(_source)
    local driver = Player.PlayerData.charinfo.firstname ..' '.. Player.PlayerData.charinfo.lastname
    local citizenid = Player.PlayerData.citizenid
    if Player.Functions.RemoveMoney("cash", amount, "pay-fine") then
	TriggerClientEvent('QBCore:Notify', _source, Lang:t('notify.payfine',{amount = amount}), "success")
    else
	if Player.Functions.RemoveMoney("bank", amount, "pay-fine") then
	    TriggerClientEvent('QBCore:Notify', _source, Lang:t('notify.payfine',{amount = amount}), "success")
	end
    end
    sendToDiscord(Lang:t('discord.title',{title=title}),Lang:t('discord.driver', {driver = driver}) ..'\n'..Lang:t('discord.model', {model = vehicleModel}) ..'\n'..Lang:t('discord.plate', {plate = plate})..'\n'..Lang:t('discord.speed', {speed = kmhSpeed, displaymph=displaymph}).. '\n'..Lang:t('discord.maxspeed', {maxspeed = maxSpeed})..'\n'..Lang:t('discord.radar', {street = radarStreet})..'\n'..Lang:t('discord.fine', {fine = amount}), color)
end)
