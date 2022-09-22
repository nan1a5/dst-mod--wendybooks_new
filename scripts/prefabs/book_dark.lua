local assets =
{
    -- Asset("ANIM", "anim/books.zip"),
    -- Asset("ANIM", "anim/books2.zip"),
    Asset("ANIM", "anim/book_dark_onbank.zip"),
    Asset("ATLAS", "images/book_dark.xml"),
    Asset("IMAGE", "images/book_dark.tex"),
}

-- local prefabs = -- this should really be broken up per book...
-- {
--   "fx_book_darktale"
-- }
local NEW_BOOK_DARK_RADIUS = 16;
local BOOK_DARK_REPLY = 25;

local uses = 1;    --使用次数一
local BOOK_DARK_READ_SANITY = 0;    --33
local BOOK_DARK_PERUSE_SANITY = -TUNING.SANITY_LARGE;

local _players = {}


local function onupdate(inst, dt)
    inst.boost_time = inst.boost_time - dt
    if inst.boost_time <= 0 then
        if inst.boost_task ~= nil then
            inst.boost_task:Cancel()
            inst.boost_task = nil
        end
        inst.components.health:DeltaPenalty(-.25)
        inst.components.talker:Say("噢,也许我得再看一遍那本书了")
        inst.components.combat.damagemultiplier = inst.boost_default
    elseif math.fmod(inst.boost_time, 60) == 0 then
        inst.components.talker:Say("记忆在逐渐衰退")
        inst.boost_mult = inst.boost_mult - 0.25    --buff效果每分钟减少0.25
        inst.components.combat.damagemultiplier = inst.boost_mult
    end
end

local function startBuff(inst, duration)
    inst.boost_time = 239
    if inst.boost_task == nil then
        inst.components.talker:Say("知识的力量")
        inst.boost_task = inst:DoPeriodicTask(1, onupdate, nil, 1)
        inst.components.combat.damagemultiplier = inst.boost_mult
        onupdate(inst, 0)
    end
end




local onreadfn = function(inst, reader)

    local x, y, z = reader.Transform:GetWorldPosition()
    local players = FindPlayersInRange( x, y, z, NEW_BOOK_DARK_RADIUS, true )

    --清空reader的全部sanity
    reader.components.sanity:SetPercent(0)
    -- TheWorld.components.shadowcreaturespawner:new_SpawnShadowCreature(reader)
    --减少生命上限
    reader.components.health:DeltaPenalty(.25)

    --添加buff
    if reader:HasTag("ghostlyfriend") then
        reader.boost_default = .75
    else
        reader.boost_default = 1
    end
    if reader.boost_task ~= nil then
        reader.boost_task:Cancel()
        reader.components.combat.damagemultiplier = reader.boost_default
    end
    reader.boost_task = nil
    reader.boost_mult = 2
    startBuff(reader)

    -- for _, player in pairs(players) do
    --     if player ~= reader and (inst.components.health == nil or not inst.components.health:IsDead())  then

    --     end
    -- end
    return true;
end


local perusefn = function(inst,reader)
    if reader.peruse_exaid then
        reader.peruse_exaid(reader)
    end
    reader.components.talker:Say(GetString(reader, "ANNOUNCE_READ_BOOK","BOOK_DARK"))
    return true
end


local function fn()
    local inst = CreateEntity()

    inst.entity:AddTransform()
    inst.entity:AddAnimState()
    inst.entity:AddSoundEmitter()
    inst.entity:AddNetwork()

    MakeInventoryPhysics(inst)

    inst.AnimState:SetBank("book_dark_onbank")
    inst.AnimState:SetBuild("book_dark_onbank")
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
    inst.components.book:SetReadSanity(BOOK_DARK_READ_SANITY)
    inst.components.book:SetPeruseSanity(BOOK_DARK_PERUSE_SANITY)
    -- inst.components.book:SetFx(fx)

    inst:AddComponent("inventoryitem")
    inst.components.inventoryitem.imagename = "book_dark"
    inst.components.inventoryitem.atlasname = "images/book_dark.xml"

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

return Prefab("book_dark", fn, assets)
