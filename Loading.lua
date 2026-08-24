local Preload = {}

do
    local HttpService = game:GetService("HttpService")

    local Folder = "EVENESCE"
    local FontFolder = Folder .. "/Fonts"
    local ImageFolder = Folder .. "/Images"
    local FontHost = "https://raw.githubusercontent.com/chillingcapi/Relay/main/"

    local Fonts = {
        { Name = "InterSemiBold", Url = FontHost .. "InterSemibold.ttf", Weight = 600 },
        { Name = "ArchivoExpandedBlack", Url = FontHost .. "fonts/ArchivoExpandedBlack.ttf", Weight = 400 },
    }

    local Images = {
        "https://files.catbox.moe/2z3lm3.png",
        "https://files.catbox.moe/emta95.png",
        "https://files.catbox.moe/6ndymn.png",
        "https://files.catbox.moe/kz1pu1.png",
        "https://files.catbox.moe/iraumn.png",
        "https://files.catbox.moe/0t0j8u.png",
        "https://files.catbox.moe/uoiw0g.png",
        "https://files.catbox.moe/zxya3e.png",
        "https://files.catbox.moe/mq7dbh.png",
        "https://raw.githubusercontent.com/chillingcapi/Images/refs/heads/main/wisp.png",
        "https://raw.githubusercontent.com/chillingcapi/Images/refs/heads/main/New_iron.png",
        "https://raw.githubusercontent.com/chillingcapi/Images/refs/heads/main/stats.png",
        "https://raw.githubusercontent.com/chillingcapi/Images/refs/heads/main/Saramaed.png",
        "https://raw.githubusercontent.com/chillingcapi/Images/refs/heads/main/L2.png",
        "https://raw.githubusercontent.com/chillingcapi/Images/main/MoonEyrie.png",
        "https://raw.githubusercontent.com/chillingcapi/Images/main/EggImage.png",
        "https://raw.githubusercontent.com/chillingcapi/Images/main/CollectCashImage.png",
        "https://raw.githubusercontent.com/chillingcapi/Images/main/DepositEggsImage.png",
        "https://raw.githubusercontent.com/chillingcapi/Images/main/MergeChickensImage.png",
        "https://raw.githubusercontent.com/chillingcapi/Images/main/UpgradeProgessImage.png",
    }

    local function EnsureFolder(Path)
        if not (isfolder and makefolder) then return false end
        return (pcall(function()
            if not isfolder(Path) then makefolder(Path) end
        end))
    end

    local function Mirrors(Url)
        local Sources = { Url }
        local Raw = Url:match("^https://raw%.githubusercontent%.com/(.+)$")
        if Raw then
            local Owner, Repo, Rest = Raw:match("^([^/]+)/([^/]+)/(.+)$")
            if Owner then
                Sources[#Sources + 1] = ("https://github.com/%s/%s/raw/%s"):format(Owner, Repo, Rest)
            end
        end
        return Sources
    end

    local function Grab(Url, Minimum)
        for _, Source in ipairs(Mirrors(Url)) do
            local Ok, Body = pcall(function() return game:HttpGet(Source, true) end)
            if Ok and type(Body) == "string" and #Body > Minimum and Body:sub(1, 1) ~= "<" then
                return Body
            end
        end
        return nil
    end

    local function FontReady(Path)
        local Ok, Body = pcall(readfile, Path)
        return Ok and type(Body) == "string" and #Body > 4096
    end

    local function LoadFont(Spec)
        local Ttf = FontFolder .. "/" .. Spec.Name .. ".ttf"
        local Descriptor = FontFolder .. "/" .. Spec.Name .. ".font"

        if not FontReady(Ttf) then
            local Body = Grab(Spec.Url, 4096)
            if not Body then return false end
            if not pcall(writefile, Ttf, Body) then return false end
        end

        local Made, Asset = pcall(getcustomasset, Ttf)
        if not Made or type(Asset) ~= "string" or Asset == "" then return false end

        return (pcall(writefile, Descriptor, HttpService:JSONEncode({
            name = Spec.Name,
            faces = { { name = Spec.Name, weight = Spec.Weight, style = "normal", assetId = Asset } },
        })))
    end

    local function ImageName(Url)
        local Clean = Url:gsub("[^%w]", "")
        local Tail = Clean:sub(math.max(1, #Clean - 24))
        local Hash = 0
        for Index = 1, #Url do
            Hash = (Hash * 31 + Url:byte(Index)) % 2147483647
        end
        return ("%s_%d.png"):format(Tail, Hash)
    end

    local function LoadImage(Url)
        local Path = ImageFolder .. "/" .. ImageName(Url)

        local Ok, Exists = pcall(isfile, Path)
        if Ok and Exists then return true end

        local Body = Grab(Url, 64)
        if not Body then return false end

        return (pcall(writefile, Path, Body))
    end

    function Preload.Run()
        if not (writefile and isfile and getcustomasset) then
            return { Fonts = 0, Images = 0 }
        end

        EnsureFolder(Folder)
        EnsureFolder(FontFolder)
        EnsureFolder(ImageFolder)

        local Done = { Fonts = 0, Images = 0 }

        for _, Spec in ipairs(Fonts) do
            if LoadFont(Spec) then Done.Fonts += 1 end
        end

        for _, Url in ipairs(Images) do
            if LoadImage(Url) then Done.Images += 1 end
        end

        return Done
    end
end

return Preload.Run()
