
globals = {
	"minetest"
}

read_globals = {
	-- Lua
	string = {fields = {"split", "trim"}},
	table = {fields = {"copy", "getn"}},

	-- Minetest
	"PseudoRandom", "ItemStack",
	"VoxelArea", "VoxelManip",
	"Settings", "vector",

	-- deps
	"monitoring", "mtt"
}
