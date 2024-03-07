AddCSLuaFile()

SWEP.PrintName = "the ZUCK"
SWEP.Purpose = "Jewicer no.3"
SWEP.Instructions = "PRIMARY - fire\n SECONDARY - shotgun"
SWEP.Category = "Jewiced Up!"
SWEP.Icon = Material("entities/pictures/zuck.png")
SWEP.KillIcon = Material("zuck_vmt.vmt")


SWEP.Spawnable = true
SWEP.AdminOnly = false

SWEP.Base = "weapon_base"

-- Primary --
local ShootSound = Sound("/weapons/glock/glock18-1.wav")
SWEP.Primary.Damage = 10 --The amount of damage will the weapon do
SWEP.Primary.TakeAmmo = 1 -- How much ammo will be taken per shot
SWEP.Primary.ClipSize = 738412  -- How much bullets are in the mag
SWEP.Primary.Ammo = "Grenade" --The ammo type will it use
SWEP.Primary.DefaultClip = 738412 -- How much bullets preloaded when spawned
SWEP.Primary.Spread = 1 -- The spread when shot
SWEP.Primary.NumberofShots = 60 -- Number of bullets when shot
SWEP.Primary.Automatic = true  -- Is it automatic
SWEP.Primary.Recoil = 0 -- The amount of recoil
SWEP.Primary.Delay = 0.1 -- Delay before the next shot
SWEP.Primary.Force = 0

-- Secondary --
SWEP.Secondary.Damage = 1 --The amount of damage will the weapon do
SWEP.Secondary.TakeAmmo = 1 -- How much ammo will be taken per shot
SWEP.Secondary.ClipSize = 738412  -- How much bullets are in the mag
SWEP.Secondary.Ammo = "GaussEnergy" --The ammo type will it use
SWEP.Secondary.DefaultClip = 738412 -- How much bullets preloaded when spawned
SWEP.Secondary.Spread = 1.221 -- The spread when shot
SWEP.Secondary.NumberofShots = 1 -- Number of bullets when shot
SWEP.Secondary.Automatic = true  -- Is it automatic
SWEP.Secondary.Recoil = .9 -- The amount of recoil
SWEP.Secondary.Delay = .4 -- Delay before the next shot
SWEP.Secondary.Force = 9119239

SWEP.Slot = 2
SWEP.SlotPos = 1
SWEP.DrawCrosshair = true --Does it draw the crosshair
SWEP.DrawAmmo = true
SWEP.Weight = 5 --Priority when the weapon your currently holding drops
SWEP.AutoSwitchTo = false
SWEP.AutoSwitchFrom = false

SWEP.ViewModelFlip		= true
SWEP.ViewModelFOV		= 100
SWEP.ViewModel			= Model("models/weapons/c_arms.mdl")
SWEP.WorldModel			= ""
SWEP.UseHands           = false

SWEP.HoldType = "knife"

SWEP.FiresUnderwater = true

SWEP.ReloadSound = Sound("reload.mp3")

-- SWEP.CSMuzzleFlashes = true

function SWEP:Initialize()
    util.PrecacheSound(ShootSound)
    util.PrecacheSound(self.ReloadSound)
    -- util.PrecacheModel(SWEP.WorldModel)
    self:SetWeaponHoldType( self.HoldType )
end

function SWEP:PrimaryAttack()
    if !self:CanPrimaryAttack() then return end

    local bullet = {}
    bullet.Num = self.Primary.NumberofShots
    bullet.Src = self.Owner:GetShootPos()
    bullet.Dir = self.Owner:GetAimVector()
    bullet.Spread = Vector( self.Primary.Spread * 0.1 , self.Primary.Spread * 0.1, 0)
    bullet.Tracer = 1
    bullet.Force = self.Primary.Force
    bullet.Damage = self.Primary.Damage
    bullet.AmmoType = self.Primary.Ammo

    local rnda = self.Primary.Recoil * -1
    local rndb = self.Primary.Recoil * math.random(-1, 1)

    self:ShootEffects()

    self.Owner:FireBullets( bullet )
    self:EmitSound(ShootSound)
    self.Owner:ViewPunch( Angle( rnda,rndb,rnda ) )
    self:TakePrimaryAmmo(self.Primary.TakeAmmo)

    self:SetNextPrimaryFire( CurTime() + self.Primary.Delay )
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
            -- TODO: test
            -- essentialy buff the user when hit ( not tested )
            local newHealth = math.min(self.Owner:Health() + 1, 999)
            self.Owner:SetHealth(newHealth)
        end
    end
end


function SWEP:Reload()
    self:EmitSound(Sound(self.ReloadSound))
            self.Weapon:DefaultReload( ACT_VM_RELOAD );
end
player_manager.AddValidHands( "css_arctic", "models/weapons/c_arms_cstrike.mdl", 0, "00000000" )