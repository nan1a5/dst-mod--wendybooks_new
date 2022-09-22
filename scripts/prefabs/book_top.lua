local assets =
{
    -- Asset("ANIM", "anim/book_top_onbank.zip"),
    Asset("ANIM", "anim/memtoast_onbank.zip"),
    Asset("ATLAS", "images/book_top.xml"),
    Asset("IMAGE", "images/book_top.tex"),
}

local NEW_BOOK_DAIRY_RADIUS = 12;
local BOOK_DAIRY_REPLY = 25;

local uses = TUNING.BOOK_USES_LARGE;    --使用次数五
local BOOK_DARKTALE_READ_SANITY = -TUNING.SANITY_SMALL;    --33
local BOOK_DARKTALE_PERUSE_SANITY = -TUNING.SANITY_SMALL;



-- 奖品列表
local prefab_list = {
    {"spider_warrior", "spider"},       --0.12
    {"yellowgem", "greengem"},      --0.17
    {"gears", "bluegem"},       --0.14
    {"twigs", "cutgrass", "flint"},     --0.45
    {"armorruins", "ruinshat", "ruins_bat"}     --0.12
}
--概率表
local chance = {0.12, 0.17, 0.14, 0.45, 0.12}
local prob = {}
local alias = {}



--生成随机数算法
--来源: https://blog.csdn.net/dan452819043/article/details/114613403
local function init(data)
    local num = #data
    local small = {}
    local large = {}
    for k, v in pairs(data) do
        v = v * num

        if v < 1 then
            table.insert(small, k)
        else
            table.insert(large, k)
        end
    end

    while #small > 0 and #large > 0 do
        local n_index = small[1]
        local a_index = large[1]
        table.remove(small, 1)
        table.remove(large, 1)

        prob[n_index] = data[n_index]
        alias[n_index] = a_index
        data[a_index] = (data[a_index] + data[n_index])

        if data[a_index] < 1 then
            table.insert(small, a_index)
        else
            table.insert(large, a_index)
        end
    end

    while #large > 0 do
        local n_index = large[1]
        table.remove(large, 1)
        prob[n_index] = 1
    end

    while #small > 0 do
        local n_index = small[1]
        table.remove(small, 1)
        prob[n_index] = 1
    end

    return prob, alias;
end

local function random(_prob, _alias)
    local nums= #_prob

    local coin_toss = math.random()

    local col = math.floor(math.random() * nums) + 1
    if coin_toss < _prob[col] then
        return col
    else
        return _alias[col]
    end
end


--发送奖励
local function SendReward(player, list)
    local pt = player:GetPosition()
    local ents = TheSim:FindEntities(pt.x, pt.y, pt.z, 10, {"magicalbird"})
    local reward_ents = TheSim:FindEntities(pt.x, pt.y, pt.z, 10, {"renewable",  "gem", "molebait", "ruins"})
    local num = #list
    


    if #reward_ents > 30 then
        return false, "TOOMANYTREASURE"
    end
    if #ents > 20 then
        return false, "TOOMANYBIRDS"
    else
        player:StartThread(function()
            for k = 1, num do
                local pos = TheWorld.components.birdspawner:GetSpawnPoint(pt)
                if pos ~= nil then
                    local bird = TheWorld.components.birdspawner:SpawnBird(pos, true)
                    if bird ~= nil then
                       bird:AddTag("magicalbird")
                    end
                    Sleep(.9)
                    SpawnPrefab(list[k]).Transform:SetPosition(pos.x, 0, pos.z)
                end
                Sleep(math.random(.2, .25))
            end
        end)

        return true
    end
end



local onreadfn = function(inst, reader)
    --没有鸟就没有奖励
    if TheWorld.components.birdspawner == nil then
        return false, "BIRDCANNOTREACH"
    end

    prob = {}
    alias = {}

    init(chance)
    local result = random(prob, alias)

    reader.components.talker:Say(prefab_list[result][1])
    return SendReward(reader, prefab_list[result])
end
local perusefn = function(inst,reader)
    if reader.peruse_temperature then
        reader.peruse_temperature(reader)
    end
    reader.components.talker:Say(GetString(reader, "ANNOUNCE_READ_BOOK","BOOK_TOP"))
    return true
end


local function fn()
    local inst = CreateEntity()

    inst.entity:AddTransform()
    inst.entity:AddAnimState()
    inst.entity:AddSoundEmitter()
    inst.entity:AddNetwork()

    MakeInventoryPhysics(inst)

    inst.AnimState:SetBank("memtoast_onbank")
    inst.AnimState:SetBuild("memtoast_onbank")
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
    inst.components.inventoryitem.imagename = "book_top"
    inst.components.inventoryitem.atlasname = "images/book_top.xml"

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

return Prefab("book_top", fn, assets)
