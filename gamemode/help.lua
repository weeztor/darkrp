HelpCategories = { }
HelpLabels = { }

function AddHelpCategory(id, name)
	table.insert(HelpCategories, {id = id, name = name})
	return id
end

function AddHelpLabel(id, category, text, constant)
	table.insert(HelpLabels, {id = id, category = category, text = text, constant = (constant or 0)})
end