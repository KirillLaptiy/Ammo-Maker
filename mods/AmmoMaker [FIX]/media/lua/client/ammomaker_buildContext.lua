--Ammo Maker by STIMP_TM

local function ammoMakerBuildContext(player, context, worldobjects)

    local toolsSaw = {
        [1] = "Base.Saw",
        [2] = "Base.GardenSaw",
    };

    --set player variables

    local playerObject = getSpecificPlayer(player);
    local playerInventory = playerObject:getInventory();

    --get player inventory item count

    local function getPlayerInventoryItemCount(itemTypes)

        local itemCount = 0;

        for _, itemType in ipairs(itemTypes) do

            itemCount = itemCount + playerInventory:getItemCountFromTypeRecurse(itemType);

        end

        return itemCount;
    
    end

    --set player inventory item count variables

    local playerPlanks = playerInventory:getItemCountFromTypeRecurse("Base.Plank");
    local playerNails = playerInventory:getItemCountFromTypeRecurse("Base.Nails") + playerInventory:getItemCountFromTypeRecurse("Base.NailsBox") * 100;
    local playerSaw = getPlayerInventoryItemCount(toolsSaw);
    local playerWoodwork = playerObject:getPerkLevel(Perks.Woodwork);

    --set bird feeder variables

    local birdFeederSprite = {};
    birdFeederSprite.east = "ammomaker_tilesheet_0_0";
    birdFeederSprite.north = "ammomaker_tilesheet_0_1";

    local birdFeederName = getText("Tooltip_Bird_Feeder_Name");
    local birdFeederDescription = getText("Tooltip_Bird_Feeder_Description") .. " <LINE> <LINE> ";

    --build bird feeder

    local function onBuildBirdFeeder(worldobjects, sprite, player, name)

        local birdFeeder = ammomaker_ISBirdFeeder:new(sprite.east, sprite.north);

        birdFeeder.player = player;
        birdFeeder.name = name;
        birdFeeder.notExterior = true;
        birdFeeder.containerType = "ammomaker_BirdFeeder";
        birdFeeder.modData["need:Base.Plank"] = 5;
        birdFeeder.modData["need:Base.Nails"] = 10;
        birdFeeder.modData["xp:Woodwork"] = 6;
        birdFeeder.completionSound = "BuildWoodenStructureMedium";

        getCell():setDrag(birdFeeder, player);

    end

    --check bird feeder materials

    local function getBirdFeederDescription()

        local result = true

        if playerPlanks >= 5 then
            birdFeederDescription = birdFeederDescription .. " <RGB:1,1,1> <INDENT:0> " .. getText("Tooltip_craft_Needs") .. ":" .. " <LINE> <RGB:0,1,0> " .. getItemNameFromFullType("Base.Plank") .. " " .. playerPlanks .. "/5 <LINE> ";
        else
            birdFeederDescription = birdFeederDescription .. " <RGB:1,1,1> <INDENT:0> " .. getText("Tooltip_craft_Needs") .. ":" .. " <LINE> <RGB:1,0,0> " .. getItemNameFromFullType("Base.Plank") .. " " .. playerPlanks .. "/5 <LINE> ";
            result = false
        end

        if playerNails >= 10 then
            birdFeederDescription = birdFeederDescription .. " <RGB:0,1,0> <INDENT:0> " .. getItemNameFromFullType("Base.Nails") .. " " .. playerNails .. "/10 <LINE> ";
        else
            birdFeederDescription = birdFeederDescription .. " <RGB:1,0,0> <INDENT:0> " .. getItemNameFromFullType("Base.Nails") .. " " .. playerNails .. "/10 <LINE> ";
            result = false
        end

        if playerSaw >= 1 then
            birdFeederDescription = birdFeederDescription .. " <RGB:0,1,0> <INDENT:0> " .. getItemNameFromFullType("Base.Saw") .. " <LINE> ";
        else
            birdFeederDescription = birdFeederDescription .. " <RGB:1,0,0> <INDENT:0> " .. getItemNameFromFullType("Base.Saw") .. " <LINE> ";
            result = false
        end

        if playerWoodwork >= 6 then
            birdFeederDescription = birdFeederDescription .. " <RGB:1,1,1> <INDENT:0> <RGB:0,1,0> " .. getText("IGUI_perks_Carpentry") .. " " .. playerWoodwork .. "/6 <LINE> ";
        else
            birdFeederDescription = birdFeederDescription .. " <RGB:1,1,1> <INDENT:0> <RGB:1,0,0> " .. getText("IGUI_perks_Carpentry") .. " " .. playerWoodwork .. "/6 <LINE> ";
            result = false
        end

        if not (result or ISBuildMenu.cheat) then
            birdFeederOption.onSelect = nil
            birdFeederOption.notAvailable = true
        end

        return birdFeederDescription;
    
    end

    --construct menu


    local buildMenu = context:getOptionFromName(getText("ContextMenu_Build"))

    if buildMenu then

        local miscMenu = context:getSubMenu(buildMenu.subOption):getOptionFromName(getText("ContextMenu_Misc"))


        if miscMenu then

            local miscSubMenu = context:getSubMenu(miscMenu.subOption)


            birdFeederOption = miscSubMenu:addOption(birdFeederName, worldobjects, onBuildBirdFeeder, birdFeederSprite, player, birdFeederName)

            local birdFeederPreview = ISToolTip:new()
            birdFeederPreview:initialise()
            birdFeederPreview:setVisible(false)
            birdFeederPreview:setName(birdFeederName)
            birdFeederPreview.description = getBirdFeederDescription()
            birdFeederPreview.footNote = getText("Tooltip_craft_pressToRotate", Keyboard.getKeyName(getCore():getKey("Rotate building")))
            birdFeederPreview:setTexture(birdFeederSprite.east)
            birdFeederOption.toolTip = birdFeederPreview
        end
    end

end

Events.OnFillWorldObjectContextMenu.Add(ammoMakerBuildContext);