LambdaRegisterVoiceType( "fall", "lambdaplayers/vo/fall", "These are voice lines that play when a Lambda Player starts falling from deadly distance." )
LambdaRegisterVoiceType( "assist", "lambdaplayers/vo/assist", "These are voice lines that play when someone else kills Lambda Player's current enemy." )
LambdaRegisterVoiceType( "witness", "lambdaplayers/vo/witness", "These are voice lines that play when a Lambda Player sees someone get killed." )

if ( CLIENT ) then return end

local IsValid = IsValid
local math_max = math.max
local random = math.random
local Rand = math.Rand
local TraceHull = util.TraceHull
local fallTrTbl = {}
local realDamage = GetConVar( "lambdaplayers_lambda_realisticfalldamage" )
local fallDir = GetConVar( "lambdaplayers_voice_falldir" )
local assistDir = GetConVar( "lambdaplayers_voice_assistdir" )
local witnessDir = GetConVar( "lambdaplayers_voice_witnessdir" )

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
    self:PlaySoundFile( ( fallDir:GetString() == "randomengine" and self:GetRandomSound() or self:GetVoiceLine( "fall" ) ), true )
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

            self:LookTo( attacker, 1 )
            self:SimpleTimer( Rand( 0.1, 1.0 ), function()
                if !IsValid( attacker ) then return end
                self:PlaySoundFile( ( assistDir:GetString() == "randomengine" and self:GetRandomSound() or self:GetVoiceLine( "assist" ) ), true )
            end )
        elseif random( 1, 10 ) == 1 and self:IsInRange( victimPos, 2000 ) then
            self:LookTo( victimPos, random( 1, 3 ) )
            self:SimpleTimer( Rand( 0.1, 1.0 ), function()
                self:PlaySoundFile( ( witnessDir:GetString() == "randomengine" and self:GetRandomSound() or self:GetVoiceLine( "witness" ) ), true )
            end )
        end
    end )
end )