meVendor_SellPrices = meVendor_SellPrices or {}
meVendor_CustomSellList = meVendor_CustomSellList or {}

local isVendorOpen = false

local function UpdateItemSellPrice(itemID)
    if isVendorOpen then
        local _, _, _, _, _, _, _, _, _, _, itemSellPrice = GetItemInfo(itemID)
        if itemSellPrice and itemSellPrice > 0 then
            meVendor_SellPrices[itemID] = itemSellPrice
        else
            meVendor_SellPrices[itemID] = 0
        end
    end
end

local function OnVendorShow()
    isVendorOpen = true
end

local function OnVendorHide()
    isVendorOpen = false
end

local function SellJunkAndSavePrices()
    for bag = 0, 4 do
        for slot = 1, C_Container.GetContainerNumSlots(bag) do
            local itemID = C_Container.GetContainerItemID(bag, slot)
            if itemID then
                local _, _, rarity, _, _, _, _, _, _, _, itemSellPrice = GetItemInfo(itemID)
                if rarity == 0 and itemSellPrice > 0 then
                    print("Selling: " .. GetItemInfo(itemID))  -- Debug print
                    C_Container.UseContainerItem(bag, slot)
                    UpdateItemSellPrice(itemID)
                end
                
            end
        end
    end
end


local function SellCustomItems()
    for bag = 0, 4 do
        for slot = 1, C_Container.GetContainerNumSlots(bag) do
            local itemID = C_Container.GetContainerItemID(bag, slot)
            if itemID and meVendor_CustomSellList[itemID] then
                C_Container.UseContainerItem(bag, slot)
                UpdateItemSellPrice(itemID)
            end
        end
    end
end


local function CreateSellJunkButton()
    local f = CreateFrame("Button", "SellJunkButton", MerchantFrame, "OptionsButtonTemplate")
    f:SetSize(25, 25)  -- Adjust the size of the button as needed
    f:SetPoint("TOPRIGHT", MerchantFrame, "TOPRIGHT", -40, -30)

    -- Setting the icon to a trashcan
    f:SetNormalTexture(237283) -- Single Copper Coins
    f:SetHighlightTexture("Interface\\Buttons\\ButtonHilight-Square", "ADD")
    f:SetPushedTexture(133789) -- A Stack of Copper Coins

    f:SetScript("OnClick", function()
        for bag = 0, 4 do
            for slot = 1, C_Container.GetContainerNumSlots(bag) do
                local itemID = C_Container.GetContainerItemID(bag, slot)
                if itemID then
                    local _, _, rarity, _, _, _, _, _, _, _, itemSellPrice = GetItemInfo(itemID)
                    if rarity == 0 and itemSellPrice > 0 then
                        C_Container.UseContainerItem(bag, slot)
                        UpdateItemSellPrice(itemID)
                    end
                end
            end
        end
    end)
end

local function CreateCustomSellButton()
    local f = CreateFrame("Button", "CustomSellButton", MerchantFrame, "OptionsButtonTemplate")
    f:SetSize(25, 25)  -- Adjust the size as needed
    f:SetPoint("TOPRIGHT", MerchantFrame, "TOPRIGHT", -70, -30)  -- Adjust position as needed

    -- Setting an icon for the custom sell button (change as needed)
    f:SetNormalTexture(237282) -- Single Silver Coin
    f:SetHighlightTexture("Interface\\Buttons\\ButtonHilight-Square", "ADD")
    f:SetPushedTexture(133786) -- A Few Silver Coins

    f:SetScript("OnClick", SellCustomItems)
end


local function OnTooltipSetItem(tooltip)
    local name, link = tooltip:GetItem()
    if name and tooltip == GameTooltip then  -- Check if it's the primary tooltip
        local itemID = link:match("item:(%d+)")
        itemID = tonumber(itemID)
        UpdateItemSellPrice(itemID)
        if meVendor_SellPrices[itemID] then
            if meVendor_SellPrices[itemID] == 0 then
                tooltip:AddLine("NOT FOR SALE")
            else
                tooltip:AddLine("Sell Price: " .. GetCoinTextureString(meVendor_SellPrices[itemID]))
            end
        end
    end
end

local frame = CreateFrame("Frame")
frame:RegisterEvent("ADDON_LOADED")
frame:RegisterEvent("MERCHANT_SHOW")
frame:RegisterEvent("MERCHANT_CLOSED")
frame:SetScript("OnEvent", function(self, event, addonName)
    if event == "ADDON_LOADED" and addonName == "meVendor" then
        CreateSellJunkButton()
        CreateCustomSellButton()
        GameTooltip:HookScript("OnTooltipSetItem", OnTooltipSetItem)
        self:UnregisterEvent("ADDON_LOADED")
    elseif event == "MERCHANT_SHOW" then
        OnVendorShow()
    elseif event == "MERCHANT_CLOSED" then
        OnVendorHide()
    end
end)