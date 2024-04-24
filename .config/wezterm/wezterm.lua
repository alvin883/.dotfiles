-- Pull in the wezterm API
local wezterm = require 'wezterm'
local mux = wezterm.mux

-- This will hold the configuration.
local config = wezterm.config_builder()

local balance = require 'balance'

-- Overriding color theme -----------------------------------------------------
-- This will get the existing theme for Catppuccin Mocha and we override some
-- of its tab color on the next line
-- reference: https://github.com/wez/wezterm/issues/3783#issuecomment-1565697898
local mocha = wezterm.color.get_builtin_schemes()['Catppuccin Mocha']
mocha.tab_bar.background = "rgba(0 0 0 0)"
mocha.tab_bar.active_tab.bg_color = "rgba(0 0 0 0)"
mocha.tab_bar.active_tab.fg_color = "#cdd6f4"
mocha.tab_bar.inactive_tab.bg_color = "rgba(0 0 0 0)"
mocha.tab_bar.inactive_tab.fg_color = "#45475a"
config.color_schemes = {
  ['Catppuccin Mocha'] = mocha,
}
config.color_scheme = 'Catppuccin Mocha'
config.inactive_pane_hsb = {
  saturation = 0.7,
  brightness = 0.5,
}
-------------------------------------------------------------------------------
-- Sizing & Position ----------------------------------------------------------
config.font = wezterm.font_with_fallback({ { family = "Fira Code" } })
config.window_decorations = 'RESIZE'
config.use_fancy_tab_bar = false
config.window_padding = {
  left = 0,
  right = 0,
  top = 0,
  bottom = 0,
}
-- config.hide_tab_bar_if_only_one_tab = true
config.tab_bar_at_bottom = true
config.show_new_tab_button_in_tab_bar = false
config.window_background_opacity = 0.97
config.font_size = 11.8
config.line_height = 1.34
-------------------------------------------------------------------------------
-- Events ---------------------------------------------------------------------
wezterm.on('trigger-open-scrollback-into-editor', function(window, pane)
  -- Retrieve the text from the pane
  local text = pane:get_lines_as_text(pane:get_dimensions().scrollback_rows)

  -- Create a temporary file to pass to vim
  local name = os.tmpname()
  local f = io.open(name, 'w+')
  f:write(text)
  f:flush()
  f:close()

  -- Open a new window running vim and tell it to open the file
  window:perform_action(
    wezterm.action.SpawnCommandInNewWindow {
      args = { 'hx', name },
      set_environment_variables = {
        PATH = wezterm.home_dir .. '/.cargo/bin:' .. os.getenv('PATH'),
        HELIX_RUNTIME = wezterm.home_dir .. '/Documents/helix/runtime'
      }
    },
    pane
  )

  -- Wait "enough" time for vim to read the file before we remove it.
  -- The window creation and process spawn are asynchronous wrt. running
  -- this script and are not awaitable, so we just pick a number.
  --
  -- Note: We don't strictly need to remove this file, but it is nice
  -- to avoid cluttering up the temporary directory.
  wezterm.sleep_ms(1000)
  os.remove(name)
end)
-------------------------------------------------------------------------------
-- Keybinding -----------------------------------------------------------------
config.keys = {
  {
    key = 'Tab',
    mods = 'SHIFT|CTRL',
    action = wezterm.action.SpawnTab 'CurrentPaneDomain',
  },
  {
    key = 'T',
    mods = 'SHIFT|CTRL',
    action = wezterm.action.DisableDefaultAssignment,
  },
  {
    key = '<',
    mods = 'SHIFT|CTRL',
    action = wezterm.action.MoveTabRelative(-1),
  },
  {
    key = '>',
    mods = 'SHIFT|CTRL',
    action = wezterm.action.MoveTabRelative(1),
  },
  {
    key = 'LeftArrow',
    mods = 'SHIFT|CTRL',
    action = wezterm.action.ActivateTabRelative(-1),
  },
  {
    key = 'RightArrow',
    mods = 'SHIFT|CTRL',
    action = wezterm.action.ActivateTabRelative(1),
  },
  {
    key = '{',
    mods = 'SHIFT|CTRL',
    action = wezterm.action.ActivatePaneDirection 'Left',
  },
  {
    key = '}',
    mods = 'SHIFT|CTRL',
    action = wezterm.action.ActivatePaneDirection 'Right',
  },
  {
    key = 'Enter',
    mods = 'SHIFT|CTRL',
    action = wezterm.action.Multiple {
      wezterm.action.SplitPane { direction = 'Right' },
      wezterm.action_callback(balance.balance_panes("x")),
    },
  },
  {
    key = 'B',
    mods = 'SHIFT|CTRL|ALT',
    action = wezterm.action_callback(balance.balance_panes("x")),
  },
  {
    key = 'W',
    mods = 'SHIFT|CTRL',
    action = wezterm.action.CloseCurrentPane {
      confirm = false,
    },
  },
  {
    key = 'UpArrow',
    mods = 'SHIFT|CTRL',
    action = wezterm.action.ScrollByLine(-1),
  },
  {
    key = 'DownArrow',
    mods = 'SHIFT|CTRL',
    action = wezterm.action.ScrollByLine(1),
  },
  {
    key = 'PageUp',
    mods = 'SHIFT|CTRL',
    action = wezterm.action.ScrollByPage(-1),
  },
  {
    key = 'PageDown',
    mods = 'SHIFT|CTRL',
    action = wezterm.action.ScrollByPage(1),
  },
  {
    key = ')',
    mods = 'SHIFT|CTRL',
    action = wezterm.action.DisableDefaultAssignment,
  },
  {
    key = 'Backspace',
    mods = 'SHIFT|CTRL',
    action = wezterm.action.ResetFontSize,
  },
  -- Quick select http pattern & open it on select
  -- reference: https://wezfurlong.org/wezterm/config/lua/keyassignment/QuickSelectArgs.html
  {
    key = 'E',
    mods = 'SHIFT|CTRL',
    action = wezterm.action.QuickSelectArgs {
      label = 'open url',
      patterns = {
        'https?://\\S+',
      },
      action = wezterm.action_callback(function(window, pane)
        local url = window:get_selection_text_for_pane(pane)
        wezterm.log_info('opening: ' .. url)
        wezterm.open_with(url)
      end),
    },
  },
  {
    key = 'T',
    mods = 'ALT|CTRL|SHIFT',
    action = wezterm.action.PromptInputLine {
      description = wezterm.format {
        { Attribute = { Intensity = 'Bold' } },
        { Foreground = { AnsiColor = 'Fuchsia' } },
        { Text = 'Enter new name for this tab' },
      },
      action = wezterm.action_callback(function(window, pane, line)
        -- line will be `nil` if they hit escape without entering anything
        -- An empty string if they just hit enter
        -- Or the actual line of text they wrote
        if line then
          window:active_tab():set_title(line)
        end
      end),
    },
  },
  {
    key = 'W',
    mods = 'ALT|CTRL|SHIFT',
    action = wezterm.action.PromptInputLine {
      description = wezterm.format {
        { Attribute = { Intensity = 'Bold' } },
        { Foreground = { AnsiColor = 'Fuchsia' } },
        { Text = 'Enter new name for this workspace' },
      },
      action = wezterm.action_callback(function(window, pane, line)
        -- line will be `nil` if they hit escape without entering anything
        -- An empty string if they just hit enter
        -- Or the actual line of text they wrote
        if line then
          wezterm.mux.rename_workspace(
            wezterm.mux.get_active_workspace(),
            line
          )
        end
      end),
    },
  },
  {
    key = 'N',
    mods = 'ALT|CTRL|SHIFT',
    action = wezterm.action.PromptInputLine {
      description = wezterm.format {
        { Attribute = { Intensity = 'Bold' } },
        { Foreground = { AnsiColor = 'Fuchsia' } },
        { Text = 'Enter name for new workspace' },
      },
      action = wezterm.action_callback(function(window, pane, line)
        -- line will be `nil` if they hit escape without entering anything
        -- An empty string if they just hit enter
        -- Or the actual line of text they wrote
        if line then
          window:perform_action(
            wezterm.action.SwitchToWorkspace {
              name = line,
            },
            pane
          )
        end
      end),
    },
  },
  {
    key = '}',
    mods = 'ALT|CTRL|SHIFT',
    action = wezterm.action.SwitchWorkspaceRelative(1),
  },
  {
    key = '{',
    mods = 'ALT|CTRL|SHIFT',
    action = wezterm.action.SwitchWorkspaceRelative(-1),
  },
  {
    key = 'M',
    mods = 'ALT|CTRL|SHIFT',
    action = wezterm.action.ToggleFullScreen,
  },
  {
    key = 'H',
    mods = 'ALT|CTRL|SHIFT',
    action = wezterm.action.EmitEvent 'trigger-open-scrollback-into-editor',
  }
}
-------------------------------------------------------------------------------
-- Multiplexing ---------------------------------------------------------------
config.ssh_domains = {
  {
    name = 'mac',
    remote_address = '192.168.1.252',
    username = 'alvinnovian',
  }
}
-------------------------------------------------------------------------------
wezterm.on("gui-startup", function()
  local tab, pane, window = mux.spawn_window {}
  window:gui_window():maximize()
end)

wezterm.on('gui-attached', function(domain)
  -- maximize all displayed windows on startup
  local workspace = mux.get_active_workspace()
  for _, window in ipairs(mux.all_windows()) do
    if window:get_workspace() == workspace then
      window:gui_window():maximize()
    end
  end
end)

wezterm.on('update-right-status', function(window, pane)
  window:set_right_status(window:active_workspace())
end)

-- wezterm.on("gui-attached", function()
--   local tab, pane, window = mux.spawn_window{}
--   window:gui_window():maximize()
-- end)
-- wezterm.on("mux-startup", function()
--   local tab, pane, window = mux.spawn_window{}
--   window:gui_window():maximize()
-- end)

-- and finally, return the configuration to wezterm
return config
