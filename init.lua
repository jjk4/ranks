-- ranks/init.lua

ranks = {}

local chat3_exists = minetest.get_modpath("chat3") ~= nil
local registered   = {}
ranks.default      = nil

-- Load mod storage
local storage = minetest.get_mod_storage()

---
--- Internal Helpers
---

-- Sicherer Fallback: Wandelt Player-Objekte garantiert in Strings um
local function get_name(name_or_obj)
    if type(name_or_obj) == "string" then
        return name_or_obj
    elseif name_or_obj and type(name_or_obj.get_player_name) == "function" then
        return name_or_obj:get_player_name()
    end
    return nil
end

---
--- API
---

-- [local function] Get colour
local function get_colour(colour)
    if type(colour) == "table" and minetest.rgba then
        return minetest.rgba(colour.r or 255, colour.g or 255, colour.b or 255, colour.a or 255)
    elseif type(colour) == "string" then
        return colour
    else
        return "#ffffff"
    end
end

-- [function] Register rank
function ranks.register(name, def)
    assert(name ~= "clear", "Invalid name \"clear\" for rank")

    registered[name] = def

    if def.default then
        ranks.default = name
    end
end

-- [function] Unregister rank
function ranks.unregister(name)
    registered[name] = nil
end

-- [function] List ranks in plain text
function ranks.list_plaintext()
    local list = {}
    for rank in pairs(registered) do
        table.insert(list, rank)
    end
    return table.concat(list, ", ")
end

-- [function] Get player rank
function ranks.get_rank(name_or_obj)
    local name = get_name(name_or_obj)
    if not name or name == "" then return nil end

    local rank = storage:get_string(name)
    if rank ~= "" and registered[rank] then
        return rank
    end
    return nil
end

-- [function] Get rank definition
function ranks.get_def(rank)
    if not rank then return nil end
    return registered[rank]
end

-- [function] Update player privileges
function ranks.update_privs(name_or_obj, trigger_name)
    local name = get_name(name_or_obj)
    if not name then return false end

    local rank = ranks.get_rank(name)
    if rank ~= nil then
        local function warn(msg)
            if msg and trigger_name and minetest.player_exists(trigger_name) then
                minetest.chat_send_player(trigger_name, minetest.colorize("red", "Warning: ")..msg)
            end
        end

        local def = registered[rank]
        if not def or not def.privs then return false end

        if def.strict_privs == true then
            local valid_privs = {}
            for p_name, p_val in pairs(def.privs) do
                -- Prüfen, ob das Privileg auf dem Server registriert ist
                if minetest.registered_privileges[p_name] then
                    valid_privs[p_name] = p_val
                else
                    minetest.log("warning", "[ranks] strict_privs: Ignoriere unbekanntes Privileg '" .. p_name .. "' für " .. name)
                end
            end
            minetest.set_player_privs(name, valid_privs)
            warn(name.."'s privileges have been reset to that of their rank (strict privileges)")
            return true
        end

        local privs = minetest.get_player_privs(name)

        if def.grant_missing == true then
            local changed = false
            for p_name, priv in pairs(def.privs) do
                if not privs[p_name] and priv == true then
                    -- Prüfen, ob das Privileg auf dem Server registriert ist
                    if minetest.registered_privileges[p_name] then
                        privs[p_name] = priv
                        changed = true
                    else
                        minetest.log("warning", "[ranks] grant_missing: Ignoriere unbekanntes Privileg '" .. p_name .. "' für " .. name)
                    end
                end
            end

            if changed then
                warn("Missing rank privileges have been granted to "..name)
            end
        end

        if def.revoke_extra == true then
            local changed = false
            for p_name in pairs(privs) do
                if not def.privs[p_name] then
                    privs[p_name] = nil
                    changed = true
                end
            end

            if changed then
                warn("Extra non-rank privileges have been revoked from "..name)
            end
        end

        local admin = (name == minetest.settings:get("name"))
        if admin then
            privs["rank"] = true
        end

        minetest.set_player_privs(name, privs)
        return true
    end
    return false
end

-- [function] Update player nametag
function ranks.update_nametag(name_or_obj)
    if not minetest.settings:get_bool("ranks.prefix_nametag", true) then
        return false
    end

    local name = get_name(name_or_obj)
    if not name then return false end

    local player = minetest.get_player_by_name(name)
    if not player then return false end

    local rank = ranks.get_rank(name)
    if rank ~= nil then
        local def    = ranks.get_def(rank)
        local colour = get_colour(def.colour)
        local prefix = def.prefix

        if prefix then
            prefix = minetest.colorize(colour, prefix).." "
        else
            prefix = ""
        end

        player:set_nametag_attributes({
            text = prefix..name,
        })
        return true
    end
    return false
end

-- [function] Set player rank
function ranks.set_rank(name_or_obj, rank)
    local name = get_name(name_or_obj)
    if not name then return false end

    if registered[rank] and minetest.player_exists(name) then
        storage:set_string(name, rank)
        ranks.update_nametag(name)
        ranks.update_privs(name)
        return true
    end
    return false
end

-- [function] Remove rank from player
function ranks.remove_rank(name_or_obj)
    local name = get_name(name_or_obj)
    if not name then return false end

    local rank = ranks.get_rank(name)
    if rank ~= nil then
        storage:set_string(name, "")

        local player = minetest.get_player_by_name(name)
        if player then
            player:set_nametag_attributes({
                text = name,
                color = "#ffffff",
            })
            local basic_privs = minetest.string_to_privs(minetest.settings:get("basic_privs") or "interact,shout")
            minetest.set_player_privs(name, basic_privs)
        end
        return true
    end
    return false
end

-- [function] Send prefixed message (if enabled)
function ranks.chat_send(name, message)
    -- Fall 1: Nachricht kommt von der Konsole oder einem ungültigen Spieler
    if not name or name == "" or not minetest.player_exists(name) then
        local display_name = (name and name ~= "") and name or "Server"
        
        if chat3_exists then
            chat3.send(display_name, message, "", "ranks")
        else
            minetest.chat_send_all("<" .. display_name .. "> " .. message)
            minetest.log("action", "CHAT: <" .. display_name .. "> " .. message)
        end
        return true
    end

    -- Fall 2: Nachricht kommt von einem echten, existierenden Spieler
    if minetest.settings:get_bool("ranks.prefix_chat", true) then
        local rank = ranks.get_rank(name)
        if rank ~= nil then
            local def = ranks.get_def(rank)
            if def and def.prefix then
                local colour = get_colour(def.colour)
                local prefix = minetest.colorize(colour, def.prefix)
                
                if chat3_exists then
                    chat3.send(name, message, prefix.." ", "ranks")
                else
                    minetest.chat_send_all(prefix.." <"..name.."> "..message)
                    minetest.log("action", "CHAT: ".."<"..name.."> "..message)
                end
                return true
            end
        end
    end
    
    return false
end

---
--- Registrations
---

-- [privilege] Rank
minetest.register_privilege("rank", {
    description = "Permission to use /rank chatcommand",
    give_to_singleplayer = false,
})

-- Assign/update rank on join player
minetest.register_on_joinplayer(function(player)
    local name = player:get_player_name()
    local db_rank = player:get_attribute("ranks:rank")
    local storage_rank = storage:get_string(name)

    -- Alte Datenbank-Einträge migrieren
    if db_rank ~= nil and storage_rank == "" then
        storage:set_string(name, db_rank)
        player:set_attribute("ranks:rank-old", db_rank)
        player:set_attribute("ranks:rank", nil)
    elseif db_rank ~= nil and storage_rank ~= "" then
        player:set_attribute("ranks:rank-old", db_rank)
        player:set_attribute("ranks:rank", nil)
    end

    if ranks.get_rank(name) then
        ranks.update_nametag(name)
        -- ranks.update_privs(name)
    else
        if ranks.default then
            -- 1. Hole die Privilegien des Spielers und die Standard-Privilegien des Servers
            local player_privs = minetest.get_player_privs(name)
            local default_privs_str = minetest.settings:get("default_privs") or "interact,shout"
            local default_privs = minetest.string_to_privs(default_privs_str)
            
            local exact_match = true
            
            -- 2. Prüfen, ob der Spieler Rechte hat, die NICHT in den default_privs stehen
            for priv_name in pairs(player_privs) do
                if not default_privs[priv_name] then
                    exact_match = false
                    break
                end
            end
            
            -- 3. Prüfen, ob dem Spieler Rechte FEHLEN, die in den default_privs stehen
            if exact_match then
                for priv_name in pairs(default_privs) do
                    if not player_privs[priv_name] then
                        exact_match = false
                        break
                    end
                end
            end
            
            -- 4. Rang nur vergeben, wenn es eine 1:1 Übereinstimmung gab
            if exact_match then
                ranks.set_rank(name, ranks.default)
            end
        end
    end
end)

-- Prefix messages if enabled
minetest.register_on_chat_message(function(name, message)
    return ranks.chat_send(name, message)
end)

-- [chatcommand] /rank
minetest.register_chatcommand("rank", {
    description = "Set a player's rank",
    params = "<player> <new rank> / \"list\" | username, rankname / list ranks",
    privs = {rank = true},
    func = function(name, param)
        local params = param:split(" ")
        if #params == 0 then
            return false, "Invalid usage (see /help rank)"
        end

        if #params == 1 and params[1] == "list" then
            return true, "Available Ranks: "..ranks.list_plaintext()
        elseif #params == 2 then
            if not minetest.player_exists(params[1]) then
                return false, "Player does not exist"
            end

            if ranks.get_def(params[2]) then
                if ranks.set_rank(params[1], params[2]) then
                    if name ~= params[1] then
                        minetest.chat_send_player(params[1], name.." set your rank to "..params[2])
                    end
                    return true, "Set "..params[1].."'s rank to "..params[2]
                else
                    return false, "Unknown error while setting "..params[1].."'s rank to "..params[2]
                end
            elseif params[2] == "clear" then
                ranks.remove_rank(params[1])
                return true, "Removed rank from "..params[1]
            else
                return false, "Invalid rank (see /rank list)"
            end
        else
            return false, "Invalid usage (see /help rank)"
        end
    end,
})

-- [chatcommand] /getrank
minetest.register_chatcommand("getrank", {
    description = "Get a player's rank. If no player is specified, your own rank is returned.",
    params = "<name> | name of player",
    func = function(name, param)
        if param and param ~= "" then
            local rank = ranks.get_rank(param)
            if rank then
                return true, "Rank of " .. param .. ": " .. rank:gsub("^%l", string.upper)
            elseif minetest.player_exists(param) then
                return false, "Rank of " .. param .. ": No rank"
            else
                return false, "Player does not exist"
            end
        else
            local rank = ranks.get_rank(name) or "No rank"
            return true, "Your rank: " .. rank:gsub("^%l", string.upper)
        end
    end,
})

---
--- Ranks
---

-- Load default ranks
dofile(minetest.get_modpath("ranks").."/ranks.lua")

local path = minetest.get_worldpath().."/ranks.lua"
if io.open(path) then
    dofile(path)
end