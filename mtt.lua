
mtt.emerge_area({x=0,y=0,z=0}, {x=32,y=32,z=32})

mtt.register("metadata check", function(callback)
    local meta = minetest.get_meta({x=0,y=0,z=0})
    meta:from_table({})

    -- set string and get int
    meta:set_string("x", "123")
    assert(meta:get_int("x") == 123)

    -- set int and get string
    meta:set_int("x", 1)
    assert(meta:get_string("x") == "1")

    -- clear and expect empty string
    meta:set_string("x", nil)
    assert(meta:get_string("x") == "")

    -- set, clear and expect empty string
    meta:set_string("x", "something")
    assert(meta:from_table({}))
    assert(meta:get_string("x") == "")

    -- set int and check returned table
    meta:set_int("x", 456)
    local t = meta:to_table()
    assert(t and t.fields and t.fields.x == "456")

    -- technic_cnc issue: set empty string and expect nil from "get"
    meta:set_string("x", "")
    assert(meta:get("x") == nil)

    -- perf test
    local t1 = minetest.get_us_time()
    local count = 1000 * 1000
    for _ = 1,count do
        meta:get("x")
    end
    local t2 = minetest.get_us_time()
    local micros = t2 - t1
    print("executed " .. count .. " iterations in " .. math.floor(micros/1000) .. " ms")

    callback()
end)