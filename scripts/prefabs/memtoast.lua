local assets = {Asset("ANIM", "anim/memtoast_onbank.zip"), Asset("IMAGE", "images/book_dairy.tex"), Asset("ATLAS", "images/book_dairy.xml")}

function fn()

    local inst = CreateEntity()
    inst.entity:AddTransform()
    inst.entity:AddAnimState()
    inst.entity:AddNetwork()

    MakeInventoryPhysics(inst)

    inst.AnimState:SetBank("memtoast_onbank")
    inst.AnimState:SetBuild("memtoast_onbank")
    inst.AnimState:PlayAnimation("idle")

    MakeInventoryFloatable(inst)
    --------------------------------------------------------------------------
    if not TheWorld.ismastersim then
        return inst
    end
    --------------------------------------------------------------------------
    inst:AddComponent("inspectable")
    inst:AddComponent("inventoryitem")

    inst.components.inventoryitem.atlasname = "images/book_dairy.xml" -- 在背包里的贴图

    inst:AddComponent("edible")
    inst.components.edible.foodtype = FOODTYPE.MEAT

    inst:AddComponent("perishable")
    inst.components.perishable:SetPerishTime(TUNING.PERISH_SUPERSLOW)
    inst.components.perishable:StartPerishing()
    inst.components.perishable.onperishreplacement = "spoiled_food" -- 腐烂成纸

    inst.components.edible.hungervalue = 88
    inst.components.edible.healthvalue = -8
    inst.components.edible.sanityvalue = 8

    inst:AddComponent("stackable") -- 可堆叠
    inst.components.stackable.maxsize = TUNING.STACK_SIZE_SMALLITEM

    MakeHauntableLaunch(inst)

    return inst
end

return Prefab("memtoast", fn, assets, prefabs)