-- [[ Services ]] --
local HttpService 	= game:GetService('HttpService')
local PhysicsService= game:GetService('PhysicsService')
local TS 			= game:GetService('TweenService')
local Debris 		= game:GetService('Debris')
local PhysicsService= game:GetService('PhysicsService')
local Run 			= game:GetService('RunService')
local RS 			= game:GetService('ReplicatedStorage')
local ServerStorage = game:GetService('ServerStorage')
local Players 		= game:GetService('Players')

-- [[ Constants ]] --
local Backup 		= 0

local ACS_WorkSpace = workspace:WaitForChild('ACS_WorkSpace')
local Engine 		= RS:WaitForChild('ACS_Engine')
local Hashes		= Engine:WaitForChild('_', 95) 
local Evt 			= Engine:WaitForChild('Events')
local Mods 			= Engine:WaitForChild('Modules')
local GunModels 	= Engine:WaitForChild('GunModels')
local AttModels 	= Engine:WaitForChild('AttModels')
local Rules			= Engine:WaitForChild('GameRules')
local ArmModel 		= Engine:WaitForChild("ArmModel")
local SVGunModels 	= Engine:WaitForChild("GrenadeModels")
local HUDs 			= Engine:WaitForChild("HUD")
local AttModules  	= Engine:WaitForChild("AttModules")

-- [[ Secure Rate ]] --
local PlayersUUID: {[Player]: {string|string|{Instance|any}}} = {}
local CD_WEBHOOK: {[Player]: boolean} = {}
local LogDamage: {[Player]: {any|any}} = {}
local PlayersRate: {EquipRemote: {[Player]: {boolean|number}}} = {
	EquipRemote = {}
}

-- [[ Modules ]] --
local gameRules		= require(Rules:WaitForChild('Config', 125))
game.StarterPlayer.CharacterWalkSpeed = gameRules.NormalWalkSpeed
local CombatLog		= require(Rules:WaitForChild('CombatLog'))
local Ragdoll		= require(Mods:WaitForChild('Ragdoll'))

local WebhookModule = require(script:WaitForChild('Webhook', 95))
local KickMessage 	= require(script:WaitForChild('kick_message', 95))
local UUIDModule	= require(script:WaitForChild('UUIDModule', 95))
local SHA256 		= require(script:WaitForChild('SHA256', 95))
local New			= require(script:WaitForChild('New', 95))

local SpringMod 	= require(Mods:WaitForChild("Spring"))
local HitMod 		= require(Mods:WaitForChild("Hitmarker"))
local Ultil			= require(Mods:WaitForChild("Utilities"))
local Utilities		= require(Mods:WaitForChild("Utilities"))

local HttpService 	= game:GetService("HttpService")
local PhysicsService= game:GetService("PhysicsService")
local TS 			= game:GetService('TweenService')
local Debris 		= game:GetService("Debris")
local PhysicsService= game:GetService("PhysicsService")
local Run 			= game:GetService("RunService")

-- [[ Config ]] --
local RestrictedRemote = New('RemoteEvent', { Name = 'Restricted Remote' })
local KEY_SERVER	= New('StringValue', { Name = '-', Value = SHA256:GenerateRandom(), Parent = Engine })
local Webhook 		= WebhookModule.new('https://discord.com/api/webhooks/1112422320695410768/-c3t92p8VJ_6CTFOviMvNKGKyvcwf9oUAuysuweFPcwXHIP1aChhyXiRp0eB62TLUfzt')
local VectorFilters = {
	'nan',
	'inf'
}
local TempBannedPlayes = {}
local TemporaryKeyServer = ''
local TemporaryValidKey = {}


local luaw,llaw,lhw, ruaw,rlaw,RA,LA,RightS,LeftS
local AnimBase,AnimBaseW

local Explosion = {"287390459"; "287390954"; "287391087"; "287391197"; "287391361"; "287391499"; "287391567";}
-----------------------------------------------------------------

game.StarterPlayer.CharacterWalkSpeed = gameRules.NormalWalkSpeed

-- Proteção do Script


local githubApiUrl = "https://raw.githubusercontent.com/MoscouPT/Licenses/main/Users/Check.json"
local expectedValue = "mHYjlzErOcENgMTkq2SmVAJzteyzWHvSgEI8vwfflKhscuzfrHkmm34Z7KD7i1KU"
local githubToken = "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"

local function ProtectCheck()
  local headers = {
	  Authorization = "token " .. githubToken
  }

  local success, response = pcall(function()
	  return HttpService:GetAsync(githubApiUrl, true, headers)
  end)

  if success then
	local jsonData, parseError = HttpService:JSONDecode(response)

	if jsonData and not parseError and jsonData.key == expectedValue then
		    print("Login: Confirmado")
	    else
		    print("Login: Revogado")
	    end
  else
	  print("Erro ao obter proteção! Contacte no discord o PK, Discord: pk_oficial")
  end
end

-- Proteção do Script

-- [[ Functions ]] --
local function detectPlr(Player, Remote, Reason, Description, Fields)
	Fields = Fields or {}
	Player:Kick(KickMessage[Reason] or Reason or '???')

	--if CD_WEBHOOK[Player] then
	--	return
	--end

	--CD_WEBHOOK[Player] = true
	task.delay(0.8, function()
		--CD_WEBHOOK[Player] = nil
	end)

	local FieldsMod = {
		{
			name = '**Remote:**',
			value =  Remote and Remote.Name or  'Remote invalid.',
			inline = true,
		}
	}
	for i = 1, #Fields do
		local field = Fields[i]
		table.insert(FieldsMod, {
			name = field.name or 'No set',
			value = field.value or 'No set',
			inline = true
		})
	end

	local playerThumb = Players:GetUserThumbnailAsync(Player.UserId, Enum.ThumbnailType.HeadShot, Enum.ThumbnailSize.Size420x420)
	local data = {
		embeds = {
			{
				title = ('%s (%d)'):format(Player.Name, Player.UserId),
				color = 16737894,
				description = Description or nil,
				url = ('https://roblox.com/users/%d/profile'):format(Player.UserId),
				fields = FieldsMod or nil,
				thumbnail = {
					url = playerThumb,
				},
				footer = {
					text = '- Anti Cheat | Zv_yz#0847',
				},
			},
		},
	}

	local debugWebhook = Webhook:Post(data)

	if Run:IsStudio() then warn('[WEBHOOK_DEBUG]:', debugWebhook) return end

	return debugWebhook
end


local function getLog(player, _table)
	_table[player] = _table[player] or {}
	local Counts = 0
	local Ticks = {}

	for i,v in pairs(_table[player]) do
		if v[1] then
			Counts = Counts + 1
			table.insert(Ticks, string.format('`%d`', v[2]))
		end
	end

	return Counts, Ticks
end

local function formatCode(lang, txt)
	return ('```%s\n%s\n```'):format(lang, txt)
end

local function getRandomDigits(userId, count)
	local userIdString = tostring(userId)
	local index = math.random(1, #userIdString - count + 1)
	local digits = userIdString:sub(index, index + count - 1)
	return digits
end

local function getRandomNames(playerName, count)
	local names = {}
	local playerNames = playerName:split(' ')
	for i = 1, #playerNames do
		local j = math.random(i, #playerNames)
		playerNames[i], playerNames[j] = playerNames[j], playerNames[i]
	end
	for i = 1, math.min(count, #playerNames) do
		table.insert(names, playerNames[i])
	end
	return names
end

local function getWeaponOwner(Weapon)
	local Name = Weapon and Weapon.Name or 'N/A'
	local Owner = (Weapon and Weapon:FindFirstChild('owner') and Weapon:FindFirstChild('owner').Value) or 'UNKNOWN'
	return { name = Name, owner = Owner }
end

local function generateAccess(Player)
	local val = Instance.new('StringValue')
	val.Name = '_'
	val.Value = SHA256:Generate(Player.Name, tostring(Player.UserId) .. os.time())
	val.Parent = Hashes
	val:SetAttribute('_', string.reverse(getRandomDigits(Player.UserId, 3) .. table.concat(getRandomNames(Player.Name, 2))))
	local Task = task.spawn(function()
		task.wait(30)
		while task.wait(7) do
			TemporaryKeyServer = KEY_SERVER.Value
			task.delay(5, function()
				TemporaryKeyServer = nil
			end)
			val.Value = SHA256:Generate(Player.Name, tostring(Player.UserId) .. os.time())
		end
	end)

	return {val, Task}
end

-- [[ Events ]] --

task.spawn(function()
	while task.wait(15) do
		TemporaryKeyServer = KEY_SERVER.Value
		task.delay(10, function()
			TemporaryKeyServer = nil
		end)
		KEY_SERVER.Value = SHA256:GenerateRandom()
	end
end)

Evt.AcessId.OnServerInvoke = function(Player, Data)
	local fields = {{ name = '**Arguments:**', value = formatCode('json', HttpService:JSONEncode(Data)) }}

	if typeof(Data) ~= 'table' then
		detectPlr(Player, Evt.AcessId, 'Default detected by ACS', '[userdata](https://create.roblox.com/docs/scripting/luau/userdata) inválido.', fields)
		return
	end

	if Player.UserId ~= Data[1] and KEY_SERVER ~= Data[2] then
		detectPlr(Player, Evt.AcessId, 'Default detected by ACS', 'Algo não está correto para obter a key.', fields)
		table.insert(TempBannedPlayes, Player.UserId)
	end

	return PlayersUUID[Player] and PlayersUUID[Player][2] or ''
end


--Glenn's Anti-Exploit System (GAE for short). This code is very ugly, but does job done
local function compareTables(arr1, arr2)
	if	arr1.gunName==arr2.gunName 				and 
		arr1.Type==arr2.Type 					and
		arr1.ShootRate==arr2.ShootRate 			and
		arr1.Bullets==arr2.Bullets				and
		arr1.LimbDamage[1]==arr2.LimbDamage[1]	and
		arr1.LimbDamage[2]==arr2.LimbDamage[2]	and
		arr1.TorsoDamage[1]==arr2.TorsoDamage[1]and
		arr1.TorsoDamage[2]==arr2.TorsoDamage[2]and
		arr1.HeadDamage[1]==arr2.HeadDamage[1]	and
		arr1.HeadDamage[2]==arr2.HeadDamage[2]
	then
		return true
	else
		return false
	end
end

local function secureSettings(Player,Gun,Module)
	local PreNewModule = Gun:FindFirstChild('ACS_Settings');
	if not Gun or not PreNewModule then
		Player:kick('Exploit Protocol');
		warn(Player.Name..' - Potential Exploiter! Case 2: Missing Gun And Module')	;
		return false;
	end;

	local NewModule = require(PreNewModule);
	if (compareTables(Module, NewModule) == false) then
		Player:kick('Exploit Protocol');
		warn(Player.Name..' - Potential Exploiter! Case 4: Exploiting Gun Stats')	;
		table.insert(TempBannedPlayes, Player.UserId);
		return false;
	end;
	return true;
end;

function CalculateDMG(SKP_0, SKP_1, SKP_2, SKP_4, SKP_5, SKP_6)

	local skp_0	= nil
	local skp_1 = 0
	local skp_2 = SKP_5.MinDamage * SKP_6.minDamageMod

	if game.Players:GetPlayerFromCharacter(SKP_1.Parent) ~= nil then
		skp_0 = game.Players:GetPlayerFromCharacter(SKP_1.Parent)
	end

	if SKP_4 == 1 then
		local skp_3 = math.random(SKP_5.HeadDamage[1], SKP_5.HeadDamage[2])
		skp_1 = math.max(skp_2 ,(skp_3 * SKP_6.DamageMod) - (SKP_2/25) * SKP_5.DamageFallOf)
	elseif SKP_4 == 2 then
		local skp_3 = math.random(SKP_5.TorsoDamage[1], SKP_5.TorsoDamage[2])
		skp_1 = math.max(skp_2 ,(skp_3 * SKP_6.DamageMod) - (SKP_2/25) * SKP_5.DamageFallOf)
	else
		local skp_3 = math.random(SKP_5.LimbDamage[1], SKP_5.LimbDamage[2])
		skp_1 = math.max(skp_2 ,(skp_3 * SKP_6.DamageMod) - (SKP_2/25) * SKP_5.DamageFallOf)
	end

	if SKP_1.Parent:FindFirstChild("ACS_Client") ~= nil and not SKP_5.IgnoreProtection then

		local skp_4 = SKP_1.Parent.ACS_Client.Protecao.VestProtect
		local skp_5 = SKP_1.Parent.ACS_Client.Protecao.HelmetProtect

		if SKP_4 == 1 then
			if SKP_5.BulletPenetration < skp_5.Value  then
				skp_1 = math.max(.5 ,skp_1 * (SKP_5.BulletPenetration/skp_5.Value))
			end
		else
			if SKP_5.BulletPenetration < skp_4.Value  then
				skp_1 = math.max(.5 ,skp_1 * (SKP_5.BulletPenetration/skp_4.Value))
			end
		end
	end		

	if skp_0 ~= nil then
		if skp_0.Team ~= SKP_0.Team or skp_0.Neutral == true then
			SKP_1:TakeDamage(skp_1)
		else
			if gameRules.TeamKill then
				SKP_1:TakeDamage(skp_1 * gameRules.TeamDmgMult)
			end
		end
	else
		SKP_1:TakeDamage(skp_1)
	end
end

Evt.Damage.OnServerEvent:Connect(function(Player, Weapon, Victim, Distance, PartHumanoid, WeaponData, ModTable, ServerKey, PlayerKey, UUID)
	if not Player or not Player.Character then
		return
	end

	if not Player.Character:FindFirstChild('Humanoid') or Player.Character.Humanoid.Health <= 0 then
		return
	end

	local PlrData = PlayersUUID[Player]

	local RNG = Random.new()
	--local weaponOwner = getWeaponOwner(Weapon)
	--local OWNER_TOOL = Weapon ~= nil and (Weapon:FindFirstChild('owner') and Weapon:FindFirstChild('owner').Value) or 'UNKNOWN'

	local origPlayer = Victim.Parent and Players:GetPlayerFromCharacter(Victim.Parent)

	local function notif()
		warn(Player.Name..' - Potential Exploiter - Don´t Have Tool!')
		Player:Kick('Potential Exploiter!')
	end

	local Data = Player:WaitForChild('Data')
	local Items = Data.Items

	if Items[Weapon].Value < 1 then
		notif()
	end

	local _Tick = tick()
	local Val = PlrData[3][1];
	local TmpKey = TemporaryValidKey[Player]

	print(Weapon)
	if (ServerKey == TemporaryKeyServer or ServerKey == KEY_SERVER.Value) and (TmpKey == Val.Value or PlayerKey == Val.Value) and UUID == PlayersUUID[Player][2] then
		coroutine.resume(coroutine.create(function()
			if not origPlayer then
				return
			end

			--[[
			local Counts, Ticks = getLog(LogDamage[Player], LogDamage)

			if Counts > 4 then
				detectPlr(Player, Evt.Damage, 'DAMAGE_REMOTE', 'Tentou dar kill all, provavalmente.', {
					{
						name = '**Arma/Owner:**',
						value = ('%s (%s)'):format()
					},
					{
						name = '**Pontos (Tentativa por kills/ms):**',
						value = ('%s\n[%s]'):format(tostring(Counts), table.concat(Ticks, ', '))
					}
				})
				LogDamage[Player] = nil
				return
			elseif not LogDamage[Player][origPlayer] then
				LogDamage[Player][origPlayer] = { true, tick() - _Tick }
				task.wait(RNG:NextNumber(0.3, 0.5))
				LogDamage[Player][origPlayer] = nil
			end
			]]--
		end))

		local secureSettingsResult = secureSettings(Player, Weapon, WeaponData)
		if not secureSettingsResult or not Victim then
			return
		end
	end
	CalculateDMG(Player, Victim, Distance, PartHumanoid, WeaponData, ModTable)

	--warn(([[
	-------------  INFO  -----------
	--Event: HeadRot
	--Player: %s
	------------- SERVER -----------
	--Server Key: %s
	--Temporary Server Key: %s
	--Argument Server Key: %s
	------------- PLAYER -----------
	--Player Key: %s
	--Temporary Player Key: %s
	--Argument Player Key: %s
	-------------  UUID  -----------
	--UUID: %s
	--Argument UUID: %s
	--]]):format(
	--		tostring(Player.Name), 
	--		tostring(KEY_SERVER.Value), 
	--		tostring(TemporaryKeyServer), 
	--		tostring(ServerKey), 
	--		tostring(Val.Value), 
	--		tostring(TmpKey), 
	--		tostring(PlayerKey), 
	--		tostring(PlayersUUID[Player][2]), 
	--		tostring(UUID)
	--	))

	--Player:Kick('Exploit Protocol')
	--warn(Player.Name .. ' - Potential Exploiter! Case 0-B: Wrong Permission Code')
	--table.insert(TempBannedPlayes, Player.UserId)
	return
end)

Evt.HitEffect.OnServerEvent:Connect(function(Player, Position, HitPart, Normal, Material, Settings)
	Evt.HitEffect:FireAllClients(Player, Position, HitPart, Normal, Material, Settings)
end)

Evt.GunStance.OnServerEvent:Connect(function(Player,stance,Data)
	Evt.GunStance:FireAllClients(Player,stance,Data)
end)

Evt.ServerBullet.OnServerEvent:Connect(function(Player,Origin,Direction,WeaponData,ModTable)
	-- this is trash i know
	local _origin = string.lower(tostring(Origin))
	local _direction = string.lower(tostring(Direction))
	for i,v in next, VectorFilters do
		if string.find(_origin, v) or string.find(_direction, v) then
			detectPlr(Player, Evt.ServerBullet, 'SVBULLET_REMOTE', Player.Name.. ' tentou crashar server.')
			return
		end
	end
	Evt.ServerBullet:FireAllClients(Player,Origin,Direction,WeaponData,ModTable)
end)


Evt.Stance.OnServerEvent:connect(function(Player, Stance, Virar)

	if Player.Character and Player.Character:FindFirstChild("Humanoid") ~= nil and Player.Character.Humanoid.Health > 0 then

		local char		= Player.Character
		local Human 	= char:WaitForChild("Humanoid")
		local ACS_Client= char:WaitForChild("ACS_Client")

		local LowerTorso= char:FindFirstChild("LowerTorso")
		local UpperTorso= char:FindFirstChild("UpperTorso")
		local RootJoint = char["LowerTorso"]:FindFirstChild("Root")
		local WaistJ 	= char["UpperTorso"]:FindFirstChild("Waist")
		local RS 		= char["RightUpperArm"]:FindFirstChild("RightShoulder")
		local LS 		= char["LeftUpperArm"]:FindFirstChild("LeftShoulder")
		local RH 		= char["RightUpperLeg"]:FindFirstChild("RightHip")
		local RK 		= char["RightLowerLeg"]:FindFirstChild("RightKnee")
		local LH 		= char["LeftUpperLeg"]:FindFirstChild("LeftHip")
		local LK 		= char["LeftLowerLeg"]:FindFirstChild("LeftKnee")

		local RightArm	= char["RightUpperArm"]
		local LeftArm 	= char["LeftUpperArm"]
		local LeftLeg 	= char["LeftUpperLeg"]
		local RightLeg 	= char["RightUpperLeg"]


		if Stance == 2 and RootJoint and WaistJ and RH and LH and RK and LK then
			TS:Create(RootJoint, TweenInfo.new(.3), {C0 = CFrame.new(0,-Human.HipHeight - LowerTorso.Size.Y,Human.HipHeight/1.25)* CFrame.Angles(math.rad(-90),0,math.rad(0))} ):Play()
			TS:Create(WaistJ, TweenInfo.new(.3), {C0 = CFrame.new(0,LowerTorso.Size.Y/2.5,0)* CFrame.Angles(math.rad(0),0,math.rad(0))} ):Play()
			TS:Create(RH, TweenInfo.new(.3), {C0 = CFrame.new(RightLeg.Size.X/2, -LowerTorso.Size.Y/2,0)* CFrame.Angles(math.rad(0),math.rad(0),math.rad(0))} ):Play()
			TS:Create(LH, TweenInfo.new(.3), {C0 = CFrame.new(-LeftLeg.Size.X/2, -LowerTorso.Size.Y/2,0)* CFrame.Angles(math.rad(0),math.rad(0),math.rad(0))} ):Play()
			TS:Create(RK, TweenInfo.new(.3), {C0 = CFrame.new(0, -RightLeg.Size.Y/3,0)* CFrame.Angles(math.rad(0),math.rad(0),math.rad(0))} ):Play()
			TS:Create(LK, TweenInfo.new(.3), {C0 = CFrame.new(0, -LeftLeg.Size.Y/3,0)* CFrame.Angles(math.rad(0),math.rad(0),math.rad(0))} ):Play()

		end
		if Virar == 1 and RootJoint and WaistJ and RH and LH and RK and LK then
			if Stance == 0 then
				TS:Create(WaistJ, TweenInfo.new(.3), {C0 = CFrame.new(0,LowerTorso.Size.Y/2.5,0) * CFrame.Angles(math.rad(0),0,math.rad(-30))} ):Play()
				TS:Create(RootJoint, TweenInfo.new(.3), {C0 = CFrame.new(0,-(Human.HipHeight/2),0)* CFrame.Angles(math.rad(0),0,math.rad(0))} ):Play()
				TS:Create(RH, TweenInfo.new(.3), {C0 = CFrame.new(RightLeg.Size.X/2, -LowerTorso.Size.Y/2,0)* CFrame.Angles(math.rad(0),math.rad(0),math.rad(0))} ):Play()
				TS:Create(LH, TweenInfo.new(.3), {C0 = CFrame.new(-LeftLeg.Size.X/2, -LowerTorso.Size.Y/2,0)* CFrame.Angles(math.rad(0),math.rad(0),math.rad(0))} ):Play()
				TS:Create(RK, TweenInfo.new(.3), {C0 = CFrame.new(0, -RightLeg.Size.Y/3,0)* CFrame.Angles(math.rad(0),math.rad(0),math.rad(0))} ):Play()
				TS:Create(LK, TweenInfo.new(.3), {C0 = CFrame.new(0, -LeftLeg.Size.Y/3,0)* CFrame.Angles(math.rad(0),math.rad(0),math.rad(0))} ):Play()

			elseif Stance == 1 then
				TS:Create(WaistJ, TweenInfo.new(.3), {C0 = CFrame.new(0,LowerTorso.Size.Y/2.5,0)* CFrame.Angles(math.rad(0),0,math.rad(-30))} ):Play()
				TS:Create(RootJoint, TweenInfo.new(.3), {C0 = CFrame.new(0,-Human.HipHeight/1.05,0)* CFrame.Angles(math.rad(0),0,math.rad(0))} ):Play()
				TS:Create(RH, TweenInfo.new(.3), {C0 = CFrame.new(RightLeg.Size.X/2, -LowerTorso.Size.Y/2,0)* CFrame.Angles(math.rad(0),math.rad(0),math.rad(0))} ):Play()
				TS:Create(LH, TweenInfo.new(.3), {C0 = CFrame.new(-LeftLeg.Size.X/2, -LowerTorso.Size.Y/2,0)* CFrame.Angles(math.rad(75),math.rad(0),math.rad(0))} ):Play()
				TS:Create(RK, TweenInfo.new(.3), {C0 = CFrame.new(0, -RightLeg.Size.Y/2,0)* CFrame.Angles(math.rad(-90),math.rad(0),math.rad(0))} ):Play()
				TS:Create(LK, TweenInfo.new(.3), {C0 = CFrame.new(0, -LeftLeg.Size.Y/3.5,0)* CFrame.Angles(math.rad(-60),math.rad(0),math.rad(0))} ):Play()

			end
		elseif Virar == -1 and RootJoint and WaistJ and RH and LH and RK and LK then
			if Stance == 0 then
				TS:Create(WaistJ, TweenInfo.new(.3), {C0 = CFrame.new(0,LowerTorso.Size.Y/2.5,0) * CFrame.Angles(math.rad(0),0,math.rad(30))} ):Play()
				TS:Create(RootJoint, TweenInfo.new(.3), {C0 = CFrame.new(0,-(Human.HipHeight/2),0)* CFrame.Angles(math.rad(0),0,math.rad(0))} ):Play()
				TS:Create(RH, TweenInfo.new(.3), {C0 = CFrame.new(RightLeg.Size.X/2, -LowerTorso.Size.Y/2,0)* CFrame.Angles(math.rad(0),math.rad(0),math.rad(0))} ):Play()
				TS:Create(LH, TweenInfo.new(.3), {C0 = CFrame.new(-LeftLeg.Size.X/2, -LowerTorso.Size.Y/2,0)* CFrame.Angles(math.rad(0),math.rad(0),math.rad(0))} ):Play()
				TS:Create(RK, TweenInfo.new(.3), {C0 = CFrame.new(0, -RightLeg.Size.Y/3,0)* CFrame.Angles(math.rad(0),math.rad(0),math.rad(0))} ):Play()
				TS:Create(LK, TweenInfo.new(.3), {C0 = CFrame.new(0, -LeftLeg.Size.Y/3,0)* CFrame.Angles(math.rad(0),math.rad(0),math.rad(0))} ):Play()

			elseif Stance == 1 then
				TS:Create(WaistJ, TweenInfo.new(.3), {C0 = CFrame.new(0,LowerTorso.Size.Y/2.5,0)* CFrame.Angles(math.rad(0),0,math.rad(30))} ):Play()
				TS:Create(RootJoint, TweenInfo.new(.3), {C0 = CFrame.new(0,-Human.HipHeight/1.05,0)* CFrame.Angles(math.rad(0),0,math.rad(0))} ):Play()
				TS:Create(RH, TweenInfo.new(.3), {C0 = CFrame.new(RightLeg.Size.X/2, -LowerTorso.Size.Y/2,0)* CFrame.Angles(math.rad(0),math.rad(0),math.rad(0))} ):Play()
				TS:Create(LH, TweenInfo.new(.3), {C0 = CFrame.new(-LeftLeg.Size.X/2, -LowerTorso.Size.Y/2,0)* CFrame.Angles(math.rad(75),math.rad(0),math.rad(0))} ):Play()
				TS:Create(RK, TweenInfo.new(.3), {C0 = CFrame.new(0, -RightLeg.Size.Y/2,0)* CFrame.Angles(math.rad(-90),math.rad(0),math.rad(0))} ):Play()
				TS:Create(LK, TweenInfo.new(.3), {C0 = CFrame.new(0, -LeftLeg.Size.Y/3.5,0)* CFrame.Angles(math.rad(-60),math.rad(0),math.rad(0))} ):Play()

			end
		elseif Virar == 0 and RootJoint and WaistJ and RH and LH and RK and LK then
			if Stance == 0 then
				TS:Create(WaistJ, TweenInfo.new(.3), {C0 = CFrame.new(0,LowerTorso.Size.Y/2.5,0)* CFrame.Angles(math.rad(-0),0,math.rad(0))} ):Play()
				TS:Create(RootJoint, TweenInfo.new(.3), {C0 = CFrame.new(0,-(Human.HipHeight/2),0)* CFrame.Angles(math.rad(0),0,math.rad(0))} ):Play()
				TS:Create(RH, TweenInfo.new(.3), {C0 = CFrame.new(RightLeg.Size.X/2, -LowerTorso.Size.Y/2,0)* CFrame.Angles(math.rad(0),math.rad(0),math.rad(0))} ):Play()
				TS:Create(LH, TweenInfo.new(.3), {C0 = CFrame.new(-LeftLeg.Size.X/2, -LowerTorso.Size.Y/2,0)* CFrame.Angles(math.rad(0),math.rad(0),math.rad(0))} ):Play()
				TS:Create(RK, TweenInfo.new(.3), {C0 = CFrame.new(0, -RightLeg.Size.Y/3,0)* CFrame.Angles(math.rad(0),math.rad(0),math.rad(0))} ):Play()
				TS:Create(LK, TweenInfo.new(.3), {C0 = CFrame.new(0, -LeftLeg.Size.Y/3,0)* CFrame.Angles(math.rad(0),math.rad(0),math.rad(0))} ):Play()

			elseif Stance == 1 then
				TS:Create(WaistJ, TweenInfo.new(.3), {C0 = CFrame.new(0,LowerTorso.Size.Y/2.5,0)* CFrame.Angles(math.rad(0),0,math.rad(0))} ):Play()
				TS:Create(RootJoint, TweenInfo.new(.3), {C0 = CFrame.new(0,-Human.HipHeight/1.05,0)* CFrame.Angles(math.rad(0),0,math.rad(0))} ):Play()
				TS:Create(RH, TweenInfo.new(.3), {C0 = CFrame.new(RightLeg.Size.X/2, -LowerTorso.Size.Y/2,0)* CFrame.Angles(math.rad(0),math.rad(0),math.rad(0))} ):Play()
				TS:Create(LH, TweenInfo.new(.3), {C0 = CFrame.new(-LeftLeg.Size.X/2, -LowerTorso.Size.Y/2,0)* CFrame.Angles(math.rad(75),math.rad(0),math.rad(0))} ):Play()
				TS:Create(RK, TweenInfo.new(.3), {C0 = CFrame.new(0, -RightLeg.Size.Y/2,0)* CFrame.Angles(math.rad(-90),math.rad(0),math.rad(0))} ):Play()
				TS:Create(LK, TweenInfo.new(.3), {C0 = CFrame.new(0, -LeftLeg.Size.Y/3.5,0)* CFrame.Angles(math.rad(-60),math.rad(0),math.rad(0))} ):Play()

			end
		end

		if ACS_Client:GetAttribute("Surrender") then
			TS:Create(RS, TweenInfo.new(.3), {C0 = CFrame.new(RightArm.Size.X/1.15, UpperTorso.Size.Y/2.8,0)* CFrame.Angles(math.rad(179),math.rad(0),math.rad(0))} ):Play()
			TS:Create(LS, TweenInfo.new(.3), {C0 = CFrame.new(-LeftArm.Size.X/1.15, UpperTorso.Size.Y/2.8,0)* CFrame.Angles(math.rad(179),math.rad(0),math.rad(0))} ):Play()
		elseif Stance == 2 then
			TS:Create(RS, TweenInfo.new(.3), {C0 = CFrame.new(RightArm.Size.X/1.15, UpperTorso.Size.Y/2.8,0)* CFrame.Angles(math.rad(170),math.rad(0),math.rad(0))} ):Play()
			TS:Create(LS, TweenInfo.new(.3), {C0 = CFrame.new(-LeftArm.Size.X/1.15, UpperTorso.Size.Y/2.8,0)* CFrame.Angles(math.rad(170),math.rad(0),math.rad(0))} ):Play()
		else
			TS:Create(RS, TweenInfo.new(.3), {C0 = CFrame.new(RightArm.Size.X/1.15, UpperTorso.Size.Y/2.8,0)* CFrame.Angles(math.rad(0),math.rad(0),math.rad(0))} ):Play()
			TS:Create(LS, TweenInfo.new(.3), {C0 = CFrame.new(-LeftArm.Size.X/1.15, UpperTorso.Size.Y/2.8,0)* CFrame.Angles(math.rad(0),math.rad(0),math.rad(0))} ):Play()
		end
	end
end)

Evt.Grenade.OnServerEvent:Connect(function(SKP_0, SKP_1, SKP_2, SKP_3, SKP_4, SKP_5, SKP_6) -- TODO: make new grenade
end)

function loadAttachment(weapon,WeaponData)
	if not weapon or not WeaponData or not weapon:FindFirstChild('Nodes') then return; end;
	--load sight Att
	if weapon.Nodes:FindFirstChild('Sight') and WeaponData.SightAtt ~= '' then

		local SightAtt = AttModels[WeaponData.SightAtt]:Clone()
		SightAtt.Parent = weapon
		SightAtt:SetPrimaryPartCFrame(weapon.Nodes.Sight.CFrame)

		for index, key in pairs(weapon:GetChildren()) do
			if not key:IsA('BasePart') or key.Name ~= 'IS' then continue; end;
			key.Transparency = 1
		end

		for index, key in pairs(SightAtt:GetChildren()) do
			if key.Name == 'SightMark' or key.Name == 'Main' then key:Destroy(); continue; end;
			if not key:IsA('BasePart') then continue; end;
			Utilities.Weld(weapon:WaitForChild('Handle'), key )
			key.Anchored = false
			key.CanCollide = false
		end

	end

	--load Barrel Att
	if weapon.Nodes:FindFirstChild('Barrel') and WeaponData.BarrelAtt ~= '' then

		local BarrelAtt = AttModels[WeaponData.BarrelAtt]:Clone()
		BarrelAtt.Parent = weapon
		BarrelAtt:SetPrimaryPartCFrame(weapon.Nodes.Barrel.CFrame)

		if BarrelAtt:FindFirstChild('BarrelPos') then
			weapon.Handle.Muzzle.WorldCFrame = BarrelAtt.BarrelPos.CFrame
		end

		for index, key in pairs(BarrelAtt:GetChildren()) do
			if not key:IsA('BasePart') then continue; end;
			Utilities.Weld(weapon:WaitForChild('Handle'), key )
			key.Anchored = false
			key.CanCollide = false
		end
	end

	--load Under Barrel Att
	if weapon.Nodes:FindFirstChild('UnderBarrel') and WeaponData.UnderBarrelAtt ~= '' then

		local UnderBarrelAtt = AttModels[WeaponData.UnderBarrelAtt]:Clone()
		UnderBarrelAtt.Parent = weapon
		UnderBarrelAtt:SetPrimaryPartCFrame(weapon.Nodes.UnderBarrel.CFrame)


		for index, key in pairs(UnderBarrelAtt:GetChildren()) do
			if not key:IsA('BasePart') then continue; end;
			Utilities.Weld(weapon:WaitForChild('Handle'), key )
			key.Anchored = false
			key.CanCollide = false
		end
	end

	if weapon.Nodes:FindFirstChild('Other') and WeaponData.OtherAtt ~= '' then

		local OtherAtt = AttModels[WeaponData.OtherAtt]:Clone()
		OtherAtt.Parent = weapon
		OtherAtt:SetPrimaryPartCFrame(weapon.Nodes.Other.CFrame)

		for index, key in pairs(OtherAtt:GetChildren()) do
			if not key:IsA('BasePart') then continue; end;
			Utilities.Weld(weapon:WaitForChild('Handle'), key )
			key.Anchored = false
			key.CanCollide = false

		end
	end
end


Evt.Equip.OnServerEvent:Connect(function(Player,Arma,Mode,Settings,Anim)
	--print(Arma)

	if Player.Character then
		if Mode == 1 then
			local Head = Player.Character:FindFirstChild('Head')

			local ServerGun = GunModels:FindFirstChild(Arma):clone()
			ServerGun.Name = 'S' .. Arma

			AnimBase = Instance.new("Part", Player.Character)
			AnimBase.FormFactor = "Custom"
			AnimBase.CanCollide = false
			AnimBase.Transparency = 1
			AnimBase.Anchored = false
			AnimBase.Name = "AnimBase"
			AnimBase.Size = Vector3.new(0.1, 0.1, 0.1)

			AnimBaseW = Instance.new("Motor6D")
			AnimBaseW.Part0 = Head
			AnimBaseW.Part1 = AnimBase
			AnimBaseW.Parent = AnimBase
			AnimBaseW.Name = "AnimBaseW"
			--AnimBaseW.C0 = CFrame.new(0,-1.25,0)

			RA = Player.Character['RightUpperArm']
			LA = Player.Character['LeftUpperArm']
			RightS = RA:WaitForChild("RightShoulder")
			LeftS = LA:WaitForChild("LeftShoulder")

			ruaw = Instance.new("Motor6D")
			ruaw.Name = "RAW"
			ruaw.Part0 = RA
			ruaw.Part1 = AnimBase
			ruaw.Parent = AnimBase
			ruaw.C0 = Anim.SV_RightArmPos
			RightS.Enabled = false

			rlaw = Instance.new("Motor6D")
			rlaw.Name = "RLAW"
			rlaw.Part0 = Player.Character.RightLowerArm
			rlaw.Part1 = RA
			rlaw.Parent = AnimBase
			rlaw.C0 = CFrame.new(0,RA.Size.Y/2,0) * Anim.SV_RightElbowPos


			ruaw = Instance.new("Motor6D")
			ruaw.Name = "RHW"
			ruaw.Part0 = Player.Character.RightHand
			ruaw.Part1 = Player.Character.RightLowerArm
			ruaw.Parent = AnimBase
			ruaw.C0 = CFrame.new(0,Player.Character.RightLowerArm.Size.Y/2,0) * Anim.SV_RightWristPos

			luaw = Instance.new("Motor6D")
			luaw.Name = "LAW"
			luaw.Part0 = LA
			luaw.Part1 = AnimBase
			luaw.Parent = AnimBase
			luaw.C0 = Anim.SV_LeftArmPos
			LeftS.Enabled = false

			llaw = Instance.new("Motor6D")
			llaw.Name = "LLAW"
			llaw.Part0 = Player.Character.LeftLowerArm
			llaw.Part1 = LA
			llaw.Parent = AnimBase
			llaw.C0 = CFrame.new(0,LA.Size.Y/2,0) * Anim.SV_LeftElbowPos

			lhw = Instance.new("Motor6D")
			lhw.Name = "LHW"
			lhw.Part0 = Player.Character.LeftHand
			lhw.Part1 = Player.Character.LeftLowerArm
			lhw.Parent = AnimBase
			lhw.C0 = CFrame.new(0,Player.Character.LeftLowerArm.Size.Y/2,0) * Anim.SV_LeftWristPos

			ServerGun.Parent = Player.Character

			loadAttachment(ServerGun,Settings)

			if ServerGun:FindFirstChild("Nodes") ~= nil then
				ServerGun.Nodes:Destroy()
			end

			for SKP_001, SKP_002 in pairs(ServerGun:GetDescendants()) do
				if SKP_002.Name == "SightMark" then
					SKP_002:Destroy()
				end
			end

			for SKP_001, SKP_002 in pairs(ServerGun:GetDescendants()) do
				if SKP_002:IsA('BasePart') and SKP_002.Name ~= 'Handle' then
					Ultil.WeldComplex(ServerGun:WaitForChild("Handle"), SKP_002, SKP_002.Name)
				end;
			end

			local SKP_004 = Instance.new('Motor6D')
			SKP_004.Name = 'Handle'
			SKP_004.Parent = ServerGun.Handle
			SKP_004.Part0 = Player.Character['RightHand']
			SKP_004.Part1 = ServerGun.Handle
			SKP_004.C1 = Anim.SV_GunPos:inverse()

			for L_74_forvar1, L_75_forvar2 in pairs(ServerGun:GetDescendants()) do
				if L_75_forvar2:IsA('BasePart') then
					L_75_forvar2.Anchored = false
					L_75_forvar2.CanCollide = false
				end
			end

		elseif Mode == 2 then
			local weaponModel = Player.Character:FindFirstChildWhichIsA("Model")
			if weaponModel and weaponModel.Name:sub(1, 1) == "S" then
				weaponModel:Destroy()
				Player.Character.AnimBase:Destroy()
			end

			local rightUpperArm = Player.Character:FindFirstChild("RightUpperArm")
			if rightUpperArm and rightUpperArm:FindFirstChild("RightShoulder") then
				rightUpperArm:WaitForChild("RightShoulder").Enabled = true
			end

			local leftUpperArm = Player.Character:FindFirstChild("LeftUpperArm")
			if leftUpperArm and leftUpperArm:FindFirstChild("LeftShoulder") then
				leftUpperArm:WaitForChild("LeftShoulder").Enabled = true
			end
		end
	end
end)

Evt.Atirar.OnServerEvent:Connect(function(Player, Arma, Suppressor, FlashHider)
	Evt.Atirar:FireAllClients(Player, Arma, Suppressor, FlashHider)
end)

Evt.HeadRot.OnServerEvent:connect(function(Player, CF)
	Evt.HeadRot:FireAllClients(Player, CF)
end)

Evt.Whizz.OnServerEvent:Connect(function(Player, ...)
	detectPlr(Player, Evt.Whizz, 'WHIZZ_REMOTE', 'Desconhecido.', {
		{
			['name'] = '**Argumentos:**',
			['value'] = formatCode('json', HttpService:JSONEncode({...}) or '{}'),
		}
	})
end)

Evt.Suppression.OnServerEvent:Connect(function(Player, ...)
	detectPlr(Player, Evt.Suppression, 'SUPPRESSION_REMOTE', 'Desconhecido.', {
		{
			['name'] = '**Argumentos:**',
			['value'] = formatCode('json', HttpService:JSONEncode({...}) or '{}'),
		}
	})
end)

Evt.Breach.OnServerInvoke = function(Player, ...)
	detectPlr(Player, Evt.Breach, 'BREACH_REMOTE', 'Possível tentou criar Instance no jogo.', {
		{
			['name'] = '**Argumentos:**',
			['value'] = formatCode('json', HttpService:JSONEncode({...}))
		}
	})
end

Evt.SVFlash.OnServerEvent:Connect(function(Player,Arma,Mode)
	Evt.SVFlash:FireAllClients(Player,Arma,Mode)
end)

Evt.Drag.OnServerEvent:Connect(function(Player) -- vulnerable
	detectPlr(Player, RestrictedRemote, '???', 'Remote censurado por motivos de segunraça.')
end)

function BreachFunction(Player,Mode,BreachPlace,Pos,Norm,Hit)

	if Mode == 1 then
		if Player.Character.ACS_Client.Kit.BreachCharges.Value > 0 then
			Player.Character.ACS_Client.Kit.BreachCharges.Value = Player.Character.ACS_Client.Kit.BreachCharges.Value - 1
			BreachPlace.Destroyed.Value = true
			local C4 = Engine.FX.BreachCharge:Clone()

			C4.Parent = BreachPlace.Destroyable
			C4.Center.CFrame = CFrame.new(Pos, Pos + Norm) * CFrame.Angles(math.rad(-90),math.rad(0),math.rad(0))
			C4.Center.Place:play()

			local weld = Instance.new("WeldConstraint")
			weld.Parent = C4
			weld.Part0 = BreachPlace.Destroyable.Charge
			weld.Part1 = C4.Center

			wait(1)
			C4.Center.Beep:play()
			wait(4)
			if C4 and C4:FindFirstChild("Center") then
				local att = Instance.new("Attachment")
				att.CFrame = C4.Center.CFrame
				att.Parent = workspace.Terrain

				local aw = Engine.FX.ExpEffect:Clone()
				aw.Parent = att
				aw.Enabled = false
				aw:Emit(35)
				Debris:AddItem(aw,aw.Lifetime.Max)

				local Exp = Instance.new("Explosion")
				Exp.BlastPressure = 0
				Exp.BlastRadius = 0
				Exp.DestroyJointRadiusPercent = 0
				Exp.Position = C4.Center.Position
				Exp.Parent = workspace

				local S = Instance.new("Sound")
				S.EmitterSize = 10
				S.MaxDistance = 1000
				S.SoundId = "rbxassetid://"..Explosion[math.random(1, 7)]
				S.PlaybackSpeed = math.random(30,55)/40
				S.Volume = 2
				S.Parent = att
				S.PlayOnRemove = true
				S:Destroy()

				for SKP_001, SKP_002 in pairs(game.Players:GetChildren()) do
					if SKP_002:IsA('Player') and SKP_002.Character and SKP_002.Character:FindFirstChild('Head') and (SKP_002.Character.Head.Position - C4.Center.Position).magnitude <= 15 then
						local DistanceMultiplier = (((SKP_002.Character.Head.Position - C4.Center.Position).magnitude/35) - 1) * -1
						local intensidade = DistanceMultiplier
						local Tempo = 15 * DistanceMultiplier
						Evt.Suppression:FireClient(SKP_002,2,intensidade,Tempo)
					end
				end

				Debris:AddItem(BreachPlace.Destroyable,0)
			end
		end

	elseif Mode == 2 then

		local aw = Engine.FX.DoorBreachFX:Clone()
		aw.Parent = BreachPlace.Door.Door
		aw.RollOffMaxDistance = 100
		aw.RollOffMinDistance = 5
		aw:Play()

		BreachPlace.Destroyed.Value = true
		if BreachPlace.Door:FindFirstChild("Hinge") ~= nil then
			BreachPlace.Door.Hinge:Destroy()
		end
		if BreachPlace.Door:FindFirstChild("Knob") ~= nil then
			BreachPlace.Door.Knob:Destroy()
		end

		local forca = Instance.new("BodyForce")
		forca.Force = -Norm * BreachPlace.Door.Door:GetMass() * Vector3.new(50,0,50)
		forca.Parent = BreachPlace.Door.Door

		Debris:AddItem(BreachPlace,3)

	elseif Mode == 3 then
		if Player.Character.ACS_Client.Kit.Fortifications.Value > 0 then
			Player.Character.ACS_Client.Kit.Fortifications.Value = Player.Character.ACS_Client.Kit.Fortifications.Value - 1
			BreachPlace.Fortified.Value = true
			local C4 = Instance.new('Part')

			C4.Parent = BreachPlace.Destroyable
			C4.Size =  Vector3.new(Hit.Size.X + .05,Hit.Size.Y + .05,Hit.Size.Z + 0.5) 
			C4.Material = Enum.Material.DiamondPlate
			C4.Anchored = true
			C4.CFrame = Hit.CFrame

			local S = Engine.FX.FortFX:Clone()
			S.PlaybackSpeed = math.random(30,55)/40
			S.Volume = 1
			S.Parent = C4
			S.PlayOnRemove = true
			S:Destroy()
		end
	end
end

Evt.Breach.OnServerInvoke = BreachFunction

function UpdateLog(Player,humanoid)

	local tag = humanoid:findFirstChild("creator")

	if tag ~= nil then

		local hours = os.date("*t")["hour"]
		local mins = os.date("*t")["min"]
		local sec = os.date("*t")["sec"]
		local TagType = tag:findFirstChild("type")

		if tag.Value.Name == Player.Name then
			local String = Player.Name.." Died | "..hours..":"..mins..":"..sec
			table.insert(CombatLog,String)
		else
			local String = tag.Value.Name.." Killed "..Player.Name.." | "..hours..":"..mins..":"..sec
			table.insert(CombatLog,String)
		end

		if #CombatLog > 50 then
			Backup = Backup + 1
			warn("ACS: Cleaning Combat Log | Backup: "..Backup)
			warn(CombatLog)
			CombatLog = {}
		end
	end
end

function CheckHostID(player)
	if Run:IsStudio() then return true end
	if game.CreatorType == Enum.CreatorType.User then
		if player.UserId == game.CreatorId then return true end
	elseif game.CreatorType == Enum.CreatorType.Group then
		if player:GetRankInGroup(game.CreatorId) >= gameRules.HostRank then return true end
	end
	for _, cID in pairs(gameRules.HostList) do
		if player.UserId == cID then return true end
	end
	return false
end

function SetupCharacter(player, char)
	char.Humanoid.BreakJointsOnDeath = false
	char.Humanoid.Died:Connect(function()

		UpdateLog(player,char.Humanoid)
		pcall(function()
			Ragdoll(char)
		end)
	end)

	repeat wait() until player:FindFirstChild('Backpack')
	repeat wait() until player:FindFirstChild('StarterGear')

	-- Set up listeners for future tools
	char.ChildAdded:Connect(function(newChild)
		if newChild:IsA('Tool') and newChild:FindFirstChild('ACS_Settings') and not newChild:FindFirstChild('owner') then
			local owner = Instance.new('StringValue')
			owner.Name = 'owner'
			owner.Value = player.Name
			owner.Parent = newChild
		end
	end)
	player.StarterGear.ChildAdded:Connect(function(newChild)
		if newChild:IsA('Tool') and newChild:FindFirstChild('ACS_Settings') and newChild:FindFirstChild('owner') and newChild:FindFirstChild('owner').Value ~= player.Name then
			newChild:FindFirstChild('owner').Value = player.Name
		end
	end)
	player.Backpack.ChildAdded:Connect(function(newChild)
		if newChild:IsA('Tool') and newChild:FindFirstChild('ACS_Settings') and newChild:FindFirstChild('owner') and newChild:FindFirstChild('owner').Value ~= player.Name then
			newChild:FindFirstChild('owner').Value = player.Name
		end
	end)
	player.Backpack.ChildRemoved:Connect(function(newChild)
		if newChild:IsA('Tool') and newChild:FindFirstChild('ACS_Settings') and char:FindFirstChild('S_'..newChild.Name) and not player.Backpack:FindFirstChild(newChild.Name) then
			char:FindFirstChild('S_'..newChild.Name):Destroy()
		end
	end)
end
Players.PlayerAdded:Connect(function(player)
  ProtectCheck()
    
	local sha, uuid = UUIDModule:Generate(false)
	--LogDamage[player] = {}
	PlayersUUID[player] = {sha, uuid, generateAccess(player)}

	if CheckHostID(player) then
		player.Chatted:Connect(function(msg)
			-- Convert to lowercase
			msg = string.lower(msg)

			local pfx = gameRules.CommandPrefix

			if msg == pfx..'acslog' or msg == pfx..'acs log' then
				Evt.CombatLog:FireClient(player,CombatLog)
			end
		end)
	end


	if table.find(TempBannedPlayes, player.UserId) then
		player:Kick('Temporary Banned')
		return
	end

	local setupWorked = false
	player.CharacterAdded:Connect(function(char)
		setupWorked = true
		SetupCharacter(player,char)
	end)

	-- Character setup failsafe
	repeat wait() until player.Character
	if not setupWorked then SetupCharacter(player,player.Character) end
end)

Players.PlayerRemoving:Connect(function(player)
	--if LogDamage[player] then LogDamage[player] = nil end
	if PlayersUUID[player] then
		local Func = PlayersUUID[player][3]
		task.cancel(Func[2])
		Func[1]:Destroy()
		PlayersUUID[player] = nil
	end
end)

-- Print version
warn('[SERVER] ' .. gameRules.Version)
