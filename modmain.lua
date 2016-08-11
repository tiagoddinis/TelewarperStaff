require = GLOBAL.require
local TheInput = GLOBAL.TheInput
local IsServer = GLOBAL.TheNet:GetIsServer()
local Ingredient = GLOBAL.Ingredient
local RECIPETABS = GLOBAL.RECIPETABS
local STRINGS = GLOBAL.STRINGS
local TECH = GLOBAL.TECH

GLOBAL.STRINGS.NAMES.TELEWARPER_STAFF = "Telewarper Staff"
GLOBAL.STRINGS.RECIPE_DESC.TELEWARPER_STAFF = "Warp heavy craftables, take them with you!"
GLOBAL.STRINGS.CHARACTERS.GENERIC.DESCRIBE.TELEWARPER_STAFF = "It pulsates with energy!"

TUNING.TELEWARPER_STAFF_USES = GetModConfigData("durability")
TUNING.TELEWARPER_STAFF_SANITY_DRAIN = GetModConfigData("sanitypenalty")
TUNING.TELEWARPER_STAFF_DAMAGE = 2

--------------------------------------------------------------------------------
-- Recipe ----------------------------------------------------------------------

if GetModConfigData("recipedifficulty") == "easy" then
    local telewarper = AddRecipe(
        "telewarper_staff",
        { Ingredient("spear", 1), Ingredient("bluegem", 1), Ingredient("purplegem", 1) },
        RECIPETABS.MAGIC, TECH.MAGIC_TWO
    )
    telewarper.atlas = "images/inventoryimages/telewarper_staff.xml"
elseif GetModConfigData("recipedifficulty") == "medium" then
	local telewarper = AddRecipe(
        "telewarper_staff",
        { Ingredient("livinglog", 2), Ingredient("bluegem", 1), Ingredient("telestaff", 1) },
        RECIPETABS.MAGIC,  TECH.MAGIC_THREE
    )
    telewarper.atlas = "images/inventoryimages/telewarper_staff.xml"
else
	local telewarper = AddRecipe(
        "telewarper_staff",
        { Ingredient("livinglog", 2), Ingredient("greenstaff", 1), Ingredient("telestaff", 1) },
        RECIPETABS.MAGIC,  TECH.MAGIC_THREE
    )
    telewarper.atlas = "images/inventoryimages/telewarper_staff.xml"
end


--------------------------------------------------------------------------------
-- Warpable objects ------------------------------------------------------------

local warpable_list = {
    "treasurechest",
    "icebox",
    "meatrack",
    "dragonflychest",
    "slow_farmplot",
    "fast_farmplot",
    "saltlick",
    "resurrectionstatue",
    "coldfirepit",
    "firepit",
    "nightlight",
    "researchlab",
    "researchlab2",
    "researchlab3",
    "researchlab4",
    "winterometer",
    "homesign",
    "wardrobe",
    "birdcage",
    "tent",
    "siestahut",
    "rainometer",
    "beebox",
    "ancient_altar",
    "arrowsign_post",
    "cookpot",
    "lightning_rod",
	"rabbithouse",
    "pighouse",
    "eyeturret",
	"firesuppressor",
    "wall_hay",
    "wall_wood",
    "wall_stone",
    "wall_moonrock",
    "wall_ruins",
	
    "pighead", -- missing inv image
    "mermhead", -- missing inv image
    "mermhouse", -- missing inv image
}

for k, v in pairs(warpable_list) do
	AddPrefabPostInit(v,function(inst)
		if GLOBAL.TheWorld.ismastersim then
			inst:AddComponent("warpable")
			inst:AddTag("warpable")
		end
	end)
end


--------------------------------------------------------------------------------
-- Warp Action -----------------------------------------------------------------

AddAction("WARP", "Warp", function(act)
	if act.doer ~= nil and act.target ~= nil
      and act.target.components.warpable
      and act.target:HasTag("warpable") then
        act.target.components.warpable:Warp(act.doer)

        -- apply sanity penalty
        if act.doer.components.sanity then
            act.doer.components.sanity:DoDelta(TUNING.TELEWARPER_STAFF_SANITY_DRAIN)
        end

        -- decrease staff durability
        local equipped = act.doer.components.inventory:GetEquippedItem(GLOBAL.EQUIPSLOTS.HANDS)
        equipped.components.finiteuses:Use(1)

        -- warp fx
        local targetPosition = act.target.Transform:GetWorldPosition()
        local lightning = GLOBAL.SpawnPrefab("lightning")
        lightning.Transform:SetPosition(act.target.Transform:GetWorldPosition())
        local clouds = GLOBAL.SpawnPrefab("collapse_small")
    	clouds.Transform:SetPosition(act.target.Transform:GetWorldPosition())
    	clouds:SetMaterial("metal")

        -- ondropped function
        act.target.components.inventoryitem:SetOnDroppedFn(function (item)
	        item:RemoveComponent("inventoryitem")
    		
            -- recreate container behaviour
    		if item.components.warpable.wascontainer then
	    		item:AddComponent("container")
	    		item.components.container.onopenfn = item.components.warpable.onopen
	    		item.components.container.onclosefn = item.components.warpable.onclose
	    		item.components.container:WidgetSetup(item.components.warpable.widgetname)
	    	end

	    	-- fix light casting
	    	if act.target.Light then
	    		act.target.Light:Enable(false)
			end

	    	-- recreate item collision
	    	if item.components.warpable.colradius then
    			GLOBAL.MakeObstaclePhysics(item, item.components.warpable.colradius)
    		end
        end)
		
        -- place item in inventory
        act.doer.components.inventory:GiveItem(act.target)
        return true
    else
        return false
    end
end)

GLOBAL.ACTIONS.WARP.priority = 2
GLOBAL.ACTIONS.WARP.distance = 8


--------------------------------------------------------------------------------
-- Component Action ------------------------------------------------------------

AddComponentAction("SCENE", "warpable", function(inst, doer, actions, right)
	local equipped = doer.components.inventory:GetEquippedItem(GLOBAL.EQUIPSLOTS.HANDS)
	local stewer = inst.components.stewer
	if equipped and equipped:HasTag("warptool") and right
	  and inst:HasTag("warpable") and not inst:HasTag("burnt")
      and (not inst:HasTag("fire") or inst:HasTag("wildfireprotected"))
      and not (stewer and stewer:IsCooking()) then
        table.insert(actions, GLOBAL.ACTIONS.WARP)
    end
end)


--------------------------------------------------------------------------------
-- Stategraph ------------------------------------------------------------------

AddStategraphState("wilson", GLOBAL.State{ name = "warpobject",
    tags = { "warping", "notalking", "abouttowarp", "autopredict" },

    onenter = function(inst)
        inst.components.locomotor:Stop()

        inst.AnimState:PlayAnimation("atk_pre")
        inst.AnimState:PushAnimation("atk", false)

        inst.SoundEmitter:PlaySound("dontstarve/wilson/attack_icestaff")
        
        inst.sg.statemem.action = inst.bufferedaction
        inst.sg:SetTimeout(20)
        
        if not GLOBAL.TheWorld.ismastersim then
            inst:PerformPreviewBufferedAction()
        end
    end,

    timeline =
    {
        GLOBAL.TimeEvent(8 * GLOBAL.FRAMES, function(inst)
            if GLOBAL.TheWorld.ismastersim then
                inst:PerformBufferedAction()
                inst.sg:RemoveStateTag("abouttowarp")
            end
        end),
    },

    events =
    {
        GLOBAL.EventHandler("equip", function(inst) inst.sg:GoToState("idle") end),
        GLOBAL.EventHandler("unequip", function(inst) inst.sg:GoToState("idle") end),
        GLOBAL.EventHandler("animqueueover", function(inst)
            if inst.AnimState:AnimDone() then
                inst.sg:GoToState("idle")
            end
        end),
    },

    onexit = function(inst)
        if inst.bufferedaction == inst.sg.statemem.action then
            inst:ClearBufferedAction()
        end
        inst.sg.statemem.action = nil
    end,
})


AddStategraphActionHandler("wilson", GLOBAL.ActionHandler(GLOBAL.ACTIONS.WARP, "warpobject"))
AddStategraphActionHandler("wilson_client", GLOBAL.ActionHandler(GLOBAL.ACTIONS.WARP, "warpobject"))

PrefabFiles = { "telewarper_staff" }