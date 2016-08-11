name = "Telewarper Staff"
description = "The Telewarper Staff allows you to warp craftable structures into your inventory without destroying them!"
author = "tiagoddinis"
version = "2.2"

forumthread = ""

dst_compatible = true

api_version = 10

icon_atlas = "modicon.xml"
icon = "modicon.tex"

configuration_options =
{
	-- Durability
    {name = "durability", 
	label = "Staff Durability",
	hover = "Set the Telewarper Staff durability",
	options =
	{
		{description = "999 Uses", data = 999},
		{description = "100 Uses", data = 100},
		{description = "50 Uses", data = 50},
		{description = "25 Uses", data = 25},
		{description = "20 Uses", data = 20},
		{description = "15 Uses", data = 15},
		{description = "10 Uses", data = 10},
		{description = "5 Uses", data = 5},
	},
	default = 999,},

	-- Sanity penalty
    {name = "sanitypenalty", 
	label = "Sanity penalty",
	hover = "Set the Telewarper Staff sanity penalty per action",
	options =
	{
		{description = "No penalty", data = 0},
		{description = "- 1", data = -1},
		{description = "- 2", data = -2},
		{description = "- 3", data = -3},
		{description = "- 4", data = -4},
		{description = "- 5", data = -5},
		{description = "- 10", data = -10},
		{description = "- 25", data = -25},
		{description = "- 50", data = -50},
	},
	default = 0,},

	-- Recipe difficulty
    {name = "recipedifficulty", 
	label = "Staff Recipe",
	hover = "Choose ingredients required to craft the Staff",
	options =
	{
		{description = "Easy", data = "easy", hover = "(1)Spear + (1)Blue Gem + (1)Purple Gem"},
    	{description = "Medium", data = "medium", hover = "(2)Living Log + (1)Blue Gem + (1)Telelocator Staff"},
		{description = "Hard", data = "hard", hover = "(2)Living Log + (1)Deconstruction Staff + (1)Telelocator Staff"},
	},
	default = "easy",},
}