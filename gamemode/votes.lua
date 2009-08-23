local Vote = {}
local Votes = {}
vote = { }

function ccDoVote(ply, cmd, args)
	if not Votes[args[1]] then return end
	if not Votes[args[1]][tonumber(args[2])] then return end
	
	-- If the player has never voted for anything then he doesn't have a table of things he has voted for. so create it.
	if not ply:GetTable().VotesVoted then
		ply:GetTable().VotesVoted = {}
	end
	
	if ply:GetTable().VotesVoted[args[1]] then
		Notify(ply, 1, 4, "You can not vote!")
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
		Notify(ent, 1, 4, "You have won the vote since you are alone in the server.")
		callback(1, ent)
		return
	end
	
	if special and #player.GetAll() <= 2 then
		Notify(ent, 1, 4, "You have won the vote since you are alone in the server.")
		callback(1, ent)
		return
	end 
	
	-- If the player has never voted for anything then he doesn't have a table of things he has voted for. so create it.
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
		Notify(ent,1,4, "The vote is created")
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
			umsg.Start("KillVoteVGUI")
				umsg.String(v.ID)
			umsg.End()
			for a, b in pairs(player.GetAll()) do
				b:GetTable().VotesVoted[v.ID] = nil
			end

			Votes[k] = nil
			VoteCopOn = false
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
