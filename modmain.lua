require("recipe")
require "languages/chs"
PrefabFiles = {"book_dairy","book_exaid","book_dark","book_season","book_top","memtoast"}

local g = GLOBAL;
local bookLabel_prefab_name = "bananapop"   --“书签”的prefab名

--获取配置项信息
local if_book_dairy = GetModConfigData("book_dairy")
local if_book_exaid = GetModConfigData("book_exaid")
local if_book_dark = GetModConfigData("book_dark")
local if_book_top = GetModConfigData("book_top")
local if_book_season = GetModConfigData("book_season")
local if_cookpot_memtoast = GetModConfigData("cookpot_memtoast")
local wendy_is_reader = GetModConfigData("wendy_is_reader")
local if_label = GetModConfigData("label")




--带有书签时，读书不消耗耐久
AddComponentPostInit("book", function (BOOK)
    function BOOK:Interact(fn, reader)
        local success = true
        local reason

        --检测reader物品栏是否有书签
        local hasBookLabel = reader.components.inventory:FindItem(function(item) return item.prefab == "bananapop" end)

        if fn then
            success, reason = fn(self.inst, reader)
            if success and not hasBookLabel
            then
                self:ConsumeUse()
            end
        end

        return success, reason
    end

    function BOOK:OnRead(reader)

        local hasBookLabel = reader.components.inventory:FindItem(function(item) return item.prefab == "bananapop" end)

        -- if hasBookLabel
        -- then
        --     self.read_sanity = 0
        -- end
        
        -- local success, reason = oldOnRead(self, reader)

        -- --物品栏有书签并且成功读书后去除一个书签
        -- if hasBookLabel and success then
        --     reader.components.inventory:ConsumeByName(bookLabel_prefab_name, 1)
        -- end

        -- return success, reason
        local success, reason = self:Interact(self.onread, reader)
        if success and reader.components.sanity then
            if self.fx then
                local fx = g.SpawnPrefab(self.fx)
                fx.Transform:SetPosition(reader.Transform:GetWorldPosition())
            end

            --物品栏有书签并且成功读书后去除一个书签
            if hasBookLabel and success then
                reader.components.inventory:ConsumeByName(bookLabel_prefab_name, 1)
            end

            reader.components.sanity:DoDelta(self.read_sanity or 0)
        end

        return success, reason
    end

end)


AddIngredientValues({"ash"}, { -- 灰
    inedible = 1
})
local memtoast = {
    test = function(cooker, names, tags)
        return tags.egg and names.egg and names.ash and not tags.meat
    end,
    name = "memtoast",
    weight = 1, 
    priority = 1, 
    foodtype = GLOBAL.FOODTYPE.MEAT,
    health = 8,
    hunger = 88,
    sanity = -8,
    perishtime = TUNING.PERISH_SUPERSLOW, --腐烂时间
    cooktime = 0.7, --烹饪时间
    potlevel = "high",
    cookbook_tex = "book_dairy.tex", -- 在游戏内食谱书里的mod食物那一栏里显示的图标，tex在 atlas的xml里定义了，所以这里只写文件名即可
    cookbook_atlas = "images/book_dairy.xml",
    floater = {"med", nil, 0.55},
    cookbook_category = "cookpot"
}

AddCookerRecipe("cookpot", memtoast)
AddCookerRecipe("portablecookpot", memtoast)



if if_book_dairy then
    AddRecipe2("book_dairy",{Ingredient("ghostflower", 1), Ingredient("nightmarefuel", 2)},g.TECH.NONE,{builder_tag="ghostlyfriend"},{"CHARACTER"},{atlas="images/book_dairy.xml",image="book_dairy.tex"})    --日记
end
if if_book_exaid then
    AddRecipe2("book_exaid",{Ingredient("ghostflower", 1), Ingredient("nightmarefuel", 2)},g.TECH.NONE,{builder_tag="ghostlyfriend"},{"CHARACTER"})    --急救
end
if if_book_dark then
    AddRecipe2("book_dark",{Ingredient("ghostflower", 1), Ingredient("nightmarefuel", 2)},g.TECH.NONE,{builder_tag="ghostlyfriend"},{"CHARACTER"})
end
if if_book_top then
    AddRecipe2("book_top",{Ingredient("ghostflower", 1), Ingredient("nightmarefuel", 2)},g.TECH.NONE,{builder_tag="ghostlyfriend"},{"CHARACTER"})
end
--季节书，默认不添加，只有四季为默认(春,夏,秋,冬)才敢保证生效
if if_book_season then
    AddRecipe2("book_season",{Ingredient("ghostflower", 1), Ingredient("nightmarefuel", 2)},g.TECH.NONE,{builder_tag="ghostlyfriend"},{"CHARACTER"})
end
