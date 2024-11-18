afk_indicator.last_updates = {}
local _lu = afk_indicator.last_updates
local time = os.time

function afk_indicator.update(name)
	if minetest.get_player_ip(name) then -- Ensure the player is online
		_lu[name] = time()
	end
end

function afk_indicator.delete(name)
	_lu[name] = nil
end

function afk_indicator.get(name)
	local entry = _lu[name]
	if not entry then return false end
	local now = time()
	return now - entry
end

function afk_indicator.get_all()
	local now = time()
	local rt = {}
	for x,y in pairs(_lu) do
		rt[x] = now - y
	end
	return rt
end

function afk_indicator.get_all_longer_than(p)
	local now = time()
	local rt = {}
	for x,y in pairs(_lu) do
		if (now - y) >= p then
			rt[x] = now - y
		end
	end
	return rt
end


