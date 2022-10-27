
Simple write-through cache for `minetest.get_meta`

Features:
* caches reads from `minetest.get_meta`
* exposes metrics for hit- and miss-stats
* cache is purged periodically (no LRU or other shenanigans)
