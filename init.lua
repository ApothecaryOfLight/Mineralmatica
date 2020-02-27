local function retFormspec( progress_percent )
	return "size[8,9;]"..
	"list[context;in;2,3;1,1;]"..
	"list[context;out;5,3;1,1;]"..
	"image[3.75,1.5;1,1;gui_furnace_arrow_bg.png^[lowpart:"..
	(progress_percent)..":gui_furnace_arrow_fg.png^[transformR270]"..
	"list[current_player;main;0,5;8,4;]"
end

minetest.register_node("mineralmatica:manual_duster", {
	description = "Manual Duster",
	drawtype = "nodebox",
	node_box = { type="regular" },
	selection_box = nil,
	paramtype = "light",
	groups = { cracky = 3; choppy = 1; punch_operable = 1 },
	tiles = {
		"mineralmatica_machine_manual_duster_side.png"
	},
	after_place_node = function( pos, placer, itemstack, pointed_thing )
		print( "[mineralmatica] Initializing new duster!" )
		local meta = minetest.get_meta( pos )
		meta:set_int( "progress", 0 )

		local inv = meta:get_inventory()
		inv:set_size( 'in', 1 )
		inv:set_size( 'out', 1 )

		meta:set_string( "formspec", retFormspec( 0 ) )
		return false -- tells the caller that the object has been placed
	end,
	on_punch = function( pos, node, player, pointed_thing )
		print("Punched!")
		--local myMeta = minetest.get_meta(pos)
		local meta = minetest.get_meta( pos )
		local inv = meta:get_inventory()
		local invIn = inv:get_list("in")
		print(dump(getmetatable(inv)))
		local myStack = inv:get_stack("in",1)
		print(dump(getmetatable(myStack)))
		local myItem = myStack:to_table()
		print("myItem:")
		print(dump(myItem))
		if myItem ~= nil then
			if myItem.name == "default:copper_lump" then
				print("Copper!")
				local progress = meta:get_int( "progress" )
				if progress < 100 then --if it isn't dusted, work it some more
					progress = progress+10
					meta:set_string( "formspec", retFormspec( progress ) )
					meta:set_int( "progress", progress )
				else --since its complete, turn it into dust
					inv:remove_item( "in", ItemStack("default:copper_lump") )
					inv:add_item( "out", ItemStack("mineralmatica:copper_dust 2") )
					meta:set_int( "progress", 0 )
					meta:set_string( "formspec", retFormspec(0) )
				end
			end
			if myItem.name == "mineralmatica:nickel_lump" then
				print("Nickel!")
				local progress = meta:get_int( "progress" )
				if progress < 100 then --if it isn't dusted, work it some more
					progress = progress+10
					meta:set_string( "formspec", retFormspec( progress ) )
					meta:set_int( "progress", progress )
				else --since its complete, turn it into dust
					inv:remove_item( "in", ItemStack("mineralmatica:nickel_lump") )
					inv:add_item( "out", ItemStack("mineralmatica:nickel_dust 2") )
					meta:set_int( "progress", 0 )
					meta:set_string( "formspec", retFormspec(0) )
				end
			end
			if myItem.name == "default:tin_lump" then
				print("Tin!")
				local progress = meta:get_int( "progress" )
				if progress < 100 then --if it isn't dusted, work it some more
					progress = progress+10
					meta:set_string( "formspec", retFormspec( progress ) )
					meta:set_int( "progress", progress )
				else --since its complete, turn it into dust
					inv:remove_item( "in", ItemStack("default:tin_lump") )
					inv:add_item( "out", ItemStack("mineralmatica:tin_dust 2") )
					meta:set_int( "progress", 0 )
					meta:set_string( "formspec", retFormspec(0) )
				end
			end
			if myItem.name == "default:iron_lump" then
				print("Iron!")
				local progress = meta:get_int( "progress" )
				if progress < 100 then --if it isn't dusted, work it some more
					progress = progress+10
					meta:set_string( "formspec", retFormspec( progress ) )
					meta:set_int( "progress", progress )
				else --since its complete, turn it into dust
					inv:remove_item( "in", ItemStack("default:iron_lump") )
					inv:add_item( "out", ItemStack("mineralmatica:iron_dust 2") )
					meta:set_int( "progress", 0 )
					meta:set_string( "formspec", retFormspec(0) )
				end
			end
		end
	end,
	on_metadata_inventory_put = function( pos )
		print( "Inventory used!" )
	end,
	on_metadata_inventory_move = function( pos )
		print( "Inventory item moved!" )
	end,
	allow_metadata_inventory_put = function( pos, listname, index, stack, player )
		print( "\n\nAllow inventory put?" )
		if minetest.is_protected(pos, player:get_player_name()) then
			print( "Protected!")
			return 0
		end
		local meta = minetest.get_meta(pos)
		local inv = meta:get_inventory()
		if listname == "in" then
			print("in")
		elseif listname == "out" then
			print("out")
			return 0
		end
		local myStack = stack:to_table()
		print( myStack.name )
		if myStack.name == "default:copper_lump" or
			myStack.name == "default:tin_lump" or
			myStack.name == "default:iron_lump" or
			myStack.name == "mineralmatica:nickel_lump" then
			print( "Allowing!")
			return stack:get_count()
		end
		print( "Rejecting!" )
		return 0
	end,
	allow_metadata_inventory_move = function( pos, from_list, from_index, to_list, to_index, count, player )
		print( "Allow inventory move?" )
		if minetest.is_protected( pos, player:get_player_name())  then
			return 0
		end
		local meta = minetest.get_meta( pos )
		local inv = meta:get_inventory()
		local stack = inv:get_stack( from_list, from_index )
		return stack:get_count()
	end
})

--Manual Duster
minetest.register_craft({
	output = "mineralmatica:manual_duster",
	recipe = {
		{"group:stone", "group:stone", "group:stone"},
		{"group:stone", "group:stone", "group:stone"},
		{"", "group:stone", ""},
	}
})

--Lava-forge (Has a small pool of lava in a basin, will eventually consume the lava after a certain # of ticks)
--[[
4x5x4
1st layer:
Lava Forge Block		Lava Forge Block		Lava Forge Block		Lava Forge Block
Lava Forge Block		Lava Forge Block		Lava Forge Block		Lava Forge Block
Lava Forge Block		Lava Forge Block		Lava Forge Block		Lava Forge Block
Lava Forge Block		Lava Forge Block		Lava Forge Block		Lava Forge Block

2nd layer
Lava Forge Block		Lava Forge Block		Lava Forge Block		Lava Forge Block
Lava Forge Block								Lava Forge Block
Lava Forge Block								Lava Forge Block
Lava Forge Block		Lava Forge Block		Lava Forge Block		Lava Forge Block

3rd layer
Lava Forge Block		Lava Forge Block		Lava Forge Block		Lava Forge Block
Lava Forge Block								Lava Forge Block
Lava Forge Block								Lava Forge Block

4th layer
			Lava Forge Block		Lava Forge Block

1 =
2
3
4
]]--
--[[
local mySchematics = {
	"lava_forge" = {
		1 = {
			{ "mineralmatica:lava_forge_block", "mineralmatica:lava_forge_block", "mineralmatica:lava_forge_block", "mineralmatica:lava_forge_block" },
			{ "mineralmatica:lava_forge_block", "mineralmatica:lava_forge_block", "mineralmatica:lava_forge_block", "mineralmatica:lava_forge_block" },
			{ "mineralmatica:lava_forge_block", "mineralmatica:lava_forge_block", "mineralmatica:lava_forge_block", "mineralmatica:lava_forge_block" },
			{ "mineralmatica:lava_forge_block", "mineralmatica:lava_forge_block", "mineralmatica:lava_forge_block", "mineralmatica:lava_forge_block" },
		},
		2 = {

		},
		3 = {

		},
		4 = {

		},
	}
}
--]]
local function doCheckForMultiblock( inBlockName, inSchematicName )
--[[
	First we're going to do framing. Edges are not just clues, but guarantees.
	So we use framing. Simple checks there.
	Framing will give us rotation, rather than simple brute force testing for it.
	Corners will be easy to establish during the framing, if they don't fit, ah-quit!
	Next we're going to enumerate from bottom to top.

	local framingWallNegX = -(max_x_size*2)
	local framingWallNegY = -(max_y_size*2)
	local framingWallNegZ = -(max_z_size*2)
	while framingWallNegX == not_colliding do
		framingWallNegX ++
	end
	repeat for Y and Z
	get the schematics
	find the biggest/smallest value of the frame
	find the biggest/smallest/matching value of the schematic
	match them and so on (so if the biggest is 8 and X in is 8 but Z in is 8, then its rotated 90 degrees)
	if they don't match, failure
	this allows you to derive the rotation

	once you have the corners and rotation, test against the schematic
	the schematics should be stored with their rotations,
	so no math is necessary, just a teensy bit of lookup,
	the rotations will all happen when the schematics are added to the index
]]--
end

minetest.register_node("mineralmatica:lava_forge_block", {
	description = "Lava Forge Block",
	drawtype = "nodebox",
	node_box = { type="regular" },
	selection_box = nil,
	paramtype = "light",
	groups = { cracky = 3; choppy = 1; punch_operable = 1 },
	tiles = {
		"mineralmatica_machine_manual_duster_side.png"
	},
	after_place_node = function( pos, placer, itemstack, pointed_thing )
		print( "[mineralmatica] Alloy forge" )
		print( "Checking for multiblock!" )
		local meta = minetest.get_meta( pos )
		local positions = {
			{ -1, 0, 0 },
			{ 1, 0, 0 },
			{ 0, -1, 0 },
			{ 0, 1, 0 },
			{ 0, 0, -1 },
			{ 0, 0, 1 },
		}
		print( "[mineralmatica] Checking for adjacent blocks." )
		for pos in positions do
			local adjacentBlock = minetest.get_node( pos )
			if adjacentBlock.name == "mineralmatica:lava_forge_block" then
				print( "[mineralmatica] Adjacent block found." )
				minetestdoCheckforMultibloock( "mineralmatica:lava_forge_block", "lava_forge" )
			end
		end
		print( "[mineralmatica] None found." )
		return false -- tells the caller that the object has been placed
	end,
	on_punch = function( pos, node, player, pointed_thing )
		print("Punched!")

	end,
})

--Alloy Forge (Requires Lava, mostly for low-resource bronze)

--==========================
--Copper 3rd lowest tool/armor set. Basic items and first machine casing.
--==========================
--Dust
minetest.register_craftitem( "mineralmatica:copper_dust", {
	description = "Copper Dust",
	groups = { ore_dust = 1 },
	inventory_image = "mineralmatica_base_dust.png^[colorize:#00FF00:50"
})
--Ingot
minetest.register_craft({
	type = "cooking",
	output = "default:copper_ingot",
	recipe = "mineralmatica:copper_dust",
})



--==========================
--Tin
--==========================
--Ore
minetest.register_node("mineralmatica:stone_with_tin", {
	description = "Tin Ore",
	tiles = {"default_stone.png^(mineralmatica_base_mineral_b.png^[colorize:#FF0000:50)"},
	groups = {cracky = 2},
	drop = "mineralmatica:tin_lump",
	sounds = default.node_sound_stone_defaults(),
})
minetest.register_ore({
	ore_type       = "scatter",
	ore            = "mineralmatica:stone_with_tin",
	wherein        = "default:stone",
	clust_scarcity = 9 * 9 * 9,
	clust_num_ores = 12,
	clust_size     = 3,
	y_max          = 31000,
	y_min          = 1025,
})
minetest.register_ore({
	ore_type       = "scatter",
	ore            = "mineralmatica:stone_with_tin",
	wherein        = "default:stone",
	clust_scarcity = 7 * 7 * 7,
	clust_num_ores = 5,
	clust_size     = 3,
	y_max          = 0,
	y_min          = -31000,
})
minetest.register_ore({
	ore_type       = "scatter",
	ore            = "mineralmatica:stone_with_tin",
	wherein        = "default:stone",
	clust_scarcity = 24 * 24 * 24,
	clust_num_ores = 27,
	clust_size     = 6,
	y_max          = -64,
	y_min          = -31000,
})
--Lump
minetest.register_craftitem("mineralmatica:tin_lump", {
	description = "Tin Lump",
	inventory_image = "mineralmatica_base_lump.png^[colorize:#0000FF:50",
})
--Dust
minetest.register_craftitem( "mineralmatica:tin_dust", {
	description = "Tin Dust",
	groups = { ore_dust = 1 },
	inventory_image = "mineralmatica_base_dust.png^[colorize:#0000FF:50"
})
--Ingot
minetest.register_craft({
	type = "cooking",
	output = "mineralmatica:tin_ingot",
	recipe = "mineralmatica:tin_dust",
})
minetest.register_craft({
	type = "cooking",
	output = "mineralmatica:tin_ingot",
	recipe = "mineralmatica:tin_lump",
})


--==========================
--Iron
--==========================
--Dust
minetest.register_craftitem( "mineralmatica:iron_dust", {
	description = "Iron Dust",
	groups = { ore_dust = 1 },
	inventory_image = "mineralmatica_base_dust.png^[colorize:#B7410E:50"
})
--Ingot
minetest.register_craftitem( "mineralmatica:iron_ingot", {
	description = "Iron Ingot",
	groups = { ore_nugget = 1 },
	inventory_image = "mineralmatica_base_ingot.png^[colorize:#3D4849:50"
})
minetest.register_craft({
	type = "cooking",
	output = "mineralmatica:iron_ingot",
	recipe = "mineralmatica:iron_dust",
})

--==========================
--Lead
--==========================
--Ore
minetest.register_node("mineralmatica:stone_with_lead", {
	description = "Lead Ore",
	tiles = {"default_stone.png^(mineralmatica_base_mineral_b.png^[colorize:#FF0000:50)"},
	groups = {cracky = 2},
	drop = "mineralmatica:lead_lump",
	sounds = default.node_sound_stone_defaults(),
})
minetest.register_ore({
	ore_type       = "scatter",
	ore            = "mineralmatica:stone_with_lead",
	wherein        = "default:stone",
	clust_scarcity = 9 * 9 * 9,
	clust_num_ores = 12,
	clust_size     = 3,
	y_max          = 31000,
	y_min          = 1025,
})
minetest.register_ore({
	ore_type       = "scatter",
	ore            = "mineralmatica:stone_with_lead",
	wherein        = "default:stone",
	clust_scarcity = 7 * 7 * 7,
	clust_num_ores = 5,
	clust_size     = 3,
	y_max          = 0,
	y_min          = -31000,
})
minetest.register_ore({
	ore_type       = "scatter",
	ore            = "mineralmatica:stone_with_lead",
	wherein        = "default:stone",
	clust_scarcity = 24 * 24 * 24,
	clust_num_ores = 27,
	clust_size     = 6,
	y_max          = -64,
	y_min          = -31000,
})
--Lump
minetest.register_craftitem("mineralmatica:lead_lump", {
	description = "Lead Lump",
	inventory_image = "mineralmatica_base_lump.png^[colorize:#0000FF:50",
})
--Dust
minetest.register_craftitem( "mineralmatica:lead_dust", {
	description = "Lead Dust",
	groups = { ore_dust = 1 },
	inventory_image = "mineralmatica_base_dust.png^[colorize:#0000FF:50"
})
--Ingot
minetest.register_craft({
	type = "cooking",
	output = "mineralmatica:lead_ingot",
	recipe = "mineralmatica:lead_dust",
})
minetest.register_craft({
	type = "cooking",
	output = "mineralmatica:lead_ingot",
	recipe = "mineralmatica:lead_lump",
})



--==========================
--Bronze
--==========================
--Dust
minetest.register_craftitem( "mineralmatica:bronze_dust", {
	description = "Bronze Dust",
	groups = { ore_dust = 1 },
	inventory_image = "mineralmatica_base_dust.png^[colorize:#CC5500:150"
})
minetest.register_craft({
	type = "shapeless",
	output = "mineralmatica:bronze_dust",
	recipe = { "mineralmatica:copper_dust", "mineralmatica:copper_dust", "mineralmatica:tin_dust" },
})
--Nugget
minetest.register_craftitem( "mineralmatica:bronze_nugget", {
	description = "Bronze Nugget",
	groups = { ore_nugget = 1 },
	inventory_image = "mineralmatica_base_nugget.png^[colorize:#CC5500:50"
})
--Ingot
minetest.register_craftitem( "mineralmatica:bronze_ingot", {
	description = "Bronze Ingot",
	groups = { ore_nugget = 1 },
	inventory_image = "mineralmatica_base_ingot.png^[colorize:#CC5500:50"
})
minetest.register_craft({
	type = "cooking",
	output = "mineralmatica:bronze_ingot",
	recipe = "mineralmatica:bronze_dust",
})
minetest.register_craft({
	output = "mineralmatica:bronze_ingot",
	recipe = {{ "mineralmatica:bronze_nugget", "mineralmatica:bronze_nugget", "mineralmatica:bronze_nugget" }}
})


function doRegisterMetal( inMetalName, inMetalColor, SpawnRules )
	--TODO: Implement SpawnRules
	--Strings
	local properName = inMetalName:sub(1,1):upper()..inMetalName:sub(2)
	local id_ore = "mineralmatica:stone_with_"..inMetalName
	local desc_ore = properName.." Ore"
	local tiles_ore = {
		"default_stone.png^(mineralmatica_base_mineral_b.png^[colorize:#"..
		inMetalColor..
		":170)"
	}

	local id_lump = "mineralmatica:"..inMetalName.."_lump"
	local desc_lump = properName.." Lump";
	local image_lump = "mineralmatica_base_lump.png^[colorize:#"..inMetalColor.."50"

	local id_dust = "mineralmatica:"..inMetalName.."_dust"
	local desc_dust = "Pile of "..properName.." Dust";
	local image_dust = "mineralmatica_base_dust.png^[colorize:#"..inMetalColor.."50"

	local id_nugget = "mineralmatica:"..inMetalName.."_nugget"
	local desc_nugget = properName.." Nugget";
	local image_nugget = "mineralmatica_base_nugget.png^[colorize:#"..inMetalColor.."50"

	local id_ingot = "mineralmatica:"..inMetalName.."_ingot"
	local desc_ingot = properName.." Ingot";
	local image_ingot = "mineralmatica_base_ingot.png^[colorize:#"..inMetalColor.."50"

	--Ores
	minetest.register_node( id_ore, {
		desc_ore = desc_ore,
		tiles = tiles_ore,
		groups = {cracky = 2},
		drop = id_lump,
		sounds = default.node_sound_stone_defaults(),
	})
	minetest.register_ore({
		ore_type       = "scatter",
		ore            = id_ore,
		wherein        = "default:stone",
		clust_scarcity = 9 * 9 * 9,
		clust_num_ores = 12,
		clust_size     = 3,
		y_max          = 31000,
		y_min          = 1025,
	})
	minetest.register_ore({
		ore_type       = "scatter",
		ore            = id_ore,
		wherein        = "default:stone",
		clust_scarcity = 7 * 7 * 7,
		clust_num_ores = 5,
		clust_size     = 3,
		y_max          = 0,
		y_min          = -31000,
	})
	minetest.register_ore({
		ore_type       = "scatter",
		ore            = id_ore,
		wherein        = "default:stone",
		clust_scarcity = 24 * 24 * 24,
		clust_num_ores = 27,
		clust_size     = 6,
		y_max          = -64,
		y_min          = -31000,
	})
	--Lump
	minetest.register_craftitem( id_lump, {
		description = desc_lump,
		inventory_image = image_lump,
	})
	minetest.register_craft({
		type = "cooking",
		output = id_ingot,
		recipe = id_lump,
	})
	--TODO: make TinyDust art
	--Nickel Tiny Dust
	--[[minetest.register_craftitem( "mineralmatica:nickel_smalldust", {
		description = "Small Pile of "..properName,
		groups = { ore_dust = 1 },
		inventory_image = image_dust,
	})]]-- 
	--Nickel Dust
	minetest.register_craftitem( id_dust, {
		description = desc_dust,
		groups = { ore_dust = 1 },
		inventory_image = image_dust,
	})
	minetest.register_craft({
		type = "cooking",
		output = id_ingot,
		recipe = id_dust,
	})
	--Nickel Nugget
	minetest.register_craftitem( id_nugget, {
		description = desc_nugget,
		groups = { ore_dust = 1 },
		inventory_image = image_nugget,
	})
	--Nickel Ingot
	minetest.register_craftitem( id_ingot, {
		description = desc_ingot,
		inventory_image = image_ingot,
	})
	minetest.register_craft({
		output = id_ingot,
		recipe = {{
			id_nugget, id_nugget, id_nugget,
			id_nugget, id_nugget, id_nugget,
			id_nugget, id_nugget, id_nugget
		 }}
	})
end

print( "[MINERALMATICA] Registerin metals..." )
doRegisterMetal( "lithium", "bbDDbb", "default" )
print( "[MINERALMATICA] Metals registered!" )

--==========================
--Nickel
--==========================
--Ores
minetest.register_node("mineralmatica:stone_with_nickel", {
	description = "Nickel Ore",
	tiles = {"default_stone.png^(mineralmatica_base_mineral_b.png^[colorize:#00008b:170)"},
	groups = {cracky = 2},
	drop = "mineralmatica:nickel_lump",
	sounds = default.node_sound_stone_defaults(),
})
minetest.register_ore({
	ore_type       = "scatter",
	ore            = "mineralmatica:stone_with_nickel",
	wherein        = "default:stone",
	clust_scarcity = 9 * 9 * 9,
	clust_num_ores = 12,
	clust_size     = 3,
	y_max          = 31000,
	y_min          = 1025,
})
minetest.register_ore({
	ore_type       = "scatter",
	ore            = "mineralmatica:stone_with_nickel",
	wherein        = "default:stone",
	clust_scarcity = 7 * 7 * 7,
	clust_num_ores = 5,
	clust_size     = 3,
	y_max          = 0,
	y_min          = -31000,
})
minetest.register_ore({
	ore_type       = "scatter",
	ore            = "mineralmatica:stone_with_nickel",
	wherein        = "default:stone",
	clust_scarcity = 24 * 24 * 24,
	clust_num_ores = 27,
	clust_size     = 6,
	y_max          = -64,
	y_min          = -31000,
})
--Nickel Lump
minetest.register_craftitem("mineralmatica:nickel_lump", {
	description = "Nickel Lump",
	inventory_image = "mineralmatica_base_lump.png^[colorize:#1FBED6:50",
})
minetest.register_craft({
	type = "cooking",
	output = "mineralmatica:nickel_ingot",
	recipe = "mineralmatica:nickel_lump",
})
--Nickel Tiny Dust
minetest.register_craftitem( "mineralmatica:nickel_smalldust", {
	description = "Small Pile of Nickel Dust",
	groups = { ore_dust = 1 },
	inventory_image = "mineralmatica_base_smalldust.png^[colorize:#1FBED6:50",
})
--Nickel Dust
minetest.register_craftitem( "mineralmatica:nickel_dust", {
	description = "Pile of Nickel Dust",
	groups = { ore_dust = 1 },
	inventory_image = "mineralmatica_base_dust.png^[colorize:#1FBED6:50",
})
minetest.register_craft({
	type = "cooking",
	output = "mineralmatica:nickel_ingot",
	recipe = "mineralmatica:nickel_dust",
})
--Nickel Nugget
minetest.register_craftitem( "mineralmatica:nickel_nugget", {
	description = "Nickel Nugget",
	groups = { ore_dust = 1 },
	inventory_image = "mineralmatica_base_nugget.png^[colorize:#1FBED6:50",
})
--Nickel Ingot
minetest.register_craftitem("mineralmatica:nickel_ingot", {
	description = "Nickel Ingot",
	inventory_image = "mineralmatica_base_ingot.png^[colorize:#1FBED6:50",
})
minetest.register_craft({
	output = "mineralmatica:nickel_ingot",
	recipe = {{ "mineralmatica:nickel_nugget", "mineralmatica:nickel_nugget", "mineralmatica:nickel_nugget",
		 "mineralmatica:nickel_nugget", "mineralmatica:nickel_nugget", "mineralmatica:nickel_nugget",
		 "mineralmatica:nickel_nugget", "mineralmatica:nickel_nugget", "mineralmatica:nickel_nugget" }}
})

--==========================
--Aluminum - For tier II machine casings.
--==========================



--==========================
--Zinc - For batteries and cannons and machines
--==========================



--==========================
--Invar - For machines and casings and a tool/armorset.
--==========================



--==========================
--Electrum - Tier II techy.
--==========================



--==========================
--Constantan - Tier II non techy.
--==========================



--==========================
--Invar - Many tier II machines.
--==========================



--==========================
--Titanium - For machines and blocks and a tool/armorset and titanium machine casings
--==========================



--==========================
--Silicon - For chips and computers and turtles tier III+ machines
--==========================



--==========================
--Lithium - For batteries
--==========================



--==========================
--Chromium - For anything lightweight, for alloys later
--==========================



--==========================
--Stainless Steel - For machine casings and tons of things
--==========================



--==========================
--Nickel-Chromium Superalloy - For nuclear and fusion reactors.
--==========================


--==========================
--Uranium - For Reactors
--==========================
--Uranium Dust TODO: Make radioactive and dangerous!
minetest.register_craftitem( "mineralmatica:uranium_dust", {
	description = "Pile of Uranium Dust",
	groups = { ore_dust = 1 },
	inventory_image = "mineralmatica_base_dust.png^[colorize:#00FF00:120",
})

