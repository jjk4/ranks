-- ranks/ranks.lua

-- =========================================
-- SPIELER
-- =========================================
ranks.register("spieler", {
    prefix = "Spieler",
    colour = {a = 255, r = 200, g = 200, b = 200}, -- Hellgrau
    default = true, -- Macht diesen Rang zum Standard für neue Spieler
    strict_privs = true,
    privs = {
        interact = true,
        shout = true,
        
        -- ess.warp & home
        ["ess.warp.warp"] = true,
        home = true,
    }
})

-- =========================================
-- SUPPORTER
-- =========================================
ranks.register("supporter", {
    prefix = "Supporter",
    colour = {a = 255, r = 230, g = 126, b = 34}, -- Orange
    strict_privs = true,
    privs = {
        -- Builtin
        bring = true,
        fast = true,
        fly = true,
        interact = true,
        kick = true,
        shout = true,
        teleport = true,
        
        -- areas
        areas_high_limit = true,
        
        -- ess.player & ess.teleport
        ["ess.player.afk"] = true,
        ["ess.teleport"] = true,
        ["ess.teleport.back"] = true,
        ["ess.teleport.top"] = true,
        ["ess.teleport.tpa"] = true,
        ["ess.teleport.tpahere"] = true,
        
        -- ess.warp & home
        ["ess.warp.warp"] = true,
        home = true,
    }
})

-- =========================================
-- MODERATOR
-- =========================================
ranks.register("moderator", {
    prefix = "Moderator",
    colour = {a = 255, r = 46, g = 204, b = 113}, -- Grün
    strict_privs = true,
    privs = {
        -- Builtin
        ban = true,
        basic_privs = true,
        bring = true,
        fast = true,
        fly = true,
        give = true,
        interact = true,
        kick = true,
        noclip = true,
        protection_bypass = true,
        settime = true,
        shout = true,
        teleport = true,
        
        -- Weitere Module
        announce = true,
        areas = true,
        areas_high_limit = true,
        help_reveal = true,
        
        -- ess.player & ess.teleport
        ["ess.player.afk"] = true,
        ["ess.player.god"] = true,
        ["ess.player.heal"] = true,
        ["ess.player.whois"] = true,
        ["ess.teleport"] = true,
        ["ess.teleport.back"] = true,
        ["ess.teleport.top"] = true,
        ["ess.teleport.tpa"] = true,
        ["ess.teleport.tpahere"] = true,
        
        -- ess.warp & home
        ["ess.warp.delwarp"] = true,
        ["ess.warp.setwarp"] = true,
        ["ess.warp.warp"] = true,
        home = true,
        ["home.all"] = true,
        ["home.multiple"] = true,
        
        -- Sonstige
        invisible = true,
        invmanage = true,
        travelnet_attach = true,
        travelnet_remove = true,
    }
})

-- =========================================
-- ADMIN
-- =========================================
ranks.register("admin", {
    prefix = "Admin",
    colour = {a = 255, r = 241, g = 196, b = 15}, -- Gelb
    strict_privs = true,
    privs = {
        -- Builtin
        ban = true,
        basic_privs = true,
        bring = true,
        debug = true,
        fast = true,
        fly = true,
        give = true,
        interact = true,
        kick = true,
        noclip = true,
        password = true,
        privs = true,
        protection_bypass = true,
        rollback = true,
        server = true,
        settime = true,
        shout = true,
        teleport = true,
        
        -- Weitere Module
        announce = true,
        areas = true,
        areas_high_limit = true,
        help_reveal = true,
        
        -- ess Kategorien
        ["ess.all"] = true,
        ["ess.kits.all"] = true,
        ["ess.kits.create"] = true,
        ["ess.kits.kits"] = true,
        ["ess.kits.kits.all"] = true,
        ["ess.kits.other"] = true,
        
        -- ess.player
        ["ess.player.afk"] = true,
        ["ess.player.all"] = true,
        ["ess.player.god"] = true,
        ["ess.player.heal"] = true,
        ["ess.player.heal.other"] = true,
        ["ess.player.whois"] = true,
        
        -- ess.teleport
        ["ess.teleport"] = true,
        ["ess.teleport.all"] = true,
        ["ess.teleport.back"] = true,
        ["ess.teleport.top"] = true,
        ["ess.teleport.tpa"] = true,
        ["ess.teleport.tpahere"] = true,
        
        -- ess.tools
        ["ess.tools.all"] = true,
        ["ess.tools.repair"] = true,
        ["ess.tools.repair.other"] = true,
        ["ess.tools.repairall"] = true,
        ["ess.tools.repairall.other"] = true,
        
        -- ess.warp & home
        ["ess.warp.all"] = true,
        ["ess.warp.delwarp"] = true,
        ["ess.warp.other"] = true,
        ["ess.warp.setwarp"] = true,
        ["ess.warp.warp"] = true,
        ["ess.warp.warp.all"] = true,
        home = true,
        ["home.all"] = true,
        ["home.all.all"] = true,
        ["home.multiple"] = true,
        ["home.multiple.all"] = true,
        
        -- Sonstige
        invisible = true,
        invmanage = true,
        maphack = true,
        no_regional_difficulty = true,
        travelnet_attach = true,
        travelnet_remove = true,
        waypoints_tp = true,
        weather_manager = true,
        worldedit = true,
		rank = true,
    }
})