
mtt.emerge_area({x=0,y=0,z=0}, {x=32,y=32,z=32})

mtt.register("metadata check", function(callback)
    local meta = minetest.get_meta({x=0,y=0,z=0})
    meta:from_table({})

    -- set string and get int
    meta:set_string("x", "123")
    print(dump(meta:get_int("x")))
    assert(meta:get_int("x") == 123)
end)