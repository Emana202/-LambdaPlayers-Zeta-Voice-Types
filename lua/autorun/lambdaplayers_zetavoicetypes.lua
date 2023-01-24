hook.Add( "LambdaOnVoiceTypesRegistered", "LambdaZetaVoiceTypes_RegisterVoiceTypes", function()
	LambdaRegisterVoiceType( "witnesskill", "lambdaplayers/vo/witnesskill", "These are voice lines that play when a Lambda Player sees someone get killed." )
    LambdaRegisterVoiceType( "killassist", "lambdaplayers/vo/killassist", "These are voice lines that play when someone else kills Lambda Player's current enemy." )
    LambdaRegisterVoiceType( "fall", "lambdaplayers/vo/fall", "These are voice lines that play when a Lambda Player starts falling from deadly distance." )
end)

if ( CLIENT ) then return end

local realDamage = GetConVar( "lambdaplayers_lambda_realisticfalldamage" )
local TraceHull = util.TraceHull
local fallTrTbl = {}
local math_max = math.max
local random = math.random
local Rand = math.Rand
local IsValid = IsValid

local fallPathCvar
local witnessPathCvar
local assistPathCvar

hook.Add( "LambdaOnLeaveGround", "LambdaZetaVoiceTypes_OnLeaveGround", function( self, ground )
    local deathDist = 800
    if realDamage:GetBool() then deathDist = math_max( 256, 800 * ( self:Health() / self:GetMaxHealth() ) ) end

    fallTrTbl.start = self:GetPos()
    fallTrTbl.endpos = ( fallTrTbl.start - self:GetUp() * deathDist )
    fallTrTbl.filter = self
    fallTrTbl.mins = self:OBBMins()
    fallTrTbl.maxs = self:OBBMaxs()
    if TraceHull( fallTrTbl ).Hit then return end
    	
	fallTrTbl.endpos = ( fallTrTbl.start - self:GetUp() * 32756 )
	if TraceHull( fallTrTbl ).HitPos:IsUnderwater() then return end

    fallPathCvar = fallPathCvar or GetConVar( "lambdaplayers_voice_falldir" )
    self:PlaySoundFile( ( fallPathCvar:GetString() == "randomengine" and self:GetRandomSound() or self:GetVoiceLine( "fall" ) ), true )
end )

hook.Add( "LambdaOnOtherKilled", "LambdaZetaVoiceTypes_OnOtherKilled", function( self, victim, dmginfo )
    local attacker = dmginfo:GetAttacker()
    if attacker == self or !self:CanSee( victim ) then return end

    local curState = self:GetState()
    local curEnemy = self:GetEnemy()
    local victimPos = victim:WorldSpaceCenter()

    self:SimpleTimer( 0, function() 
        if self:GetState() == "Laughing" then return end

        if curState == "Combat" then
            if victim != curEnemy or random( 1, 100 ) > self:GetVoiceChance() then return end
            if !attacker:IsPlayer() and !attacker:IsNPC() and !attacker:IsNextBot() or !self:CanSee( attacker ) then return end

            self:SimpleTimer( Rand( 0.1, 1.0 ), function()
                if !IsValid( attacker ) then return end
                assistPathCvar = assistPathCvar or GetConVar( "lambdaplayers_voice_killassistdir" )
                self:PlaySoundFile( ( assistPathCvar:GetString() == "randomengine" and self:GetRandomSound() or self:GetVoiceLine( "killassist" ) ), true )
            end )
        else
            if random( 1, 10 ) != 1 or !self:IsInRange( victimPos, 2000 ) then return end
            self:LookTo( victimPos, random( 1, 3 ) )

            self:SimpleTimer( Rand( 0.1, 1.0 ), function()
                witnessPathCvar = witnessPathCvar or GetConVar( "lambdaplayers_voice_witnesskilldir" )
                self:PlaySoundFile( ( witnessPathCvar:GetString() == "randomengine" and self:GetRandomSound() or self:GetVoiceLine( "witnesskill" ) ), true )
            end )
        end
    end )
end )