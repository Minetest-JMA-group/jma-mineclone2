day_coin_vote = {}

day_coin_vote.yes_votes = 0
day_coin_vote.no_votes = 0
day_coin_vote.players_who_voted = {}
day_coin_vote.days_on_which_voting_took_place = {}
day_coin_vote.has_already_taken_place = false

day_coin_vote.morning_time = 0.22916--~5:30
day_coin_vote.evening_time = 0.75--18:00

function day_coin_vote.start_the_morning()
    minetest.set_timeofday(day_coin_vote.morning_time)
end

local function table_contains(tbl, value)
    for _, v in ipairs(tbl) do
        if v == value then
            return true
        end
    end
    return false
end

function day_coin_vote.start_vote()
    if day_coin_vote.yes_votes == 0 and day_coin_vote.no_votes == 0 then
        minetest.after(60, function()
            if day_coin_vote.yes_votes > day_coin_vote.no_votes then
                day_coin_vote.start_the_morning()
                minetest.chat_send_all("The night was skipped with " .. day_coin_vote.yes_votes .. " votes in favor and " .. day_coin_vote.no_votes .. " against.")
                day_coin_vote.has_already_taken_place = false
            else
                minetest.chat_send_all("The night wasn't skipped with " .. day_coin_vote.yes_votes .. " votes in favor and " .. day_coin_vote.no_votes .. " against.")
                day_coin_vote.has_already_taken_place = true
            end
            day_coin_vote.yes_votes = 0
            day_coin_vote.no_votes = 0
            day_coin_vote.players_who_voted = {}
            local current_day = minetest.get_day_count()
            table.insert(day_coin_vote.days_on_which_voting_took_place, current_day)
        end)
    end
end

minetest.register_craftitem("day_coin_vote:vote_coin", {
    description = "Vote Coin",
    inventory_image = "day_vote_coin.png",
    on_use = function(itemstack, user)
        local player_name = user:get_player_name()
        local time_of_day = minetest.get_timeofday()
        local current_day = minetest.get_day_count()
        if table_contains(day_coin_vote.days_on_which_voting_took_place, current_day) then
            minetest.chat_send_player(player_name, "A vote has already taken place today.")
        else
            if time_of_day <= day_coin_vote.morning_time or time_of_day >= day_coin_vote.evening_time then
                minetest.show_formspec(player_name, "day_coin_vote:day_vote_formspec", day_coin_vote.get_day_vote_formspec())
            else
                minetest.chat_send_player(player_name, "You can only vote at night.")
            end
        end
    end,
    stack_max = 64,
})

function day_coin_vote.get_day_vote_formspec()
    local day_vote_formspec = "size[4,3]"

    day_vote_formspec = day_vote_formspec .. "label[0,0;Day Vote!]"
    day_vote_formspec = day_vote_formspec .. "button_exit[1,2.5;2,1;exit;Exit]"

    day_vote_formspec = day_vote_formspec .. "button[0,1;2,1;day_vote_yes;Yes]"
    day_vote_formspec = day_vote_formspec .. "label[0.84,0.6;" .. day_coin_vote.yes_votes .. "]"

    day_vote_formspec = day_vote_formspec .. "button[2,1;2,1;day_vote_no;No]"
    day_vote_formspec = day_vote_formspec .. "label[2.8,0.6;" .. day_coin_vote.no_votes .. "]"

    return day_vote_formspec
end

minetest.register_on_player_receive_fields(function(player, formname, fields)
    local player_name = player:get_player_name()
    if formname == "day_coin_vote:day_vote_formspec" then
        if fields.day_vote_yes then
            minetest.show_formspec(player_name, "", "")
            day_coin_vote.start_vote()
            if not day_coin_vote.players_who_voted[player_name] then
                day_coin_vote.yes_votes = day_coin_vote.yes_votes + 1
                day_coin_vote.players_who_voted[player_name] = true
                player:get_inventory():remove_item("main", "day_coin_vote:vote_coin")
                minetest.chat_send_all(player_name .. " voted to skip the night.")
            else
                minetest.chat_send_player(player_name, "You have already voted.")
            end
        end

        if fields.day_vote_no then
            minetest.show_formspec(player_name, "", "")
            day_coin_vote.start_vote()
            if not day_coin_vote.players_who_voted[player_name] then
                day_coin_vote.no_votes = day_coin_vote.no_votes + 1
                day_coin_vote.players_who_voted[player_name] = true
                player:get_inventory():remove_item("main", "day_coin_vote:vote_coin")
                minetest.chat_send_all(player_name .. " voted to don't skip the night.")
            else
                minetest.chat_send_player(player_name, "You have already voted.")
            end
        end
    end
end)
