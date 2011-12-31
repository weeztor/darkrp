local Vote = {}
local Votes = {}
vote = { }

local function ccDoVote(ply, cmd, args)
	if not Votes[args[1]] then return end
	if not Votes[args[1]][tonumber(args[2])] then return end
	
	-- If the player has never voted for anything then he doesn't have a table of things he has voted for. so create it.
	ply.VotesVoted = ply.VotesVoted or {}
	
	if ply:GetTable().VotesVoted[args[1]] then
		Notify(ply, 1, 4, "You cannot vote!")
		return
	end
	ply:GetTable().VotesVoted[args[1]] = true

	Votes[args[1]]:HandleNewVote(ply, tonumber(args[2]))
end
concommand.Add("vote", ccDoVote)

function Vote:HandleNewVote(ply, id)
	self[id] = self[id] + 1

	if (self[1] + self[2] >= (#player.GetAll() - 1) and not self.special) or (self.special and self[1] + self[2] >= (#player.GetAll() - 2)) then
		vote.HandleVoteEnd(self.ID)
	end
end

function vote:Create(question, voteid, ent, delay, callback, special)
	if #player.GetAll() == 1 then
		Notify(ent, 0, 4, LANGUAGE.vote_alone)
		callback(1, ent)
		return
	end
	
	if special and #player.GetAll() <= 2 then
		Notify(ent, 0, 4, LANGUAGE.vote_alone)
		callback(1, ent)
		return
	end 
	
	-- If the player has never voted for anything then he doesn't have a table of things he has voted for. So create it.
	if not ent:GetTable().VotesVoted then
		ent:GetTable().VotesVoted = {}
	end
	
	ent:GetTable().VotesVoted[voteid] = true
	local newvote = { }
	for k, v in pairs(Vote) do newvote[k] = v end

	newvote.ID = voteid
	newvote.Callback = callback
	newvote.Ent = ent
	newvote.special = special
	

	newvote[1] = 0
	newvote[2] = 0

	Votes[voteid] = newvote
	if ent:IsPlayer() then
		Notify(ent,1,4, LANGUAGE.vote_started)
	end
	umsg.Start("DoVote")
		umsg.String(question)
		umsg.String(voteid)
		umsg.Float(delay)
	umsg.End()

	timer.Create(voteid .. "timer", delay, 1, vote.HandleVoteEnd, voteid)
end

function vote.DestroyVotesWithEnt(ent)
	for k, v in pairs(Votes) do
		if v.Ent == ent then
			timer.Destroy(v.ID .. "timer")
			umsg.Start("KillVoteVGUI")
				umsg.String(v.ID)
			umsg.End()
			for a, b in pairs(player.GetAll()) do
				b.VotesVoted = b.VotesVoted or {}
				b.VotesVoted[v.ID] = nil
			end

			Votes[k] = nil
		end
	end
end

function vote.HandleVoteEnd(id, OnePlayer)
	if not Votes[id] then return end

	local choice = 1

	if Votes[id][2] >= Votes[id][1] then choice = 2 end

	Votes[id].Callback(choice, Votes[id].Ent)
	
	for a, b in pairs(player.GetAll()) do
		if not b:GetTable().VotesVoted then
			b:GetTable().VotesVoted = {}
		end
		b:GetTable().VotesVoted[id] = nil
	end
	umsg.Start("KillVoteVGUI")
		umsg.String(id)
	umsg.End()

	Votes[id] = nil
end

-- Eusion's vote handler; note this is not related to DarkRP votes, the system is different. Please report any bugs; I haven't tested extensively.
local Trades = {}
function vote:Trade(id, client, recipient, trade)
	Trades[id] = {["client"] = client, ["recipient"] = recipient, ["votes"] = 0, ["trade"] = trade}
	timer.Create("TVC_" .. id, 20, 1, HandleTrade, id)
	umsg.Start("darkrp_treq", recipient)
		umsg.Short(id)
		umsg.Entity(client)
		umsg.Entity(trade)
	umsg.End()
end

function HandleTrade(id)
	if not Trades[id] then return end
	if not ValidEntity(Trades[id].client) then return end
	if not ValidEntity(Trades[id].recipient) then return end
	if not ValidEntity(Trades[id].trade) then return end
	if Trades[id].votes > 0 then
		Notify(Trades[id].client, 2, 4, "Recipient accepted the trade request.")
		local rf = RecipientFilter()
		rf:AddPlayer(Trades[id].client)
		rf:AddPlayer(Trades[id].recipient)
		umsg.Start("darkrp_trade", rf)
			umsg.Entity(Trades[id].client) -- Client making the trade
			umsg.Entity(Trades[id].recipient) -- Recipient recieving the request
			umsg.Entity(Trades[id].trade) -- The entity being traded
			umsg.Short(id) -- The trade ID so the trade can be killed client-side.
		umsg.End()
		-- Empty the table to make sure the vote can't be repeated (extra security).
		Trades[id] = {}
		table.remove(Trades, id)
	else
		Notify(Trades[id].client, 1, 4, "Recipient declined this trade request.")
		-- Empty the table to make sure the vote can't be repeated (extra security).
		Trades[id] = {}
		table.remove(Trades, id)
	end
end

concommand.Add("rp_tradevote", function(ply, cmd, args)
	local id = tonumber(args[1])
	local vote = args[2]
	if not Trades[id] then return end
	if Trades[id].recipient == ply then
		if vote == "yes" then
			Trades[id].votes = tonumber(Trades[id].votes) + 1
			timer.Destroy("TVC_" .. id)
			HandleTrade(id)
		elseif vote == "no" then
			timer.Destroy("TVC_" .. id)
			HandleTrade(id)
		end
	end
end)