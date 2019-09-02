--By Hel for YGOPro Percy
sql = require("lsqlite3")
lfs = require("lfs")
io = require("io")

Debug.SetAIName("Ignis")
Debug.ReloadFieldBegin(DUEL_SIMPLE_AI+DUEL_ATTACK_FIRST_TURN,4)
Debug.SetPlayerInfo(0,8000,0,0)
Debug.SetPlayerInfo(1,8000,0,0)
Debug.ReloadFieldEnd()

--load deck's name in .cdb
db = sql.open("./expansions/single-user-mode.cdb")
local i=1
deck = {}
for file in lfs.dir("./deck") do
	local found=file:find(".ydk")
	if found and found>0 then
		local sql="UPDATE texts SET str"..i.." = '"..file.."' WHERE id='51105014';"
		db:exec(sql)
		deck[i-1] = file
		i=i+1
		if i>16 then break end
	end
end

local e1=Effect.GlobalEffect()
	e1:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_CONTINUOUS)
	e1:SetCode(EVENT_PREDRAW)
	e1:SetCountLimit(1)
	e1:SetProperty(EFFECT_FLAG_NO_TURN_RESET)
	e1:SetOperation(function(e,tp,eg,ep,ev,re,r,rp)
		singleusermode(e,tp,eg,ep,ev,re,r,rp)
	end)
Duel.RegisterEffect(e1,0)

function singleusermode(e,tp,eg,ep,ev,re,r,rp)
	Duel.SendtoDeck(Duel.GetFieldGroup(0,0x43,0x43),nil,-2,REASON_RULE)
	Duel.SetLP(tp,8000)
	Duel.SetLP(1-tp,8000)
	local d1=aux.Stringid(51105014,0)
	local d2=aux.Stringid(51105014,1)
	local d3=aux.Stringid(51105014,2)
	local d4=aux.Stringid(51105014,3)
	local d5=aux.Stringid(51105014,4)
	local d6=aux.Stringid(51105014,5)
	local d7=aux.Stringid(51105014,6)
	local d8=aux.Stringid(51105014,7)
	local d9=aux.Stringid(51105014,8)
	local d10=aux.Stringid(51105014,9)
	local d11=aux.Stringid(51105014,10)
	local d12=aux.Stringid(51105014,11)
	local d13=aux.Stringid(51105014,12)
	local d14=aux.Stringid(51105014,13)
	local d15=aux.Stringid(51105014,14)
	local d16=aux.Stringid(51105014,15)
	e:SetLabel(Duel.SelectOption(tp,d1,d2,d3,d4,d5,d6,d7,d8,d9,d10,d11,d12,d13,d14,d15,d16))
	--read the deck file
	f=io.open("./deck/"..deck[e:GetLabel()],"r")
	for lines in f:lines() do 
		if lines:find("side") then break end
		if tonumber(lines)~=nil then
			c=Duel.CreateToken(tp,tonumber(lines))
			Duel.SendtoDeck(c,tp,0,REASON_RULE)
		end
	end
	Duel.ShuffleDeck(tp)
	Duel.Draw(tp,5,REASON_RULE)
	local e1=Effect.CreateEffect(e:GetHandler())
	e1:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_CONTINUOUS)
	e1:SetCode(EVENT_TURN_END)
	e1:SetCountLimit(1)
	e1:SetCondition(function(e,tp,eg,ep,ev,re,r,rp)
		return Duel.GetTurnPlayer()==tp
	end)
	e1:SetOperation(function(e,tp,eg,ep,ev,re,r,rp)
		--do something during the EP
		local reset=aux.Stringid(51105015,0)
		local change_deck=aux.Stringid(51105015,1)
		local continue=aux.Stringid(51105015,2)
		local choice=Duel.SelectOption(tp,reset,change_deck,continue)
		if choice==0 then
			g=Duel.GetFieldGroup(tp,LOCATION_HAND+LOCATION_ONFIELD+LOCATION_REMOVED+LOCATION_GRAVE,0)
			Duel.SendtoDeck(g,tp,0,REASON_RULE)
			Duel.SetLP(tp,8000)
			Duel.SetLP(1-tp,8000)
			Duel.ShuffleDeck(tp)
			Duel.Draw(tp,5,REASON_RULE)		
		end
		if choice==1 then
			singleusermode(e,tp,eg,ep,ev,re,r,rp)
		end
		Duel.SkipPhase(1-tp,PHASE_MAIN1,RESET_PHASE+PHASE_END,1)
		Duel.SkipPhase(1-tp,PHASE_BATTLE,RESET_PHASE+PHASE_END,1)
	end)
	Duel.RegisterEffect(e1,tp)
end
