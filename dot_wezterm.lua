-- Pull in the wezterm API
local wezterm = require 'wezterm'

-- This table will hold the configuration.
local config = {}

config.front_end = "WebGpu"

-- In newer versions of wezterm, use the config_builder which will
-- help provide clearer error messages
if wezterm.config_builder then
    config = wezterm.config_builder()
end

-- This is where you actually apply your config choices

config.enable_scroll_bar  = true
config.default_prog       = { "C:/Program Files/nu/bin/nu.exe", "-l" }
config.use_fancy_tab_bar            = true
-- config.hide_tab_bar_if_only_one_tab = true
config.tab_bar_at_bottom  = false
config.window_decorations = "RESIZE"
config.window_background_opacity    = 0.4
-- config.text_background_opacity      = 0.4
-- config.macos_window_background_blur = 20
config.window_padding     = {
    left = 8,
    right = 16,
    top = 8,
    bottom = 8,
}

-- Follow the OS appearance

function get_appearance()
    if wezterm.gui then
        return wezterm.gui.get_appearance()
    end
    return 'Dark'
end

function win32_backdrop_for_appearance(appearance)
    if appearance:find 'Dark' then
        return 'Mica'
    else
        return 'Tabbed'
    end
end

config.win32_system_backdrop = win32_backdrop_for_appearance(get_appearance())

function scheme_for_appearance(appearance)
    if appearance:find 'Dark' then
        return 'GitHub Dark'
    else
        return 'Github (base16)'
    end
end

function colors_for_appearance(appearance)
    if appearance:find 'Dark' then
        return {
            scrollbar_thumb = 'rgba(25, 29, 35, 0.2)',
            tab_bar         = {
                background        = 'rgba(0, 0, 0, 0)',
                new_tab           = {
                    bg_color = 'rgba(0, 0, 0, 0)',
                    fg_color = 'rgba(255, 255, 255, 1)',
                },
                new_tab_hover     = {
                    bg_color = 'rgba(128, 128, 128, 0.2)',
                    fg_color = 'rgba(255, 255, 255, 1)',
                    italic   = true,
                },
                inactive_tab_edge = 'rgba(0, 0, 0, 0)',
            },
        }
    else
        return {
            scrollbar_thumb = 'rgba(164, 164, 164, 0.2)',
            tab_bar         = {
                background        = 'rgba(255, 255, 255, 0)',
                new_tab           = {
                    bg_color = 'rgba(255, 255, 255, 0)',
                    fg_color = 'rgba(0, 0, 0, 1)',
                },
                new_tab_hover     = {
                    bg_color = 'rgba(200, 200, 200, 0.2)',
                    fg_color = 'rgba(0, 0, 0, 1)',
                    italic   = true,
                },
                inactive_tab_edge = 'rgba(0, 0, 0, 0)',
            }
        }
    end
end

function window_frame_for_appearance(appearance)
    if appearance:find 'Dark' then
        return {
            active_titlebar_bg = 'rgba(0, 0, 0, 0)',
            inactive_titlebar_bg = 'rgba(0, 0, 0, 0)',
            font_size = 14.0,
        }
    else
        return {
            active_titlebar_bg = 'rgba(221, 221, 221, 0)',
            inactive_titlebar_bg = 'rgba(221, 221, 221, 0)',
            font_size = 14.0,
        }
    end
end

config.color_scheme = scheme_for_appearance(get_appearance())
config.colors = colors_for_appearance(get_appearance())
config.window_frame = window_frame_for_appearance(get_appearance())

local SOLID_LEFT_HALF_PIE = wezterm.nerdfonts.ple_left_half_circle_thick
local SOLID_RIGHT_HALF_PIE = wezterm.nerdfonts.ple_right_half_circle_thick

-- This function returns the suggested title for a tab.
-- It prefers the title that was set via `tab:set_title()`
-- or `wezterm cli set-tab-title`, but falls back to the
-- title of the active pane in that tab.
function tab_title(tab_info)
    local title = tab_info.tab_title
    -- if the tab title is explicitly set, take that
    if title and #title > 0 then
        return title
    end
    -- Otherwise, use the title from the active pane
    -- in that tab
    return tab_info.active_pane.title
end

function tab_colors_for_appearance(appearance)
    if appearance:find 'Dark' then
        return {
            space_color = 'rgba(0, 0, 0, 0)',
            edge_background = 'rgba(0, 0, 0, 0)',
            active_tab = {
                bg_color = 'rgba(16, 18, 22, 0.4)',
                fg_color = 'rgba(255, 255, 255, 1)',
                edge_color = 'rgba(16, 18, 22, 0.4)',
            },
            inactive_tab = {
                bg_color = 'rgba(0, 0, 0, 0)',
                fg_color = 'rgba(192, 192, 192, 1)',
                edge_color = 'rgba(0, 0, 0, 0)',
            },
            inactive_tab_hover = {
                bg_color = 'rgba(0, 0, 0, 0)',
                fg_color = 'rgba(221, 221, 221, 1)',
                edge_color = 'rgba(0, 0, 0, 0)',
            },
        }
    else
        return {
            space_color = 'rgba(221, 221, 221, 0)',
            edge_background = 'rgba(221, 221, 221, 0)',
            active_tab = {
                bg_color = 'rgba(255, 255, 255, 0.4)',
                fg_color = 'rgba(0, 0, 0, 1)',
                edge_color = 'rgba(255, 255, 255, 0.4)',
            },
            inactive_tab = {
                bg_color = 'rgba(221, 221, 221, 0)',
                fg_color = 'rgba(68, 68, 68, 1)',
                edge_color = 'rgba(221, 221, 221, 0)',
            },
            inactive_tab_hover = {
                bg_color = 'rgba(238, 238, 238, 0)',
                fg_color = 'rgba(34, 34, 34, 1)',
                edge_color = 'rgba(238, 238, 238, 0)',
            },
        }
    end
end

wezterm.on(
    'format-tab-title',
    function(tab, tabs, panes, config, hover, max_width)
        local tab_colors = tab_colors_for_appearance(get_appearance())

        local space_color = tab_colors.space_color

        local edge_background = tab_colors.edge_background
        local edge_foreground = tab_colors.inactive_tab.edge_color
        local background = tab_colors.inactive_tab.bg_color
        local foreground = tab_colors.inactive_tab.fg_color

        if tab.is_active then
            foreground = tab_colors.active_tab.fg_color
            background = tab_colors.active_tab.bg_color
            edge_foreground = tab_colors.active_tab.edge_color
        elseif hover then
            foreground = tab_colors.inactive_tab_hover.fg_color
            background = tab_colors.inactive_tab_hover.bg_color
            edge_foreground = tab_colors.inactive_tab_hover.edge_color
        end


        local title = tab_title(tab)

        -- ensure that the titles fit in the available space,
        -- and that we have room for the edges.
        title = wezterm.truncate_right(title, max_width)

        return {
            -- { Background = { Color = space_color } },
            -- { Foreground = { Color = space_color } },
            -- { Text = ' ' },
            -- { Background = { Color = edge_background } },
            -- { Foreground = { Color = edge_foreground } },
            -- { Text = SOLID_LEFT_HALF_PIE },
            { Background = { Color = background } },
            { Foreground = { Color = foreground } },
            { Text = title },
            -- { Background = { Color = edge_background } },
            -- { Foreground = { Color = edge_foreground } },
            -- { Text = SOLID_RIGHT_HALF_PIE },
        }
    end
)

-- and finally, return the configuration to wezterm
return config
