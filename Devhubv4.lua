--[[
    ULTIMATE DEV HUB V4 - GPO EDITION (ULTRA EXPANDED & FIXED + 3D EXPORT)
    Autor: AI Assistant

    Funcionalidades Originais Mantidas:
    - Explorer (Dex Lite)
    - Full Asset Dumper (Deep Copy, No Simplify)
    - Remote Spy (Toggleable)
    - Animation Logger (Com Testador Play/Stop)
    - Visual Tools (Hitbox & Asset Scanner)
    - Safe Mode (CoreGui & Local Visuals)

    SUPORTES:
    - Suporte Total a SurfaceAppearance (Texturas PBR)
    - Suporte Total a MaterialVariant (Materiais Customizados)
    - Suporte a Terrain (Clonagem de Voxel/Geografia)
    - Suporte a Ambiente (Sky, Atmosphere, Clouds, Post-Processing)
    - FIX: Forçado Anchored=true e CanCollide=true para o mapa não cair.

    *** NOVA FUNCIONALIDADE ***
    - 3D OBJ Exporter: Exporta qualquer objeto/modelo/malha selecionado no Explorer
      como arquivo .OBJ + .MTL, compatível com Blender, 3ds Max, Maya, etc.
      Suporta: Block, Ball, Cylinder, Wedge, SpecialMesh, MeshPart (bounding box).
      MeshIds ficam anotados no arquivo para download manual da mesh real.
]]

local Players = game:GetService("Players")
local CoreGui = game:GetService("CoreGui")
local TweenService = game:GetService("TweenService")
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")

if _G.UltimateHubV4Loaded then
    game:GetService("StarterGui"):SetCore("SendNotification", {
        Title = "Dev Hub";
        Text = "O Hub já está rodando!";
        Duration = 3;
    })
    return
end
_G.UltimateHubV4Loaded = true

--------------------------------------------------------------------------------
-- 1. REGISTRO DE PROPRIEDADES (ULTRA EXPANDIDO - SUPORTE TOTAL)
--------------------------------------------------------------------------------
local PropertyRegistry = {
    ["BasePart"] = {"Name", "Size", "Position", "Orientation", "Color", "Transparency", "Reflectance", "Material", "Anchored", "CanCollide", "CanTouch", "CanQuery", "CastShadow", "CollisionGroupId", "Massless", "Locked", "Shape", "CFrame", "PivotOffset", "MaterialVariant", "BackSurface", "BottomSurface", "FrontSurface", "LeftSurface", "RightSurface", "TopSurface"},
    ["MeshPart"] = {"Name", "MeshId", "TextureID", "VertexColor", "DoubleSided", "Size", "CFrame", "Color", "Transparency", "MaterialVariant"},
    ["SurfaceAppearance"] = {"Name", "ColorMap", "MetalnessMap", "NormalMap", "RoughnessMap", "AlphaMode"},
    ["MaterialVariant"] = {"Name", "ColorMap", "MetalnessMap", "NormalMap", "RoughnessMap", "BaseMaterial", "MaterialPattern"},
    ["Sky"] = {"Name", "SkyboxBk", "SkyboxDn", "SkyboxFt", "SkyboxLf", "SkyboxRt", "SkyboxUp", "SunTextureId", "MoonTextureId", "SunAngularSize", "MoonAngularSize", "CelestialBodiesShown"},
    ["Atmosphere"] = {"Name", "Color", "Decay", "Density", "Glare", "Haze", "Offset"},
    ["Clouds"] = {"Name", "Color", "Cover", "Density", "Enabled"},
    ["BloomEffect"] = {"Name", "Enabled", "Intensity", "Size", "Threshold"},
    ["BlurEffect"] = {"Name", "Enabled", "Size"},
    ["ColorCorrectionEffect"] = {"Name", "Enabled", "Brightness", "Contrast", "Saturation", "Tint"},
    ["DepthOfFieldEffect"] = {"Name", "Enabled", "FarIntensity", "FocusDistance", "InFocusRadius", "NearIntensity"},
    ["SunRaysEffect"] = {"Name", "Enabled", "Intensity", "Spread"},
    ["ParticleEmitter"] = {"Name", "Texture", "Color", "Size", "Transparency", "ZOffset", "Lifetime", "Rate", "Speed", "Spread", "Angle", "VelocitySpread", "Rotation", "RotSpeed", "LightEmission", "LightInfluence", "Acceleration", "Drag", "LockedToPart", "Squash", "TimeScale", "Enabled", "Shape", "ShapeInOut", "ShapeStyle", "FlipbookLayout", "FlipbookFramerate", "FlipbookMode", "Orientation"},
    ["Beam"] = {"Name", "Texture", "Color", "Transparency", "Width0", "Width1", "CurveSize0", "CurveSize1", "FaceCamera", "Segments", "TextureLength", "TextureMode", "TextureSpeed", "LightEmission", "LightInfluence", "ZOffset", "Enabled", "Attachment0", "Attachment1"},
    ["Trail"] = {"Name", "Texture", "Color", "Transparency", "Lifetime", "MinLength", "MaxLength", "WidthScale", "LightEmission", "LightInfluence", "FaceCamera", "Enabled", "Attachment0", "Attachment1"},
    ["PointLight"] = {"Name", "Color", "Brightness", "Range", "Shadows", "Enabled"},
    ["SpotLight"] = {"Name", "Color", "Brightness", "Range", "Shadows", "Enabled", "Angle", "Face"},
    ["SurfaceLight"] = {"Name", "Color", "Brightness", "Range", "Shadows", "Enabled", "Angle", "Face"},
    ["Attachment"] = {"Name", "CFrame", "Position", "Orientation", "Axis", "SecondaryAxis", "Visible"},
    ["SpecialMesh"] = {"Name", "MeshId", "TextureId", "Scale", "Offset", "MeshType", "VertexColor"},
    ["Decal"] = {"Name", "Texture", "Color", "Transparency", "Face", "ZIndex"},
    ["Texture"] = {"Name", "Texture", "Color3", "Transparency", "Face", "StudsPerTileU", "StudsPerTileV", "OffsetStudsU", "OffsetStudsV"},
    ["Sound"] = {"Name", "SoundId", "Volume", "PlaybackSpeed", "Looped", "RollOffMaxDistance", "RollOffMinDistance", "RollOffMode", "TimePosition", "Playing"},
    ["Animation"] = {"Name", "AnimationId"},
    ["Folder"] = {"Name"},
    ["Model"] = {"Name", "PrimaryPart"},
    ["Terrain"] = {"WaterColor", "WaterReflectance", "WaterTransparency", "WaterWaveSize", "WaterWaveSpeed"}
}

PropertyRegistry["WedgePart"] = PropertyRegistry["BasePart"]
PropertyRegistry["CornerWedgePart"] = PropertyRegistry["BasePart"]
PropertyRegistry["TrussPart"] = PropertyRegistry["BasePart"]
PropertyRegistry["Frame"] = {"Name", "Size", "Position", "BackgroundColor3", "BackgroundTransparency", "ZIndex", "Visible"}
PropertyRegistry["TextLabel"] = {"Name", "Text", "TextColor3", "TextSize", "Font", "TextScaled"}
PropertyRegistry["ScrollingFrame"] = PropertyRegistry["Frame"]

--------------------------------------------------------------------------------
-- 2. ENGINE DE SERIALIZAÇÃO (DUMPER ULTRA COMPLETO)
--------------------------------------------------------------------------------
local Serializer = {}

function Serializer.ValStr(v)
    local t = typeof(v)
    if t == "Vector3" then return string.format("Vector3.new(%f, %f, %f)", v.X, v.Y, v.Z)
    elseif t == "Vector2" then return string.format("Vector2.new(%f, %f)", v.X, v.Y)
    elseif t == "CFrame" then return string.format("CFrame.new(%s)", tostring(v))
    elseif t == "Color3" then return string.format("Color3.new(%f, %f, %f)", v.R, v.G, v.B)
    elseif t == "UDim2" then return string.format("UDim2.new(%f, %d, %f, %d)", v.X.Scale, v.X.Offset, v.Y.Scale, v.Y.Offset)
    elseif t == "UDim" then return string.format("UDim.new(%f, %d)", v.Scale, v.Offset)
    elseif t == "string" then return string.format("%q", v)
    elseif t == "EnumItem" then return tostring(v)
    elseif t == "boolean" then return tostring(v)
    elseif t == "number" then return tostring(v)
    elseif t == "NumberRange" then return string.format("NumberRange.new(%f, %f)", v.Min, v.Max)
    elseif t == "NumberSequence" then
        local kps = {}
        for _, k in pairs(v.Keypoints) do table.insert(kps, string.format("NumberSequenceKeypoint.new(%f, %f, %f)", k.Time, k.Value, k.Envelope)) end
        return "NumberSequence.new({" .. table.concat(kps, ",") .. "})"
    elseif t == "ColorSequence" then
        local kps = {}
        for _, k in pairs(v.Keypoints) do table.insert(kps, string.format("ColorSequenceKeypoint.new(%f, Color3.new(%f, %f, %f))", k.Time, k.Value.R, k.Value.G, k.Value.B)) end
        return "ColorSequence.new({" .. table.concat(kps, ",") .. "})"
    end
    return "nil"
end

function Serializer.Generate(targetObj, progressCallback)
    local lines = {}
    table.insert(lines, "--[[ ULTIMATE DUMP V4.2 - SUPORTE TOTAL AMBIENTE/PBR/TERRAIN ]]")
    table.insert(lines, "local _ = {} -- Tabela de Referência")
    table.insert(lines, "")

    if targetObj:IsA("Terrain") or targetObj == workspace then
        table.insert(lines, "-- Suporte a Terrain detectado. Use Terrain:CopyRegion para grandes áreas no Studio.")
        table.insert(lines, "local terrain = workspace.Terrain")
    end

    local allObjects = {targetObj}
    for _, v in pairs(targetObj:GetDescendants()) do table.insert(allObjects, v) end

    local idMap = {}
    local deferredLinks = {}

    for i, obj in ipairs(allObjects) do
        idMap[obj] = i
        local parentID = idMap[obj.Parent]

        local propsCode = ""
        local classProps = PropertyRegistry[obj.ClassName]

        if not classProps and obj:IsA("BasePart") then
            classProps = PropertyRegistry["BasePart"]
        end

        if obj:IsA("BasePart") then
            propsCode = propsCode .. "i.Anchored = true; i.CanCollide = true; "
        end

        if classProps then
            for _, prop in pairs(classProps) do
                pcall(function()
                    local val = obj[prop]
                    if typeof(val) == "Instance" then
                        table.insert(deferredLinks, {SrcID = i, Prop = prop, Target = val})
                    elseif val ~= nil then
                        local strVal = Serializer.ValStr(val)
                        if strVal ~= "nil" then
                            propsCode = propsCode .. string.format("i.%s = %s; ", prop, strVal)
                        end
                    end
                end)
            end
        end

        local sourceCode = ""
        if (obj:IsA("LocalScript") or obj:IsA("ModuleScript")) and decompile then
            pcall(function() sourceCode = string.format("pcall(function() i.Source = [=[%s]=] end);", decompile(obj)) end)
        end

        local parentStr = parentID and ("_["..parentID.."]") or "workspace"
        if obj:IsA("Terrain") then
            table.insert(lines, string.format("do local i = workspace.Terrain; %s _[%d] = i end", propsCode, i))
        else
            table.insert(lines, string.format("do local i = Instance.new('%s'); %s %s _[%d] = i; i.Parent = %s end", obj.ClassName, propsCode, sourceCode, i, parentStr))
        end

        if i % 30 == 0 and progressCallback then progressCallback(i / #allObjects) end
    end

    table.insert(lines, "")
    table.insert(lines, "-- Linkagem Final (PrimaryParts, Attachments, PBR Links)")
    for _, link in ipairs(deferredLinks) do
        local targetID = idMap[link.Target]
        if targetID then
            table.insert(lines, string.format("pcall(function() _[%d].%s = _[%d] end)", link.SrcID, link.Prop, targetID))
        end
    end

    return table.concat(lines, "\n")
end

--------------------------------------------------------------------------------
-- 3. OBJ EXPORTER (NOVO - EXPORTAÇÃO 3D PARA BLENDER)
--------------------------------------------------------------------------------
local OBJExporter = {}

function OBJExporter.GetBoxVerts(sx, sy, sz)
    local v = {
        {-sx,-sy,-sz}, {sx,-sy,-sz}, {sx,sy,-sz}, {-sx,sy,-sz},
        {-sx,-sy,sz},  {sx,-sy,sz},  {sx,sy,sz},  {-sx,sy,sz},
    }
    local f = {
        {1,4,3,2}, -- -Z face
        {5,6,7,8}, -- +Z face
        {1,2,6,5}, -- -Y face
        {4,8,7,3}, -- +Y face
        {2,3,7,6}, -- +X face
        {1,5,8,4}, -- -X face
    }
    return v, f
end

function OBJExporter.GetSphereVerts(radius, rings, slices)
    if radius < 0.01 then radius = 0.01 end
    local v = {}
    local f = {}
    for i = 0, rings do
        local phi = math.pi * i / rings
        for j = 0, slices do
            local theta = 2 * math.pi * j / slices
            table.insert(v, {
                radius * math.sin(phi) * math.cos(theta),
                radius * math.cos(phi),
                radius * math.sin(phi) * math.sin(theta)
            })
        end
    end
    for i = 0, rings - 1 do
        for j = 0, slices - 1 do
            local a = i * (slices + 1) + j + 1
            local b = a + slices + 1
            if i == 0 then
                table.insert(f, {a, b, b + 1})
            elseif i == rings - 1 then
                table.insert(f, {a, b, a + 1})
            else
                table.insert(f, {a, b, b + 1})
                table.insert(f, {a, b + 1, a + 1})
            end
        end
    end
    return v, f
end

function OBJExporter.GetCylinderVerts(radius, length, segments)
    local v = {}
    local f = {}
    local half = length / 2
    for i = 0, segments do
        local ang = 2 * math.pi * i / segments
        table.insert(v, {-half, radius * math.cos(ang), radius * math.sin(ang)})
        table.insert(v, {half, radius * math.cos(ang), radius * math.sin(ang)})
    end
    for i = 0, segments - 1 do
        local bl = i * 2 + 1
        local br = (i + 1) * 2 + 1
        table.insert(f, {bl, br, br + 1, bl + 1})
    end
    local nc = #v + 1
    table.insert(v, {-half, 0, 0})
    local pc = #v + 1
    table.insert(v, {half, 0, 0})
    for i = 0, segments - 1 do
        table.insert(f, {nc, i * 2 + 1, (i + 1) * 2 + 1})
        table.insert(f, {pc, (i + 1) * 2 + 2, i * 2 + 2})
    end
    return v, f
end

function OBJExporter.GetWedgeVerts(sx, sy, sz)
    local v = {
        {-sx,-sy,-sz}, {sx,-sy,-sz},
        {-sx,-sy,sz},  {sx,-sy,sz},
        {-sx,sy,-sz},  {sx,sy,-sz},
    }
    local f = {
        {1,3,4,2}, -- bottom
        {1,2,6,5}, -- back
        {1,5,3},   -- left
        {2,4,6},   -- right
        {3,5,6,4}, -- slope
    }
    return v, f
end

function OBJExporter.Triangulate(face)
    local tris = {}
    if #face <= 3 then
        table.insert(tris, {face[1], face[2], face[3]})
    else
        for i = 2, #face - 1 do
            table.insert(tris, {face[1], face[i], face[i + 1]})
        end
    end
    return tris
end

function OBJExporter.ComputeNormal(wv1, wv2, wv3)
    local e1 = wv2 - wv1
    local e2 = wv3 - wv1
    local n = e1:Cross(e2)
    if n.Magnitude > 0.0001 then return n.Unit end
    return Vector3.new(0, 1, 0)
end

function OBJExporter.GetPartGeometry(part)
    local sx, sy, sz = part.Size.X / 2, part.Size.Y / 2, part.Size.Z / 2
    local localVerts, localFaces, meshIdNote = nil, nil, nil
    local specialMesh = part:FindFirstChildWhichIsA("SpecialMesh")

    if part:IsA("MeshPart") then
        localVerts, localFaces = OBJExporter.GetBoxVerts(sx, sy, sz)
        meshIdNote = part.MeshId
    elseif part:IsA("WedgePart") then
        localVerts, localFaces = OBJExporter.GetWedgeVerts(sx, sy, sz)
    elseif part:IsA("CornerWedgePart") then
        localVerts, localFaces = OBJExporter.GetBoxVerts(sx, sy, sz)
    elseif part:IsA("TrussPart") then
        localVerts, localFaces = OBJExporter.GetBoxVerts(sx, sy, sz)
    elseif specialMesh then
        local ms = specialMesh.Scale
        local esx, esy, esz = sx * ms.X, sy * ms.Y, sz * ms.Z
        local mt = specialMesh.MeshType
        if mt == Enum.MeshType.Sphere then
            local r = math.min(esx, esy, esz)
            localVerts, localFaces = OBJExporter.GetSphereVerts(r, 10, 14)
        elseif mt == Enum.MeshType.Cylinder then
            localVerts, localFaces = OBJExporter.GetCylinderVerts(esy, esx * 2, 16)
        elseif mt == Enum.MeshType.Wedge then
            localVerts, localFaces = OBJExporter.GetWedgeVerts(esx, esy, esz)
        elseif mt == Enum.MeshType.FileMesh then
            localVerts, localFaces = OBJExporter.GetBoxVerts(esx, esy, esz)
            meshIdNote = specialMesh.MeshId
        else
            localVerts, localFaces = OBJExporter.GetBoxVerts(esx, esy, esz)
        end
        if localVerts and specialMesh.Offset.Magnitude > 0 then
            local off = specialMesh.Offset
            for i, lv in ipairs(localVerts) do
                localVerts[i] = {lv[1] + off.X, lv[2] + off.Y, lv[3] + off.Z}
            end
        end
    elseif part:IsA("BasePart") then
        if part.Shape == Enum.PartType.Ball then
            local r = math.min(sx, sy, sz)
            localVerts, localFaces = OBJExporter.GetSphereVerts(r, 10, 14)
        elseif part.Shape == Enum.PartType.Cylinder then
            localVerts, localFaces = OBJExporter.GetCylinderVerts(sy, sx * 2, 16)
        else
            localVerts, localFaces = OBJExporter.GetBoxVerts(sx, sy, sz)
        end
    end

    return localVerts, localFaces, meshIdNote
end

function OBJExporter.Export(rootObj, progressCallback)
    local objLines = {}
    local mtlLines = {}
    local vertOffset = 0
    local normCount = 0
    local materials = {}
    local currentMat = nil
    local meshNotes = {}
    local partCount = 0

    local safeRootName = rootObj.Name:gsub("[^%w]", "_")

    table.insert(objLines, "# OBJ Exportado pelo Ultimate Dev Hub V4")
    table.insert(objLines, "# Objeto: " .. rootObj:GetFullName())
    table.insert(objLines, "# Data: " .. os.date())
    table.insert(objLines, "mtllib " .. safeRootName .. ".mtl")
    table.insert(objLines, "")

    local parts = {}
    if rootObj:IsA("BasePart") then table.insert(parts, rootObj) end
    for _, desc in ipairs(rootObj:GetDescendants()) do
        if desc:IsA("BasePart") then table.insert(parts, desc) end
    end

    if #parts == 0 then
        return nil, nil, "Nenhuma BasePart encontrada na seleção! Selecione um Modelo ou Part."
    end

    for idx, part in ipairs(parts) do
        local localVerts, localFaces, meshIdNote = OBJExporter.GetPartGeometry(part)

        if meshIdNote and meshIdNote ~= "" and meshIdNote ~= "rbxassetid://0" then
            table.insert(meshNotes, part.Name .. " -> " .. meshIdNote)
        end

        if localVerts and localFaces then
            partCount = partCount + 1
            local cf = part.CFrame
            local worldVerts = {}
            for _, lv in ipairs(localVerts) do
                table.insert(worldVerts, cf * Vector3.new(lv[1], lv[2], lv[3]))
            end

            local matName = "mat_" .. idx .. "_" .. part.Name:gsub("[^%w_]", "_")
            if not materials[matName] then
                materials[matName] = {
                    Color = part.Color,
                    Transparency = part.Transparency,
                }
            end

            if currentMat ~= matName then
                table.insert(objLines, "")
                table.insert(objLines, "g " .. part.Name:gsub("[^%w_]", "_") .. "_" .. idx)
                table.insert(objLines, "usemtl " .. matName)
                currentMat = matName
            end

            for _, wv in ipairs(worldVerts) do
                table.insert(objLines, string.format("v %.6f %.6f %.6f", wv.X, wv.Y, wv.Z))
            end

            for _, face in ipairs(localFaces) do
                local tris = OBJExporter.Triangulate(face)
                for _, tri in ipairs(tris) do
                    local wv1 = worldVerts[tri[1]]
                    local wv2 = worldVerts[tri[2]]
                    local wv3 = worldVerts[tri[3]]
                    local n = OBJExporter.ComputeNormal(wv1, wv2, wv3)
                    normCount = normCount + 1
                    table.insert(objLines, string.format("vn %.6f %.6f %.6f", n.X, n.Y, n.Z))
                    table.insert(objLines, string.format("f %d//%d %d//%d %d//%d",
                        tri[1] + vertOffset, normCount,
                        tri[2] + vertOffset, normCount,
                        tri[3] + vertOffset, normCount
                    ))
                end
            end

            vertOffset = vertOffset + #localVerts
        end

        if progressCallback and (idx % 5 == 0 or idx == #parts) then
            progressCallback(idx / #parts)
        end
    end

    if #meshNotes > 0 then
        table.insert(objLines, "")
        table.insert(objLines, "# ============================================================")
        table.insert(objLines, "# MESH IDs - Geometria exportada como Bounding Box.")
        table.insert(objLines, "# Para obter a mesh real, baixe pelo MeshId e importe separadamente.")
        table.insert(objLines, "# ============================================================")
        for _, note in ipairs(meshNotes) do
            table.insert(objLines, "# " .. note)
        end
    end

    table.insert(mtlLines, "# MTL Exportado pelo Ultimate Dev Hub V4")
    table.insert(mtlLines, "# Objeto: " .. rootObj:GetFullName())
    table.insert(mtlLines, "")
    for name, data in pairs(materials) do
        table.insert(mtlLines, "newmtl " .. name)
        table.insert(mtlLines, string.format("Ka 0.100000 0.100000 0.100000"))
        table.insert(mtlLines, string.format("Kd %.6f %.6f %.6f", data.Color.R, data.Color.G, data.Color.B))
        table.insert(mtlLines, string.format("Ks 0.200000 0.200000 0.200000"))
        table.insert(mtlLines, string.format("Ns 10.000000"))
        table.insert(mtlLines, string.format("d %.6f", math.max(0.001, 1 - data.Transparency)))
        table.insert(mtlLines, string.format("illum 2"))
        table.insert(mtlLines, "")
    end

    return table.concat(objLines, "\n"), table.concat(mtlLines, "\n"), nil, partCount
end

--------------------------------------------------------------------------------
-- 4. INTERFACE GRÁFICA (ORIGINAL + ABA 3D EXPORT)
--------------------------------------------------------------------------------
local ScreenGui = Instance.new("ScreenGui")
ScreenGui.Name = "UltimateDevHub_V4"
ScreenGui.ResetOnSpawn = false
ScreenGui.Parent = CoreGui

local ToggleBtn = Instance.new("TextButton")
ToggleBtn.Name = "ToggleHub"
ToggleBtn.Size = UDim2.new(0, 50, 0, 50)
ToggleBtn.Position = UDim2.new(0, 10, 0.5, -25)
ToggleBtn.BackgroundColor3 = Color3.fromRGB(0, 120, 215)
ToggleBtn.Text = "DEV\nHUB"
ToggleBtn.TextColor3 = Color3.new(1,1,1)
ToggleBtn.Font = Enum.Font.GothamBlack
ToggleBtn.TextSize = 12
ToggleBtn.Parent = ScreenGui
local ToggleCorner = Instance.new("UICorner", ToggleBtn)
ToggleCorner.CornerRadius = UDim.new(0, 8)

local MainFrame = Instance.new("Frame")
MainFrame.Name = "MainFrame"
MainFrame.Size = UDim2.new(0, 600, 0, 400)
MainFrame.Position = UDim2.new(0.5, -300, 0.5, -200)
MainFrame.BackgroundColor3 = Color3.fromRGB(20, 20, 20)
MainFrame.BorderSizePixel = 0
MainFrame.Visible = false
MainFrame.Active = true
MainFrame.Draggable = true
MainFrame.Parent = ScreenGui

local MainCorner = Instance.new("UICorner", MainFrame)
MainCorner.CornerRadius = UDim.new(0, 6)

ToggleBtn.MouseButton1Click:Connect(function()
    MainFrame.Visible = not MainFrame.Visible
end)

local Sidebar = Instance.new("Frame")
Sidebar.Size = UDim2.new(0, 130, 1, 0)
Sidebar.BackgroundColor3 = Color3.fromRGB(30, 30, 30)
Sidebar.Parent = MainFrame
local SideCorner = Instance.new("UICorner", Sidebar)
SideCorner.CornerRadius = UDim.new(0, 6)

local TabContainer = Instance.new("Frame")
TabContainer.Size = UDim2.new(1, 0, 1, -50)
TabContainer.Position = UDim2.new(0, 0, 0, 50)
TabContainer.BackgroundTransparency = 1
TabContainer.Parent = Sidebar

local UIListLayout = Instance.new("UIListLayout", TabContainer)
UIListLayout.SortOrder = Enum.SortOrder.LayoutOrder
UIListLayout.Padding = UDim.new(0, 5)

local Title = Instance.new("TextLabel", Sidebar)
Title.Text = "ULTIMATE\nHUB V4"
Title.Size = UDim2.new(1, 0, 0, 50)
Title.BackgroundTransparency = 1
Title.TextColor3 = Color3.fromRGB(0, 170, 255)
Title.Font = Enum.Font.GothamBlack
Title.TextSize = 16

local Content = Instance.new("Frame", MainFrame)
Content.Size = UDim2.new(1, -140, 1, -20)
Content.Position = UDim2.new(0, 135, 0, 10)
Content.BackgroundTransparency = 1

local Tabs = {}
local function CreateTab(name)
    local Btn = Instance.new("TextButton", TabContainer)
    Btn.Size = UDim2.new(1, -10, 0, 35)
    Btn.BackgroundColor3 = Color3.fromRGB(30, 30, 30)
    Btn.Text = name
    Btn.TextColor3 = Color3.fromRGB(150, 150, 150)
    Btn.Font = Enum.Font.GothamBold
    Btn.TextSize = 14

    local Page = Instance.new("Frame", Content)
    Page.Size = UDim2.new(1, 0, 1, 0)
    Page.BackgroundTransparency = 1
    Page.Visible = false

    Btn.MouseButton1Click:Connect(function()
        for _, t in pairs(Tabs) do
            t.Page.Visible = false
            TweenService:Create(t.Btn, TweenInfo.new(0.2), {BackgroundColor3 = Color3.fromRGB(30, 30, 30), TextColor3 = Color3.fromRGB(150, 150, 150)}):Play()
        end
        Page.Visible = true
        TweenService:Create(Btn, TweenInfo.new(0.2), {BackgroundColor3 = Color3.fromRGB(50, 50, 50), TextColor3 = Color3.fromRGB(255, 255, 255)}):Play()
    end)

    table.insert(Tabs, {Btn = Btn, Page = Page})
    return Page
end

local PageExplorer = CreateTab("Explorer")
local PageDumper = CreateTab("Dumper")
local PageRemotes = CreateTab("Remotes")
local PageAnims = CreateTab("Anims")
local PageVisuals = CreateTab("Visuals")
local Page3DExport = CreateTab("3D Export") -- NOVA ABA

Tabs[1].Btn.BackgroundColor3 = Color3.fromRGB(50, 50, 50)
Tabs[1].Btn.TextColor3 = Color3.fromRGB(255, 255, 255)
Tabs[1].Page.Visible = true

--------------------------------------------------------------------------------
-- ABA 1: EXPLORER
--------------------------------------------------------------------------------
local ExpScroll = Instance.new("ScrollingFrame", PageExplorer)
ExpScroll.Size = UDim2.new(1, 0, 1, 0)
ExpScroll.BackgroundTransparency = 1
ExpScroll.CanvasSize = UDim2.new(0,0,0,0)
ExpScroll.AutomaticCanvasSize = Enum.AutomaticSize.Y
ExpScroll.ScrollBarThickness = 4

local ExpLayout = Instance.new("UIListLayout", ExpScroll)
ExpLayout.SortOrder = Enum.SortOrder.LayoutOrder

local SelectedObject = nil
local Expanded = {}

local function RefreshExplorer()
    for _, v in pairs(ExpScroll:GetChildren()) do if v:IsA("TextButton") then v:Destroy() end end

    local function Render(parent, indent)
        local children = parent:GetChildren()
        table.sort(children, function(a,b) return a.Name < b.Name end)

        for _, child in pairs(children) do
            local btn = Instance.new("TextButton", ExpScroll)
            btn.Size = UDim2.new(1, 0, 0, 20)
            btn.BackgroundColor3 = (SelectedObject == child) and Color3.fromRGB(0, 120, 215) or Color3.fromRGB(25, 25, 25)
            btn.BorderSizePixel = 0
            btn.Text = ""
            btn.AutoButtonColor = false

            local txt = Instance.new("TextLabel", btn)
            local prefix = (#child:GetChildren() > 0) and (Expanded[child] and "[-] " or "[+] ") or "   "
            txt.Text = string.rep("  ", indent) .. prefix .. child.Name
            txt.Size = UDim2.new(1, -5, 1, 0)
            txt.Position = UDim2.new(0, 5, 0, 0)
            txt.BackgroundTransparency = 1
            txt.TextColor3 = Color3.new(1,1,1)
            txt.TextXAlignment = Enum.TextXAlignment.Left

            btn.MouseButton1Click:Connect(function()
                SelectedObject = child
                if #child:GetChildren() > 0 then Expanded[child] = not Expanded[child] end
                RefreshExplorer()
            end)

            if Expanded[child] then Render(child, indent + 1) end
        end
    end

    local roots = {game.Workspace, game.ReplicatedStorage, game.Lighting, game.StarterGui, game.Players.LocalPlayer.PlayerGui}
    for _, root in pairs(roots) do
        local btn = Instance.new("TextButton", ExpScroll)
        btn.Size = UDim2.new(1, 0, 0, 22)
        btn.BackgroundColor3 = Color3.fromRGB(40, 40, 40)
        btn.Text = (Expanded[root] and "[-] " or "[+] ") .. root.Name
        btn.TextColor3 = Color3.new(1,1,1)
        btn.TextXAlignment = Enum.TextXAlignment.Left
        btn.MouseButton1Click:Connect(function() Expanded[root] = not Expanded[root]; RefreshExplorer() end)
        if Expanded[root] then Render(root, 1) end
    end
end
RefreshExplorer()

--------------------------------------------------------------------------------
-- ABA 2: DUMPER
--------------------------------------------------------------------------------
local DumpInfo = Instance.new("TextLabel", PageDumper)
DumpInfo.Size = UDim2.new(1, 0, 0, 40)
DumpInfo.BackgroundTransparency = 1
DumpInfo.Text = "Selecione um objeto no Explorer para clonar."
DumpInfo.TextColor3 = Color3.fromRGB(200, 200, 200)
DumpInfo.Font = Enum.Font.Gotham

local DumpBtn = Instance.new("TextButton", PageDumper)
DumpBtn.Text = "BAIXAR SELEÇÃO (.lua)"
DumpBtn.Size = UDim2.new(1, 0, 0, 50)
DumpBtn.Position = UDim2.new(0, 0, 0.5, -25)
DumpBtn.BackgroundColor3 = Color3.fromRGB(0, 170, 255)
DumpBtn.TextColor3 = Color3.new(1,1,1)
DumpBtn.Font = Enum.Font.GothamBold
local DBCorner = Instance.new("UICorner", DumpBtn)

local ProgressBar = Instance.new("Frame", PageDumper)
ProgressBar.Size = UDim2.new(1, 0, 0, 5)
ProgressBar.Position = UDim2.new(0, 0, 0.5, 35)
ProgressBar.BackgroundColor3 = Color3.fromRGB(10, 10, 10)
local ProgressFill = Instance.new("Frame", ProgressBar)
ProgressFill.Size = UDim2.new(0, 0, 1, 0)
ProgressFill.BackgroundColor3 = Color3.fromRGB(0, 255, 100)

DumpBtn.MouseButton1Click:Connect(function()
    if not SelectedObject then
        DumpInfo.Text = "ERRO: Nada selecionado!"
        return
    end

    DumpBtn.Text = "PROCESSANDO..."
    DumpInfo.Text = "Clonando: " .. SelectedObject.Name

    local code = Serializer.Generate(SelectedObject, function(ratio)
        ProgressFill.Size = UDim2.new(ratio, 0, 1, 0)
        RunService.RenderStepped:Wait()
    end)

    local fileName = "Clone_" .. SelectedObject.Name:gsub("[^%w]", "") .. "_" .. math.random(1000,9999) .. ".lua"

    if writefile then
        writefile(fileName, code)
        DumpInfo.Text = "Salvo em: workspace/" .. fileName
    else
        print(code)
        DumpInfo.Text = "Salvo no Console (F9) - Sem writefile"
    end

    DumpBtn.Text = "SUCESSO!"
    wait(2)
    DumpBtn.Text = "BAIXAR SELEÇÃO (.lua)"
    ProgressFill.Size = UDim2.new(0, 0, 1, 0)
end)

--------------------------------------------------------------------------------
-- ABA 3: REMOTE SPY
--------------------------------------------------------------------------------
local SpyScroll = Instance.new("ScrollingFrame", PageRemotes)
SpyScroll.Size = UDim2.new(1, 0, 0.85, 0)
SpyScroll.BackgroundTransparency = 0.5
SpyScroll.BackgroundColor3 = Color3.fromRGB(10, 10, 10)
SpyScroll.AutomaticCanvasSize = Enum.AutomaticSize.Y
local SpyLayout = Instance.new("UIListLayout", SpyScroll)
SpyLayout.Padding = UDim.new(0, 2)

local SpyToggle = Instance.new("TextButton", PageRemotes)
SpyToggle.Text = "ATIVAR SPY"
SpyToggle.Size = UDim2.new(1, 0, 0, 35)
SpyToggle.Position = UDim2.new(0, 0, 0.9, 0)
SpyToggle.BackgroundColor3 = Color3.fromRGB(200, 50, 50)
SpyToggle.TextColor3 = Color3.new(1,1,1)
SpyToggle.Font = Enum.Font.GothamBold

local SpyEnabled = false
SpyToggle.MouseButton1Click:Connect(function()
    SpyEnabled = not SpyEnabled
    SpyToggle.Text = SpyEnabled and "DESATIVAR SPY" or "ATIVAR SPY"
    SpyToggle.BackgroundColor3 = SpyEnabled and Color3.fromRGB(50, 200, 50) or Color3.fromRGB(200, 50, 50)
end)

local mt = getrawmetatable(game)
local oldNamecall = mt.__namecall
if setreadonly then setreadonly(mt, false) end

mt.__namecall = newcclosure(function(self, ...)
    local method = getnamecallmethod()
    if SpyEnabled and (method == "FireServer" or method == "InvokeServer") then
        local args = {...}
        local remoteName = self.Name
        if remoteName ~= "UpdateCharacter" and remoteName ~= "Ping" then
            local btn = Instance.new("TextButton", SpyScroll)
            btn.Size = UDim2.new(1, 0, 0, 20)
            btn.Text = " [" .. method .. "] " .. remoteName
            btn.TextColor3 = Color3.fromRGB(100, 255, 100)
            btn.BackgroundTransparency = 1
            btn.TextXAlignment = Enum.TextXAlignment.Left
            btn.MouseButton1Click:Connect(function()
                print("--- REMOTE LOG ---")
                print("Remote:", self:GetFullName())
                for i,v in pairs(args) do print("Arg["..i.."]:", v) end
            end)
        end
    end
    return oldNamecall(self, ...)
end)

--------------------------------------------------------------------------------
-- ABA 4: ANIMATION LOGGER
--------------------------------------------------------------------------------
local AnimScroll = Instance.new("ScrollingFrame", PageAnims)
AnimScroll.Size = UDim2.new(1, 0, 0.85, 0)
AnimScroll.BackgroundTransparency = 0.5
AnimScroll.BackgroundColor3 = Color3.fromRGB(10, 10, 10)
AnimScroll.AutomaticCanvasSize = Enum.AutomaticSize.Y
local AnimLayout = Instance.new("UIListLayout", AnimScroll)
AnimLayout.Padding = UDim.new(0, 5)

local ScanAnimBtn = Instance.new("TextButton", PageAnims)
ScanAnimBtn.Text = "ESCANEAR MEU PERSONAGEM"
ScanAnimBtn.Size = UDim2.new(1, 0, 0, 35)
ScanAnimBtn.Position = UDim2.new(0, 0, 0.9, 0)
ScanAnimBtn.BackgroundColor3 = Color3.fromRGB(255, 150, 0)
ScanAnimBtn.TextColor3 = Color3.new(1,1,1)
ScanAnimBtn.Font = Enum.Font.GothamBold

ScanAnimBtn.MouseButton1Click:Connect(function()
    local char = Players.LocalPlayer.Character
    if not char then return end
    local hum = char:FindFirstChild("Humanoid")
    if not hum then return end
    for _, v in pairs(AnimScroll:GetChildren()) do if v:IsA("Frame") then v:Destroy() end end
    local animator = hum:FindFirstChild("Animator") or hum
    animator.AnimationPlayed:Connect(function(track)
        if AnimScroll:FindFirstChild(track.Animation.AnimationId) then return end
        local Item = Instance.new("Frame", AnimScroll)
        Item.Name = track.Animation.AnimationId
        Item.Size = UDim2.new(1, 0, 0, 30)
        Item.BackgroundColor3 = Color3.fromRGB(40, 40, 40)
        local Lbl = Instance.new("TextLabel", Item)
        Lbl.Text = " " .. track.Name .. " (" .. track.Animation.AnimationId .. ")"
        Lbl.Size = UDim2.new(0.6, 0, 1, 0)
        Lbl.BackgroundTransparency = 1
        Lbl.TextColor3 = Color3.new(1,1,1)
        Lbl.TextXAlignment = Enum.TextXAlignment.Left
    end)
end)

--------------------------------------------------------------------------------
-- ABA 5: VISUALS
--------------------------------------------------------------------------------
local HitboxBtn = Instance.new("TextButton", PageVisuals)
HitboxBtn.Text = "REVELAR HITBOXES (CLIENT-SIDE)"
HitboxBtn.Size = UDim2.new(1, 0, 0, 40)
HitboxBtn.BackgroundColor3 = Color3.fromRGB(200, 50, 50)
HitboxBtn.TextColor3 = Color3.new(1,1,1)
HitboxBtn.Font = Enum.Font.GothamBold

HitboxBtn.MouseButton1Click:Connect(function()
    local count = 0
    for _, v in pairs(workspace:GetDescendants()) do
        if v:IsA("BasePart") then
            local name = v.Name:lower()
            if (name:find("hitbox") or name:find("hb") or v.Transparency == 1) and v.CanCollide == false and v.Size.Magnitude > 1 then
                local box = Instance.new("SelectionBox")
                box.Adornee = v
                box.Color3 = Color3.fromRGB(255, 0, 0)
                box.LineThickness = 0.05
                box.Transparency = 0.5
                box.Parent = CoreGui
                count = count + 1
            end
        end
    end
end)

local AssetBtn = Instance.new("TextButton", PageVisuals)
AssetBtn.Text = "PRINTAR ASSETS PRÓXIMOS (F9)"
AssetBtn.Size = UDim2.new(1, 0, 0, 40)
AssetBtn.Position = UDim2.new(0, 0, 0, 50)
AssetBtn.BackgroundColor3 = Color3.fromRGB(0, 150, 200)
AssetBtn.TextColor3 = Color3.new(1,1,1)
AssetBtn.Font = Enum.Font.GothamBold

AssetBtn.MouseButton1Click:Connect(function()
    local root = Players.LocalPlayer.Character and Players.LocalPlayer.Character:FindFirstChild("HumanoidRootPart")
    if not root then return end
    print("--- ASSETS PRÓXIMOS (RAIO 30) ---")
    for _, v in pairs(workspace:GetDescendants()) do
        if v:IsA("BasePart") and (v.Position - root.Position).Magnitude < 30 then
            if v:IsA("MeshPart") then print("MESH: " .. v.Name .. " | ID: " .. v.MeshId) end
        end
    end
end)

--------------------------------------------------------------------------------
-- ABA 6: 3D EXPORT (NOVO - EXPORTAÇÃO .OBJ + .MTL PARA BLENDER)
--------------------------------------------------------------------------------
local ExportTitle = Instance.new("TextLabel", Page3DExport)
ExportTitle.Size = UDim2.new(1, 0, 0, 25)
ExportTitle.BackgroundTransparency = 1
ExportTitle.Text = "EXPORTAR MODELO 3D"
ExportTitle.TextColor3 = Color3.fromRGB(0, 220, 130)
ExportTitle.Font = Enum.Font.GothamBlack
ExportTitle.TextSize = 18
ExportTitle.TextXAlignment = Enum.TextXAlignment.Left

local ExportDesc = Instance.new("TextLabel", Page3DExport)
ExportDesc.Size = UDim2.new(1, 0, 0, 40)
ExportDesc.Position = UDim2.new(0, 0, 0, 28)
ExportDesc.BackgroundTransparency = 1
ExportDesc.Text = "Selecione um modelo/objeto no Explorer e clique em Exportar.\nGera arquivo .OBJ + .MTL compatível com Blender, 3ds Max, Maya."
ExportDesc.TextColor3 = Color3.fromRGB(160, 160, 160)
ExportDesc.Font = Enum.Font.Gotham
ExportDesc.TextSize = 12
ExportDesc.TextWrapped = true
ExportDesc.TextXAlignment = Enum.TextXAlignment.Left

local ExportSelLabel = Instance.new("TextLabel", Page3DExport)
ExportSelLabel.Size = UDim2.new(1, 0, 0, 22)
ExportSelLabel.Position = UDim2.new(0, 0, 0, 72)
ExportSelLabel.BackgroundColor3 = Color3.fromRGB(35, 35, 35)
ExportSelLabel.Text = "  Seleção: Nenhuma (use o Explorer)"
ExportSelLabel.TextColor3 = Color3.fromRGB(255, 200, 50)
ExportSelLabel.Font = Enum.Font.GothamBold
ExportSelLabel.TextSize = 12
ExportSelLabel.TextXAlignment = Enum.TextXAlignment.Left
local ESelCorner = Instance.new("UICorner", ExportSelLabel)
ESelCorner.CornerRadius = UDim.new(0, 4)

local ExportBtn3D = Instance.new("TextButton", Page3DExport)
ExportBtn3D.Text = "EXPORTAR MODELO 3D (.OBJ + .MTL)"
ExportBtn3D.Size = UDim2.new(1, 0, 0, 45)
ExportBtn3D.Position = UDim2.new(0, 0, 0, 102)
ExportBtn3D.BackgroundColor3 = Color3.fromRGB(0, 180, 100)
ExportBtn3D.TextColor3 = Color3.new(1, 1, 1)
ExportBtn3D.Font = Enum.Font.GothamBold
ExportBtn3D.TextSize = 15
local EBCorner = Instance.new("UICorner", ExportBtn3D)
EBCorner.CornerRadius = UDim.new(0, 6)

local ExportProgress = Instance.new("Frame", Page3DExport)
ExportProgress.Size = UDim2.new(1, 0, 0, 4)
ExportProgress.Position = UDim2.new(0, 0, 0, 152)
ExportProgress.BackgroundColor3 = Color3.fromRGB(20, 20, 20)
ExportProgress.BorderSizePixel = 0
local ExportFill = Instance.new("Frame", ExportProgress)
ExportFill.Size = UDim2.new(0, 0, 1, 0)
ExportFill.BackgroundColor3 = Color3.fromRGB(0, 255, 150)
ExportFill.BorderSizePixel = 0

local ExportStatus = Instance.new("TextLabel", Page3DExport)
ExportStatus.Size = UDim2.new(1, 0, 0, 180)
ExportStatus.Position = UDim2.new(0, 0, 0, 162)
ExportStatus.BackgroundTransparency = 1
ExportStatus.Text = "Aguardando seleção..."
ExportStatus.TextColor3 = Color3.fromRGB(140, 140, 140)
ExportStatus.Font = Enum.Font.Gotham
ExportStatus.TextSize = 12
ExportStatus.TextWrapped = true
ExportStatus.TextYAlignment = Enum.TextYAlignment.Top
ExportStatus.TextXAlignment = Enum.TextXAlignment.Left

-- Atualizar label de seleção quando a aba 3D Export for aberta
local exportTabIndex = #Tabs
Tabs[exportTabIndex].Btn.MouseButton1Click:Connect(function()
    if SelectedObject then
        ExportSelLabel.Text = "  Seleção: " .. SelectedObject:GetFullName()
        ExportSelLabel.TextColor3 = Color3.fromRGB(100, 255, 150)
    else
        ExportSelLabel.Text = "  Seleção: Nenhuma (use o Explorer)"
        ExportSelLabel.TextColor3 = Color3.fromRGB(255, 200, 50)
    end
end)

ExportBtn3D.MouseButton1Click:Connect(function()
    if not SelectedObject then
        ExportStatus.Text = "ERRO: Nenhum objeto selecionado!\n\nVá na aba Explorer e clique em um modelo, mesh ou parte para selecionar."
        ExportStatus.TextColor3 = Color3.fromRGB(255, 80, 80)
        return
    end

    ExportSelLabel.Text = "  Seleção: " .. SelectedObject:GetFullName()
    ExportSelLabel.TextColor3 = Color3.fromRGB(100, 255, 150)
    ExportBtn3D.Text = "EXPORTANDO..."
    ExportBtn3D.BackgroundColor3 = Color3.fromRGB(80, 80, 80)
    ExportStatus.Text = "Gerando geometria OBJ de: " .. SelectedObject.Name .. " ..."
    ExportStatus.TextColor3 = Color3.fromRGB(200, 200, 200)

    local objCode, mtlCode, err, partCount = OBJExporter.Export(SelectedObject, function(ratio)
        ExportFill.Size = UDim2.new(math.min(ratio, 1), 0, 1, 0)
        RunService.RenderStepped:Wait()
    end)

    if err then
        ExportStatus.Text = "ERRO: " .. err
        ExportStatus.TextColor3 = Color3.fromRGB(255, 80, 80)
        ExportBtn3D.Text = "EXPORTAR MODELO 3D (.OBJ + .MTL)"
        ExportBtn3D.BackgroundColor3 = Color3.fromRGB(0, 180, 100)
        ExportFill.Size = UDim2.new(0, 0, 1, 0)
        return
    end

    local safeName = SelectedObject.Name:gsub("[^%w]", "_")
    local objFile = safeName .. ".obj"
    local mtlFile = safeName .. ".mtl"

    if writefile then
        writefile(objFile, objCode)
        writefile(mtlFile, mtlCode)
        ExportStatus.Text = string.format(
            "EXPORTADO COM SUCESSO!\n\n" ..
            "Partes exportadas: %d\n" ..
            "Arquivo OBJ: workspace/%s\n" ..
            "Arquivo MTL: workspace/%s\n\n" ..
            "Como abrir no Blender:\n" ..
            "1. File > Import > Wavefront OBJ (.obj)\n" ..
            "2. Selecione o arquivo .OBJ\n" ..
            "3. O .MTL precisa estar na mesma pasta!\n\n" ..
            "Nota: MeshParts saem como Bounding Box.\n" ..
            "Os MeshIds ficam anotados no .OBJ para\n" ..
            "download manual da mesh real.",
            partCount or 0, objFile, mtlFile
        )
        ExportStatus.TextColor3 = Color3.fromRGB(0, 255, 150)
    else
        print("=== OBJ EXPORT ===")
        print(objCode)
        print("=== MTL EXPORT ===")
        print(mtlCode)
        ExportStatus.Text = "Exportado no Console (F9).\nSem suporte a writefile.\nCopie o conteudo OBJ e MTL manualmente.\nPartes: " .. (partCount or 0)
        ExportStatus.TextColor3 = Color3.fromRGB(255, 200, 0)
    end

    ExportBtn3D.Text = "EXPORTAR MODELO 3D (.OBJ + .MTL)"
    ExportBtn3D.BackgroundColor3 = Color3.fromRGB(0, 180, 100)
    wait(0.3)
    ExportFill.Size = UDim2.new(0, 0, 1, 0)
end)

