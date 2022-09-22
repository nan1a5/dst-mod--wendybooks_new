local assets =
{
    -- Asset("ANIM", "anim/books.zip"),
    -- Asset("ANIM", "anim/books2.zip"),
    -- Asset("ANIM", "anim/fx_book_temperature.zip"),
    Asset("ANIM", "anim/book_season_onbank.zip"),
    Asset("ATLAS", "images/book_season.xml"),
    Asset("IMAGE", "images/book_season.tex"),
}

-- local prefabs = -- this should really be broken up per book...
-- {
--   "fx_book_darktale"
-- }
local NEW_BOOK_DAIRY_RADIUS = 12;
local BOOK_DAIRY_REPLY = 25;

local uses = 4;    --使用次数四
local BOOK_DARKTALE_READ_SANITY = -TUNING.SANITY_LARGE;    --33
local BOOK_DARKTALE_PERUSE_SANITY = TUNING.SANITY_LARGE;


local function GetNextSeason(season)
    local i
    local seasons = {
        "autumn",
        "winter",
        "spring",
        "summer",
    }
    for key, value in pairs(seasons) do
        if value == season then
          i = key
        end
    end
    i = math.fmod((i + 1), 4)
    return seasons[i]
end

local onreadfn = function(inst, reader)
    if not TheWorld.ismastersim then
        return false
    end
    --获取当前季节
    local season = TheWorld.state.season
    --获取下一个季节
    local next_season = GetNextSeason(season)
    reader.components.talker:Say(next_season)
    TheWorld:PushEvent("ms_setseason", next_season)

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

    inst.AnimState:SetBank("book_season_onbank")
    inst.AnimState:SetBuild("book_season_onbank")
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
    inst.components.inventoryitem.imagename = "book_season"
    inst.components.inventoryitem.atlasname = "images/book_season.xml"

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

return Prefab("book_season", fn, assets)
