local has_monitoring_mod = minetest.get_modpath("monitoring")

local hit_count = { inc = function() end }
local miss_count = { inc = function() end }

if has_monitoring_mod then
  hit_count = monitoring.counter("metadata_cache_hit", "cache hits")
  miss_count = monitoring.counter("metadata_cache_miss", "cache misses")
end

local old_get_meta = minetest.get_meta

-- pos-hash -> meta-proxy
local cache = {}

local function purge_cache()
    cache = {}
    minetest.after(60, purge_cache)
end

minetest.after(60, purge_cache)

local function create_getter(meta, accessor, value_cache)
    return function(_, key)
        local v = value_cache[key]
        if v == nil then
            v = accessor(meta, key)
            value_cache[key] = v
            miss_count.inc()
        else
            hit_count.inc()
        end
        return v
    end
end

local function create_setter(meta, accessor, value_cache)
    return function(_, key, value)
        accessor(meta, key, value)
        value_cache[key] = value
    end
end

local function create_meta_proxy(pos)
    local meta = old_get_meta(pos)
    local data = {}

    return {
        get = create_getter(meta, meta.get_string, data),
        get_string = create_getter(meta, meta.get_string, data),
        set_string = create_setter(meta, meta.set_string, data),
        get_int = create_getter(meta, meta.get_int, data),
        set_int = create_setter(meta, meta.set_int, data),
        get_float = create_getter(meta, meta.get_float, data),
        set_float = create_setter(meta, meta.set_float, data),
        contains = function(key)
            if data[key] then
                return true
            end
            return meta:contains(key)
        end,
        to_table = function()
            return meta:to_table()
        end,
        from_table = function(_, t)
            meta:from_table(t)
            data = {}
        end,
        get_inventory = function()
            return meta:get_inventory()
        end,
        mark_as_private = function(_, key)
            meta:mark_as_private(key)
        end,
        equals = function(other)
            return meta:equals(other)
        end
    }
end

function minetest.get_meta(pos)
    local hash = minetest.hash_node_position(pos)

    if not cache[hash] then
        cache[hash] = create_meta_proxy(pos)
    end

    return cache[hash]
end

local MP = minetest.get_modpath("metadata_cache")
if minetest.get_modpath("mtt") then
    dofile(MP .. "/mtt.lua")
end