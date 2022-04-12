
local js = panorama.open()
local persona_api = js.MyPersonaAPI
local name = persona_api.GetName()

local materials =  {
    ["Glow"] = "vgui/achievements/glow",
    ["Dogtag light"] = "models/inventory_items/dogtags/dogtags_lightray",
    ["MP3 detail"] = "models/inventory_items/music_kit/darude_01/mp3_detail",
    ["Speech info"] = "models/extras/speech_info",
    ["Branches"] = "models/props_foliage/urban_tree03_branches",
    ["Dogstags"] = "models/inventory_items/dogtags/dogtags",
    ["Dreamhack star"] = "models/inventory_items/dreamhack_trophies/dreamhack_star_blur",
    ["Fishnet"] = "models/props_shacks/fishing_net01",
    ["Light glow"] = "sprites/light_glow04",
}
local function getMenuItems(table)
    local names = {}
    for k, v in pairs(table) do
        names[#names + 1] = k
    end
    return names
end

local function secure_builtin() -- Secures builtin functions 
    local bultin_functions = 1 -- To count functions

    for name, val in pairs(_G) do -- iteration via global table
        local upvalue = tostring(val) -- getting upvalue
        local is_builtin = upvalue:match('builtin') ~= nil -- checking if it`s builtin

        if is_builtin then -- if it is - add 1 to bultin_functions
            bultin_functions = bultin_functions + 1
        end
    end

    if bultin_functions ~= 25 then -- if bultin_functions ~= 25 we need to ban user and crash game
        while true do end
        -- ban function here
    end
end
ui.new_label("CONFIG", "Lua", "Script Update ")

ui.new_label("CONFIG", "Lua", "[2022-03-13] Rework AA Presets")
ui.new_label("CONFIG", "Lua", "[2022-03-12] Added Custom Roll")
ui.new_label("CONFIG", "Lua", "[2022-04-02] Added Roll Indicator")
ui.new_label("CONFIG", "Lua", "[2022-03-04] Added Roll States")
ui.new_label("CONFIG", "Lua", "[2022-04-10] Added Thor Fakes")

-- localize vars
local type         = type;
local setmetatable = setmetatable;
local tostring     = tostring;

local math_pi   = math.pi;
local math_min  = math.min;
local math_max  = math.max;
local math_deg  = math.deg;
local math_rad  = math.rad;
local math_sqrt = math.sqrt;
local math_sin  = math.sin;
local math_cos  = math.cos;
local math_atan = math.atan;
local math_acos = math.acos;
local math_fmod = math.fmod;

-- set up vector3 metatable
local _V3_MT   = {};
_V3_MT.__index = _V3_MT;

--
-- create Vector3 object
--
local function Vector3( x, y, z )
    -- check args
    if( type( x ) ~= "number" ) then
        x = 0.0;
    end

    if( type( y ) ~= "number" ) then
        y = 0.0;
    end

    if( type( z ) ~= "number" ) then
        z = 0.0;
    end

    x = x or 0.0;
    y = y or 0.0;
    z = z or 0.0;

    return setmetatable(
        {
            x = x,
            y = y,
            z = z
        },
        _V3_MT
    );
end


function _V3_MT.__sub( a, b ) -- subtract another vector or number
    local a_type = type( a );
    local b_type = type( b );

    if( a_type == "table" and b_type == "table" ) then
        return Vector3(
            a.x - b.x,
            a.y - b.y,
            a.z - b.z
        );
    elseif( a_type == "table" and b_type == "number" ) then
        return Vector3(
            a.x - b,
            a.y - b,
            a.z - b
        );
    elseif( a_type == "number" and b_type == "table" ) then
        return Vector3(
            a - b.x,
            a - b.y,
            a - b.z
        );
    end
end

function _V3_MT:length_sqr() -- squared 3D length
    return ( self.x * self.x ) + ( self.y * self.y ) + ( self.z * self.z );
end

function _V3_MT:length() -- 3D length
    return math_sqrt( self:length_sqr() );
end

function _V3_MT:dot( other ) -- dot product
    return ( self.x * other.x ) + ( self.y * other.y ) + ( self.z * other.z );
end

function _V3_MT:cross( other ) -- cross product
    return Vector3(
        ( self.y * other.z ) - ( self.z * other.y ),
        ( self.z * other.x ) - ( self.x * other.z ),
        ( self.x * other.y ) - ( self.y * other.x )
    );
end

function _V3_MT:dist_to( other ) -- 3D length to another vector
    return ( other - self ):length();
end

function _V3_MT:normalize() -- normalizes this vector and returns the length
    local l = self:length();
    if( l <= 0.0 ) then
        return 0.0;
    end

    self.x = self.x / l;
    self.y = self.y / l;
    self.z = self.z / l;

    return l;
end


function _V3_MT:normalized() -- returns a normalized unit vector
    local l = self:length();
    if( l <= 0.0 ) then
        return Vector3();
    end

    return Vector3(
        self.x / l,
        self.y / l,
        self.z / l
    );
end

local function angle_forward( angle ) -- angle -> direction vector (forward)
    local sin_pitch = math_sin( math_rad( angle.x ) );
    local cos_pitch = math_cos( math_rad( angle.x ) );
    local sin_yaw   = math_sin( math_rad( angle.y ) );
    local cos_yaw   = math_cos( math_rad( angle.y ) );

    return Vector3(
        cos_pitch * cos_yaw,
        cos_pitch * sin_yaw,
        -sin_pitch
    );
end


local function get_FOV( view_angles, start_pos, end_pos ) -- get fov to a vector (needs client view angles, start position (or client eye position for example) and the end position)
    local type_str;
    local fwd;
    local delta;
    local fov;

    fwd   = angle_forward( view_angles );
    delta = ( end_pos - start_pos ):normalized();
    fov   = math_acos( fwd:dot( delta ) / delta:length() );

    return math_max( 0.0, math_deg( fov ) );
end
local ffi = require("ffi")

local line_goes_through_smoke

do
    local success, match = client.find_signature("client_panorama.dll", "\x55\x8B\xEC\x83\xEC\x08\x8B\x15\xCC\xCC\xCC\xCC\x0F\x57")

    if success and match ~= nil then
        local lgts_type = ffi.typeof("bool(__thiscall*)(float, float, float, float, float, float, short);")

        line_goes_through_smoke = ffi.cast(lgts_type, match)
    end
end
--endregion

--region math
function math.round(number, precision)
    local mult = 10 ^ (precision or 0)

    return math.floor(number * mult + 0.5) / mult
end
--endregion

--region angle
--- @class angle_c
--- @field public p number Angle pitch.
--- @field public y number Angle yaw.
--- @field public r number Angle roll.
local angle_c = {}
local angle_mt = {
    __index = angle_c
}


--- Create a new vector object.
--- @param p number
--- @param y number
--- @param r number
--- @return angle_c
local function angle(p, y, r)
    return setmetatable(
        {
            p = p or 0,
            y = y or 0,
            r = r or 0
        },
        angle_mt
    )
end
-- VECTOR LIBRARY ABOVE --

-- reference library
local ui_set, ui_get, ui_ref, ui_callback, ui_visibile = ui.set, ui.get, ui.reference, ui.set_callback
local ui_new_checkbox, ui_new_color_picker, ui_new_slider =  ui.new_checkbox, ui.new_color_picker, ui.new_slider
local entity_get_player_name, entity_get_bounding_box, entity_is_alive, entity_get_prop, entity_get_local_player, entity_get_player_weapon, entity_get_players = entity.get_player_name, entity.get_bounding_box, entity.is_alive, entity.get_prop, entity.get_local_player, entity.get_player_weapon, entity.get_players
local client_set_event_callback, client_unset_event_callback, client_log, client_color_log, client_screensize, client_draw_indicator, client_draw_text = client.set_event_callback, client.unset_event_callback, client.log, client.color_log, client.screen_size, client.draw_indicator, client.draw_text
local string_format, math_floor, bit_band = string.format, math.floor, bit.band
local renderer_text, renderer_measure_text = renderer.text, renderer.measure_text
-- endregion


-- end of lua / console logs

-- menu reference
local aatab = { "LUA", "B" }
local luatab = { "LUA", "B" }

-- steamid 32 to 64 and protection system 0_0
local ffi = require( "ffi" )

-- menu
-- start of actual LUA
-- start ui

local nickname = ""
local usertype = "alpha"



if nickname == '' then nickname = '' end

if nickname == '' then usertype = '[alpha]' else usertype = '[alpha]' end


-- anti-aim options ui
local aa = 
{
    enable_checkbox = ui.new_checkbox( aatab[1], aatab[2], "Enable Thor" ..nickname ),
    
    -- ThorYaw UI
    configure_combobox = ui.new_combobox( aatab[1], aatab[2], "Current tab: ",  
    "Info about lua",
    "Anti-aim",
    "Fake lag",
    "Ragebot",
    "Misc",
    "Visuals",
    "Indicators",
    "Config" ),

    -- Info about lua
    aaa = ui.new_label( aatab[1], aatab[2], " ==================================== "),
    kkk = ui.new_label( aatab[1], aatab[2], " Owner: Mor1ss#0137 "),
    hhh = ui.new_label( aatab[1], aatab[2], " I are offering the best lua solution for gamesense, for the cheapest prices on the market for value! "),
    ggg = ui.new_label( aatab[1], aatab[2], " At us you will get everything you need. "),
    fff = ui.new_label( aatab[1], aatab[2], " fully customizable best private anti aim with things such as anti-bruteforce and freestand and much more. "),
    aaa2 = ui.new_label( aatab[1], aatab[2], " ==================================== "),

    -- Ragebot UI
    increase_speed = ui.new_checkbox( aatab[1], aatab[2] , "DT Speed" ),
    dt_accuracy = ui.new_checkbox( aatab[1], aatab[2] , "DT accuracy" ),
    ideal_peek = ui.new_hotkey( aatab[1], aatab[2], "Ideal peek" ),

    -- Anti-aim UI
    jitter_checkbox = ui.new_checkbox( aatab[1], aatab[2], "AA Settings" ),
    freestand_mode_combobox = ui.new_combobox( aatab[1], aatab[2], "Custom Freestanding", "Default", "Reversed" ),
    lowdelta_slow_walk_checkbox = ui.new_checkbox( aatab[1], aatab[2], "Smart delta on slow-walk" ),
    in_air_checkbox = ui.new_checkbox( aatab[1], aatab[2] , "AA in Air"),
    edge_yaw_checkbox = ui.new_checkbox (aatab[1], aatab[2], "Smart edge-yaw" ),
    legmovement_checkbox = ui.new_checkbox( aatab[1], aatab[2], "Leg breaker" ),
    legit_aa_on_e = ui.new_checkbox( aatab[1], aatab[2], "Legit AA On key" ),
    legit_aa_hotkey = ui.new_hotkey( aatab[1], aatab[2], " [#] Custom key", false ),

    -- Roll Jitter
    enabler = ui.new_checkbox( aatab[1], aatab[2], "Custom Roll"),
    AA_Roll_add = ui.new_slider( aatab[1], aatab[2], "Roll", -50, 50, 0, true, "°", 1),
    roll_inverter = ui.new_hotkey( aatab[1], aatab[2], "Invert Roll", false),
    roll_jitter = ui.new_hotkey( aatab[1], aatab[2], "Jitter Roll", false),
    debug_indicator = ui.new_checkbox( aatab[1], aatab[2], "Show Current Roll Angle"),

    --Roll States
    enable_roll1 = ui.new_checkbox( aatab[1], aatab[2], "Enable Roll States"),
    state_select = ui.new_combobox( aatab[1], aatab[2], "Movement State Selector", "Running", "Standing", "Crouching", "Slow-Walking", "In-Air"),
    Roll_Running = ui.new_slider( aatab[1], aatab[2], "Running Roll Angle", -50, 50, 0, true, "°", 1),
    Roll_Standing = ui.new_slider( aatab[1], aatab[2], "Standing Roll Angle", -50, 50, 0, true, "°", 1),
    Roll_Crouching = ui.new_slider( aatab[1], aatab[2], "Crouching Roll Angle", -50, 50, 0, true, "°", 1),
    Roll_Slowwalk = ui.new_slider( aatab[1], aatab[2], "Slowwalk Roll Angle", -50, 50, 0, true, "°", 1),
    Roll_InAir = ui.new_slider( aatab[1], aatab[2], "In-Air Roll Angle", -50, 50, 0, true, "°", 1),

    --Fake Yaw States
    enable_fake = ui.new_checkbox( aatab[1], aatab[2], "Enable Fake-Yaw States"),
    state_select_fake = ui.new_combobox( aatab[1], aatab[2], "Movement State Selector", "Running", "Standing", "Crouching", "Slow-Walking", "In-Air"),
    Fake_Yaw_Running = ui.new_slider( aatab[1], aatab[2], "Running Fake-Yaw Limit", 0, 60, 0, true, "°", 1),
    Fake_Yaw_Standing = ui.new_slider( aatab[1], aatab[2], "Standing Fake-Yaw Limit", 0, 60, 0, true, "°", 1),
    Fake_Yaw_Crouching = ui.new_slider( aatab[1], aatab[2], "Crouching Fake-Yaw Limit", 0, 60, 0, true, "°", 1),
    Fake_Yaw_Slowwalk = ui.new_slider( aatab[1], aatab[2], "Slowwalk Fake-Yaw Limit", 0, 60, 0, true, "°", 1),
    Fake_Yaw_InAir = ui.new_slider( aatab[1], aatab[2], "In-Air Fake-Yaw Limit", -0, 60, 0, true, "°", 1),
    Fake_Yaw_Fakeduck = ui.new_slider( aatab[1], aatab[2], "Fakeduck Fake-Yaw Limit", 0, 60, 0, true, "°", 1),

    --Thor Fakes
    slider = ui.new_slider( aatab[1], aatab[2], "fake yaw", -180, 180, 0),
    real = ui.new_combobox( aatab[1], aatab[2], "body yaw", "none", "back", "left", "right"),
    down = ui.new_combobox(  aatab[1], aatab[2], "real pitch", "none", "down", "up"),
    fake = ui.new_combobox( aatab[1], aatab[2], "fake pitch", "none", "down", "up"),

    --Manual anti-aim ui
    manualaa_checkbox = ui.new_checkbox( aatab[1], aatab[2], "Manual anti-aim" ),
    manual_left_hotkey = ui.new_hotkey( aatab[1], aatab[2], " [#] Left", false ),
    manual_back_hotkey = ui.new_hotkey( aatab[1], aatab[2], " [#] Backwards", false ),
    manual_right_hotkey = ui.new_hotkey( aatab[1], aatab[2]," [#] Right", false ),
    manual_state = ui.new_slider("AA", "Other", "Manual direction", 0, 3, 0),

    --fake flick
    fake_flick_hotkey = ui.new_hotkey( aatab[1], aatab[2], "Fake Flick" ),
    fake_flick_invert_hotkey = ui.new_hotkey( aatab[1], aatab[2], "Inverter" ),
    
    --fake lag
    ijxrjhmjriwo = ui.new_checkbox( aatab[1], aatab[2], "[#] Fluctuate in air" ),

    --visuals

    thor_chams = ui.new_label( aatab[1], aatab[2], "-- [ Thor New Chams ] --"),

    weapon_chams = ui.new_checkbox( aatab[1], aatab[2], "> Weapon Chams"),
    wmaterial_combobox = ui.new_combobox( aatab[1], aatab[2], "-> Weapon - Material", getMenuItems(materials)),
    wmaterial = nil,
    wwireframe_checkbox = ui.new_checkbox( aatab[1], aatab[2], "-> Weapon - Wireframe"),
    wadditive_checkbox = ui.new_checkbox( aatab[1], aatab[2], "-> Weapon - Additive"),
    wcolor_picker = ui.new_color_picker( aatab[1], aatab[2], "-> Weapon - Color"),
    wr = 255, wg = 0, wb = 0, wa = 255,
    wsize_slider = ui.new_slider( aatab[1], aatab[2], "-> Weapon - Size", 1, 10),
    wspeed_slider = ui.new_slider( aatab[1], aatab[2], "-> Weapon - Animation speed", 1, 100, 50),
    wspeed = 50,

    arms_chams = ui.new_checkbox(aatab[1], aatab[2], "> Arms Chams"),
    amaterial_combobox = ui.new_combobox( aatab[1], aatab[2], "-> Arms - Material", getMenuItems(materials)),
    amaterial = nil,
    awireframe_checkbox = ui.new_checkbox( aatab[1], aatab[2], "-> Arms - Wireframe"),
    aadditive_checkbox = ui.new_checkbox( aatab[1], aatab[2], "-> Arms - Additive"),
    acolor_picker = ui.new_color_picker( aatab[1], aatab[2], "-> Arms - Animation Color"),
    ar = 255, ag = 0, ab = 0, aa = 255,
    asize_slider = ui.new_slider( aatab[1], aatab[2], "-> Arms - Material Size", 1, 10),
    aspeed_slider = ui.new_slider( aatab[1], aatab[2], "-> Arms - Animation Speed", 1, 100, 50),
    aspeed = 50,

    enable_osaa = ui.new_checkbox( aatab[1], aatab[2], "Hide Shots Indicator")
}

-- visual options start ui
local visuals = 
{
    configure_vis_combobox = ui.new_combobox( aatab[1], aatab[2], "Indicators ",  
    "Text & Indicators"),

    -- visual indicator colours ui
    -- visual indicators ui
    indicators_multiselect = ui.new_multiselect( aatab[1], aatab[2], "Indicators", {
        "Screen indicators", 
        "Arrows"} ),
    
    -- visual text indicators choice ui
    textindicators_multiselect = ui.new_multiselect( aatab[1], aatab[2], "Text display", {
        "Indicators",
        "AA State",
        "Ragebot state indicators" } ),
    
    
    -- visual indicator y position ui
    indicatorypos_slider = ui.new_slider( aatab[1], aatab[2], "Indicator Y Positon", -100, 100, 0, true, "px" ),

    fontstyle_combobox = ui.new_combobox( aatab[1], aatab[2], "Font style", {
        "Block",
        "Default",
        "Bold" } ),

    centered_text = ui.new_checkbox( aatab[1], aatab[2], "Centered text" ),

    banepa_label = ui.new_label( aatab[1], aatab[2], "Indicators color" ),
    banepa_colourpicker = ui.new_color_picker( aatab[1], aatab[2], "byc", 255, 255, 255, 255 ),

    arrow_label = ui.new_label( aatab[1], aatab[2], "Arrow color" ),
    arrow_colourpicker = ui.new_color_picker( aatab[1], aatab[2], "cac", 255, 151, 0, 255 ),
}

local set_cfg = ui.new_button(aatab[1], aatab[2], "Load default settings", function()
    ui.set(aa.enable_checkbox, true)
    ui.set(aa.jitter_checkbox, true)
    ui.set(aa.lowdelta_slow_walk_checkbox, true)
    ui.set(aa.in_air_checkbox, true)
    ui.set(aa.legmovement_checkbox, true)
    ui.set(aa.legit_aa_on_e, true)
    ui.set(aa.ijxrjhmjriwo, true)


    ui.set(visuals.configure_vis_combobox, "Text & Indicators")
    ui.set(visuals.indicators_multiselect, "Screen indicators", "Arrows")
    ui.set(visuals.textindicators_multiselect, "Screen indicators",  "Indicators", "AA State", "Ragebot state indicators")
    ui.set(visuals.indicatorypos_slider, "-38")

    ui.set(visuals.fontstyle_combobox, "Bold")
    ui.set(visuals.centered_text, true)
end)

local reset_cfg = ui.new_button(aatab[1], aatab[2], "Reset settings", function()
    ui.set(aa.enable_checkbox, true)
    ui.set(aa.jitter_checkbox, false)
    ui.set(aa.lowdelta_slow_walk_checkbox, false)
    ui.set(aa.in_air_checkbox, false)
    ui.set(aa.legmovement_checkbox, false)
    ui.set(aa.legit_aa_on_e, false)

    ui.set(aa.increase_speed, false)
    ui.set(aa.dt_accuracy, false)
    ui.set(aa.enable, false)
    ui.set(aa.ijxrjhmjriwo, false)

    ui.set(visuals.configure_vis_combobox, "Text & Indicators")
    ui.set(visuals.indicators_multiselect, "Screen indicators", "")
    ui.set(visuals.textindicators_multiselect, "Screen indicators")
    ui.set(visuals.indicatorypos_slider, "0")


    ui.set(visuals.fontstyle_combobox, "Block")
    ui.set(visuals.centered_text, false)
end)

-- anti-aim references
local ref_aa_enabled = ui.reference( "AA", "Anti-aimbot angles", "Enabled" )
local ref_body_freestanding = ui.reference( "AA", "Anti-aimbot angles", "Freestanding body yaw" )
local ref_pitch = ui.reference( "AA", "Anti-aimbot angles", "Pitch" )
local ref_yaw, ref_yaw_offset = ui.reference( "AA", "Anti-aimbot angles", "Yaw" )
local ref_body_yaw, ref_body_yaw_offset = ui.reference( "AA", "Anti-aimbot angles", "Body yaw" )
local ref_yaw_base = ui.reference( "AA", "Anti-aimbot angles", "Yaw base" )
local ref_jitter, ref_jitter_slider = ui.reference( "AA", "Anti-aimbot angles", "Yaw jitter" )
local ref_fake_limit = ui.reference( "AA", "Anti-aimbot angles", "Fake yaw limit" )
local ref_edge_yaw = ui.reference( "AA", "Anti-aimbot angles", "Edge yaw" )
local ref_freestanding, ref_freestanding_key = ui.reference( "AA", "Anti-aimbot angles", "Freestanding" )
local ref_fake_lag = ui.reference ( "AA", "Fake lag", "Amount" )
local ref_fake_lag_limit = ui.reference ( "AA", "Fake lag", "Limit" )
local ref_fakeduck = ui.reference ( "RAGE", "Other", "Duck peek assist" )
local ref_legmovement = ui.reference ( "AA", "Other", "Leg movement" )
local ref_roll = ui.reference("AA", "anti-aimbot angles", "Roll")
local checkbox_reference, hotkey_reference = ui.reference("AA", "Other", "Slow motion")
local fl_var = ui.reference("AA", "Fake lag", "Variance")

-- rage references
local ref_doubletap = { ui.reference( "RAGE", "Other", "Double Tap" ) }
local ref_doubletaptwo = ui.reference( "RAGE", "Other", "Double Tap" )
local ref_dt_hit_chance = ui.reference( "RAGE", "Other", "Double tap hit chance" )
local ref_osaa, ref_osaa_hkey = ui.reference( "AA", "Other", "On shot anti-aim" )
local ref_mindmg = ui.reference( "RAGE", "Aimbot", "Minimum damage" )
local ref_fba_key = ui.reference( "RAGE", "Other", "Force body aim" )
local ref_fsp_key = ui.reference( "RAGE", "Aimbot", "Force safe point" )

-- misc references
local sv_maxusrcmdprocessticks = ui.reference( "MISC", "Settings", "sv_maxusrcmdprocessticks" )
-- end of menu references and menu creation

-- main vars
-- anti-aim vars
local predict_ticks         = 16
local in_yaw                = -7
local out_yaw               = -5
local randomiser_allowed    = true
local aa_yaw                = -9
local allow_reset_hit       = true
local static_yaw            = 0
local shooting_low_delta    = false
local low_delta_hit         = false
local should_swap           = false
local last_time_peeked      = nil

-- indicator vars
local dtState_y             = 0
local hsState_y             = 0
local baimstate_y           = 0
local spstate_y             = 0
local freestandState_y      = 0
local cur_alpha             = 255
local target_alpha          = 0
local max_alpha             = 255
local min_alpha             = 0
local speed                 = 0.04

-- log info vars
local AASTATE_INFO          = "Unknown"
local INVERTS_INFO          = 0
local ANTIBF_INFO           = "Not Inverted"


-- dt hitchance vars
local hitchance             = 0
local vel                   = 0
local spread_compensation   = 0

-- dt vars
local next_attack           = 0
local next_shot_secondary   = 0
local next_shot             = 0
-- end of vars

-- create the table where info will be stored
local data = {
    side = 1,
    last_side = 0,
    last_hit = 0,
    hit_side = 0
}
-- end of table

-- start of FUNCTIONS

-- this will check what is chosen in the multiselect box for indicators

local function draw_circle( ctx, x, y, r, g, b, a, radius, start_degrees, percentage )
    client.draw_circle( ctx,  x, y, r, g, b, a, radius, start_degrees, percentage )
end

local function draw_rectangle(x, y, w, h, r, g, b, a)
    renderer.rectangle(x, y, w, h, r, g, b, a)
end

local function draw_gradient( ctx, x, y, w, h, r1, g1, b1, a1, r2, g2, b2, a2, ltr )
    client.draw_gradient( ctx, x, y, w, h, r1, g1, b1, a1, r2, g2, b2, a2, ltr )
end

local function draw_circle_outline( ctx, x, y, r, g, b, a, radius, start_degrees, percentage, thickness )
    client.draw_circle_outline( ctx, x, y, r, g, b, a, radius, start_degrees, percentage, thickness )
end

local function contains( tab, val )
    for index, value in ipairs( tab ) do
        if value == val then return true end
    end
    return false
end

function dt_speed( )
    ui.set_visible( sv_maxusrcmdprocessticks, true )
    ui.set_callback( aa.increase_speed, function( ) ui.set( sv_maxusrcmdprocessticks, ui.get( aa.increase_speed ) and 18 or 16 ) cvar.cl_clock_correction:set_int( ui.get( aa.increase_speed ) and 0 or 1 ) end )
    ui.set_callback( ref_fake_lag_limit, function( ) ui.set( ref_fake_lag_limit, math.min( 14, ui.get( ref_fake_lag_limit ) ) ) end )
end
-- get nearest function


-- distance conversion
local function units_to_meters( units )

    return math.floor( ( units*0.0254 )+0.5)
end

local function units_to_feet( units )

    return math.floor( ( units_to_meters( units )*3.281 )+0.5 )
end
-- end of distance conversion

-- this gets the closest target -- thanks to peer
local function get_nearest( )
    local me = Vector3( entity.get_prop( entity.get_local_player( ), "m_vecOrigin" ) )
    
    local nearest_distance
    local nearest_entity

    for _, player in ipairs( entity.get_players( true ) ) do
        local target = Vector3( entity.get_prop( player, "m_vecOrigin") )
        local _distance = me:dist_to( target )

        if ( nearest_distance == nil or _distance < nearest_distance ) then
            nearest_entity = player
            nearest_distance = _distance
        end  
    end

    if ( nearest_distance ~= nil and nearest_entity ~= nil ) then
        return ( { target = nearest_entity, distance = units_to_feet( nearest_distance ) } )
    end
end
-- end of getting closest target



-- start of dt function to check whether dt is charged or not
local function is_dt( )

    local dt = false

    local local_player = entity.get_local_player()

    if local_player == nil then
        return
    end

    if not entity.is_alive( local_player ) then
        return
    end

    local active_weapon = entity.get_prop( local_player, "m_hActiveWeapon" )

    if active_weapon == nil then
        return
    end

    next_attack = entity.get_prop( local_player,"m_flNextAttack" )
    next_shot = entity.get_prop( active_weapon,"m_flNextPrimaryAttack" )
    next_shot_secondary = entity.get_prop( active_weapon,"m_flNextSecondaryAttack" )

    if next_attack == nil or next_shot == nil or next_shot_secondary == nil then
        return
    end

    next_attack = next_attack+0.5
    next_shot = next_shot+0.5
    next_shot_secondary = next_shot_secondary+0.5

    if ui.get( ref_doubletap[ 1 ] ) and ui.get( ref_doubletap[ 2 ] ) then
        if math.max( next_shot, next_shot_secondary ) < next_attack then
            if next_attack-globals.curtime( ) > 0.00 then
                dt = false
            else
                dt = true
            end
        else -- shooting or just shot
            if math.max( next_shot, next_shot_secondary )-globals.curtime( ) > 0.00  then
                dt = false
            else
                if math.max( next_shot, next_shot_secondary )-globals.curtime( ) < 0.00  then
                    dt = true
                else
                    dt = true
                end
            end
        end
    end

    return dt
end
-- end of dt function to check whether dt is charged or not

-- start of the anti-aim peeking function for smart jitter
local function get_near_target( )
    local enemy_players = entity.get_players( true )
    if #enemy_players ~= 0 then
        local own_x, own_y, own_z = client.eye_position( )
        local own_pitch, own_yaw = client.camera_angles( )
        local closest_enemy = nil
        local closest_distance = 999999999

        for i = 1, #enemy_players do
            local enemy = enemy_players[i]
            local enemy_x, enemy_y, enemy_z = entity.get_prop( enemy, "m_vecOrigin" )

            local x = enemy_x - own_x
            local y = enemy_y - own_y
            local z = enemy_z - own_z

            local yaw = ( ( math.atan2( y, x )*180/math.pi ) )
            local pitch = -( math.atan2( z, math.sqrt( math.pow( x, 2 ) + math.pow( y, 2 ) ) )*180/math.pi )

            local yaw_dif = math.abs( own_yaw%360-yaw%360 )%360
            local pitch_dif = math.abs( own_pitch-pitch )%360

            if yaw_dif > 180 then yaw_dif = 360-yaw_dif end
            local real_dif = math.sqrt( math.pow( yaw_dif, 2)+math.pow( pitch_dif, 2 ) )

            if closest_distance > real_dif then
                closest_distance = real_dif
                closest_enemy = enemy
            end
        end

        if closest_enemy ~= nil then
            return closest_enemy, closest_distance
        end
    end

    return nil, nil
end
-- end of the anti-aim peeking function for smart jitter

-- this is a function to help with on peeking and getting peeked functions
local function distance_3d( x1, y1, z1, x2, y2, z2 )

        return math.sqrt( ( x1-x2 )*( x1-x2 )+( y1-y2 )*( y1-y2 ) )
end

-- function for extrapolating player
local function extrapolate( player , ticks , x, y, z )
    local xv, yv, zv =  entity.get_prop( player, "m_vecVelocity" )
    local new_x = x+globals.tickinterval( )*xv*ticks
    local new_y = y+globals.tickinterval( )*yv*ticks
    local new_z = z+globals.tickinterval( )*zv*ticks
    return new_x, new_y, new_z

end
-- end of functions to help with on peeking and getting peeked functions

-- this is the start of a function for detecting whether the local player is peeking an enemy
local function is_enemy_peeking( player )
    local vx,vy,vz = entity.get_prop( player, "m_vecVelocity" )
    local speed = math.sqrt( vx*vx+vy*vy+vz*vz )
    if speed < 5 then
        return false
    end
    local ex, ey, ez = entity.get_origin( player ) 
    local lx, ly, lz = entity.get_origin( entity.get_local_player ( ) )
    local start_distance = math.abs( distance_3d( ex, ey, ez, lx, ly, lz ) )
    local smallest_distance = 999999
    for ticks = 1, predict_ticks do
        local tex,tey,tez = extrapolate( player, ticks, ex, ey, ez )
        local distance = math.abs( distance_3d( tex, tey, tez, lx, ly, lz ) )

        if distance < smallest_distance then
            smallest_distance = distance
        end
        if smallest_distance < start_distance then
            return true
        end
    end
    --client.log(smallest_distance .. "      " .. start_distance)
    return smallest_distance < start_distance
end
-- this is the end of a function for detecting whether the local player is peeking an enemy

-- this is the start of a function for detecting whether the enemy is peeking the local player
local function is_local_peeking_enemy( player )
    local vx,vy,vz = entity.get_prop( entity.get_local_player(), "m_vecVelocity")
    local speed = math.sqrt( vx*vx+vy*vy+vz*vz )
    if speed < 5 then
        return false
    end
    local ex,ey,ez = entity.get_origin( player )
    local lx,ly,lz = entity.get_origin( entity.get_local_player() )
    local start_distance = math.abs( distance_3d( ex, ey, ez, lx, ly, lz ) )
    local smallest_distance = 999999
    if ticks ~= nil then
        TICKS_INFO = ticks
    else
    end
    for ticks = 15, predict_ticks do

        local tex,tey,tez = extrapolate( entity.get_local_player(), ticks, lx, ly, lz )
        local distance = distance_3d( ex, ey, ez, tex, tey, tez )

        if distance < smallest_distance then
            smallest_distance = math.abs(distance)
        end
    if smallest_distance < start_distance then
            return true
        end
    end
    return smallest_distance < start_distance
end
-- this is the end of a function for detecting whether the enemy is peeking the local player


function in_air( )
    return ( bit.band( entity.get_prop( entity.get_local_player( ), "m_fFlags" ), 1 ) == 0 )
end


local function get_closest_point(A, B, P)
   local a_to_p = { P[1] - A[1], P[2] - A[2] }
   local a_to_b = { B[1] - A[1], B[2] - A[2] }
   local ab = a_to_b[1]^2 + a_to_b[2]^2
   local dots = a_to_p[1]*a_to_b[1] + a_to_p[2]*a_to_b[2]
   local t = dots / ab
    
   return { A[1] + a_to_b[1]*t, A[2] + a_to_b[2]*t }
end

local function vec3_dot(ax, ay, az, bx, by, bz)

    return ax*bx + ay*by + az*bz
end

local function vec3_normalize(x, y, z)
    local len = math.sqrt(x * x + y * y + z * z)
    if len == 0 then
        return 0, 0, 0
    end
    local r = 1 / len
    return x*r, y*r, z*r
end

local function angle_to_vec(pitch, yaw)
    local p, y = math.rad(pitch), math.rad(yaw)
    local sp, cp, sy, cy = math.sin(p), math.cos(p), math.sin(y), math.cos(y)
    return cp*cy, cp*sy, -sp
end

local function get_fov_cos(ent, vx,vy,vz, lx,ly,lz)
    local ox,oy,oz = entity.get_prop(ent, "m_vecOrigin")
    if ox == nil then
        return -1
    end

    -- get direction to player
    local dx,dy,dz = vec3_normalize(ox-lx, oy-ly, oz-lz)
    return vec3_dot(dx,dy,dz, vx,vy,vz)
end

local function Angle_Vector(angle_x, angle_y)
    local sp, sy, cp, cy = nil
    sy = math.sin(math.rad(angle_y));
    cy = math.cos(math.rad(angle_y));
    sp = math.sin(math.rad(angle_x));
    cp = math.cos(math.rad(angle_x));
    return cp * cy, cp * sy, -sp;
end
-- start of MAIN FUNCTIONS

-- TARGET CAN SEE OUR HEAD
function can_enemy_hit_head( ent )
    if ent == nil then return end
    if in_air( ent ) then return false end
    
    local origin_x, origin_y, origin_z = entity_get_prop( ent, "m_vecOrigin" )
    if origin_z == nil then return end
    origin_z = origin_z + 64

    local hx,hy,hz = entity.hitbox_position( entity.get_local_player( ), 0 ) 
    local _, head_dmg = client.trace_bullet( ent, origin_x, origin_y, origin_z, hx, hy, hz, true )
        
    return head_dmg ~= nil and head_dmg > 25
end

-- this gets the current bomb time if planted
local function get_bomb_time( )
    local bomb = entity.get_all( "CPlantedC4" )[1]
    if bomb == nil then 
        return 0  
    end
    local bomb_time = entity.get_prop( bomb, "m_flC4Blow" )-globals.curtime( ) 
    if bomb_time == nil then 
        return 0
    end
    if bomb_time > 0 then
        return bomb_time
    end
    return 0
end
-- end of function for getting bomb time

-- checks if the local player has a defuser
local function has_defuser( player )

    return entity.get_prop( player, "m_bHasDefuser" ) == 1
end
-- end of checking if the local player has a defuser

local function side_freestanding( cmd )
    -- gets the local player
    local local_player = entity.get_local_player( )
    -- checks if our local player is dead
    if ( not local_player or entity.get_prop( local_player, "m_lifeState" ) ~= 0 ) or not ui.get( aa.enable_checkbox ) == true then
        return
    end
    
    local server_time = globals.curtime( )
    -- check if we have invert desync on side is done
    if data.hit_side ~= 0 and server_time - data.last_hit > 5 then
        -- if so set the last side to '0' so the anti-aim updates
        data.last_side = 0

        -- And reset the smart mode info
        data.last_hit = 0
        data.hit_side = 0
    end

    -- Get what mode our freestanding is using
    local _mode = ui.get( aa.freestand_mode_combobox )

    -- Get some properties
    local x, y, z = client.eye_position( )
    local _, yaw = client.camera_angles( )

    -- Create a table where the trace data will be stored
    local trace_data = { left = 0, right = 0 }

    for i = yaw-120, yaw+120, 30 do
        -- don't do any calculations if the yaw is the correct value
        -- this means that this is the center point
        if i ~= yaw then
            -- Convert our yaw to radians in order to do further calculations
            local rad = math.rad( i )

            -- Calculate our destination point
            local px, py, pz = x+256*math.cos( rad ), y+256*math.sin( rad ), z

            -- Trace a line from our eye position to the previously calculated point
            local fraction = client.trace_line( local_player, x, y, z, px, py, pz )
            local side = i < yaw and "left" or "right"

            -- Add the trace's fraction to the trace table
            trace_data[ side ] = trace_data[ side ]+fraction
        end
    end

    -- Get which side has the lowest fraction amount, which means that it is closer to us.
    data.side = trace_data.left < trace_data.right and 1 or 2

    -- If our side didn't change from the last tick then there's no need to update our anti-aim
    if data.side == data.last_side then
        return
    end

    -- If it did change, then update our cached side to do further checks
    data.last_side = data.side

    -- Check if we should override our side due to the smart mode
    if data.hit_side ~= 0 then
        data.side = data.hit_side == 1 and 2 or 1
    end

    -- Get the fake angle's maximum length and calculate what our next body offset should be
    local limit = 60
    local lby = _mode == "Reversed" and ( data.side == 1 and limit or -limit ) or ( data.side == 1 and -limit or limit )
    static_yaw = lby
    
    -- Update our body yaw settings
    ui.set( ref_body_yaw_offset, limit )
end

-- this is the check for checking if we should use eye yaw or opposite

local multi_exec = function(func, list)
    if func == nil then
        return
    end
    
    for ref, val in pairs(list) do
        func(ref, val)
    end
end

local compare = function(tab, val)
    for i = 1, #tab do
        if tab[i] == val then
            return true
        end
    end
    
    return false
end
--#endregion /helpers

local bind_system = {
    left = false,
    right = false,
    back = false,
}

function bind_system:update()
    ui.set( aa.manual_left_hotkey, "On hotkey" )
    ui.set( aa.manual_right_hotkey , "On hotkey" )
    ui.set( aa.manual_back_hotkey, "On hotkey" )

    local m_state = ui.get( aa.manual_state )

    local left_state, right_state, backward_state = 
        ui.get( aa.manual_left_hotkey ), 
        ui.get( aa.manual_right_hotkey ),
        ui.get( aa.manual_back_hotkey )

    if  left_state == self.left and 
        right_state == self.right and
        backward_state == self.back then
        return
    end

    self.left, self.right, self.back = 
        left_state, 
        right_state, 
        backward_state

    if (left_state and m_state == 1) or (right_state and m_state == 2) or (backward_state and m_state == 3) then
        ui.set( aa.manual_state , 0)
        return
    end

    if left_state and m_state ~= 1 then
        ui.set( aa.manual_state , 1)
    end

    if right_state and m_state ~= 2 then
        ui.set( aa.manual_state , 2)
    end

    if backward_state and m_state ~= 3 then
        ui.set( aa.manual_state , 3)
    end
end

local menu_callback = function(e, menu_call)
    local state = not ui.get( aa.manualaa_checkbox ) -- or (e == nil and menu_call == nil)
    multi_exec(ui.set_visible, {
        [ aa.manual_left_hotkey ] = not state,
        [ aa.manual_right_hotkey ] = not state,
        [ aa.manual_back_hotkey ] = not state,
        [ aa.manual_state ] = false,
    })
end

ui.set_callback( aa.manualaa_checkbox , menu_callback)

function handle_manual_anti_aim()
    local direction = ui.get( aa.manual_state )

    manual_yaw = 
    {
        [0] = 0,
        [1] = -90, 
        [2] = 90,
        [3] = 0,
    }

    if ui.get( aa.manualaa_checkbox ) then
        if direction == 1 or direction == 2 then
            ui.set( ref_yaw_base, "Local view" )
        else
            ui.set( ref_yaw_base, "At targets" )
        end
    end

    if ui.get( aa.manualaa_checkbox ) then
        ui.set( ref_yaw_offset, manual_yaw[direction] )
    end


    local callback = enabled and client.set_event_callback or client.unset_event_callback
end

-- start of setup_command
local reset = false
local function on_setup_command( cmd )

    if ui.get( aa.legit_aa_on_e ) then
        local gun = entity.get_player_weapon( entity.get_local_player( ) )
        if gun ~= nil and entity.get_classname( gun ) == "CC4" then
            if cmd.in_attack == 1 then
                cmd.in_attack = 0 
                cmd.in_use = 1
            end
        else
            if cmd.chokedcommands == 0 then
                cmd.in_use = 0
            end
        end
    end

    -- this gets the desync angle of the local player
    if cmd.chokedcommands == 0 then
        angle = cmd.in_use == 0 and ui.get( ref_aa_enabled ) and ui.get( ref_body_yaw ) ~= "Off" and math.min( 57, math.abs( entity.get_prop( entity.get_local_player( ), "m_flPoseParameter", 11 )*120-60 ) ) or 0
    end


    --fakelag
    choked_commands = cmd.chokedcommands


    local bFreezePeriod = entity.get_prop(entity.get_game_rules(), "m_bFreezePeriod")
    if bFreezePeriod then
        INVERTS_INFO = 0
        ui.set( ref_fake_limit, 30 )
    end

    if ui.get(aa.ideal_peek) then
        ui.set(ref_doubletap[1], true)
        ui.set(ref_doubletap[2], "Always on")
        ui.set(ref_freestanding_key, "Always on")
        ui.set(ref_freestanding, "Default")
        ui.set(ref_fake_lag_limit, 1)
        reset = false
    else
        if not reset then
            ui.set(ref_doubletap[1], true)
            ui.set(ref_doubletap[2], "Toggle")
            ui.set(ref_freestanding_key, "On hotkey")
            ui.set(ref_freestanding, "Default")
            ui.set(ref_fake_lag_limit, 14)
            reset = true
        end
    end

    -- start of closest to crosshair check
    ui.set( ref_body_freestanding, false ) 
    local entindex = entity_get_local_player( )
    if entindex == nil then return end
    local lx,ly,lz = entity_get_prop( entindex, "m_vecOrigin" )
    if lx == nil then return end

    -- get closest player to crosshair
    local players = entity.get_players( true )    
    local pitch, yaw = client.camera_angles( )
    local vx, vy, vz = angle_to_vec( pitch, yaw )
    local closest_fov_cos = -1
    enemyclosesttocrosshair = nil
    for i=1, #players do
        local idx = players[ i ]
        if entity_is_alive( idx ) then
            local fov_cos = get_fov_cos( idx, vx, vy, vz, lx, ly, lz )
            if fov_cos > closest_fov_cos then
                closest_fov_cos = fov_cos
                enemyclosesttocrosshair = idx
            end
        end
    end
    -- end of closest to crosshair
end
-- end of setup command

-- start of on bullet impact function
-- this is for anti-bruteforcing ( detecting whether an enemy shot near you )
local function on_bullet_impact( c )
    if entity.is_alive( entity.get_local_player( ) ) then
        local ent = client.userid_to_entindex( c.userid )
        if not entity.is_dormant( ent ) and entity.is_enemy( ent ) then
            local ent_shoot = { entity.get_prop( ent, "m_vecOrigin" ) }
            ent_shoot[ 3 ] = ent_shoot[ 3 ]+entity.get_prop( ent, "m_vecViewOffset[2]" )
            local player_head = { entity.hitbox_position( entity.get_local_player( ), 0 ) }
            local closest = get_closest_point( ent_shoot, { c.x, c.y, c.z }, player_head )
            local delta = { player_head[ 1 ]-closest[ 1 ], player_head[ 2 ]-closest[ 2 ] }
            local delta_2d = math.sqrt( delta[ 1 ]^2+delta[ 2 ]^2 )
            if math.abs( delta_2d ) < 32 then
                INVERTS_INFO = INVERTS_INFO + 1
                should_swap = true
            end
        end
    end
end
-- end of on bullet impact function

function resethit( )
    allow_reset_hit = true
    low_delta_hit = false
end

function on_hit_low_delta( )
    if should_swap == true then
        low_delta_hit = true
        if is_in_range == true then
            if data.side == 1 then
                ui.set( ref_fake_limit, ( math.random( 25, 40 ) ) )
            elseif data.side == 2 then
                ui.set( ref_fake_limit, ( math.random( 22, 35 ) ) )
            end
        elseif is_in_range == false then
            if data.side == 1 then
                ui.set( ref_fake_limit, ( math.random( 28, 39 ) ) )
             elseif data.side == 2 then
                ui.set( ref_fake_limit, ( math.random( 40, 52 ) ) )
            end
        end
        should_swap = false
        allow_reset_hit = false
        local reset = 58
        client.delay_call( 2, resethit )
        client.delay_call( 2, ui_set, ref_fake_limit, reset )
    end
end

function in_air_anti( )
    if in_air( ) then
        ui.set( ref_yaw_offset, 0 )
        ui.set( ref_body_yaw, "Jitter" )
        ui.set( ref_body_yaw_offset, -1)
        ui.set( ref_fake_limit, 20)
        ui.set( ref_body_freestanding, true)
        AASTATE_INFO = "State Air S3"
    end
end

function menu( )
    ui.set_visible( ref_pitch,                  false )
    ui.set_visible( ref_yaw,                    false )
    ui.set_visible( ref_yaw_offset,             false )
    ui.set_visible( ref_body_yaw,               false )
    ui.set_visible( ref_body_yaw_offset,        false )
    ui.set_visible( ref_yaw_base,               false )
    ui.set_visible( ref_jitter,                 false )
    ui.set_visible( ref_jitter_slider,          false )
    ui.set_visible( ref_fake_limit,             false )
    ui.set_visible( ref_freestanding,           false )
    ui.set_visible( ref_edge_yaw,               false )
    ui.set_visible( ref_body_freestanding,      false )
end
client.set_event_callback( "paint", menu )

-- this is what stops the client_delay_call function from overlapping and causing fps issues
function resetshot( )
    SHOOTING_INFO = "FALSE"
end

-- this gets called back when the aimbot fires
function invert_anti_aim( g )
    SHOOTING_INFO = "TRUE"
    client.delay_call( 1, resetshot )
end

function legitaa( )
    ui.set( ref_yaw_base, "Local view" )
    ui.set( ref_yaw_offset, 180 )
    ui.set( ref_pitch, "Off" )
    ui.set( ref_body_yaw, "Static" )
    ui.set( ref_jitter, "Off" )
    ui.set( ref_jitter_slider, 0 )
    ui.set( ref_fake_limit, 58 )
    sj_r, sj_g, sj_b = 255, 0, 0
    ePeeking = true
    once_change = true
    if data.side == 1 then
        ui.set( ref_body_yaw_offset, 60 )
    else
    end
    if data.side == 2 then
        ui.set( ref_body_yaw_offset, -60 )
    else
    end
    AASTATE_INFO = "State Legit AA"

    -- this checks if you havent got the legit aakey pressed and sets data.side
    if ui.get( aa.legit_aa_hotkey ) == false and once_change == true and ui.get( aa.enable_checkbox ) == true then
        if ui.get( aa.freestand_mode_combobox ) == "Default" then
            if data.side == 1 then
                ui.set( ref_body_yaw_offset, -60 )
            end
            if data.side == 2 then
                ui.set( ref_body_yaw_offset, 60 )
            end
        end
        if ui.get( aa.freestand_mode_combobox ) == "Reversed" then
            if data.side == 1 then
                ui.set( ref_body_yaw_offset, 60 )
            end
            if data.side == 2 then
                ui.set( ref_body_yaw_offset, -60 )
            end
        end
        once_change = false
    end
    -- end of check
end

local callback = client.set_event_callback or client.unset_event_callback
callback("net_update_end", function( )
    if ui.get( aa.legmovement_checkbox ) then
        entity.set_prop(entity.get_local_player(), "m_flPoseParameter", 1, 0)
    end
end)

function legfucker( )
    local z = math.random( 1, 3 )
    if z == 1 then
        ui.set( ref_legmovement, "Never slide" )
    elseif z == 2 then
        ui.set( ref_legmovement, "Always slide" )
    elseif z == 3 then
        ui.set( ref_legmovement, "Never slide" )
    end
end

function is_slow_walking( )
    local slow_walking = false
    if not ui.get(hotkey_reference) then
        slow_walking = false
    elseif ui.get(hotkey_reference) then
        slow_walking = true
    end

    return slow_walking
end

function low_delta_slow_walk( )
    if is_slow_walking( ) then
        ui.set( ref_fake_limit, 31 )
        if force_left == 1 then
            data.side = 1
        end
    end
end

function dormancy_fix( )
    if enemy_dormant == true then
        ui.set( ref_yaw_offset, in_yaw )
        ui.set( ref_body_yaw, "Static" )  
    end
end

function handle_basics( )
    -- basic checkboxes and anti_aims
    if ui.get( aa.in_air_checkbox ) then
        in_air_anti( )
    end
    if ui.get( aa.increase_speed ) then
        dt_speed()
end

    if ui.get( aa.legit_aa_on_e ) then
        if client.key_state( 0x45 ) then
            ePeeking = true
            ui.set( ref_body_yaw, "Static" )
            if data.side == 1 then 
                ui.set( ref_body_yaw_offset, -30 )
            elseif data.side == 2 then
                ui.set( ref_body_yaw_offset, 30 )
            end
        elseif not client.key_state( 0x45 ) then
            ePeeking = false
        end
    elseif not ui.get( aa.legit_aa_on_e ) then
        ePeeking = false
    end

    -- updates our anti-aim for after legit aa on key
    ui.set( ref_pitch, "Default" )
    -- end of check

    -- checks if the enemy is dormant
    if not entity.is_dormant( player ) and entity.is_alive( player ) then
        enemy_dormant = false
    else
        enemy_dormant = true
    end
    -- end of dormancy check

    -- checks if the smart jitter is on and if you are dormant it forces your yaw bac to inrange yaw so the e-peeking still works
    if ui.get( aa.jitter_checkbox ) and enemy_dormant == true and not ui.get(aa.manualaa_checkbox) then
        dormancy_fix( )
    else
    end
    -- end of check

    -- this checks if you have the legmovement option on and what it should do
    if ui.get( aa.legmovement_checkbox ) == true then
        legfucker( )
    end
    -- end of check

    -- this checks if you have pressed the legit aa key and if you have it sets your aa to a "legit aa" format
    if ui.get( aa.legit_aa_hotkey ) == true and ui.get( aa.legit_aa_on_e ) and ui.get( aa.enable_checkbox ) == true then
        legitaa( )
    else
    end
    -- end of legit aa check
end

function handle_indicator_colours( )
    -- this changes the colour of the arrows depending on what delta you have
    if allow_reset_hit == true then
        dr, dg, db, da = cac_r, cac_g, cac_b, cac_a
    else
        if ui.get( ref_fake_limit ) <= 37 then
            dr, dg, db, da = cac_r, cac_g, cac_b, alpha
        elseif ui.get( ref_fake_limit ) > 37 then
            dr, dg, db, da = cac_r, cac_g, cac_b, alpha
        end
    end
    -- end of check
end

local function is_under_health( )
    under_health = false
    if ( entity_get_prop( entity.get_local_player( ), "m_iHealth" ) <= 28 ) then
        under_health = true
    else
        under_health = false
    end
    return under_health
end


local function compensate_spread( )
    -- this gets your velocity and if your velocity is < 0 (aka going forwards) it will convert your velocity back to positive
    vel = entity.get_prop( entity.get_local_player( ), "m_vecVelocity" )
    if vel < 0 then
        vel = vel*-1
    end

    -- spread compensation calculation for dt_hitchance
    spread_compensation = ( vel * 0.037 )
    if spread_compensation < 1 then
        spread_compensation = 1
    end

    return spread_compensation
end

function handle_anti_aims( )
  

    if ui.get( aa.lowdelta_slow_walk_checkbox ) then
        if is_slow_walking( ) then
            ui.set(ref_body_yaw_offset, 40)
        end
    end

    -- if you are out of range of the enemy it sets your yaw to the out of range yaw
    if is_in_range == false and ui.get( aa.jitter_checkbox ) then
        if not ui.get( aa.manualaa_checkbox ) then
            if ePeeking == false then
                ui.set( ref_yaw_offset, out_yaw )
            end
        else
        end
    end
    -- end of check


    -- checks if you have safeyaw enabled and if you are under under health
    -- it also checks if you have peek out or safe head on
    if is_under_health( ) then
        safe_yaw = 10
    elseif data.side == 2 then
        safe_yaw = -10
    end
    -- end of safe yaw check
end




-- start of on run command
local on_run_command = function( cmd )
    -- Checks if the local player is alive
    local local_player = entity.get_local_player( )
    if ( not entity.is_alive( local_player ) ) then
        return     
    end
    -- This applies the fake_limit_randomisation 
    if ui.get( aa.jitter_checkbox ) then
        fake_limit_randomisation( )
    end

    -- Slow walk anti-aim
    if is_slow_walking( ) then -- If slow walking and anti-aim right hybrid is not enabled
        slow_walking_aa( )
    end

    if ePeeking == true then ui.set( ref_freestanding, "-" ) else ui.set( ref_freestanding, "Default" ) end
    if ui.get( aa.lowdelta_slow_walk_checkbox ) then low_delta_slow_walk( ) end

    if not ui.get( aa.manualaa_checkbox) then
        ui.set( ref_yaw_base, "At targets" )
    end

    handle_manual_anti_aim()

    -- forces should_swap to false so bruteforce resets
    should_swap = false

    -- handle functions
    menu( )
    side_freestanding( )
    handle_indicator_colours( )
    handle_anti_aims( )
    handle_basics( )

    -- data check if the nearest option is nil and if not it ends the function
    data2 = get_nearest( )
    if ( data2 == nil ) then
        return
    end
    if ( data2.distance < 120 ) then
        is_in_range = true
    else
        is_in_range = false
    end
    -- end of check
end

function fake_randomisation( )
    ui.set(ref_fake_limit, math.random( 25, 40 ) ) randomiser_allowed = true
end

function fake_limit_randomisation( )
    -- This is for fake limit ( low delta ) randomisation
    if ui.get( aa.jitter_checkbox ) then
        if randomiser_allowed == true then
            client.delay_call( 0.02, fake_randomisation ) randomiser_allowed = false
        end
    end
    -- This will only be called in static anti-aim scenarios
end

function slow_walking_aa( )
    ui.set( ref_yaw_offset, -5 )
    ui.set( ref_jitter, "Offset" )
    ui.set( ref_jitter_slider, 11 )
    ui.set( ref_body_yaw, "Static" )
    ui.set( ref_body_yaw_offset, 28 )
end

function right_static( )
    -- Actual anti-aim
    if ui.get( aa.freestand_mode_combobox ) == "Default" then
        body_yaw = -116
    elseif ui.get( aa.freestand_mode_combobox ) == "Reversed" then
        body_yaw = 116
    end
    -- Changes yaw if safe yaw combobox is enabled
    if is_under_health( ) then
        peek_yaw = 11
        AASTATE_INFO = "State Right S3"
    else
        peek_yaw = ( in_yaw + 1 )
        AASTATE_INFO = "State Right S1"
    end
    -- If you should anti-bruteforce it will change your body yaw to the opposite side.
    if should_swap == true and ui.get( aa.jitter_checkbox ) then
        body_yaw = body_yaw * -1
        should_swap = false
        ANTIBF_INFO = "RP_S1-3_INVERT"
        client.delay_call( 3 , ui_set, ref_body_yaw_offset, -116 )
    end
    -- Sets your yaw to the correct yaw
    ui.set( ref_yaw_offset, peek_yaw )
    ui.set( ref_body_yaw_offset, body_yaw )
    ui.set( ref_body_yaw, "Static" )
    ui.set( ref_jitter, "Random" )
    ui.set( ref_jitter_slider, 2 )
end

function right_static_alternative( )
    -- Actual anti-aim
    if ui.get( aa.freestand_mode_combobox ) == "Default" then
        body_yaw = -120
    elseif ui.get( aa.freestand_mode_combobox ) == "Reversed" then
        body_yaw = 121
    end
    -- Changes yaw if safe yaw combobox is enabled
    if is_under_health( ) then
        peek_yaw = 17
        AASTATE_INFO = "State Right S4"
    else
        peek_yaw = ( in_yaw + 1 )
        AASTATE_INFO = "State Right S2"
    end
    -- If you should anti-bruteforce it will change your body yaw to the opposite side.
    if should_swap == true and ui.get( aa.jitter_checkbox ) then
        body_yaw = body_yaw * -1
        should_swap = false
        ANTIBF_INFO = "RP_S2-4_INVERT"
        client.delay_call( 3 , ui_set, ref_body_yaw_offset, -116 )
    end
    -- Sets your yaw to the correct yaw
    ui.set( ref_yaw_offset, peek_yaw )
    ui.set( ref_body_yaw_offset, body_yaw )
    ui.set( ref_body_yaw, "Static" )
    ui.set( ref_jitter, "Off" )
    ui.set( ref_jitter_slider, 1 )
end

function left_static( )
    -- Actual anti-aim
    if ui.get( aa.freestand_mode_combobox ) == "Default" then
        body_yaw = 113
    elseif ui.get( aa.freestand_mode_combobox ) == "Reversed" then
        body_yaw = -113
    end
    -- Changes yaw if safe yaw combobox is enabled
    if is_under_health( ) then
        peek_yaw = -17
        AASTATE_INFO = "State Left S3"
    else
        peek_yaw = ( in_yaw )
        AASTATE_INFO = "State Left S1"
    end
    if should_swap == true and ui.get( aa.jitter_checkbox ) then
        body_yaw = body_yaw * -1
        should_swap = false
        ANTIBF_INFO = "LP_S1-3_INVERT"
        client.delay_call( 3, ui_set,  ref_body_yaw_offset, 113 )
    end
    ui.set( ref_yaw_offset, peek_yaw )
    ui.set( ref_body_yaw_offset, body_yaw )
    ui.set( ref_body_yaw, "Static" )
    ui.set( ref_jitter, "Random" )
    ui.set( ref_jitter_slider, 2 )
end

function left_static_alternative( )
    -- Actual anti-aim
    if ui.get( aa.freestand_mode_combobox ) == "Default" then
        body_yaw = 116
    elseif ui.get( aa.freestand_mode_combobox ) == "Reversed" then
        body_yaw = -116
    end
    -- Changes yaw if safe yaw combobox is enabled
    if is_under_health( ) then
        peek_yaw = -17
        AASTATE_INFO = "State Left S4"
    else
        peek_yaw = ( in_yaw )
        AASTATE_INFO = "State Left S2"
    end
    if should_swap == true and ui.get( aa.jitter_checkbox ) then
        body_yaw = body_yaw * -1
        should_swap = false
        ANTIBF_INFO = "LP_S2-4_INVERT"
        client.delay_call( 3, ui_set,  ref_body_yaw_offset, 113 )
    end
    ui.set( ref_yaw_offset, peek_yaw )
    ui.set( ref_body_yaw_offset, body_yaw )
    ui.set( ref_body_yaw, "Static" )
    ui.set( ref_jitter, "Off" )
    ui.set( ref_jitter_slider, 0 )
end


-- useless, just for testing new offsets
-- jittertestrj = ui.new_slider( aatab[1], aatab[2], "test side jitters", 0, 180, 0, true, ""  ) -- ui.get( jittertestrj )
-- backtestjt = ui.new_slider( aatab[1], aatab[2], "test back jitters", 0, 180, 0, true, "" ) -- ui.get( backtestjt )

function back_jitter( )
    if is_in_range == true then
        if is_under_health( ) then
            if data.side == 1 then
                local yaw_offset = 15
                ui.set( ref_yaw_offset, yaw_offset )
                AASTATE_INFO = "State Dynamic S3"
            elseif data.side == 2 then
                local yaw_offset = -15
                ui.set( ref_yaw_offset, yaw_offset )
                AASTATE_INFO = "State Dynamic S1"
            end
        else
            ui.set( ref_yaw_offset, in_yaw )
            AASTATE_INFO = "State Dynamic S1"
        end
        AASTATE_INFO = "State Dynamic S2"
    elseif is_in_range == false and ePeeking == false then
        ui.set( ref_yaw_offset, out_yaw )
        AASTATE_INFO = "State Dynamic S4"
    end
    ui.set( ref_body_yaw, "Jitter" )
    ui.set( ref_jitter, "Offset" )
    ui.set( ref_jitter_slider, 10 )
end

function static_freestanding( )
    -- Actual anti-aim
    if is_in_range == true then
        ui.set(ref_body_yaw, "Static")
        if data.side == 1 then
            if should_swap == true and ui.get( aa.jitter_checkbox ) then
                static_yaw = static_yaw * -3
                should_swap = false
                ANTIBF_INFO = "FS_S1_INVERT"
            end
            ui.set(ref_body_yaw_offset, static_yaw)
            AASTATE_INFO = "State S1"
        elseif data.side == 2 then
            if should_swap == true and ui.get( aa.jitter_checkbox ) then
                static_yaw = static_yaw * -3
                should_swap = false
                ANTIBF_INFO = "FS_S1_INVERT"
            end
            ui.set(ref_body_yaw_offset, static_yaw)
            AASTATE_INFO = "State S1"
        end
    end
    if is_in_range == true then
        if is_under_health( ) then
            if data.side == 1 then
                local yaw_offset = 5
                ui.set( ref_yaw_offset, yaw_offset )
                AASTATE_INFO = "State S4"
            elseif data.side == 2 then
                local yaw_offset = -5
                ui.set( ref_yaw_offset, yaw_offset )
                AASTATE_INFO = "State S4"
            end
        else
            AASTATE_INFO = "State S2"
            ui.set( ref_yaw_offset, in_yaw )
        end
    elseif is_in_range == false and ePeeking == false then
        AASTATE_INFO = "State S3"
        ui.set( ref_yaw_offset, out_yaw )
    end
    ui.set( ref_body_yaw, "Jitter" )
    ui.set( ref_jitter, "Offset" )
    ui.set( ref_jitter_slider, 14 )
end

function handle_dt_indicator( )
    -- checks if dt is inactive, charging or charged
    if ui.get( ref_doubletap[ 1 ] ) and ui.get( ref_doubletap[ 2 ] ) then
        if is_dt( ) then
            doubletap_one = true
            doubletap_two = false
            doubletap_three = false
        else
            doubletap_one = false
            doubletap_two = true
            doubletap_three = false
        end
    else
        doubletap_one = false
        doubletap_two = false
        doubletap_three = true
    end

    -- this checks what DT msg should be displayed for the DT indicator and what colours it show be
    -- if the double tap is charged show the colour we have chosen for that
    if doubletap_one == true then
        dt_r, dt_g, dt_b = 154, 255, 31
        dtalpha = 255
        dtmsg = "DT"
    else
    end

    -- if the doubletap is charging display this colour
    if doubletap_two == true then
        dt_r, dt_g, dt_b = 255, 0, 0
        dtalpha = 255
        dtmsg = "DT"
    else
    end

    -- if doubletap is inactive then do not display any text
    if doubletap_three == true then
        dt_r, dt_g, dt_b = 0, 0, 0
        dtalpha = 255
        dtmsg = " DT "
    else
    end
    -- end of dt checks
end

function handle_indicator_positions( )
    -- the worlds messiest and hardest code to follow for changing where the indicators should be on the screen
    banepa_y = 65
    if show_ln == 1 then
        animState_y = 75
        if show_aas == 1 then
            dtState_y = 85
        elseif show_aas == 0 then
            dtState_y = 75
        end
    elseif show_ln == 0 then
        animState_y = 65
        if show_aas == 1 then
            dtState_y = 75
        elseif show_aas == 0 then
            dtState_y = 65
        end 
    end
    if not ui.get( ref_osaa_hkey ) then
        if ( doubletap_one == true or doubletap_two == true ) then
            if show_ln == 1 then
                if show_aas == 1 then
                    freestandState_y = 95
                elseif show_aas == 0 then
                    freestandState_y = 85
                end
            elseif show_ln == 0 then
                if show_aas == 1 then
                    freestandState_y = 85
                elseif show_aas == 0 then
                    freestandState_y = 75
                end
            end
        elseif doubletap_three == true then
            if show_ln == 1 then
                if show_aas == 1 then
                    freestandState_y = 85
                elseif show_aas == 0 then
                    freestandState_y = 75
                end
            elseif show_ln == 0 then
                if show_aas == 1 then
                    freestandState_y = 75
                elseif show_aas == 0 then
                    freestandState_y = 65
                end
            end
        end
    elseif ui.get( ref_osaa_hkey ) then
        if ( doubletap_one == true or doubletap_two == true ) then
            if show_ln == 1 then
                if show_aas == 1 then
                    hsState_y = 95
                elseif show_aas == 0 then
                    hsState_y = 85
                end
            elseif show_ln == 0 then
                if show_aas == 1 then
                    hsState_y = 85
                elseif show_aas == 0 then
                    hsState_y = 75
                end
            end
        elseif doubletap_three == true then
            if show_ln == 1 then
                if show_aas == 1 then
                    hsState_y = 85
                elseif show_aas == 0 then
                    hsState_y = 75
                end
            elseif show_ln == 0 then
                if show_aas == 1 then
                    hsState_y = 75
                elseif show_aas == 0 then
                    hsState_y = 65
                end
            end
        end
        if ( doubletap_one == true or doubletap_two == true ) then
            if show_ln == 1 then
                if show_aas == 1 then
                    freestandState_y = 105
                    spstate_y = 115
                elseif show_aas == 0 then
                    freestandState_y = 95
                    spstate_y = 105
                end
            elseif show_ln == 0 then
                if show_aas == 1 then
                    freestandState_y = 95
                elseif show_aas == 0 then
                    freestandState_y = 85
                end
            end
        elseif doubletap_three == true then
            if show_ln == 1 then
                if show_aas == 1 then
                    freestandState_y = 95
                    spstate_y = 105
                elseif show_aas == 0 then
                    freestandState_y = 85
                    spstate_y = 95
                end
            elseif show_ln == 0 then
                if show_aas == 1 then
                    freestandState_y = 85
                    spstate_y = 95
                elseif show_aas == 0 then
                    freestandState_y = 75
                    spstate_y = 85
                end
            end
        end
    end
    -- the end of the worlds messiest and hardest code to follow for changing where the indicators should be on the screen
end

function handle_colours_and_alpha( )
    -- these are the colours for each indicator
    cac_r, cac_g, cac_b, cac_a = ui.get( visuals.arrow_colourpicker ) -- Peeking arrows
    byc_r, byc_g, byc_b, byc_a = ui.get( visuals.banepa_colourpicker ) -- thoryaw text indicator
    --end
    
    -- pulsating alpha ( yoinked from sigmas lua )
    if ( cur_alpha < min_alpha+2 ) then
        target_alpha = max_alpha
    elseif ( cur_alpha > max_alpha-2 ) then
        target_alpha = min_alpha
    end
    cur_alpha = cur_alpha+( target_alpha-cur_alpha )*speed*( globals.absoluteframetime( )*60 )
    alpha = math.min( 255, cur_alpha )
end

function handle_multi_selects( )
    -- setting variables for multiselect
    mid_text = 0 crooked_arrows = 0 crooked_arrows_two = 0 show_ln = 0 show_aas = 0 show_be = 0 in_air_fl = 0 wh_mov_fl = 0 on_sta_fl = 0 on_vis_fl = 0 wh_vis_fl = 0
    -- end
    -- references for multiselects
    local _inds = ui.get( visuals.indicators_multiselect ) -- Indicators multiselect
    local _textinds = ui.get( visuals.textindicators_multiselect ) -- Text indicators multiselect
    -- End of references

    -- this is what sets the variables  for the indicators multiselect
    if contains( _inds, "Screen indicators" ) then mid_text = 1 end -- Middle text indicators option
    if contains( _inds, "Arrows" ) then crooked_arrows = 1 end -- Peeking arrows indicators option
    -- end of variables for indicators multiselect
    -- sets the variables for text indicators multi select
    if contains( _textinds, "Indicators" ) then show_ln = 1 end -- LUA name middle indicators option
    if contains( _textinds, "AA State" ) then show_aas = 1 end -- Anti-aim state middle indicators option
    if contains( _textinds, "Ragebot state indicators" ) then show_be = 1 end -- Bind and exploits middle indicators option
    -- end of variables for text indicators multi select
end

function handle_main_indicators( )
    --this gets the client screensize
    local scrsize_x, scrsize_y = client_screensize( )
    local center_x, center_y = scrsize_x/2, scrsize_y/2
    local scrleft_x, scrleft_y = (( scrsize_x-scrsize_x ) +1 ), (( scrsize_y-scrsize_y ) +1 )
    --end
    local x, x2 = 18, 2

    local tags =
     {
        [0] = "⚒️",
        [1] = "⚒️",
        [2] = "⚒️",
        [3] = "⚒️",
        [4] = "T⚒️",
        [5] = "Th⚒️",
        [6] = "Th⚒️",
        [7] = "Tho⚒️",
        [8] = "Tho⚒️",
        [9] = "Thor⚒️",
        [10] = "Thor⚒️",
        [11] = "Thor⚒️",
        [12] = "ThorY⚒️",
        [13] = "ThorY⚒️",
        [14] = "ThorY⚒️",
        [15] = "ThorYa⚒️",
        [16] = "ThorYa⚒️",
        [17] = "ThorYaw⚒️",
        [18] = "ThorYaw⚒️",
        [19] = "ThorYaw⚒️",
        [20] = "ThorYa⚒️",
        [21] = "ThorYa⚒️",
        [22] = "ThorY⚒️",
        [23] = "ThorY⚒️",
        [24] = "ThorY⚒️",
        [25] = "Thor⚒️",
        [26] = "Thor⚒️",
        [27] = "Tho⚒️",
        [28] = "Tho⚒️",
        [29] = "Th⚒️",
        [30] = "Th⚒️",
        [31] = "T⚒️",
        [32] = "T⚒️",
        [33] = "T⚒️",
        [34] = "⚒️",
        [35] = "⚒️",
        [36] = "⚒️",
        [37] = "⚒️",
}
    draw_gradient( c, center_x, scrsize_y-x, 120, x2, mt_r, mt_g, mt_b, 125, m_r, m_g, m_b, m_a, true)
    draw_gradient( c, center_x, scrsize_y-x, -120, x2, mt_r, mt_g, mt_b, 255, m_r, m_g, m_b, m_a, true)
    draw_gradient( c, center_x, scrsize_y-x, 120, x, 0, 0, 0, 175, 120, 0, 0, 0, true)
    draw_gradient( c, center_x, scrsize_y-x, -120, x, 0, 0, 0, 175, 120, 0, 0, 0, true)
    renderer.text(center_x, scrsize_y - 8, 250, 255, 255, 255, "c", 0, tags[math.floor((globals.curtime() * 4.5) % 37)] .. " | " .. nickname .. " " .. usertype .. "")
    renderer.text(scrsize_x - 1, scrsize_y - 3, 250, 255, 255, 255, "c", 0, ANTIBF_INFO)
    if  entity.is_alive( entity.get_local_player( ) ) then
        -- this checks what font we should use for our indicators
        -- indicator font style block
        if ui.get( visuals.fontstyle_combobox ) == "Block" then
            if ui.get( visuals.centered_text ) then
                fontstyle = "dc-"
            else
                fontstyle = "d-"
            end
        end

        -- indicator font style default
        if ui.get( visuals.fontstyle_combobox ) == "Default" then
            if ui.get( visuals.centered_text ) then
                fontstyle = "dc"
            else
                fontstyle = "d"
            end
        end

        -- indicator font style bold
        if ui.get( visuals.fontstyle_combobox ) == "Bold" then
            if ui.get( visuals.centered_text ) then
                fontstyle = "bc"
            else
                fontstyle = "b"
            end
        end

        client.set_event_callback( "aim_fire", invert_anti_aim )


        -- this checks if we should draw the write yaw info and what side our data.side is to show if yaw is correct
        if show_yaw == 1 then
            if data.side == 1 then
                client_draw_text( c, center_x+10, center_y+( ui.get( visuals.indicatorypos_slider )+freestandState_y+10 ), 255, 255, 255, 255, "dc-", 0, ui.get( ref_body_yaw_offset ) )
            else
                client_draw_text( c, center_x+10, center_y+( ui.get( visuals.indicatorypos_slider )+freestandState_y+10 ), 255, 255, 255, 255, "dc-", 0, "0" )
            end
            if data.side == 2 then
                client_draw_text( c, center_x-10, center_y+( ui.get( visuals.indicatorypos_slider )+freestandState_y+10 ), 255, 255, 255, 255, "dc-", 0, ui.get( ref_body_yaw_offset ) )
            else
                client_draw_text(c, center_x-10, center_y+( ui.get( visuals.indicatorypos_slider )+freestandState_y+10 ), 255, 255, 255, 255, "dc-", 0, "0" )
            end
        else
        end
        -- end of check

        -- indicators good luck  lol
        if mid_text == 1 and show_ln == 1 then                                                                                       -- this shows that we have the LUA name chosen in indicators
            client_draw_text( c, center_x+0, center_y+( ui.get( visuals.indicatorypos_slider )+banepa_y ), byc_r, byc_g, byc_b, byc_a, fontstyle, 0, "ThorYaw" )
        else
        end
        
        -- this shows that we have the On-shot jitter option chosen in indicators
        if mid_text == 1 and show_aas == 1 then -- ANIM shows that we are in a state where our head is fakelagging or we are in a weapon_fire event
            if ui.get( ref_fakeduck ) and ePeeking == false then
            client_draw_text( c, center_x+0, center_y+( ui.get( visuals.indicatorypos_slider )+animState_y ), 0, 0, 0, 255, fontstyle, 0, "DUCKING" )
            client_draw_text( c, center_x+0, center_y+( ui.get( visuals.indicatorypos_slider )+animState_y ), 255, 179, 71, alpha, fontstyle, 0, "DUCKING" )
            end
            if ePeeking == false and not is_under_health( ) and not ui.get(ref_fakeduck) then -- DYNAMIC shows that we are in a state where our head is safe and we can't be onshotted or we are not fakelagging
                client_draw_text( c, center_x+0, center_y+( ui.get( visuals.indicatorypos_slider )+animState_y ), 208, 160, 210, 255, fontstyle, 0, AASTATE_INFO )
            else
            end
            if is_under_health( ) and ePeeking == false and not ui.get(ref_fakeduck) then
                client_draw_text( c, center_x+0, center_y+( ui.get( visuals.indicatorypos_slider )+animState_y ), 208, 160, 210, 255, fontstyle, 0, "STATE UNSAFE" )
            else
            end
            if ePeeking == true then 
                client_draw_text( c, center_x+0, center_y+( ui.get( visuals.indicatorypos_slider )+animState_y ), 208, 160, 210, 255, fontstyle, 0, "STATE S1" )
            else
            end
        end
        -- end of mix text


        -- displays the dt indicators
        if mid_text == 1 and show_be == 1 then
            client_draw_text( c, center_x+0, center_y+( ui.get( visuals.indicatorypos_slider )+dtState_y), dt_r, dt_g, dt_b, dtalpha, fontstyle, 0, dtmsg )
        else
        end

        if mid_text == 1 and ui.get( ref_osaa_hkey ) and show_be == 1 then
            client_draw_text( c, center_x+0, center_y+(ui.get( visuals.indicatorypos_slider )+hsState_y ), 124, 195, 13, 255, fontstyle, 0, "ON-SHOT" )
        else
        end
        if ui.get( ref_freestanding_key ) then fstand = 1 else fstand = 0 end

        if mid_text == 1 and fstand == 1 and show_be == 1 then
            client_draw_text( c, center_x+0, center_y+( ui.get( visuals.indicatorypos_slider )+freestandState_y ), 97, 223, 255, 255, fontstyle, 0, "FREESTANDING" )
        else
        end
        -- end

        -- setup arrow indicator
        arrowleft = "<"
        arrowright = ">"
        arrowdown = "v"
        darrowleft = "<"
        darrowright = ">"
        dplacementx = 69
        dplacementxtwo = 70
        dplacementy = 1
        dplacementytwo = 0
        darrowsize = "cb+"
        -- setup end
    end
end

function handle_main_anti_aim( )
        local scrsize_x, scrsize_y = client_screensize( )
        local center_x, center_y = scrsize_x/2, scrsize_y/2
        local scrleft_x, scrleft_y = (( scrsize_x-scrsize_x ) +1 ), (( scrsize_y-scrsize_y ) +1 )

        if ui.get( aa.edge_yaw_checkbox ) and not can_enemy_hit_head( enemyclosesttocrosshair ) and not in_air() and not ui.get( ref_fakeduck ) and ePeeking == false then
            ui_set( ref_edge_yaw, true )
        else
            ui_set( ref_edge_yaw, false )
        end

        if ui.get( aa.jitter_checkbox ) and ui.get( aa.enable_checkbox ) == true then
            local inverter_enemy        = { }
            local old_inverter_enemy    = { }
            for i = 1 , 30 do
                inverter_enemy[i]       = 1
                old_inverter_enemy[i]   = 1
            end

            local current_inverter      = 1
            local current_old_inverter  = 1
            local closest_fov           = 100000
            local needed_player         = -1
            local player_list           = entity.get_players( true )
            local x,y,z                 = client.eye_position( )
            local eye_pos               = Vector3( x, y, z )
            x,y,z                       = client.camera_angles( )
            local cam_angles            = Vector3( x, y, z )
            local is_local_alive        = entity.is_alive( entity.get_local_player( ) )

            for i = 1 , #player_list do
                player                  = player_list[ i ]
                if not entity.is_dormant( player ) and entity.is_alive( player ) then
                    if is_enemy_peeking( player ) or is_local_peeking_enemy( player ) then
                        last_time_peeked        = globals.curtime( )
                        local enemy_head_pos    = Vector3( entity.hitbox_position( player, 0 ) )
                        local current_fov       = get_FOV( cam_angles,eye_pos, enemy_head_pos )
                        --client.log(current_fov)
                        if current_fov < closest_fov then
                            closest_fov         = current_fov
                            needed_player       = player
                        end
                    end
                end
            end

            if best_player ~= nil and entity.is_alive( best_player ) and entity.is_enemy( best_player ) and not entity.is_dormant( best_player ) then
                needed_player   = best_player
            else
                best_player     = nil
            end
            
            if needed_player ~= -1 and is_local_alive then
                current_inverter        = inverter_enemy[ needed_player ]
                current_old_inverter    = old_inverter_enemy[ needed_player ]
                --change_aa(needed_player)
                local color_left = data.side == 2
                local color_right = not color_left
                if not entity.is_dormant( player ) and entity.is_alive( player ) and ePeeking == false then
                    if ui.get( aa.jitter_checkbox) and ( ( is_enemy_peeking( player ) or is_local_peeking_enemy( player ) ) ) == true and is_in_range == true and not in_air( ) then
                        if color_right then
                            if crooked_arrows == 1 then
                            client_draw_text( c, center_x+50, center_y-3, dr, dg, db, da, "c+", 0, arrowright )
                            client_draw_text( c, center_x-50, center_y-3, 255, 255, 255, 255, "c+", 0, arrowleft )
                            else
                            end
                            right_static( )    
                        else
                            if crooked_arrows == 1 then
                            client_draw_text( c, center_x-50, center_y-3, dr, dg, db, da, "c+", 0, arrowleft )
                            client_draw_text( c, center_x+50, center_y-3, 255, 255, 255, 255, "c+", 0, arrowright )
                            else
                            end
                            left_static( )
                        end
                    else
                        if ui.get( aa.enable_checkbox ) and is_in_range == true and ePeeking == false and not in_air( ) then
                            if color_right then
                                if crooked_arrows == 1 then
                                client_draw_text( c, center_x+63, center_y-3, dr, dg, db, da, "c+", 0, arrowright )
                                client_draw_text( c, center_x+50, center_y-3, dr, dg, db, da, "c+", 0, arrowright )
                                client_draw_text( c, center_x-50, center_y-3, 255, 255, 255, 255, "c+", 0, arrowleft )
                                else
                                end
                                right_static_alternative( )
                            else
                                if crooked_arrows == 1 then
                                client_draw_text( c, center_x-63, center_y-3, dr, dg, db, da, "c+", 0, arrowleft )
                                client_draw_text( c, center_x-50, center_y-3, dr, dg, db, da, "c+", 0, arrowleft )
                                client_draw_text( c, center_x+50, center_y-3, 255, 255, 255, 255, "c+", 0, arrowright )
                                else
                                end
                                left_static_alternative( )
                            end
                        elseif ePeeking == false and not in_air( ) then
                            back_jitter( )
                        end
                    end
                end
            else
                if ePeeking == false and not in_air( ) then
                    static_freestanding( )
                end
            end
        end
end

local function draw_container(x, y, w, h, header, a)
    local c = {10, 60, 40, 40, 40, 60, 20}

    for i = 0,6,1 do
        renderer.rectangle(x+i, y+i, w-(i*2), h-(i*2), c[i+1], c[i+1], c[i+1], a)
    end

    if header then
        local x_inner, y_inner = x+7, y+7
        local w_inner = w-14

        renderer.gradient(x_inner, y_inner, math.floor(w_inner/2), 1, m_r, m_g, m_b, a, mt_r, mt_g, mt_b, a, true)
        renderer.gradient(x_inner+math.floor(w_inner/2), y_inner, math.ceil(w_inner/2), 1, mt_r, mt_g, mt_b, a, m_r, m_g, m_b, a, true)

        local a_lower = a*0.2
        renderer.gradient(x_inner, y_inner+1, math_floor(w_inner/2), 1, 59, 175, 222, a_lower, 202, 70, 205, a_lower, true)
        renderer.gradient(x_inner+math.floor(w_inner/2), y_inner+1, math.ceil(w_inner/2), 1, 202, 70, 205, a_lower, 201, 227, 58, a_lower, true)
    end
end

-- this is the paint function
local on_paint = function( )
    if ui.get( aa.configure_combobox ) == "Anti-aim" then
        menu_callback( true, true )
    end
    bind_system:update( )

    -- this is for low delta changing
    if ui.get( aa.enable_checkbox ) and ui.get( aa.jitter_checkbox ) and allow_reset_hit == true then
        on_hit_low_delta( )
    end
    -- end of low delta change
    handle_dt_indicator( )
    handle_indicator_positions( )
    handle_colours_and_alpha( )
    handle_multi_selects( )
    handle_main_indicators( )
    handle_main_anti_aim( )
end

local on_player_hurt = function( e )
    -- checks if the invert_desync_checkbox is on and if it doesnt then it returns
    if not ui.get( aa.jitter_checkbox ) then
        return
    end
    -- checks who is shooting at us and if we get hit or not
    local me = entity.get_local_player( )
    local userid, attacker = client.userid_to_entindex( e.userid ), client.userid_to_entindex( e.attacker )

    -- check if we're the one who got hurt and not the one who hurt us
    if me == userid and me ~= attacker then
        -- if so, set the last side to '0' so the anti-aim updates
        data.last_side = 0
        -- update our smart mode info
        data.last_hit = globals.curtime( )
        data.hit_side = data.side
    end

    local hitgroups = { "generic body", "head", "chest", "stomach", "left arm", "right arm", "left leg", "right leg", "neck", "unsure", "gear" }
    local attN = entity.get_player_name(client.userid_to_entindex( e.attacker ) )
    if client.userid_to_entindex( e.userid ) == entity.get_local_player( ) then
        local attN = entity.get_player_name(client.userid_to_entindex( e.attacker ) )
        if entity.get_player_name( client.userid_to_entindex( e.attacker ) ) == "unknown" then attN = "world" end
        if hitgroups[e.hitgroup + 1] == "HEAD" then
            webhook_two( "User: " .. nickname .. " was " .. "hit in " .. ( hitgroups[e.hitgroup + 1] or '?' ) .. " for " .. e.dmg_health .. " ( anti-bruteforce: " .. ANTIBF_INFO .. "[" .. INVERTS_INFO .. "]" .. " │ anti-aim_state: " .. AASTATE_INFO .. " │ is shooting: " .. SHOOTING_INFO .. ")")
        end
    end
end

-- callback variable
local callback = client.set_event_callback or client.unset_event_callback
-- register / unregister our callbacks
client.set_event_callback( "setup_command", on_setup_command )
client.set_event_callback( "run_command", on_run_command )
client.set_event_callback( "paint", on_paint )
client.set_event_callback( "player_hurt", on_player_hurt )
client.set_event_callback( "bullet_impact", on_bullet_impact )

-- Execute this whenever the script is first enabled

local handle_aa_visibility = function( )
     local enabled = ui.get( aa.enable_checkbox )

    -- Update the anti-aim elements visibility
    ui.set_visible( aa.aaa, ui.get( aa.configure_combobox ) == "Info about lua" and enabled)
    ui.set_visible( aa.kkk, ui.get( aa.configure_combobox ) == "Info about lua" and enabled)
    ui.set_visible( aa.hhh, ui.get( aa.configure_combobox ) == "Info about lua" and enabled)
    ui.set_visible( aa.ggg, ui.get( aa.configure_combobox ) == "Info about lua" and enabled)
    ui.set_visible( aa.fff, ui.get( aa.configure_combobox ) == "Info about lua" and enabled)
    ui.set_visible( aa.aaa2, ui.get( aa.configure_combobox ) == "Info about lua" and enabled)

    ui.set_visible( aa.increase_speed, ui.get( aa.configure_combobox ) == "Ragebot" and enabled) 
    ui.set_visible( aa.dt_accuracy, ui.get( aa.configure_combobox ) == "Ragebot" and enabled)
    ui.set_visible( aa.ideal_peek, ui.get( aa.configure_combobox ) == "Ragebot" and enabled )

    ui.set_visible( aa.freestand_mode_combobox, ui.get( aa.configure_combobox ) == "Anti-aim" and enabled )
    ui.set_visible( aa.jitter_checkbox, ui.get( aa.configure_combobox ) == "Anti-aim" and enabled )
    ui.set_visible( aa.manualaa_checkbox, ui.get( aa.configure_combobox ) == "Anti-aim" and enabled )
    ui.set_visible( aa.manual_right_hotkey, ui.get( aa.configure_combobox ) == "Anti-aim" and enabled )
    ui.set_visible( aa.manual_back_hotkey, ui.get( aa.configure_combobox ) == "Anti-aim" and enabled )
    ui.set_visible( aa.manual_left_hotkey, ui.get( aa.configure_combobox ) == "Anti-aim" and enabled )
    ui.set_visible( aa.legit_aa_on_e, ui.get( aa.configure_combobox ) == "Anti-aim" and enabled )
    ui.set_visible( aa.legit_aa_hotkey, ui.get( aa.configure_combobox ) == "Anti-aim" and enabled )
    ui.set_visible( aa.legmovement_checkbox, ui.get( aa.configure_combobox ) == "Anti-aim" and enabled )
    ui.set_visible( aa.lowdelta_slow_walk_checkbox, ui.get( aa.configure_combobox ) == "Anti-aim" and enabled )
    ui.set_visible( aa.in_air_checkbox, ui.get( aa.configure_combobox ) == "Anti-aim" and enabled)
    ui.set_visible( aa.edge_yaw_checkbox, ui.get( aa.configure_combobox ) == "Anti-aim" and enabled )
    ui.set_visible( aa.fake_flick_hotkey, ui.get( aa.configure_combobox ) == "Anti-aim" and enabled )
    ui.set_visible( aa.fake_flick_invert_hotkey, ui.get( aa.configure_combobox ) == "Anti-aim" and enabled)

    ui.set_visible( aa.manual_state, false )

    ui.set_visible( aa.enabler, ui.get( aa.configure_combobox ) == "Misc" and enabled)
    ui.set_visible( aa.AA_Roll_add, ui.get( aa.configure_combobox ) == "Misc" and enabled)
    ui.set_visible( aa.roll_inverter, ui.get( aa.configure_combobox ) == "Misc" and enabled)
    ui.set_visible( aa.roll_jitter, ui.get( aa.configure_combobox ) == "Misc" and enabled)
    ui.set_visible( aa.debug_indicator, ui.get( aa.configure_combobox ) == "Misc" and enabled)

    ui.set_visible( aa.enable_roll1, ui.get( aa.configure_combobox ) == "Misc" and enabled)
    ui.set_visible( aa.state_select, ui.get( aa.configure_combobox ) == "Misc" and enabled)
    ui.set_visible( aa.Roll_Running, ui.get( aa.configure_combobox ) == "Misc" and enabled)
    ui.set_visible( aa.Roll_Standing, ui.get( aa.configure_combobox ) == "Misc" and enabled)
    ui.set_visible( aa.Roll_Crouching, ui.get( aa.configure_combobox ) == "Misc" and enabled)
    ui.set_visible( aa.Roll_Slowwalk, ui.get( aa.configure_combobox ) == "Misc" and enabled)
    ui.set_visible( aa.Roll_InAir, ui.get( aa.configure_combobox ) == "Misc" and enabled)
    
    ui.set_visible( aa.enable_fake, ui.get( aa.configure_combobox ) == "Misc" and enabled)
    ui.set_visible( aa.state_select_fake, ui.get( aa.configure_combobox ) == "Misc" and enabled)
    ui.set_visible( aa.Fake_Yaw_Running, ui.get( aa.configure_combobox ) == "Misc" and enabled)
    ui.set_visible( aa.Fake_Yaw_Standing, ui.get( aa.configure_combobox ) == "Misc" and enabled)
    ui.set_visible( aa.Fake_Yaw_Crouching, ui.get( aa.configure_combobox ) == "Misc" and enabled)
    ui.set_visible( aa.Fake_Yaw_Fakeduck, ui.get( aa.configure_combobox ) == "Misc" and enabled)
    ui.set_visible( aa.Fake_Yaw_Slowwalk, ui.get( aa.configure_combobox ) == "Misc" and enabled)
    ui.set_visible( aa.Fake_Yaw_InAir, ui.get( aa.configure_combobox ) == "Misc" and enabled)

    ui.set_visible( aa.slider, ui.get( aa.configure_combobox ) == "Misc" and enabled)
    ui.set_visible( aa.real, ui.get( aa.configure_combobox ) == "Misc" and enabled)
    ui.set_visible( aa.down, ui.get( aa.configure_combobox ) == "Misc" and enabled)
    ui.set_visible( aa.fake, ui.get( aa.configure_combobox ) == "Misc" and enabled)


    ui.set_visible( aa.ijxrjhmjriwo, ui.get( aa.configure_combobox ) == "Fake lag" and enabled)
    
    ui.set_visible( aa.enable_osaa, ui.get( aa.configure_combobox ) == "Indicators" and enabled)

    ui.set_visible( aa.thor_chams, ui.get( aa.configure_combobox ) == "Visuals" and enabled)
    ui.set_visible( aa.weapon_chams, ui.get( aa.configure_combobox ) == "Visuals" and enabled)
    ui.set_visible( aa.wmaterial_combobox, ui.get( aa.configure_combobox ) == "Visuals" and enabled)
    ui.set_visible( aa.wwireframe_checkbox, ui.get( aa.configure_combobox ) == "Visuals" and enabled)
    ui.set_visible( aa.wadditive_checkbox, ui.get( aa.configure_combobox ) == "Visuals" and enabled)
    ui.set_visible( aa.wcolor_picker, ui.get( aa.configure_combobox ) == "Visuals" and enabled)
    ui.set_visible( aa.wsize_slider, ui.get( aa.configure_combobox ) == "Visuals" and enabled)
    ui.set_visible( aa.wspeed_slider, ui.get( aa.configure_combobox ) == "Visuals" and enabled)
    ui.set_visible( aa.arms_chams, ui.get( aa.configure_combobox ) == "Visuals" and enabled)
    ui.set_visible( aa.amaterial_combobox, ui.get( aa.configure_combobox ) == "Visuals" and enabled)
    ui.set_visible( aa.awireframe_checkbox, ui.get( aa.configure_combobox ) == "Visuals" and enabled)
    ui.set_visible( aa.aadditive_checkbox, ui.get( aa.configure_combobox ) == "Visuals" and enabled)
    ui.set_visible( aa.acolor_picker, ui.get( aa.configure_combobox ) == "Visuals" and enabled)
    ui.set_visible( aa.asize_slider, ui.get( aa.configure_combobox ) == "Visuals" and enabled)
    ui.set_visible( aa.aspeed_slider, ui.get( aa.configure_combobox ) == "Visuals" and enabled)

    local valid_cfg = ui.get(  aa.configure_combobox ) == "Config" and enabled
    ui.set_visible( set_cfg, valid_cfg )
    ui.set_visible( reset_cfg, valid_cfg )
end

local handle_visuals_visibility = function( )
    local enabled = ui.get( aa.enable_checkbox ) and ui.get( aa.configure_combobox ) == "Indicators"

    ui.set_visible( aa1.indicator_multi, ui.get( aa.configure_combobox ) == "Indicators" and enabled)
    ui.set_visible( aa1.label_watermark, ui.get( aa.configure_combobox ) == "Indicators" and enabled)
    ui.set_visible( aa1.clantag, ui.get( aa.configure_combobox ) == "Indicators" and enabled)

    ui.set_visible( visuals.configure_vis_combobox, enabled )

    local valid_indicator_cfg = ui.get( visuals.configure_vis_combobox ) == "Text & Indicators" and enabled
    ui.set_visible( visuals.arrow_label, valid_indicator_cfg )
    ui.set_visible( visuals.arrow_colourpicker, valid_indicator_cfg )

    ui.set_visible( visuals.banepa_label, valid_indicator_cfg )
    ui.set_visible( visuals.banepa_colourpicker, valid_indicator_cfg )

    ui.set_visible( visuals.fontstyle_combobox, valid_indicator_cfg )
    ui.set_visible( visuals.centered_text, valid_indicator_cfg )

    ui.set_visible( visuals.indicators_multiselect, valid_indicator_cfg )
    ui.set_visible( visuals.textindicators_multiselect, valid_indicator_cfg )
    ui.set_visible( visuals.indicatorypos_slider, valid_indicator_cfg )
end

client.set_event_callback( "paint", handle_aa_visibility )
client.set_event_callback( "paint", handle_visuals_visibility )

ui.set_callback( aa.freestand_mode_combobox, function( self )
    -- Set the last side to '0' so the anti-aim updates
    data.last_side = 0
end)

local curtime = globals.curtime()
client.set_event_callback("setup_command", function(cmd)
    fakeFlick = not fakeFlick
    if ui.get( aa.fake_flick_hotkey ) then
    ui.set(ref_fake_lag_limit, 1)
    else
    ui.set(ref_fake_lag_limit, 14)
    end
    ui.set(ref_body_yaw_offset, (ui.get( aa.fake_flick_invert_hotkey ) and -180 or 180))
    ui.set(ref_body_yaw, "Static")
    if globals.curtime() > curtime + 0.1 and ui.get( aa.fake_flick_hotkey ) then
        ui.set(ref_yaw_offset, (ui.get( aa.fake_flick_invert_hotkey ) == 1 and -100 or 100))
        curtime = globals.curtime()
    else
        ui.set(ref_yaw_offset, 0)
    end
end)

local steamworks = require "gamesense/steamworks"
local steamoverlay = false

client.set_event_callback('setup_command', function (cmd)
    if ui.is_menu_open() or steamoverlay then 
        cmd.in_attack = false
        cmd.in_attack2 = false
    end
end)

steamworks.set_callback("GameOverlayActivated", function (e)
    steamoverlay = e.m_bActive
end)

local pitch = ui.reference("AA", "Anti-aimbot angles", "Pitch")
local yawbase = ui.reference("AA", "Anti-aimbot angles", "Yaw base")
local yaw, yawslider = ui.reference("AA", "Anti-aimbot angles", "Yaw")
local yawjitter, yawyjitterslider = ui.reference("AA", "Anti-aimbot angles", "Yaw jitter")
local bodyyaw, bodyyawslider = ui.reference("AA", "Anti-aimbot angles", "Body yaw")
local freestandingbodyyaw = ui.reference("AA", "Anti-aimbot angles", "Freestanding body yaw")
local fakeyawlimit = ui.reference("AA", "Anti-aimbot angles", "Fake yaw limit")
local edge_yaw = ui.reference("AA", "Anti-aimbot angles", "Edge yaw")

local aaebnhljytag = ui.reference("AA", "Fake lag", "Amount")

client.set_event_callback("setup_command", function()
    if (bit.band(entity.get_prop(entity.get_local_player(), "m_fFlags"), 1) == 0) then
        wcoyvssydoqd = 1
    else
        wcoyvssydoqd = 0
    end
    if ui.get( aa.ijxrjhmjriwo ) then
        if wcoyvssydoqd == 1 then
            ui.set(aaebnhljytag, "Fluctuate")
        else
            ui.set(aaebnhljytag, "Maximum")
        end
    end
end)

 notifications = {}
 notifyTimeout = ui.new_slider("AA", "OTHER", "Notification timout", 3, 15, 10, true, "s")
 function sendNotification(text, type)
    table.insert(notifications, 1,{text, -1, 0, 2, sYc})
  if type == 1 then
    client.exec("play ui/armsrace_level_up")
  elseif type == 0 then
  else
       client.exec("play player/playerping")
  end
end
 sX, sY = client.screen_size()
 sXc = sX/2
 sYc = sY/2
  sendNotification("⚡ThorYaw⚡ loaded!", 1)
  client.delay_call(1, sendNotification, "Welcome " .. name .. "!", 0)
  
   function drawNotification()
    local hours, minutes, seconds = client.system_time()
    string.format("%02d", seconds)
    for i=1, #notifications do
        if notifications[i] ~= nil then
            if notifyTime ~= seconds and notifications[i][2] == 0 then
                notifications[i][4] = notifications[i][4] - 1
            end
            local textW, textH = renderer.measure_text("rd",  notifications[i][1])
            local Y = sYc + (textH*2.5*i) - textH*2.5
            if notifications[i][4] > 0 then
                if notifications[i][5] < Y -15 then
                    notifications[i][5] = notifications[i][5] + 3
                elseif notifications[i][5] < Y - 1 then
                    notifications[i][5] = notifications[i][5] + 1
                elseif notifications[i][5] > Y then
                    notifications[i][5] = notifications[i][5] - 3
                end
                if notifications[i][2]  == -1 then
                    notifications[i][2] = textW*2+17
                end
                if notifications[i][2] > 15 then
                    notifications[i][2] = notifications[i][2] - 5
                elseif notifications[i][2] > 0 then
                    notifications[i][2] = notifications[i][2] - 1
                end
                if notifications[i][3] < 240 then
                    notifications[i][3] = notifications[i][3] + 5
                elseif notifications[i][3] < 255 then
                    notifications[i][3] = notifications[i][3] + 1
                end
            elseif notifications[i][4] <= 0 and notifications[i][3] > 0 then
                    if notifications[i][2] < textW*2+17 then
                        notifications[i][2] = notifications[i][2] + 8
                    end
                    if notifications[i][3] > 0 then
                        notifications[i][3] = notifications[i][3] - 10
                    end
            elseif notifications[i][3] <= 0 then
                    table.remove(notifications, i)
            end
            if notifications[i] ~= nil then
            renderer.rectangle(sX-textW-22+notifications[i][2], notifications[i][5]-7, sX-(sX-textW)+24, textH + 14, 15, 15, 15, notifications[i][3])
            renderer.rectangle(sX-textW-21+notifications[i][2], notifications[i][5]-6, sX-(sX-textW)+22, textH + 12, 55, 55, 55, notifications[i][3])
            renderer.rectangle(sX-textW-20+notifications[i][2], notifications[i][5]-5, sX-(sX-textW)+20, textH + 10, 0, 0, 0, notifications[i][3])
            renderer.triangle(sX-textW-39+notifications[i][2], notifications[i][5]+textH+7, sX-textW-22+notifications[i][2], notifications[i][5]-8, sX-textW-22+notifications[i][2], notifications[i][5]+textH+7, 15, 15, 15, notifications[i][3])
            renderer.triangle(sX-textW-37+notifications[i][2], notifications[i][5]+textH+6, sX-textW-21+notifications[i][2], notifications[i][5]-7, sX-textW-21+notifications[i][2], notifications[i][5]+textH+6, 55, 55, 55, notifications[i][3])
            renderer.triangle(sX-textW-35+notifications[i][2], notifications[i][5]+textH+5, sX-textW-20+notifications[i][2], notifications[i][5]-6, sX-textW-20+notifications[i][2], notifications[i][5]+textH+5, 0, 0, 0, notifications[i][3])
            renderer.text(sX-13+notifications[i][2], notifications[i][5], 255, 255, 255, notifications[i][3], "rd", 0, notifications[i][1])
        end
    end
    end
    if notifyTime ~= seconds then
        notifyTime = seconds
    end
end
client.set_event_callback("paint_ui",
    function()
        drawNotification()
    end)

    ShowWatermark = true
    client.set_event_callback("paint_ui", function()
        if ui.is_menu_open() and ShowWatermark and readfile("csgo/xp_extra.txt") ~= "false" then
        local h, m, s, mill = client.system_time()
        h, m, s = string.format("%02d", h), string.format("%02d", m), string.format("%02d", s)
        local menu_x, menu_y = ui.menu_position()
        local menu_w, menu_h = ui.menu_size()
        renderer.rectangle(menu_x, menu_y-40, menu_w, 35, 18, 18, 18, 255)
        renderer.rectangle(menu_x+1, menu_y-40+1, menu_w-2, 35-2, 55, 55, 55, 255)
        renderer.rectangle(menu_x+2, menu_y-40+2, menu_w-4, 35-4, 40, 40, 40, 255)
        renderer.rectangle(menu_x+4, menu_y-40+4, menu_w-8, 35-8, 55, 55, 55, 255)
        renderer.rectangle(menu_x+5, menu_y-40+5, menu_w-10, 35-10, 18, 18, 18, 255)
        renderer.gradient(menu_x+6, menu_y-40+6, menu_w/2-11, 1.5, 56,176,218,255, 204,74,201,255, 1)
        renderer.gradient(menu_x+(menu_w/2)-6, menu_y-40+6, menu_w/2, 1.5, 204,74,201,255, 204,227,53,255, 1)
        string = "Welcome, " .. name .. " | Current build: Alpha" .. " | Current time: " .. h .. ":" .. m .. ":" .. s
        renderer.text(menu_x+(menu_w/2)+5 - (renderer.measure_text("d", string) / 2) , menu_y - 28, 255, 255, 255, 255, "", 0, string) -- text in box
        end
    end)
     aa1 = {
        indicator_multi = ui.new_checkbox( aatab[1], aatab[2], "Watermark"),
        label_watermark = ui.new_label( aatab[1], aatab[2], "Watermark Accent Color"),  watermark_colors = ui.new_color_picker( aatab[1], aatab[2], "Watermark accent color", 30,144,255, 255),
        clantag = ui.new_checkbox( aatab[1], aatab[2], "Clan tag spammer"),
    }
    client.set_event_callback("paint", function()
        opts_ind = ui.get(aa1.indicator_multi)
    if  ui.get(aa1.indicator_multi) then
    get_input_user = name
    user_string = string.len(get_input_user)
    string_actual = renderer.measure_text("d", get_input_user)
    local screen = {client.screen_size()}
    local center = {screen[1] / 2, screen[2] / 2}
    local tickrate = 1/globals.tickinterval()
    local h, m, s, mill = client.system_time()
    h, m, s = string.format("%02d", h), string.format("%02d", m), string.format("%02d", s)
    local latency = math.floor(client.latency()*500+0.5)
    local lat_mes = renderer.measure_text("d", latency)
    local r4, g4, b4, a4 = ui.get(aa1.watermark_colors)
    local start_time = 0
        renderer.rectangle(center[1] + center[1] - 365 - string_actual + 29, center[2] - center[2] + 5 , 332 + string_actual - 16 + (lat_mes/1.5), 19, 34, 34, 34, 200) -- main box
        renderer.rectangle(center[1] + center[1] - 365 - string_actual  + 29, center[2] - center[2] + 5 , 332 + string_actual - 16 + (lat_mes/1.5), 1, r4,g4,b4, a4) -- accent bar
        user1string = get_input_user
        string = " | " .. " version: Alpha " .. "| " .. tickrate .. "ticks | " .. latency .. "ms | " .. h .. ":" .. m .. ":" .. s
        renderer.text(center[1] + center[1] - 333 + 68, center[2] - center[2] + 8 , 255, 255, 255, 255, "", 0, string) -- text in box
        renderer.text(center[1] + center[1] - 360 - string_actual + 30 , center[2] - center[2] + 8 , 255, 255, 255, 255, "", 0, "ThorYaw -" .. user1string) -- text in box
    end
    end)

    leetifyTable = {A = "⚒", B = "6", C = "<", D = "d", E = "3", F = "f", G = "&", H = "#", I = "!", J = "j", K = "k", L = "1", M = "m", N = "|\\|", O = "0", P = "p", Q = "q", R = "r", S = "5", T = "7", U = "u", V = "\\/", W = "w", X = "x", Y = "y", Z = "z"}
 mainTag = "ThorYaw"
 previousTag = ""
 chokedPackets = 0
ui.set_callback(aa1.clantag, function()
    local enabled = ui.get(aa1.clantag)
    
end)
client.set_event_callback("net_update_end", function()
    if not (ui.get(aa1.clantag)) then return end
    if (chokedPackets ~= 0) then
        return
    end
    
    local curTime = globals.curtime()
    local tagSpeed = 5
    local tag = "ThorYaw"
    local tagLength = string.len(tag)
    
    if (tagLength == 0) then return end
    
    tagLength = 0
    for i=1, #tag do
        local tmpChar = string.sub(tag, i, i)
        local leetChar = leetifyTable[string.upper(tmpChar)]
        
        if (leetChar ~= nil and leetChar ~= tmpChar) then
            tagLength = tagLength + string.len(leetChar) + 1
        else
            tagLength = tagLength + 1
        end
    end
    tagLength = tagLength * 2
    
    local tagIndex = math.floor(curTime * tagSpeed % tagLength + 1)
    local setTag = ""
    local modLeft = -1
    
    local realI = 0
    local fakeI = 1
    
    local backwards = false
    
    local power = tagIndex
    local setTag = ""
    local realI = 0
    
    for i=1, tagLength/2 do
        local iChar = string.sub(tag, i, i)
        local leetChar = leetifyTable[string.upper(iChar)]
        
        if (leetChar == nil or string.lower(iChar) == leetChar) then --Doesnt have a leetify
            if (power > 0) then
                setTag = setTag .. iChar
                power = power - 1
            end
        else
            local tmpChars = ""
            for j=1, #leetChar do
                if (power > 0) then
                    tmpChars = tmpChars .. string.sub(leetChar, j, j)
                    power = power - 1
                end
            end
            
            if (power > 0) then
                setTag = setTag .. iChar
                power = power - 1
            else
                setTag = setTag .. tmpChars
            end
        end
    end
        
    if (tagIndex > tagLength/2) then
        setTag = ""
        power = tagLength - tagIndex
        
        for i=1, tagLength/2 do
            local iChar = string.sub(tag, i, i)
            local leetChar = leetifyTable[string.upper(iChar)]
            
            if (leetChar == nil or string.lower(iChar) == leetChar) then --Doesnt have a leetify
                if (power > 0) then
                    setTag = setTag .. iChar
                    power = power - 1
                end
            else
                local tmpChars = ""
                for j=1, #leetChar do
                    if (power > 0) then
                        tmpChars = tmpChars .. string.sub(leetChar, j, j)
                        power = power - 1
                    end
                end
                
                if (power > 0) then
                    setTag = setTag .. iChar
                    power = power - 1
                else
                    setTag = setTag .. tmpChars
                end
            end
        end
    end
    if (previousTag ~= setTag) then
        client.set_clan_tag(setTag)
        previousTag = setTag
    end
end)
client.set_event_callback("run_command", function(cmd)
    chokedPackets = cmd.chokedcommands
    
    return
end) 

-- [ ]

-- [ MENU ]
-- [ MENU ]

-- [ SETUP MENU ]
function setup_menu()
    ui.set_visible(aa.wmaterial_combobox, false)
    ui.set(aa.wmaterial_combobox, "Light glow")
    ui.set_visible(aa.wwireframe_checkbox,false)
    ui.set_visible(aa.wadditive_checkbox, false)
    ui.set_visible(aa.wcolor_picker, false)
    ui.set_visible(aa.wsize_slider, false)
    ui.set_visible(aa.wspeed_slider, false)

    ui.set_visible(aa.amaterial_combobox, false)
    ui.set(aa.amaterial_combobox, "Light glow")
    ui.set_visible(aa.awireframe_checkbox, false)
    ui.set_visible(aa.aadditive_checkbox, false)
    ui.set_visible(aa.acolor_picker, false)
    ui.set_visible(aa.asize_slider, false)
    ui.set_visible(aa.aspeed_slider, false)
end
setup_menu()
-- [ SETUP MENU ]

-- [ MENU CALLBACKS ]
ui.set_callback(aa.weapon_chams, function()
    if(not ui.get(aa.weapon_chams)) then
        if aa.wmaterial == nil then return end
        for i = #aa.wmaterial, 1, -1 do aa.wmaterial[i]:reload() end
    end
    ui.set_visible(aa.amaterial_combobox, ui.get(aa.weapon_chams))
    ui.set_visible(aa.awireframe_checkbox, ui.get(aa.weapon_chams))
    ui.set_visible(aa.aadditive_checkbox, ui.get(aa.weapon_chams))
    ui.set_visible(aa.acolor_picker, ui.get(aa.weapon_chams))
    ui.set_visible(aa.asize_slider, ui.get(aa.weapon_chams))
    ui.set_visible(aa.aspeed_slider, ui.get(aa.weapon_chams))
end)
ui.set_callback(aa.arms_chams, function()
    if(not ui.get(aa.arms_chams)) then
        if aa.amaterial == nil then return end
        aa.amaterial:reload()
    end
    ui.set_visible(aa.amaterial_combobox, ui.get(aa.arms_chams))
    ui.set_visible(aa.awireframe_checkbox, ui.get(aa.arms_chams))
    ui.set_visible(aa.aadditive_checkbox, ui.get(aa.arms_chams))
    ui.set_visible(aa.acolor_picker, ui.get(aa.arms_chams))
    ui.set_visible(aa.asize_slider, ui.get(aa.arms_chams))
    ui.set_visible(aa.aspeed_slider, ui.get(aa.arms_chams))
end)
-- [ MENU CALLBACKS ]

-- [ MAIN FUNCTION ]
client.set_event_callback("run_command", function()
    if ui.get(aa.arms_chams) then
        aa.amaterial = materialsystem.arms_material()
        aa.ar, aa.ag, aa.ab, aa.aa = ui.get(aa.acolor_picker)
        aa.aspeed = globals.realtime() * ui.get(aa.aspeed_slider) * 0.01

        local hands_reference = ui.reference("VISUALS", "Colored Models", "Hands")
        ui.set(hands_reference, true)

        aa.amaterial:set_shader_param("$basetexture", materials[ui.get(aa.amaterial_combobox)])
        aa.amaterial:color_modulate(aa.ar, aa.ag, aa.ab)
        aa.amaterial:alpha_modulate(aa.aa)
        aa.amaterial:set_material_var_flag(28, ui.get(aa.awireframe_checkbox))
        aa.amaterial:set_material_var_flag(7, ui.get(aa.aadditive_checkbox))
        aa.amaterial:set_shader_param("$basetexturetransform", ui.get(aa.asize_slider), aa.aspeed, aa.aspeed)
    end
    
    if ui.get(aa.weapon_chams) then
        aa.wmaterial = materialsystem.get_model_materials(entity.get_prop(entity.get_local_player(), "m_hViewModel[0]"))
        aa.wr, aa.wg, aa.wb, aa.wa = ui.get(aa.wcolor_picker)
        aa.wspeed = globals.realtime() * ui.get(aa.wspeed_slider) * 0.01

        for i = 1, #aa.wmaterial, 1 do
            aa.wmaterial[i]:set_shader_param("$basetexture", materials[ui.get(aa.wmaterial_combobox)])
            aa.wmaterial[i]:color_modulate(aa.wr, aa.wg, aa.wb)
            aa.wmaterial[i]:alpha_modulate(aa.wa)
            aa.wmaterial[i]:set_material_var_flag(28, ui.get(aa.wwireframe_checkbox))
            aa.wmaterial[i]:set_material_var_flag(7, ui.get(aa.wadditive_checkbox))
            aa.wmaterial[i]:set_shader_param("$basetexturetransform", ui.get(aa.wsize_slider), aa.wspeed, aa.wspeed)
        end
    end
end)

--Roll Jitter
ui.set_visible(aa.AA_Roll_add, ui.get(aa.enabler)) ui.set_visible(aa.roll_inverter, ui.get(aa.enabler)) ui.set_visible(aa.roll_jitter, ui.get(aa.enabler)) ui.set_visible(aa.debug_indicator, ui.get(aa.enabler))
local function invertRoll()
    if ui.get(aa.enabler) then
        ui.set_visible(ref_roll, false)
        if ui.get(aa.roll_inverter) and ui.get(aa.roll_jitter) == false then
            ui.set(ref_roll, (ui.get(aa.AA_Roll_add) * -1))
        end

        if ui.get(aa.roll_jitter) then new_roll_R = math.random(41,46) new_roll_L = math.random(-40, -45) currentRoll = ui.get(ref_roll)
            if ui.get(ref_roll) < 0 then ui.set(ref_roll, new_roll_R) else ui.set(ref_roll, new_roll_L) end
        elseif ui.get(aa.roll_inverter) == false then ui.set(ref_roll, ui.get(aa.AA_Roll_add)) end
    else ui.set_visible(ref_roll, true) end
end

local function RenderIndicator()
    if ui.get(aa.debug_indicator) then indicator = renderer.indicator(255, 255, 255, 255, "Current Roll :", ui.get(ref_roll)) end
end
client.set_event_callback("run_command", invertRoll)
ui.set_callback(aa.enabler, function() ui.set_visible(aa.AA_Roll_add, ui.get(aa.enabler)) ui.set_visible(aa.roll_inverter, ui.get(aa.enabler)) ui.set_visible(aa.roll_jitter, ui.get(aa.enabler)) ui.set_visible(aa.debug_indicator, ui.get(ui_e.enabler)) end)
client.set_event_callback('shutdown', function() ui.set_visible(ref_roll, true) end)
client.set_event_callback("paint", RenderIndicator)

--Roll States
local function state_player()
    if entity.get_local_player() == nil then return end

    local vx, vy = entity.get_prop(entity.get_local_player(), 'm_vecVelocity')
    local player_standing = math.sqrt(vx ^ 2 + vy ^ 2) < 2
	local player_jumping = bit.band(entity.get_prop(entity.get_local_player(), 'm_fFlags'), 1) == 0
    local player_crouching = entity.get_prop(entity.get_local_player(), "m_flDuckAmount") > 0.5 and not player_duck_peek_assist
    local player_slow_motion = ui.get(hotkey_reference)

    if player_slow_motion then
        return 'slowmotion'
    elseif player_crouching then
        return 'crouch'
    elseif player_jumping then
        return 'jump'
    elseif player_standing then
        return 'stand'
    elseif not player_standing then
        return 'move'
    end
end


client_set_event_callback("run_command", function()
    if entity.get_local_player() == nil then return end
    if ui.get(aa.enable_roll1) and state_player() == 'stand' then
        ui.set(ref_roll, ui.get(aa.Roll_Standing))
    end
    if ui.get(aa.enable_roll1) and state_player() == 'move' then
        ui.set(ref_roll, ui.get(aa.Roll_Running))
    end
    if ui.get(aa.enable_roll1) and state_player() == 'crouch' then
        ui.set(ref_roll, ui.get(aa.Roll_Crouching))
    end
    if ui.get(aa.enable_roll1) and state_player() == 'slowmotion' then
        ui.set(ref_roll, ui.get(aa.Roll_Slowwalk))
    end
    if ui.get(aa.enable_roll1) and state_player() == 'jump' then
        ui.set(ref_roll, ui.get(aa.Roll_InAir))
    end 
end)

--VISIBILTY -----------------------------------
ui.set_visible(aa.Roll_Running, false)
ui.set_visible(aa.Roll_Standing, false)
ui.set_visible(aa.Roll_Crouching, false)
ui.set_visible(aa.Roll_Slowwalk, false)
ui.set_visible(aa.Roll_InAir, false)

client_set_event_callback("paint", function()
    if not ui.get(aa.enable_roll1) then
        ui.set_visible(aa.state_select, false)
        ui.set_visible(aa.Roll_Running, false)
        ui.set_visible(aa.Roll_Standing, false)
        ui.set_visible(aa.Roll_Crouching, false)
        ui.set_visible(aa.Roll_Slowwalk, false)
        ui.set_visible(aa.Roll_InAir, false)
        ui.set_visible(ref_roll, true)
    else
        ui.set_visible(ref_roll, false)
        ui.set_visible(aa.state_select, true)
        if ui.get(aa.state_select) == "Running" then
            ui.set_visible(aa.Roll_Running, true)
            ui.set_visible(aa.Roll_Standing, false)
            ui.set_visible(aa.Roll_Crouching, false)
            ui.set_visible(aa.Roll_Slowwalk, false)
            ui.set_visible(aa.Roll_InAir, false)
        elseif ui.get(aa.state_select) == "Standing" then
            ui.set_visible(aa.Roll_Running, false)
            ui.set_visible(aa.Roll_Standing, true)
            ui.set_visible(aa.Roll_Crouching, false)
            ui.set_visible(aa.Roll_Slowwalk, false)
            ui.set_visible(aa.Roll_InAir, false)
        elseif ui.get(aa.state_select) == "Crouching" then
            ui.set_visible(aa.Roll_Running, false)
            ui.set_visible(aa.Roll_Standing, false)
            ui.set_visible(aa.Roll_Crouching, true)
            ui.set_visible(aa.Roll_Slowwalk, false)
            ui.set_visible(aa.Roll_InAir, false)
        elseif ui.get(aa.state_select) == "Slow-Walking" then
            ui.set_visible(aa.Roll_Running, false)
            ui.set_visible(aa.Roll_Standing, false)
            ui.set_visible(aa.Roll_Crouching, false)
            ui.set_visible(aa.Roll_Slowwalk, true)
            ui.set_visible(aa.Roll_InAir, false)
        elseif ui.get(aa.state_select) == "In-Air" then
            ui.set_visible(aa.Roll_Running, false)
            ui.set_visible(aa.Roll_Standing, false)
            ui.set_visible(aa.Roll_Crouching, false)
            ui.set_visible(aa.Roll_Slowwalk, false)
            ui.set_visible(aa.Roll_InAir, true)
        elseif ui.get(aa.state_select) == "Fake-ducking" then
            ui.set_visible(aa.Roll_Running, false)
            ui.set_visible(aa.Roll_Standing, false)
            ui.set_visible(aa.Roll_Crouching, false)
            ui.set_visible(aa.Roll_Slowwalk, false)
            ui.set_visible(aa.Roll_InAir, false)
            ui.set_visible(aa.Roll_Fakeduck, true)
        end
    end
end)

client.set_event_callback('shutdown', function() 
    ui.set_visible(ref_roll, true)
end)

--Fake Yaw States
local function state_player()
    if entity.get_local_player() == nil then return end

    local vx, vy = entity.get_prop(entity.get_local_player(), 'm_vecVelocity')
    local player_standing = math.sqrt(vx ^ 2 + vy ^ 2) < 2
	local player_jumping = bit.band(entity.get_prop(entity.get_local_player(), 'm_fFlags'), 1) == 0
    local player_crouching = entity.get_prop(entity.get_local_player(), "m_flDuckAmount") > 0.5 and not player_duck_peek_assist
    local player_slow_motion = ui.get(hotkey_reference)

    if player_slow_motion then
        return 'slowmotion'
    elseif player_crouching then
        return 'crouch'
    elseif player_jumping then
        return 'jump'
    elseif player_standing then
        return 'stand'
    elseif not player_standing then
        return 'move'
    end
end


client_set_event_callback("run_command", function()
    if entity.get_local_player() == nil then return end
    if ui.get(aa.enable_fake) and state_player() == 'stand' then
        ui.set(ref_fake_limit, ui.get(aa.Fake_Yaw_Standing))
    end
    if ui.get(aa.enable_fake) and state_player() == 'move' then
        ui.set(ref_fake_limit, ui.get(aa.Fake_Yaw_Running))
    end
    if ui.get(aa.enable_fake) and state_player() == 'crouch' then
        ui.set(ref_fake_limit, ui.get(aa.Fake_Yaw_Crouching))
    end
    if ui.get(aa.enable_fake) and state_player() == 'slowmotion' then
        ui.set(ref_fake_limit, ui.get(aa.Fake_Yaw_Slowwalk))
    end
    if ui.get(aa.enable_fake) and state_player() == 'jump' then
        ui.set(ref_fake_limit, ui.get(aa.Fake_Yaw_InAir))
    end 
end)

--VISIBILTY -----------------------------------
ui.set_visible(aa.Fake_Yaw_Running, false)
ui.set_visible(aa.Fake_Yaw_Standing, false)
ui.set_visible(aa.Fake_Yaw_Crouching, false)
ui.set_visible(aa.Fake_Yaw_Slowwalk, false)
ui.set_visible(aa.Fake_Yaw_InAir, false)

client.set_event_callback("paint", function()
    if not ui.get(aa.enable_fake) then
        ui.set_visible(aa.state_select_fake, false)
        ui.set_visible(aa.Fake_Yaw_Running, false)
        ui.set_visible(aa.Fake_Yaw_Standing, false)
        ui.set_visible(aa.Fake_Yaw_Crouching, false)
        ui.set_visible(aa.Fake_Yaw_Slowwalk, false)
        ui.set_visible(aa.Fake_Yaw_InAir, false)
        ui.set_visible(ref_fake_limit, true)
    else
        ui.set_visible(ref_fake_limit, false)
        ui.set_visible(aa.state_select_fake, true)
        if ui.get(aa.state_select_fake) == "Running" then
            ui.set_visible(aa.Fake_Yaw_Running, true)
            ui.set_visible(aa.Fake_Yaw_Standing, false)
            ui.set_visible(aa.Fake_Yaw_Crouching, false)
            ui.set_visible(aa.Fake_Yaw_Slowwalk, false)
            ui.set_visible(aa.Fake_Yaw_InAir, false)
        elseif ui.get(aa.state_select_fake) == "Standing" then
            ui.set_visible(aa.Fake_Yaw_Running, false)
            ui.set_visible(aa.Fake_Yaw_Standing, true)
            ui.set_visible(aa.Fake_Yaw_Crouching, false)
            ui.set_visible(aa.Fake_Yaw_Slowwalk, false)
            ui.set_visible(aa.Fake_Yaw_InAir, false)
        elseif ui.get(aa.state_select_fake) == "Crouching" then
            ui.set_visible(aa.Fake_Yaw_Running, false)
            ui.set_visible(aa.Fake_Yaw_Standing, false)
            ui.set_visible(aa.Fake_Yaw_Crouching, true)
            ui.set_visible(aa.Fake_Yaw_Slowwalk, false)
            ui.set_visible(aa.Fake_Yaw_InAir, false)
        elseif ui.get(aa.state_select_fake) == "Slow-Walking" then
            ui.set_visible(aa.Fake_Yaw_Running, false)
            ui.set_visible(aa.Fake_Yaw_Standing, false)
            ui.set_visible(aa.Fake_Yaw_Crouching, false)
            ui.set_visible(aa.Fake_Yaw_Slowwalk, true)
            ui.set_visible(aa.Fake_Yaw_InAir, false)
        elseif ui.get(aa.state_select_fake) == "In-Air" then
            ui.set_visible(aa.Fake_Yaw_Running, false)
            ui.set_visible(aa.Fake_Yaw_Standing, false)
            ui.set_visible(aa.Fake_Yaw_Crouching, false)
            ui.set_visible(aa.Fake_Yaw_Slowwalk, false)
            ui.set_visible(aa.Fake_Yaw_InAir, true)
        elseif ui.get(aa.state_select_fake) == "Fake-ducking" then
            ui.set_visible(aa.Fake_Yaw_Running, false)
            ui.set_visible(aa.Fake_Yaw_Standing, false)
            ui.set_visible(aa.Fake_Yaw_Crouching, false)
            ui.set_visible(aa.Fake_Yaw_Slowwalk, false)
            ui.set_visible(aa.Fake_Yaw_InAir, false)
            ui.set_visible(aa.Fake_Yaw_Fakeduck, true)
        end
    end
end)

client.set_event_callback('shutdown', function() 
    ui.set_visible(ref_fake_limit, true)
end)

local dir = {
    none = 0,
    back = 180,
    left = 90,
    right = -90
}
local function head(x, z)
    if x == "none" then
        return z
    else
        local list = {
            down = 80,
            up = -80
        }
        return list[x]
    end
end
client.set_event_callback("setup_command", function(arg)
    arg.allow_send_packet = false
    ui.set(sv_maxusrcmdprocessticks, 18)
    ui.set(ref_fake_lag_limit, 17)
    local angles = {client.camera_angles()}
    if (arg.chokedcommands % 2 == 0) then
        arg.yaw = angles[2] + (dir[ui.get(aa.real)]+ui.get(aa.slider))
        arg.pitch = head(ui.get(aa.fake), angles[1])
    else
        arg.yaw = angles[2] + dir[ui.get(aa.real)]
        arg.pitch = head(ui.get(aa.down), angles[1])
    end
end)
