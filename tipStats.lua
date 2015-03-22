local frame, events = CreateFrame("Frame"), {};

function events:PLAYER_ENTERING_WORLD(...)
	--
end

function events:ADDON_LOADED(...)
	_init()
end

function events:PLAYER_LEAVING_WORLD(...)
 -- handle PLAYER_LEAVING_WORLD here
end

function events:UNIT_AURA(...)
	--_overlay()
end

frame:SetScript("OnEvent", function(self, event, ...)
 events[event](self, ...); -- call one of the functions above
end)

for k, v in pairs(events) do
 frame:RegisterEvent(k); -- Register all events for which handlers have been defined
end

function _init()

SlashCmdList["STATS"] = _ArgStatImport
SLASH_STATS1 = '/stats'

_loadPlayerDefaultStats()

--local db_StatValues = db_defaultStatValues
val_Gem = 50
val_GemSize = "Mastery"

db_defaultStatValues =
	{
		-- if no arguments given, use following defaults
		AttackPower = 0,
		MainHandDps = 0,
		Haste = 0,
		Strength = 0,
		Versatility = 0,
		CriticalStrike = 0,
		Multistrike = 0,
		Mastery = 0,
		Stamina = 0,
		SpellPower = 0,
		Intellect = 0,
		Agility = 0
	}

db_BestInSlot = {
	"118882",		-- Scabbard
	"113848",		-- Waffe
	"113658",		-- trinket socket
	"118295",		-- leg ring
}
db_Wearables = {
	"Rüstung",
	"Waffe",
	-- enGB,
	"Armor",
	"Weapon",
	-- ...
}

end

function _loadPlayerDefaultStats()
	-- no stats, default fallback
	if not((GetUnitName("player") == "Irrlicht") or (GetUnitName("player") == "Felino")) then _ArgStatImport("MainHandDps:0,Agility:0,AttackPower:0,CriticalStrike:0,Haste:0,Mastery:0,Multistrike:0,Versatility:0.,Stamina:0,Intellect:0,SpellPower:0,Strength:0") end

	if (GetUnitName("player") == "Quisa") then _ArgStatImport("SpellPower:0,Stamina:0,Agility:0,Intellect:0,Strength:1.00,AttackPower:0.89,CriticalStrike:0.44,Haste:0.27,Mastery:0.46,MainHandDps:1.54,Multistrike:0.46,Versatility:0.38") end
	if (GetUnitName("player") == "Irrlicht") then _ArgStatImport("SpellPower:0,Stamina:0,Agility:0,Intellect:0,Strength:1.00,AttackPower:0.89,CriticalStrike:0.44,Haste:0.27,Mastery:0.46,MainHandDps:1.54,Multistrike:0.46,Versatility:0.38") end
	if (GetUnitName("player") == "Felino") then _ArgStatImport("MainHandDps:1.00,Agility:1.00,AttackPower:0.91,CriticalStrike:0.85,Haste:0.59,Mastery:0.52,Multistrike:0.84,Versatility:0.73,Stamina:0,Intellect:0,SpellPower:0,Strength:0") end
end

function _ArgStatImport(msg)
	db_StatValues = {};
	KeyValuePairs = { strsplit(",", strtrim(msg)) }
	
	for _ in pairs(KeyValuePairs) do
		key, value = strsplit(":", (strsplit(",", KeyValuePairs[_])))
		db_StatValues[key] = value
	end
	
	UIErrorsFrame:AddMessage("StatValues importiert.", 1, 1, 1, 53, 5)
end



local function _getItemId(item)
	local itemTable = { GetItemInfo(item) }
	a, b = strsplit(":", itemTable[2])
	return b
end

local function _checkBIS(itemId)
	for _,v in pairs(db_BestInSlot) do
	  if v == itemId then return true end
	end
end

local function _checkIfWearable(item)
	itemTable = {}
	for _,v in pairs(db_Wearables) do
		itemTable = { GetItemInfo(item) }
		a = itemTable[6]
		if v == a then return true end
	end
end

-- Rechnen
local function OnTooltipSetItem(self)
	-- Guck ob rüstung/waffe
	itemType = _checkIfWearable(self:GetItem())
	
	if itemType == true then
		-- item is wearable, init
		ItemStats = {}
		StatWert = 0.0
		
		-- hol item id
		itemId = _getItemId(self:GetItem())
		
		local name, link = self:GetItem()
		GetItemStats(link, ItemStats)
			
		if (ItemStats["EMPTY_SOCKET_PRISMATIC"]) then
			StatWert = StatWert + ((val_Gem * ItemStats["EMPTY_SOCKET_PRISMATIC"]) * db_StatValues[val_GemSize])
		end
			
		-- defaults are given, however do the nil check
		if db_StatValues == nil then end

		StatWert = StatWert + ((ItemStats["ITEM_MOD_DAMAGE_PER_SECOND"] or 0) * db_StatValues.MainHandDps or 0)
		StatWert = StatWert + ((ItemStats["ITEM_MOD_SPELL_POWER_SHORT"] or 0) * (db_StatValues.SpellPower or 0))
			
		StatWert = StatWert + ((ItemStats["ITEM_MOD_AGILITY_SHORT"] or 0) * (db_StatValues.Agility or 0))
		StatWert = StatWert + ((ItemStats["ITEM_MOD_INTELLECT_SHORT"] or 0) * (db_StatValues.Intellect or 0))
		StatWert = StatWert + ((ItemStats["ITEM_MOD_STAMINA_SHORT"] or 0) * (db_StatValues.Stamina or 0))
		StatWert = StatWert + ((ItemStats["ITEM_MOD_STRENGTH_SHORT"] or 0) * (db_StatValues.Strength or 0))
			
		StatWert = StatWert + ((ItemStats["ITEM_MOD_ATTACK_POWER_SHORT"] or 0) * (db_StatValues.AttackPower or 0))
		StatWert = StatWert + ((ItemStats["ITEM_MOD_CriticalStrike_RATING_SHORT"] or 0) * (db_StatValues.CriticalStrike or 0))
		StatWert = StatWert + ((ItemStats["ITEM_MOD_HASTE_RATING_SHORT"] or 0) * (db_StatValues.Haste or 0))
		StatWert = StatWert + ((ItemStats["ITEM_MOD_MASTERY_RATING_SHORT"] or 0) * (db_StatValues.Mastery or 0))
		StatWert = StatWert + ((ItemStats["ITEM_MOD_CR_MULTISTRIKE_SHORT"] or 0) * (db_StatValues.Multistrike or 0))
		StatWert = StatWert + ((ItemStats["ITEM_MOD_VERSATILITY"] or 0) * (db_StatValues.Versatility or 0))
			
		if (StatWert > 0) then	
			if (ItemStats["EMPTY_SOCKET_PRISMATIC"]) then
				GameTooltip:AddLine("ItemValue: " .. StatWert .. " (" .. ItemStats["EMPTY_SOCKET_PRISMATIC"] .. "x " .. val_Gem .. " " .. val_GemSize ..")", 140, 140, 0)
			else
				GameTooltip:AddLine("ItemValue: " .. StatWert, 140, 140, 0)--75, 0, 130)
			end

		end

		isBiS = _checkBIS(itemId)

		if (isBiS == true ) then
			GameTooltip:AddLine("Best in Slot", 1, 0, 0)
		end
		
	end
end
	
GameTooltip:HookScript("OnTooltipSetItem", OnTooltipSetItem)