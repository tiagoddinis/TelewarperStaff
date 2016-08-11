local assets=
{ 
    Asset("ANIM", "anim/telewarper_staff.zip"),
    Asset("ANIM", "anim/swap_telewarper_staff.zip"), 

    Asset("ATLAS", "images/inventoryimages/telewarper_staff.xml"),
    Asset("IMAGE", "images/inventoryimages/telewarper_staff.tex"),
}

local function onequip(inst, owner) 
    owner.AnimState:OverrideSymbol("swap_object", "swap_telewarper_staff", "telewarper_staff")
    owner.AnimState:Show("ARM_carry") 
    owner.AnimState:Hide("ARM_normal") 
end

local function onunequip(inst, owner) 
    owner.AnimState:Hide("ARM_carry") 
    owner.AnimState:Show("ARM_normal") 
end

local function fn()
    local inst = CreateEntity()

    inst.entity:AddTransform()
    inst.entity:AddAnimState()

    MakeInventoryPhysics(inst)

    inst:AddTag("warptool")

    inst.AnimState:SetBank("telewarper_staff")
    inst.AnimState:SetBuild("telewarper_staff")
    inst.AnimState:PlayAnimation("idle")

    if not TheWorld.ismastersim then
        return inst
    end

    inst:AddComponent("weapon")
    inst.components.weapon:SetDamage(TUNING.TELEWARPER_STAFF_DAMAGE)

    inst:AddComponent("finiteuses")
    inst.components.finiteuses:SetMaxUses(TUNING.TELEWARPER_STAFF_USES)
    inst.components.finiteuses:SetUses(TUNING.TELEWARPER_STAFF_USES)
    inst.components.finiteuses:SetOnFinished(inst.Remove)
    inst.components.finiteuses:SetConsumption(ACTIONS.WARP, 1)

    inst:AddComponent("inspectable")

    inst:AddComponent("inventoryitem")
    inst.components.inventoryitem.imagename = "telewarper_staff"
    inst.components.inventoryitem.atlasname = "images/inventoryimages/telewarper_staff.xml"
    
    inst:AddComponent("equippable")
    inst.components.equippable:SetOnEquip(onequip)
    inst.components.equippable:SetOnUnequip(onunequip)

    return inst
end

return  Prefab("common/inventory/telewarper_staff", fn, assets)