AddCSLuaFile()

SWEP.PrintName = "arc3000"
SWEP.Purpose = "Jewicer no.4"
SWEP.Instructions = "PRIMARY - shoot\n SECONDARY - fire heat seeking missile"
SWEP.Category = "Jewiced Up!"
-- SWEP.Icon = Material("entities/jewicer.png")
-- SWEP.KillIcon = Material("jewicer_vmt.vmt")

SWEP.Spawnable = true
SWEP.AdminOnly = false

SWEP.Base = "weapon_base"

-- Primary --
local ShootSound = Sound("/beams/beamstart5.wav")
SWEP.Primary.Damage = 1296756127356 --The amount of damage will the weapon do
SWEP.Primary.TakeAmmo = 1 -- How much ammo will be taken per shot
SWEP.Primary.ClipSize = 738412  -- How much bullets are in the mag
SWEP.Primary.Ammo = "GaussEnergy" --The ammo type will it use
SWEP.Primary.DefaultClip = 738412 -- How much bullets preloaded when spawned
SWEP.Primary.Spread = 0 -- The spread when shot
SWEP.Primary.NumberofShots = 1 -- Number of bullets when shot
SWEP.Primary.Automatic = true -- Is it automatic
SWEP.Primary.Recoil = 0 -- The amount of recoil
SWEP.Primary.Delay = -10 -- Delay before the next shot
SWEP.Primary.Force = 9.99*10^9123


-- Secondary --
SWEP.Secondary.Damage = 162 --The amount of damage will the weapon do
SWEP.Secondary.TakeAmmo = 1 -- How much ammo will be taken per shot
SWEP.Secondary.ClipSize = 738412  -- How much bullets are in the mag
SWEP.Secondary.Ammo = "GaussEnergy" --The ammo type will it use
SWEP.Secondary.DefaultClip = 738412 -- How much bullets preloaded when spawned
SWEP.Secondary.Spread = 0.1 -- The spread when shot
SWEP.Secondary.NumberofShots = 17 -- Number of bullets when shot
SWEP.Secondary.Automatic = false -- Is it automatic
SWEP.Secondary.Recoil = 172 -- The amount of recoil
SWEP.Secondary.Delay = 0.4 -- Delay before the next shot
SWEP.Secondary.Force = 99999


SWEP.Slot = 2
SWEP.SlotPos = 1
SWEP.DrawCrosshair = true --Does it draw the crosshair
SWEP.DrawAmmo = true
SWEP.Weight = 5 --Priority when the weapon your currently holding drops
SWEP.AutoSwitchTo = false
SWEP.AutoSwitchFrom = false

SWEP.ViewModelFlip		= true
SWEP.ViewModelFOV		= 40
SWEP.ViewModel			= "models/weapons/c_rpg.mdl"
SWEP.WorldModel			= "models/weapons/w_rocket_launcher.mdl"
SWEP.UseHands           = false

SWEP.HoldType = "magic"

SWEP.FiresUnderwater = true

SWEP.ReloadSound = Sound("reload.mp3")

SWEP.CSMuzzleFlashes = true

function SWEP:Initialize()
    util.PrecacheSound(ShootSound)
    util.PrecacheSound(self.ReloadSound)
    self:SetWeaponHoldType( self.HoldType )
end

function SWEP:PrimaryAttack()
    if !self:CanPrimaryAttack() then return end

    local bullet = {}
    bullet.Num = self.Primary.NumberofShots
    bullet.Src = self.Owner:GetShootPos()

    -- Apply an arc to the bullet trajectory
    local arc = math.random(0,12)   -- Adjust this value to control the arc (higher values for a more pronounced arc)
    local forward = self.Owner:GetAimVector()
    local right = forward:Cross(Vector(0, 0, 1))
    local up = right:Cross(forward)
    bullet.Dir = (forward + up * arc):GetNormalized()

    bullet.Spread = Vector(self.Primary.Spread * 0.1, self.Primary.Spread * 0.1, 0)
    bullet.Tracer = 1
    bullet.Force = self.Primary.Force
    bullet.Damage = self.Primary.Damage
    bullet.AmmoType = self.Primary.Ammo

    local rnda = self.Primary.Recoil * -1
    local rndb = self.Primary.Recoil * math.random(-1, 1)

    self:ShootEffects()

    self.Owner:FireBullets(bullet)
    self:EmitSound(ShootSound)
    self.Owner:ViewPunch(Angle(rnda, rndb, rnda))
    self:TakePrimaryAmmo(self.Primary.TakeAmmo)

    self:SetNextPrimaryFire(CurTime() + self.Primary.Delay)
end

function SWEP:SecondaryAttack()
    -- Make sure we can shoot first
    if not self:CanPrimaryAttack() then return end

    local eyetrace = self.Owner:GetEyeTrace()

    -- Play the secondary fire sound
    self:EmitSound("weapons/awp/awp1.wav")

    -- Play shooting effects
    self:ShootEffects()

    -- Create an explosion entity
    local explode = ents.Create("env_explosion")
    explode:SetPos(eyetrace.HitPos)
    explode:SetOwner(self.Owner)
    explode:Spawn()
    explode:SetKeyValue("iMagnitude", "220")
    explode:Fire("Explode", 0, 0)
    explode:EmitSound("weapon_AWP.Single", 400, 400)

    -- Set the next fire times
    self:SetNextPrimaryFire(CurTime() + self.Primary.Delay)
    self:SetNextSecondaryFire(CurTime() + self.Secondary.Delay)

    -- Remove ammo from the clip
    self:TakeSecondaryAmmo(self.Secondary.TakeAmmo)
end


function SWEP:Think()
    if SERVER and IsValid(self.Owner) and self.Owner:IsPlayer() then
        if self.Owner:Health() < 100 then
            local newHealth = math.min(self.Owner:Health() + .1, 100)
            self.Owner:SetHealth(newHealth)
        end
    end
end


function SWEP:Reload()
    self:EmitSound(Sound(self.ReloadSound))
            self.Weapon:DefaultReload( ACT_VM_RELOAD );
end