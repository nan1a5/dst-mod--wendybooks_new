local assets =
{
    -- Asset("ANIM", "anim/books.zip"),
    -- Asset("ANIM", "anim/books2.zip"),
    -- Asset("ANIM", "anim/fx_book_temperature.zip"),
    Asset("ANIM", "anim/book_diary_onbank.zip"),
    Asset("ATLAS", "images/book_dairy.xml"),
    Asset("IMAGE", "images/book_dairy.tex"),
}

-- local prefabs = -- this should really be broken up per book...
-- {
--   "fx_book_darktale"
-- }
local NEW_BOOK_DAIRY_RADIUS = 12;
local BOOK_DAIRY_REPLY = 25;

local uses = TUNING.BOOK_USES_SMALL;    --使用次数三
local BOOK_DARKTALE_READ_SANITY = -TUNING.SANITY_LARGE;    --33
local BOOK_DARKTALE_PERUSE_SANITY = TUNING.SANITY_LARGE;

local onreadfn = function(inst, reader)
    local x, y, z = reader.Transform:GetWorldPosition()
    local players = FindPlayersInRange( x, y, z, NEW_BOOK_DAIRY_RADIUS, true )
    
    for _, player in pairs(players) do


        if player:HasTag("ghostlyfriend") then
            player.components.inventory:GiveItem(SpawnPrefab("bananapop")) --奖励一个香蕉冰
            player.components.ghostlybond:SetBondLevel(3)
        end
        if player ~= reader then
            player.components.sanity:DoDelta(BOOK_DAIRY_REPLY)
        end
    end
    reader.components.talker:Say("1111111111")

    return true
end
local perusefn = function(inst,reader)
    if reader.peruse_temperature then
        reader.peruse_temperature(reader)
    end
    reader.components.talker:Say(GetString(reader, "ANNOUNCE_READ_BOOK","BOOK_TEMPERATURE"))
    return true
end


local function fn()
    local inst = CreateEntity()

    inst.entity:AddTransform()
    inst.entity:AddAnimState()
    inst.entity:AddSoundEmitter()
    inst.entity:AddNetwork()

    MakeInventoryPhysics(inst)

    inst.AnimState:SetBank("book_diary_onbank")
    inst.AnimState:SetBuild("book_diary_onbank")
    inst.AnimState:PlayAnimation("idle")

    MakeInventoryFloatable(inst, "med", nil, 0.75)

    inst:AddTag("book")
    inst:AddTag("bookcabinet_item")

    inst.entity:SetPristine()

    if not TheWorld.ismastersim then
        return inst
    end


    
    -----------------------------------

    -- inst.def = new_book

    inst:AddComponent("inspectable")
    inst:AddComponent("book")
    inst.components.book:SetOnRead(onreadfn)
    inst.components.book:SetOnPeruse(perusefn)
    inst.components.book:SetReadSanity(BOOK_DARKTALE_READ_SANITY)
    inst.components.book:SetPeruseSanity(BOOK_DARKTALE_PERUSE_SANITY)
    -- inst.components.book:SetFx(fx)

    inst:AddComponent("inventoryitem")
    inst.components.inventoryitem.imagename = "book_dairy"
    inst.components.inventoryitem.atlasname = "images/book_dairy.xml"

    inst:AddComponent("finiteuses")
    inst.components.finiteuses:SetMaxUses(uses)
    inst.components.finiteuses:SetUses(uses)
    inst.components.finiteuses:SetOnFinished(inst.Remove)

    inst:AddComponent("fuel")
    inst.components.fuel.fuelvalue = TUNING.MED_FUEL

    MakeSmallBurnable(inst, TUNING.MED_BURNTIME)
    MakeSmallPropagator(inst)

    --MakeHauntableLaunchOrChangePrefab(inst, TUNING.HAUNT_CHANCE_OFTEN, TUNING.HAUNT_CHANCE_OCCASIONAL, nil, nil, morphlist)
    MakeHauntableLaunch(inst)

    return inst
end

return Prefab("book_dairy", fn, assets)
