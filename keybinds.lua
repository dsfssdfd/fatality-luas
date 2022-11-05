-- fixed and modified from https://fatality.win/threads/keybinds.11561/
-- screen size
local screen_size = {render.get_screen_size()}

-- fonts
local verdana = render.create_font("verdana.ttf", 14, render.font_flag_shadow)

-- menu
local keybinds_cb = gui.add_checkbox("Keybinds", "lua>tab a")
local keybinds_x = gui.add_slider("keybinds_x", "lua>tab a", 0, screen_size[1], 1)
local keybinds_y = gui.add_slider("keybinds_y", "lua>tab a", 0, screen_size[2], 1)
gui.set_visible("lua>tab a>keybinds_x", false)
gui.set_visible("lua>tab a>keybinds_y", false)


function animate(value, cond, max, speed, dynamic, clamp)

    -- animation speed
    speed = speed * global_vars.frametime * 20

    -- static animation
    if dynamic == false then
        if cond then
            value = value + speed
        else
            value = value - speed
        end
    
    -- dynamic animation
    else
        if cond then
            value = value + (max - value) * (speed / 100)
        else
            value = value - (0 + value) * (speed / 100)
        end
    end

    -- clamp value
    if clamp then
        if value > max then
            value = max
        elseif value < 0 then
            value = 0
        end
    end

    return value
end

function drag(var_x, var_y, size_x, size_y)
    local mouse_x, mouse_y = input.get_cursor_pos()

    local drag = false

    if input.is_key_down(0x01) then
        if mouse_x > var_x:get_int() and mouse_y > var_y:get_int() and mouse_x < var_x:get_int() + size_x and mouse_y < var_y:get_int() + size_y then
            drag = true
        end
    else
        drag = false
    end

    if (drag) then
        var_x:set_int(mouse_x - (size_x / 2))
        var_y:set_int(mouse_y - (size_y / 2))
    end

end
function on_paint()

    if not keybinds_cb:get_bool() then return end

    local pos = {keybinds_x:get_int(), keybinds_y:get_int()}

    local size_offset = 0

    local binds =
    {
        gui.get_config_item("rage>aimbot>aimbot>double tap"):get_bool(),
        gui.get_config_item("rage>aimbot>aimbot>hide shot"):get_bool(),
        gui.get_config_item("rage>aimbot>ssg08>scout>override"):get_bool(), -- override dmg is taken from the scout
        gui.get_config_item("rage>aimbot>aimbot>force extra safety"):get_bool(),
        gui.get_config_item("rage>aimbot>aimbot>headshot only"):get_bool(),
        gui.get_config_item("misc>movement>fake duck"):get_bool()
    }

    local binds_name = 
    {
        "Double tap",
        "Hide shots",
        "Min. Damage",
        "Force safepoint",
        "Headshot only",
        "Fake duck",
    }

    if not binds[4] then
        if not binds[5] then
            if not binds[3] then
                if not binds[1] then
                    if not binds[6] then
                        if not binds[2] then
                            size_offset = 0
                        else
                            size_offset = 38
                        end
                    else
                        size_offset = 40
                    end
                else
                    size_offset = 41
                end
            else
                size_offset = 54
            end
        else
            size_offset = 63
        end
    else
        size_offset = 70
    end

    animated_size_offset = animate(animated_size_offset or 0, true, size_offset, 60, true, false)

    local size = {100 + animated_size_offset, 22}

    local enabled = "[enabled]"
    local text_size = render.get_text_size(verdana, enabled) + 7

    local override_active = binds[3] or binds[4] or binds[5] or binds[6] or binds[7] or binds[8]
    local other_binds_active = binds[1] or binds[2] or binds[9] or binds[10] or binds[11]

    drag(keybinds_x, keybinds_y, size[1], size[2])

    alpha = animate(alpha or 0, gui.is_menu_open() or override_active or other_binds_active, 1, 0.5, false, true)

    -- top rect
    render.push_clip_rect(pos[1], pos[2], pos[1] + size[1], pos[2] + 5)
    render.rect_filled_rounded(pos[1], pos[2], pos[1] + size[1], pos[2] + size[2], render.color(0, 170, 229, 255 * alpha), 5)
    render.pop_clip_rect()

    -- bot rect
    render.push_clip_rect(pos[1], pos[2] + 17, pos[1] + size[1], pos[2] + 22)
    render.rect_filled_rounded(pos[1], pos[2], pos[1] + size[1], pos[2] + 22, render.color(41, 101, 123, 255 * alpha), 5)
    render.pop_clip_rect()

    -- other
    render.rect_filled_multicolor(pos[1], pos[2] + 5, pos[1] + size[1], pos[2] + 17, render.color(0, 170, 229, 255 * alpha), render.color(0, 170, 229, 255 * alpha), render.color(41, 101, 123, 255 * alpha), render.color(41, 101, 123, 255 * alpha))
    render.rect_filled_rounded(pos[1] + 2, pos[2] + 2, pos[1] + size[1] - 2, pos[2] + 20, render.color(24, 24, 26, 255 * alpha), 5)
    render.text(verdana, pos[1] + size[1] / 2 - render.get_text_size(verdana, "keybinds") / 2 - 1, pos[2] + 3, "keybinds", render.color(255, 255, 255, 255 * alpha))


    local bind_offset = 0
    dt_alpha = animate(dt_alpha or 0, binds[1], 1, 0.5, false, true)
    render.text(verdana, pos[1] + 6, pos[2] + size[2] + 2, binds_name[1], render.color(255, 255, 255, 255 * dt_alpha))
    render.text(verdana, pos[1] + size[1] - text_size, pos[2] + size[2] + 2, enabled, render.color(255, 255, 255, 255 * dt_alpha))
    if binds[1] then
        bind_offset = bind_offset + 15
    end

    hs_alpha = animate(hs_alpha or 0, binds[2], 1, 0.5, false, true)
    render.text(verdana, pos[1] + 6, pos[2] + size[2] + 2 + bind_offset, binds_name[2], render.color(255, 255, 255, 255 * hs_alpha))
    render.text(verdana, pos[1] + size[1] - text_size, pos[2] + size[2] + 2 + bind_offset, enabled, render.color(255, 255, 255, 255 * hs_alpha))
    if binds[2] then
        bind_offset = bind_offset + 15
    end

    dmg_alpha = animate(dmg_alpha or 0, binds[3], 1, 0.5, false, true)
    render.text(verdana, pos[1] + 6, pos[2] + size[2] + 2 + bind_offset, binds_name[3], render.color(255, 255, 255, 255 * dmg_alpha))
    render.text(verdana, pos[1] + size[1] - text_size, pos[2] + size[2] + 2 + bind_offset, enabled, render.color(255, 255, 255, 255 * dmg_alpha))
    if binds[3] then
        bind_offset = bind_offset + 15
    end

    fs_alpha = animate(fs_alpha or 0, binds[4], 1, 0.5, false, true)
    render.text(verdana, pos[1] + 6, pos[2] + size[2] + 2 + bind_offset, binds_name[4], render.color(255, 255, 255, 255 * fs_alpha))
    render.text(verdana, pos[1] + size[1] - text_size, pos[2] + size[2] + 2 + bind_offset, enabled, render.color(255, 255, 255, 255 * fs_alpha))
    if binds[4] then
        bind_offset = bind_offset + 15
    end

    ho_alpha = animate(ho_alpha or 0, binds[5], 1, 0.5, false, true)
    render.text(verdana, pos[1] + 6, pos[2] + size[2] + 2 + bind_offset, binds_name[5], render.color(255, 255, 255, 255 * ho_alpha))
    render.text(verdana, pos[1] + size[1] - text_size, pos[2] + size[2] + 2 + bind_offset, enabled, render.color(255, 255, 255, 255 * ho_alpha))
    if binds[5] then
        bind_offset = bind_offset + 15
    end

    fd_alpha = animate(fd_alpha or 0, binds[6], 1, 0.5, false, true)
    render.text(verdana, pos[1] + 6, pos[2] + size[2] + 2 + bind_offset, binds_name[6], render.color(255, 255, 255, 255 * fd_alpha))
    render.text(verdana, pos[1] + size[1] - text_size, pos[2] + size[2] + 2 + bind_offset, enabled, render.color(255, 255, 255, 255 * fd_alpha))

end