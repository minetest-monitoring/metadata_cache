local MP = minetest.get_modpath("metadata_cache")
dofile(MP .. "/cache.lua")

if minetest.get_modpath("mtt") then
    dofile(MP .. "/mtt.lua")
end