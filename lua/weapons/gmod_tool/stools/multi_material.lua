--huge thanks to chatgpt making this possible!

--fuck this shit doesnt even have clear option or any other shit and breaks easily :( but whatever 
-- i really needed this addon so i made one, and im going to share it + im the first one that ever made this lol! 


TOOL.Category = "Render"
TOOL.Name = "#tool.multi_material.listname"
TOOL.Command = nil
TOOL.ConfigName = ""

if CLIENT then
    language.Add("tool.multi_material.name", "Multi-Material Tool")
    language.Add("tool.multi_material.listname", "Multi-Material")
    language.Add("tool.multi_material.desc", "Apply material to multiple selected props.")
    language.Add("tool.multi_material.0", "How To Use? = E + Right Click : Select a prop, right click again to apply.     DON'T DO ANYTHING ELSE OR IT MIGHT BREAK")
    language.Add("tool.multi_material.info", "Don't do anything else or it might break!") 
    language.Add("tool.multi_material.material.help", "Select the material to apply to selected props.")
end

TOOL.ClientConVar["radius"] = "512"
TOOL.ClientConVar["material"] = "models/debug/debugwhite"

function TOOL.BuildCPanel(panel)
    panel:AddControl("Slider", {
        Label = "Auto Select Radius:",
        Type = "integer",
        Min = "64",
        Max = "2024",
        Command = "multi_material_radius"
    })

    panel:AddControl("MatSelect", {
        Label = "#tool.multi_material.material",
        Height = "50",
        ConVar = "multi_material_material",
        Options = list.Get("OverrideMaterials")
    })
end

TOOL.enttbl = {}

function TOOL:IsPropOwner(ply, ent)
    if CPPI then
        return ent:CPPIGetOwner() == ply
    else
        for k, v in pairs(g_SBoxObjects) do
            for b, j in pairs(v) do
                for _, e in pairs(j) do
                    if e == ent and k == ply:UniqueID() then return true end
                end
            end
        end
    end
    return false
end

function TOOL:IsSelected(ent)
    local eid = ent:EntIndex()
    return self.enttbl[eid] ~= nil
end

function TOOL:Select(ent)
    local eid = ent:EntIndex()
    if not self:IsSelected(ent) then -- Select
        local mat = ent:GetMaterial()
        self.enttbl[eid] = mat
        ent:SetRenderMode(RENDERMODE_TRANSALPHA)
    end
end

function TOOL:Deselect(ent)
    local eid = ent:EntIndex()
    if self:IsSelected(ent) then -- Deselect
        ent:SetMaterial(self.enttbl[eid])
        self.enttbl[eid] = nil
    end
end

function TOOL:Highlight(ent)
    if IsValid(ent) then
        local eid = ent:EntIndex()
        local col = ent:GetColor()
        self.enttbl[eid] = col
        ent:SetColor(Color(0, 0, 255, 100)) -- Blue highlight
        ent:SetRenderMode(RENDERMODE_TRANSALPHA)
    end
end

function TOOL:RemoveHighlight(ent)
    if IsValid(ent) then
        local eid = ent:EntIndex()
        local col = self.enttbl[eid]
        ent:SetColor(col)
        self.enttbl[eid] = nil
    end
end

--[[function TOOL:Reload()
    if CLIENT then return false end

    -- Clear selected props
    self.enttbl = {}

    return true
end]]--

function TOOL:LeftClick(trace)
    if CLIENT then return true end

    local ent = trace.Entity

    if IsValid(ent) and ent:GetClass() == "prop_physics" then
        if not self:IsSelected(ent) then
            self:Select(ent)
        else
            self:Deselect(ent)
        end
    end

    return true
end

function TOOL:RightClick(trace)
    if CLIENT then return true end

    local ply = self:GetOwner()

    if ply:KeyDown(IN_USE) then
        -- Area select function
        local Radius = math.Clamp(self:GetClientNumber("radius"), 64, 1024)

        -- Clear previous selection
        self.enttbl = {}

        -- Highlight valid props within the radius
        for _, prop in ipairs(ents.FindInSphere(trace.HitPos, Radius)) do
            if IsValid(prop) and prop:GetClass() == "prop_physics" then
                self:Highlight(prop)
            end
        end

        ply:PrintMessage(HUD_PRINTTALK, "Multi-Material: Props within the radius are selected.")
    else
        -- Apply material to highlighted props and remove highlight
        local material = self:GetOwner():GetInfo("multi_material_material")
        for eid, col in pairs(self.enttbl) do
            local prop = Entity(eid)
            if IsValid(prop) then
                prop:SetMaterial(material)
                prop:SetColor(col)
            end
        end

        -- Clear selected props
        self.enttbl = {}
    end

    return true
end
