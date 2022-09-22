local assets =
{
    -- Asset("ANIM", "anim/books.zip"),
    -- Asset("ANIM", "anim/books2.zip"),
    Asset("ANIM", "anim/book_exaid_onbank.zip"),
    Asset("ATLAS", "images/book_exaid.xml"),
    Asset("IMAGE", "images/book_exaid.tex"),
}

-- local prefabs = -- this should really be broken up per book...
-- {
--   "fx_book_darktale"
-- }
local NEW_BOOK_DARKTALE_RADIUS = 16;
local BOOK_DARKTALE_REPLY = 25;

local uses = 1;    --使用次数一
local BOOK_DARKTALE_READ_SANITY = -TUNING.SANITY_LARGE;    --33
local BOOK_DARKTALE_PERUSE_SANITY = TUNING.SANITY_LARGE;

local onreadfn = function(inst, reader)



    --半血以下无法读书
    if reader.components.health:GetPercent() <= 0.5 then
        return false, "RISKONESHEAD";
    else
        local half_health = reader.components.health.currenthealth * 0.5

        local x, y, z = reader.Transform:GetWorldPosition()
        local players = FindPlayersInRange( x, y, z, NEW_BOOK_DARKTALE_RADIUS, true )


        if #players < 2 then
            return false, "NOONENEEDHELP"
        end
        -- reader.components.health:DeltaPenalty(half_health)
        reader.components.health:DoDelta(-half_health, nil, nil, nil, nil, true)
        for _, player in pairs(players) do

            if player ~= reader and (inst.components.health == nil or not inst.components.health:IsDead()) and not player:HasTag("health_as_oldage") then --对旺达无效
                local pataint_health = player.components.health
                if pataint_health:GetPercent() < 0.5 then
                    pataint_health:DoDelta(half_health * 0.75)
                    player.components.talker:Say("噢,我感觉好多了")
                else
                    player.components.talker:Say("谢谢,我很好")
                end
            end

        end
        return true;
    end


end
local perusefn = function(inst,reader)
    if reader.peruse_exaid then
        reader.peruse_exaid(reader)
    end
    reader.components.talker:Say(GetString(reader, "ANNOUNCE_READ_BOOK","BOOK_EXAID"))
    return true
end


local function fn()
    local inst = CreateEntity()

    inst.entity:AddTransform()
    inst.entity:AddAnimState()
    inst.entity:AddSoundEmitter()
    inst.entity:AddNetwork()

    MakeInventoryPhysics(inst)

    inst.AnimState:SetBank("book_exaid_onbank")
    inst.AnimState:SetBuild("book_exaid_onbank")
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
    inst.components.inventoryitem.imagename = "book_exaid"
    inst.components.inventoryitem.atlasname = "images/book_exaid.xml"

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

return Prefab("book_exaid", fn, assets)
