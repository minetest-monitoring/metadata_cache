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

local function create_getter(meta, getter, value_cache, expected_type)
    return function(_, key)
        local v = value_cache[key]
        if v == nil or type(v) ~= expected_type then
            v = getter(meta, key)
            value_cache[key] = v
            miss_count.inc()
        else
            hit_count.inc()
        end
        return v
    end
end

local function create_setter(meta, setter, getter, value_cache)
    return function(_, key, value)
        setter(meta, key, value)
        if value == "" then
            -- clear data
            value_cache[key] = nil
        else
            -- read back from engine
            value_cache[key] = getter(meta, key)
        end
    end
end

local function create_meta_proxy(pos)
    local meta = old_get_meta(pos)
    local data = {}

    return {
        get = create_getter(meta, meta.get, data, "string"),
        get_string = create_getter(meta, meta.get_string, data, "string"),
        set_string = create_setter(meta, meta.set_string, meta.get_string, data),
        get_int = create_getter(meta, meta.get_int, data, "number"),
        set_int = create_setter(meta, meta.set_int, meta.get_int, data),
        get_float = create_getter(meta, meta.get_float, data, "number"),
        set_float = create_setter(meta, meta.set_float, meta.get_float, data),
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
            -- invalidate all entries
            for k in pairs(data) do
                data[k] = nil
            end
            return meta:from_table(t)
        end,
        get_inventory = function()
            return meta:get_inventory()
        end,
        mark_as_private = function(_, key)
            return meta:mark_as_private(key)
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
