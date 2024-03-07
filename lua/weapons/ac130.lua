AddCSLuaFile()

SWEP.PrintName = "ac130"
SWEP.Purpose = "Jewicer no.2"
SWEP.Instructions = "PRIMARY - big spray\nSECONDARY - big boom"
SWEP.Category = "Jewiced Up!"
SWEP.Icon = Material("ac130_vmt.vmt")
SWEP.KillIcon = Material("ac130_vmt.vmt")

SWEP.Spawnable = true
SWEP.AdminOnly = false

SWEP.Base = "weapon_base"

-- Primary --
local ShootSound = Sound("ac130shot.mp3")
SWEP.Primary.Damage = 10 --The amount of damage will the weapon do
SWEP.Primary.TakeAmmo = 1 -- How much ammo will be taken per shot
SWEP.Primary.ClipSize = 738412  -- How much bullets are in the mag
SWEP.Primary.Ammo = "GaussEnergy" --The ammo type will it use
SWEP.Primary.DefaultClip = 738412 -- How much bullets preloaded when spawned
SWEP.Primary.Spread = 1 -- The spread when shot
SWEP.Primary.NumberofShots = 17 -- Number of bullets when shot
SWEP.Primary.Automatic = true -- Is it automatic
SWEP.Primary.Recoil = 1 -- The amount of recoil
SWEP.Primary.Delay = 0.1 -- Delay before the next shot
SWEP.Primary.Force = 99999


-- Secondary --
SWEP.Secondary.Damage = 10203102312391 --The amount of damage will the weapon do
SWEP.Secondary.TakeAmmo = 1 -- How much ammo will be taken per shot
SWEP.Secondary.ClipSize = 738412  -- How much bullets are in the mag
SWEP.Secondary.Ammo = "GaussEnergy" --The ammo type will it use
SWEP.Secondary.DefaultClip = 738412 -- How much bullets preloaded when spawned
SWEP.Secondary.Spread = 0 -- The spread when shot
SWEP.Secondary.NumberofShots = 100 -- Number of bullets when shot
SWEP.Secondary.Automatic = true -- Is it automatic
SWEP.Secondary.Recoil = .12 -- The amount of recoil
SWEP.Secondary.Delay = 0 -- Delay before the next shot
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
SWEP.ViewModel			= "models/weapons/cstrike/c_smg_mp5.mdl"
SWEP.WorldModel			= "models/weapons/w_smg_mp5.mdl"
SWEP.UseHands           = true

SWEP.HoldType = "duel"

SWEP.FiresUnderwater = true

SWEP.ReloadSound = Sound("reload.mp3")

SWEP.CSMuzzleFlashes = true

function SWEP:Initialize()
    util.PrecacheSound(ShootSound)
    util.PrecacheSound(self.ReloadSound)
    self:SetWeaponHoldType( self.HoldType )
end

function SWEP:PrimaryAttack()
    if ( !self:CanPrimaryAttack() ) then return end

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
    if not self:CanSecondaryAttack() then return end

    local rocket = ents.Create("rpg_missile")
    if not IsValid(rocket) then return end

    local startPos = self.Owner:GetShootPos()
    local direction = self.Owner:GetAimVector()

    rocket:SetPos(startPos)
    rocket:SetAngles(direction:Angle())
    rocket:SetOwner(self.Owner)
    rocket:Spawn()
    rocket:Activate()

    local rocketPhys = rocket:GetPhysicsObject()
    if IsValid(rocketPhys) then
        local rocketSpeed = 5000
        rocketPhys:SetVelocity(direction * rocketSpeed)
    end

    local explosionDamage = 100000 -- Adjust this value to set the desired damage

    rocket:CallOnRemove("RocketExplosion", function()
        print("Rocket exploded at:", rocket:GetPos())

        util.BlastDamage(self.Owner, self.Owner, rocket:GetPos(), 500, explosionDamage)  -- Adjust blast radius if needed

        -- Additional effects or logic if needed
    end)

    -- RPG missile launch sound
    self:EmitSound("ambient/explosions/explode_1.wav")

    -- Ignore rocket collisions with other rockets
    rocket:SetCustomCollisionCheck(true)
    rocket:SetCollisionGroup(COLLISION_GROUP_PROJECTILE)

    -- Secondary recoil effects
    local rnda = self.Secondary.Recoil * -1
    local rndb = self.Secondary.Recoil * math.random(-1, 1)
    self.Owner:ViewPunch(Angle(rnda, rndb, rnda))

    self:TakeSecondaryAmmo(self.Secondary.TakeAmmo)
    self:SetNextSecondaryFire(CurTime() + self.Secondary.Delay)
end

hook.Add("PhysicsCollide", "HandleRocketCollision", function(data, collider)
    local ent = data.HitEntity
    local phys = data.PhysObject

    if ent and ent.DoExplode and phys and IsValid(collider) and collider:IsPlayer() then
        ent:DoExplode()
        ent:Remove()  -- Remove the rocket after exploding
    end
end)
