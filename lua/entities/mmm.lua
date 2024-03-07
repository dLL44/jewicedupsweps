AddCSLuaFile()

--[[
    mm bot
]]--

ENT.Base = "base_nextbot"
ENT.Spawnable = true 

function ENT:Initialize()
    self:SetModel("models/hunter.mdl")

    self.LoseTargetDist = 2000
    self.SearchRadius = 1000
end

-- Enemy (grr)

-- Get and set enemy

function ENT:SetEnemy(ent)
    self.Enemy = ent
end

function ENT:GetEnemy()
    return self.Enemy
end

-- Have enemy
function ENT:HaveEnemy()
    -- If valid
    if self:GetEnemy() and IsValid(self:GetEnemy()) then
        -- Too far?
        if self:GetRangeTo(self:GetEnemy():GetPos()) > self.LoseTargetDist then
            return self:FindEnemy()
        -- Dead? (check if player before checking if dead)
        elseif self:GetEnemy():IsPlayer() and not self:GetEnemy():Alive() then
            return self:FindEnemy()
        end
        -- Alles gut, so we can say you have an enemy
        return true
    else
        -- nah find one
        return self:FindEnemy()
    end
end

-- find the enemy
function ENT:FindEnemy()
    -- do a search
    local _ents = ents.FindInSphere(self:GetPos(), self.SearchRadius)
    -- loop through ents and find one we want
    for k,v in ipairs(_ents) do
        if v:IsPlayer() then
            self:SetEnemy(v)
            return true
        end
    end
    self:SetEnemy(nil)
    return false 
end

-- big brain

-- Check if we have an enemy, if not it will look for one using the above HaveEnemy() function.
-- If there is an enemy then play some animations and run at the player.
-- If there are not any enemies, then walk to a random spot.
-- Stand idle for 2 seconds.
function ENT:RunBehaviour()
    while true do
        if self:HaveEnemy() then
            self.loco:FaceTowards(self:GetEnemy():GetPos())
            
            self:PlaySequenceAndWait("plant")
            self:PlaySequenceAndWait("hunter_angry")
            self:PlaySequenceAndWait("unplant")

            self:StartActivity(ACT_RUN)
            self.loco:SetDesiredSpeed(450)
            self.loco:SetAcceleration(900)
            self:ChaseEnemy()
            self.loco:SetAcceleration(400)
            self:PlaySequenceAndWait("charge_miss_slide")
            self.StartActivity(ACT_IDLE)
        else
            self.StartActivity(ACT_WALK)
            self.loco:SetDesiredSpeed(200)
            self.MoveToPos(self:GetPos() + Vector( math.Rand( -1, 1 ), math.Rand( -1, 1 ), 0 ) * 400)
            self:StartActivity(ACT_IDLE)
        end

        coroutine.wait(2)
    end    
end

function ENT:ChaseEnemy(opts)
    local options = opts or {}
    local path = Path("Follow")
    path:SetMinLookAheadDistance(options.lookahead or 300)
    path:SetGoalTolerance(options.tolerance or 20)
    path:Compute(self, self:GetEnemy():GetPos())
    if !path:IsValid() then return "failed" end
    while path:IsValid() and self:HaveEnemy() do
        if (path:GetAge() > 0.1) then
            path:Compute(self, self:GetEnemy():GetPos())
        end
        path:Update(self)

        if options.draw then path:Draw() end
        if self.loco:IsStuck() then self:HandleStuck(); return "stuck" end

        coroutine.yield()
    end
    return "ok"
end

list.Set("NPC", "mmm",
    {
        Name = "mm",
        Class = "mmm",
        Category = "Jewice!"
    }
)