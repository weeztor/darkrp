HelpCategories = { }
HelpLabels = { }

function AddHelpCategory(id, name)
	table.insert(HelpCategories, { id = id, name = name })
	return id
end

function ChangeHelpLabel(id, text)
	umsg.Start("ChangeHelpLabel")
		umsg.Short(id)
		umsg.String(text)
	umsg.End()

	for k, v in pairs(HelpLabels) do
		if v.id == id then
			v.text = text
			return
		end
	end
end

function AddHelpLabel(id, category, text, constant)
	table.insert(HelpLabels, { id = id, category = category, text = text, constant = (constant or 0) })
end
