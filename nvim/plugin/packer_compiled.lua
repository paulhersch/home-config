-- Automatically generated packer.nvim plugin loader code

if vim.api.nvim_call_function('has', {'nvim-0.5'}) ~= 1 then
  vim.api.nvim_command('echohl WarningMsg | echom "Invalid Neovim version for packer.nvim! | echohl None"')
  return
end

vim.api.nvim_command('packadd packer.nvim')

local no_errors, error_msg = pcall(function()

_G._packer = _G._packer or {}
_G._packer.inside_compile = true

local time
local profile_info
local should_profile = false
if should_profile then
  local hrtime = vim.loop.hrtime
  profile_info = {}
  time = function(chunk, start)
    if start then
      profile_info[chunk] = hrtime()
    else
      profile_info[chunk] = (hrtime() - profile_info[chunk]) / 1e6
    end
  end
else
  time = function(chunk, start) end
end

local function save_profiles(threshold)
  local sorted_times = {}
  for chunk_name, time_taken in pairs(profile_info) do
    sorted_times[#sorted_times + 1] = {chunk_name, time_taken}
  end
  table.sort(sorted_times, function(a, b) return a[2] > b[2] end)
  local results = {}
  for i, elem in ipairs(sorted_times) do
    if not threshold or threshold and elem[2] > threshold then
      results[i] = elem[1] .. ' took ' .. elem[2] .. 'ms'
    end
  end
  if threshold then
    table.insert(results, '(Only showing plugins that took longer than ' .. threshold .. ' ms ' .. 'to load)')
  end

  _G._packer.profile_output = results
end

time([[Luarocks path setup]], true)
local package_path_str = "/home/paul/.cache/nvim/packer_hererocks/2.1.0-beta3/share/lua/5.1/?.lua;/home/paul/.cache/nvim/packer_hererocks/2.1.0-beta3/share/lua/5.1/?/init.lua;/home/paul/.cache/nvim/packer_hererocks/2.1.0-beta3/lib/luarocks/rocks-5.1/?.lua;/home/paul/.cache/nvim/packer_hererocks/2.1.0-beta3/lib/luarocks/rocks-5.1/?/init.lua"
local install_cpath_pattern = "/home/paul/.cache/nvim/packer_hererocks/2.1.0-beta3/lib/lua/5.1/?.so"
if not string.find(package.path, package_path_str, 1, true) then
  package.path = package.path .. ';' .. package_path_str
end

if not string.find(package.cpath, install_cpath_pattern, 1, true) then
  package.cpath = package.cpath .. ';' .. install_cpath_pattern
end

time([[Luarocks path setup]], false)
time([[try_loadstring definition]], true)
local function try_loadstring(s, component, name)
  local success, result = pcall(loadstring(s), name, _G.packer_plugins[name])
  if not success then
    vim.schedule(function()
      vim.api.nvim_notify('packer.nvim: Error running ' .. component .. ' for ' .. name .. ': ' .. result, vim.log.levels.ERROR, {})
    end)
  end
  return result
end

time([[try_loadstring definition]], false)
time([[Defining packer_plugins]], true)
_G.packer_plugins = {
  LuaSnip = {
    loaded = true,
    path = "/home/paul/.local/share/nvim/site/pack/packer/start/LuaSnip",
    url = "https://github.com/L3MON4D3/LuaSnip"
  },
  ["aerial.nvim"] = {
    config = { "\27LJ\2\nu\0\0\6\0\a\0\r6\0\0\0'\2\1\0B\0\2\0029\0\2\0004\2\0\0B\0\2\0016\0\3\0'\2\4\0'\3\5\0'\4\6\0004\5\0\0B\0\5\1K\0\1\0\26<cmd>AerialToggle<cr>\r<Space>a\6n\bMap\nsetup\vaerial\frequire\0" },
    loaded = true,
    path = "/home/paul/.local/share/nvim/site/pack/packer/start/aerial.nvim",
    url = "https://github.com/stevearc/aerial.nvim"
  },
  ["barbar.nvim"] = {
    config = { "\27LJ\2\nA\0\0\3\0\4\0\0066\0\0\0'\2\1\0B\0\2\0029\0\2\0009\0\3\0L\0\2\0\nwidth\tView\19nvim-tree.view\frequire.\0\0\4\2\1\0\6-\0\0\0009\0\0\0-\2\1\0B\2\1\0A\0\0\1K\0\1\0\1¿\2¿\15set_offset.\0\0\4\2\1\0\6-\0\0\0009\0\0\0-\2\1\0B\2\1\0A\0\0\1K\0\1\0\1¿\2¿\15set_offset(\0\0\3\1\1\0\5-\0\0\0009\0\0\0)\2\0\0B\0\2\1K\0\1\0\1¿\15set_offsetù\2\1\0\a\0\14\0\0276\0\0\0'\2\1\0B\0\2\0029\0\2\0005\2\3\0B\0\2\0016\0\0\0'\2\4\0B\0\2\0026\1\0\0'\3\5\0B\1\2\0023\2\6\0009\3\a\0'\5\b\0003\6\t\0B\3\3\0019\3\a\0'\5\n\0003\6\v\0B\3\3\0019\3\a\0'\5\f\0003\6\r\0B\3\3\0012\0\0ÄK\0\1\0\0\14TreeClose\0\vResize\0\rTreeOpen\14subscribe\0\19bufferline.api\21nvim-tree.events\1\0\4\28icon_separator_inactive\5\26icon_separator_active\5\14auto_hide\2\14animation\1\nsetup\15bufferline\frequire\0" },
    loaded = true,
    path = "/home/paul/.local/share/nvim/site/pack/packer/start/barbar.nvim",
    url = "https://github.com/romgrk/barbar.nvim"
  },
  ["cmp-buffer"] = {
    loaded = true,
    path = "/home/paul/.local/share/nvim/site/pack/packer/start/cmp-buffer",
    url = "https://github.com/hrsh7th/cmp-buffer"
  },
  ["cmp-nvim-lsp"] = {
    loaded = true,
    path = "/home/paul/.local/share/nvim/site/pack/packer/start/cmp-nvim-lsp",
    url = "https://github.com/hrsh7th/cmp-nvim-lsp"
  },
  ["cmp-path"] = {
    loaded = true,
    path = "/home/paul/.local/share/nvim/site/pack/packer/start/cmp-path",
    url = "https://github.com/hrsh7th/cmp-path"
  },
  ["cmp-treesitter"] = {
    loaded = true,
    path = "/home/paul/.local/share/nvim/site/pack/packer/start/cmp-treesitter",
    url = "https://github.com/ray-x/cmp-treesitter"
  },
  cmp_luasnip = {
    loaded = true,
    path = "/home/paul/.local/share/nvim/site/pack/packer/start/cmp_luasnip",
    url = "https://github.com/saadparwaiz1/cmp_luasnip"
  },
  ["dashboard-nvim"] = {
    config = { "\27LJ\2\n¢\17\0\0\n\0\17\1'6\0\0\0'\2\1\0B\0\2\0024\1\5\0005\2\3\0>\2\1\0015\2\4\0>\2\2\0015\2\5\0>\2\3\0015\2\6\0>\2\4\1=\1\2\0005\1\b\0=\1\a\0006\1\t\0009\1\n\1'\3\v\0B\1\2\2\n\1\0\0X\2\15Ä5\2\f\0\18\5\1\0009\3\r\1B\3\2\4X\6\3Ä\21\a\2\0\22\a\0\a<\6\a\2E\6\3\2R\6˚\127=\2\14\0\18\5\1\0009\3\15\1B\3\2\1X\2\2Ä'\2\16\0=\2\14\0K\0\1\0\5\nclose\18custom_footer\nlines\1\2\0\0\5\15fortune -s\npopen\aio\1\21\0\0S=================     ===============     ===============   ========  ========S\\\\ . . . . . . .\\\\   //. . . . . . .\\\\   //. . . . . . .\\\\  \\\\. . .\\\\// . . //S||. . ._____. . .|| ||. . ._____. . .|| ||. . ._____. . .|| || . . .\\/ . . .||S|| . .||   ||. . || || . .||   ||. . || || . .||   ||. . || ||. . . . . . . ||S||. . ||   || . .|| ||. . ||   || . .|| ||. . ||   || . .|| || . | . . . . .||S|| . .||   ||. _-|| ||-_ .||   ||. . || || . .||   ||. _-|| ||-_.|\\ . . . . ||S||. . ||   ||-'  || ||  `-||   || . .|| ||. . ||   ||-'  || ||  `|\\_ . .|. .||S|| . _||   ||    || ||    ||   ||_ . || || . _||   ||    || ||   |\\ `-_/| . ||S||_-' ||  .|/    || ||    \\|.  || `-_|| ||_-' ||  .|/    || ||   | \\  / |-_.||S||    ||_-'      || ||      `-_||    || ||    ||_-'      || ||   | \\  / |  `||S||    `'         || ||         `'    || ||    `'         || ||   | \\  / |   ||S||            .===' `===.         .==='.`===.         .===' /==. |  \\/  |   ||S||         .=='   \\_|-_ `===. .==='   _|_   `===. .===' _-|/   `==  \\/  |   ||S||      .=='    _-'    `-_  `='    _-'   `-_    `='  _-'   `-_  /|  \\/  |   ||S||   .=='    _-'          '-__\\._-'         '-_./__-'         `' |. /|  |   ||S||.=='    _-'                                                     `' |  /==.||S=='    _-'                        N E O V I M                         \\/   `==S\\   _-'                                                                `-_   /S `''                                                                       ``'S                                                                              \18custom_header\1\0\4\vaction SessionManager load_session\tdesc%Select recent session           \rshortcut\afs\ticon\tÔë§ \1\0\4\vaction\24Telescope live_grep\tdesc%Live Grep with Telescope        \rshortcut\agf\ticon\tÔÄÇ \1\0\4\vaction\25Telescope find_files\tdesc%Find file with Telescope        \rshortcut\aff\ticon\tÔÄÇ \1\0\4\vaction\19NvimTreeToggle\tdesc\"Open Nvim Tree               \rshortcut\nSPC f\ticon\tÔÅª \18custom_center\14dashboard\frequire\2\0" },
    loaded = true,
    path = "/home/paul/.local/share/nvim/site/pack/packer/start/dashboard-nvim",
    url = "https://github.com/glepnir/dashboard-nvim"
  },
  ["fidget.nvim"] = {
    config = { "\27LJ\2\n8\0\0\3\0\3\0\a6\0\0\0'\2\1\0B\0\2\0029\0\2\0004\2\0\0B\0\2\1K\0\1\0\nsetup\vfidget\frequire\0" },
    loaded = true,
    path = "/home/paul/.local/share/nvim/site/pack/packer/start/fidget.nvim",
    url = "https://github.com/j-hui/fidget.nvim"
  },
  gitsigns = {
    config = { "\27LJ\2\n6\0\0\3\0\3\0\0066\0\0\0'\2\1\0B\0\2\0029\0\2\0B\0\1\1K\0\1\0\nsetup\rgitsigns\frequire\0" },
    loaded = true,
    path = "/home/paul/.local/share/nvim/site/pack/packer/start/gitsigns",
    url = "https://github.com/lewis6991/gitsigns.nvim"
  },
  ["indent-blankline.nvim"] = {
    config = { "\27LJ\2\nr\0\0\3\0\4\0\a6\0\0\0'\2\1\0B\0\2\0029\0\2\0005\2\3\0B\0\2\1K\0\1\0\1\0\2\25space_char_blankline\6 \25show_current_context\2\nsetup\21indent_blankline\frequire\0" },
    loaded = true,
    path = "/home/paul/.local/share/nvim/site/pack/packer/start/indent-blankline.nvim",
    url = "https://github.com/lukas-reineke/indent-blankline.nvim"
  },
  ["lsp-colors.nvim"] = {
    loaded = true,
    path = "/home/paul/.local/share/nvim/site/pack/packer/start/lsp-colors.nvim",
    url = "https://github.com/folke/lsp-colors.nvim"
  },
  ["lspsaga.nvim"] = {
    config = { "\27LJ\2\nè\4\0\0\6\0\22\00096\0\0\0'\2\1\0B\0\2\0029\0\2\0005\2\4\0005\3\3\0=\3\5\2B\0\2\0016\0\6\0'\2\a\0'\3\b\0'\4\t\0004\5\0\0B\0\5\0016\0\6\0'\2\a\0'\3\n\0'\4\v\0004\5\0\0B\0\5\0016\0\6\0'\2\a\0'\3\f\0'\4\r\0004\5\0\0B\0\5\0016\0\6\0'\2\14\0'\3\15\0'\4\r\0004\5\0\0B\0\5\0016\0\6\0'\2\a\0'\3\16\0'\4\17\0004\5\0\0B\0\5\0016\0\6\0'\2\a\0'\3\18\0'\4\19\0004\5\0\0B\0\5\0016\0\6\0'\2\14\0'\3\20\0'\4\21\0004\5\0\0B\0\5\0016\0\6\0'\2\a\0'\3\20\0'\4\21\0004\5\0\0B\0\5\1K\0\1\0+<cmd>Lspsaga diagnostic_jump_next <CR>\n<C-D> <cmd>Lspsaga hover_doc <CR>\6D&<cmd>Lspsaga peek_definition <CR>\agd\n<C-R>\6i\29<cmd>Lspsaga rename <CR>\agr\"<cmd>Lspsaga code_action <CR>\aca <cmd>Lspsaga lsp_finder<CR>\agt\6n\bMap\22diagnostic_header\1\0\0\1\5\0\0\b‚úã\tüëÜ\tüëâ\tü§è\18init_lsp_saga\flspsaga\frequire\0" },
    loaded = true,
    path = "/home/paul/.local/share/nvim/site/pack/packer/start/lspsaga.nvim",
    url = "https://github.com/glepnir/lspsaga.nvim"
  },
  lualine = {
    config = { "\27LJ\2\nH\0\0\4\0\5\0\t6\0\0\0009\0\1\0009\0\2\0006\2\0\0009\2\1\0029\2\3\2B\2\1\2'\3\4\0D\0\3\0\a:~\vgetcwd\16fnamemodify\afn\bvimÜ\14\1\0\v\0e\0Ï\0013\0\0\0005\1\2\0005\2\1\0=\2\3\0015\2\4\0004\3\3\0>\0\1\3=\3\5\2=\2\6\0015\2\a\0004\3\3\0>\0\1\3=\3\b\2=\2\t\0016\2\n\0'\4\v\0B\2\2\0029\2\f\2B\2\1\0026\3\n\0'\5\r\0B\3\2\0029\3\14\0035\5A\0005\6\16\0005\a\15\0=\a\17\0065\a \0005\b\23\0005\t\19\0009\n\18\2=\n\20\t9\n\21\2=\n\22\t=\t\24\b5\t\26\0009\n\25\2=\n\20\t9\n\27\2=\n\22\t=\t\28\b5\t\30\0009\n\29\2=\n\20\t9\n\29\2=\n\22\t=\t\31\b=\b!\a5\b$\0005\t#\0009\n\"\2=\n\20\t9\n\21\2=\n\22\t=\t\24\b5\t%\0009\n\25\2=\n\20\t9\n\27\2=\n\22\t=\t\28\b5\t&\0009\n\29\2=\n\20\t9\n\29\2=\n\22\t=\t\31\b=\b'\a5\b*\0005\t)\0009\n(\2=\n\20\t9\n\21\2=\n\22\t=\t\24\b5\t+\0009\n\25\2=\n\20\t9\n\27\2=\n\22\t=\t\28\b5\t,\0009\n\29\2=\n\20\t9\n\29\2=\n\22\t=\t\31\b=\b-\a5\b0\0005\t/\0009\n.\2=\n\20\t9\n\21\2=\n\22\t=\t\24\b5\t1\0009\n\25\2=\n\20\t9\n\27\2=\n\22\t=\t\28\b5\t2\0009\n\29\2=\n\20\t9\n\29\2=\n\22\t=\t\31\b=\b3\a5\b5\0005\t4\0009\n\27\2=\n\20\t9\n\21\2=\n\22\t=\t\24\b5\t6\0009\n\25\2=\n\20\t9\n\27\2=\n\22\t=\t\28\b5\t7\0009\n\29\2=\n\20\t9\n\29\2=\n\22\t=\t\31\b=\b8\a5\b:\0005\t9\0009\n\"\2=\n\20\t9\n\21\2=\n\22\t=\t\24\b5\t;\0009\n\25\2=\n\20\t9\n\27\2=\n\22\t=\t\28\b5\t<\0009\n\29\2=\n\20\t9\n\29\2=\n\22\t=\t\31\b=\b=\a=\a>\0065\a?\0=\a@\6=\6B\0055\6I\0004\a\3\0005\bC\0005\tD\0=\tE\b6\tF\0009\tG\t=\tH\b>\b\1\a=\a\5\0064\a\3\0005\bJ\0005\tK\0009\n\25\2=\n\20\t9\n\"\2=\n\22\t=\tL\b5\tM\0=\tN\b5\tO\0=\tP\b>\b\1\a5\bQ\0005\tR\0009\n\29\2=\n\20\t9\n\27\2=\n\22\t=\tL\b>\b\2\a=\a\b\0064\a\0\0=\aS\0064\a\0\0=\aT\0064\a\3\0005\bU\0005\tV\0009\n\29\2=\n\20\t=\tL\b5\tW\0=\tX\b5\tY\0=\t\6\b5\tZ\0=\tP\b5\t[\0=\tN\b>\b\1\a5\b\\\0005\t]\0009\n\25\2=\n\20\t9\n^\2=\n\22\t=\tL\b>\b\2\a=\a_\0064\a\0\0=\a`\6=\6\6\0055\6a\0004\a\0\0=\a\5\0065\ab\0=\a\b\0064\a\0\0=\aS\0064\a\0\0=\aT\0064\a\0\0=\a_\0064\a\0\0=\a`\6=\6\t\0054\6\0\0=\6c\0054\6\3\0>\1\1\6=\6d\5B\3\2\1K\0\1\0\15extensions\ftabline\1\2\0\0\rfilename\1\0\0\14lualine_z\14lualine_y\fcolor12\1\0\0\1\2\0\0\rfiletype\1\0\2\nright\5\tleft\5\1\0\2\nerror\t‚úó \twarn\bÔºÅ\1\3\0\0\nerror\twarn\fsources\1\3\0\0\rnvim_lsp\20nvim_diagnostic\1\0\0\1\2\2\0\16diagnostics\21update_in_insert\2\fcolored\2\14lualine_x\14lualine_c\1\0\0\1\2\0\0\vbranch\fsymbols\1\0\3\funnamed\funnamed\rreadonly\15(readonly)\rmodified\t [+]\14separator\1\0\2\nright\5\tleft\5\ncolor\1\0\0\1\2\0\0\rfilename\1\0\0\bfmt\nlower\vstring\14seperator\1\0\2\nright\5\tleft\5\1\2\0\0\tmode\foptions\1\0\0\23disabled_filetypes\1\2\0\0\vpacker\ntheme\rinactive\1\0\0\1\0\0\1\0\0\1\0\0\fcommand\1\0\0\1\0\0\1\0\0\1\0\0\freplace\1\0\0\1\0\0\1\0\0\1\0\0\vcolor1\vvisual\1\0\0\1\0\0\1\0\0\1\0\0\vcolor5\vinsert\1\0\0\1\0\0\1\0\0\1\0\0\vcolor4\vnormal\1\0\0\6c\1\0\0\rcontrast\6b\vcolor7\1\0\0\vcolor0\6a\1\0\0\afg\15background\abg\1\0\0\vcolor2\23section_separators\1\0\2\18icons_enabled\2\17globalstatus\2\1\0\2\nright\5\tleft\5\nsetup\flualine\15get_colors\14azul.core\frequire\22inactive_sections\14lualine_b\1\0\0\rsections\14lualine_a\1\0\0\14filetypes\1\0\0\1\2\0\0\rNvimTree\0\0" },
    loaded = true,
    path = "/home/paul/.local/share/nvim/site/pack/packer/start/lualine",
    url = "https://github.com/nvim-lualine/lualine.nvim"
  },
  ["neovim-session-manager"] = {
    config = { "\27LJ\2\nÛ\4\0\0\n\0\25\0*6\0\0\0'\2\1\0B\0\2\0026\1\0\0'\3\2\0B\1\2\0029\1\3\0015\3\n\0\18\6\0\0009\4\4\0006\a\5\0009\a\6\a9\a\a\a'\t\b\0B\a\2\2'\b\t\0B\4\4\2=\4\v\0036\4\0\0'\6\f\0B\4\2\0029\4\r\0049\4\14\4=\4\15\0034\4\0\0=\4\16\0035\4\17\0=\4\18\3B\1\2\0016\1\19\0'\3\20\0'\4\21\0'\5\22\0004\6\0\0B\1\5\0016\1\19\0'\3\20\0'\4\23\0'\5\24\0004\6\0\0B\1\5\1K\0\1\0+<cmd>SessionManager delete_session<cr>\ads)<cmd>SessionManager load_session<cr>\afs\6n\bMap\30autosave_ignore_filetypes\1\4\0\0\14gitcommit\rNvimTree\15toggleterm\25autosave_ignore_dirs\18autoload_mode\15CurrentDir\17AutoloadMode\27session_manager.config\17sessions_dir\1\0\6\31autosave_ignore_not_normal\2\26autosave_last_session\2\20max_path_length\3P\19colon_replacer\a++\18path_replacer\a__\29autosave_only_in_session\1\rsessions\tdata\fstdpath\afn\bvim\bnew\nsetup\20session_manager\17plenary.path\frequire\0" },
    loaded = true,
    path = "/home/paul/.local/share/nvim/site/pack/packer/start/neovim-session-manager",
    url = "https://github.com/Shatur/neovim-session-manager"
  },
  ["nvim-cmp"] = {
    config = { "\27LJ\2\n-\0\1\4\1\2\0\5-\1\0\0009\1\0\0019\3\1\0B\1\2\1K\0\1\0\0¿\tbody\15lsp_expand}\0\2\5\1\a\0\0229\2\0\1\n\2\0\0X\2\16Ä'\2\2\0009\3\0\1'\4\3\0&\2\4\2=\2\1\1'\2\4\0-\3\0\0009\4\0\0018\3\4\3\14\0\3\0X\4\1Ä'\3\5\0'\4\4\0&\2\4\2=\2\0\1X\2\2Ä'\2\6\0=\2\0\1L\1\2\0\2¿\t <> \a<>\6 \6)\n    (\tmenu\tkindö\1\0\1\3\2\4\0\21-\1\0\0009\1\0\1B\1\1\2\15\0\1\0X\2\4Ä-\1\0\0009\1\1\1B\1\1\1X\1\vÄ-\1\1\0009\1\2\1B\1\1\2\15\0\1\0X\2\4Ä-\1\1\0009\1\3\1B\1\1\1X\1\2Ä\18\1\0\0B\1\1\1K\0\1\0\1¿\0¿\19expand_or_jump\23expand_or_jumpable\21select_next_item\fvisible∑\a\1\0\r\0*\0G6\0\0\0'\2\1\0B\0\2\0026\1\0\0'\3\2\0B\1\2\0025\2\3\0009\3\4\0015\5\b\0005\6\6\0003\a\5\0=\a\a\6=\6\t\0055\6\v\0005\a\n\0=\a\f\6=\6\r\0055\6\15\0005\a\14\0=\a\16\0063\a\17\0=\a\18\6=\6\19\0059\6\20\0019\6\21\0069\6\22\0065\b\25\0009\t\20\0013\v\23\0005\f\24\0B\t\3\2=\t\26\b9\t\20\0019\t\27\t)\v¸ˇB\t\2\2=\t\28\b9\t\20\0019\t\27\t)\v\4\0B\t\2\2=\t\29\b9\t\20\0019\t\30\tB\t\1\2=\t\31\b9\t\20\0019\t \t5\v!\0B\t\2\2=\t\"\bB\6\2\2=\6\20\0059\6#\0019\6$\0064\b\6\0005\t%\0>\t\1\b5\t&\0>\t\2\b5\t'\0>\t\3\b5\t(\0>\t\4\b5\t)\0>\t\5\bB\6\2\2=\6$\5B\3\2\0012\0\0ÄK\0\1\0\1\0\2\19keyword_length\3\3\tname\vbuffer\1\0\1\tname\tpath\1\0\1\tname\15treesitter\1\0\1\tname\fluasnip\1\0\1\tname\rnvim_lsp\fsources\vconfig\t<CR>\1\0\1\vselect\1\fconfirm\n<C-e>\nabort\n<C-s>\n<C-w>\16scroll_docs\n<Tab>\1\0\0\1\3\0\0\6i\6s\0\vinsert\vpreset\fmapping\15formatting\vformat\0\vfields\1\0\0\1\4\0\0\tkind\tabbr\tmenu\vwindow\15completion\1\0\0\1\0\2\17side_padding\3\0\15col_offset\3˝ˇˇˇ\15\fsnippet\1\0\0\vexpand\1\0\0\0\nsetup\1\0\25\rVariable\bÔî™\rConstant\bÔ£æ\nField\bÔ∞†\vStruct\bÔ≠Ñ\16Constructor\bÔê£\nEvent\bÔÉß\rFunction\bÔûî\vFolder\bÔùä\vMethod\bÔö¶\14Reference\bÔúÜ\tText\bÔùæ\tFile\bÔúò\nColor\bÔ£ó\fSnippet\bÔëè\fKeyword\bÔ†ä\tEnum\bÔÖù\18TypeParameter\5\nValue\bÔ¢ü\rOperator\bÔöî\tUnit\bÔ•¨\rProperty\bÔ∞†\vModule\bÔíá\14Interface\bÔÉ®\15EnumMember\bÔÖù\nClass\bÔ¥Ø\bcmp\fluasnip\frequire\0" },
    loaded = true,
    path = "/home/paul/.local/share/nvim/site/pack/packer/start/nvim-cmp",
    url = "https://github.com/hrsh7th/nvim-cmp"
  },
  ["nvim-colorizer.lua"] = {
    config = { "\27LJ\2\nX\0\0\4\0\5\0\b6\0\0\0'\2\1\0B\0\2\0029\0\2\0005\2\3\0005\3\4\0B\0\3\1K\0\1\0\1\0\1\tmode\15background\1\2\0\0\6*\nsetup\14colorizer\frequire\0" },
    loaded = true,
    path = "/home/paul/.local/share/nvim/site/pack/packer/start/nvim-colorizer.lua",
    url = "https://github.com/norcalli/nvim-colorizer.lua"
  },
  ["nvim-lspconfig"] = {
    config = { "\27LJ\2\nV\0\0\6\0\6\0\f6\0\0\0009\0\1\0009\0\2\0006\2\0\0009\2\1\0029\2\3\2B\2\1\2'\3\4\0'\4\5\0'\5\5\0B\0\5\2L\0\2\0\5\t^.*/\vgetcwd\15substitute\afn\bvim˜\4\0\2\15\0$\0G6\2\0\0009\2\1\2'\4\2\0B\2\2\0016\2\0\0009\2\3\0029\2\4\2\18\4\1\0'\5\5\0'\6\6\0'\a\6\0B\2\5\0026\3\0\0009\3\1\3'\5\a\0\18\6\2\0'\a\b\0&\5\a\5B\3\2\1\a\2\t\0X\3\23Ä6\3\0\0009\3\n\3'\5\v\0\18\6\0\0005\a\25\0005\b\23\0005\t\f\0005\n\14\0005\v\r\0=\v\15\n=\n\16\t5\n\20\0006\v\17\0009\v\18\v'\r\19\0B\v\2\2=\v\21\n=\n\22\t=\t\24\b=\b\26\aB\3\4\2\18\0\3\0X\3\26Ä\a\2\27\0X\3\24Ä6\3\0\0009\3\n\3'\5\v\0\18\6\0\0005\a#\0005\b\"\0005\t\28\0005\n\30\0005\v\29\0=\v\15\n=\n\16\t5\n!\0006\v\0\0009\v\31\v9\v \v'\r\6\0+\14\2\0B\v\3\2=\v\21\n=\n\22\t=\t\24\b=\b\26\aB\3\4\2\18\0\3\0K\0\1\0\1\0\0\1\0\0\1\0\0\26nvim_get_runtime_file\bapi\1\0\0\1\2\0\0\bvim\1\0\1\fruntime\vLuaJIT\tnvim\rsettings\1\0\0\bLua\1\0\0\14workspace\flibrary\1\0\0\17AWM_LIB_PATH\vgetenv\aos\16diagnostics\fglobals\1\0\0\1\n\0\0\troot\fawesome\btag\vscreen\vclient\vmodkey\valtkey\nmouse\17mousegrabber\1\0\1\fruntime\b5.2\nforce\20tbl_deep_extend\fawesome\6'\16echo 'pwd: \5\t^.*/\15substitute\afn\"echo 'reloading lsp settings'\bcmd\bvimÄ\1\0\1\a\1\b\0\16-\1\0\0009\1\0\1'\3\1\0'\4\2\0'\5\3\0'\6\4\0B\1\5\2\18\3\0\0B\1\2\2\15\0\1\0X\2\1ÄL\1\2\0006\2\5\0009\2\6\0029\2\a\2D\2\1\0\2¿\vgetcwd\afn\bvim\6.\t.git\fpom.xml\17build.gradle\17root_pattern˙\b\1\0\f\0D\1w3\0\0\0006\1\1\0'\3\2\0B\1\2\0026\2\1\0'\4\3\0B\2\2\0026\3\4\0009\3\5\0039\3\6\0039\3\a\3B\3\1\0026\4\4\0009\4\t\4'\6\n\0009\a\b\0025\b\r\0006\t\1\0'\v\v\0B\t\2\0029\t\f\t\18\v\3\0B\t\2\2=\t\14\bB\4\4\2=\4\b\0029\4\15\0019\4\16\0045\6\18\0003\a\17\0=\a\19\0065\a\31\0005\b\21\0005\t\20\0=\t\22\b5\t\24\0005\n\23\0=\n\25\t5\n\26\0=\n\27\t=\t\28\b5\t\29\0=\t\30\b=\b \a=\a!\6B\4\2\0019\4\"\0019\4\16\0045\6'\0005\a#\0006\b$\0006\n\4\0009\n%\n9\n&\nB\n\1\0A\b\0\0?\b\0\0=\a(\6B\4\2\0019\4)\0019\4\16\0045\0062\0005\a1\0005\b/\0005\t-\0005\n+\0005\v*\0=\v,\n=\n.\t=\t0\b=\b)\a=\a!\6B\4\2\0019\0043\0019\4\16\0044\6\0\0B\4\2\0019\0044\0019\4\16\0044\6\0\0B\4\2\0019\0045\0019\4\16\0044\6\0\0B\4\2\0019\0046\0019\4\16\0045\6=\0005\a7\0006\b8\0009\b9\b'\n:\0B\b\2\2'\t;\0&\b\t\b>\b\3\a6\b8\0009\b9\b'\n:\0B\b\2\2'\t<\0&\b\t\b>\b\5\a=\a(\6B\4\2\0019\4>\0019\4\16\0045\6@\0005\a?\0=\a(\0063\aA\0=\aB\6B\4\2\0019\4C\0019\4\16\0044\6\0\0B\4\2\0012\0\0ÄK\0\1\0\tltex\rroot_dir\0\1\0\0\1\2\0\0\25java-language-server\25java_language_server\1\0\0\28/.cache/jdtls/workspace\25/.cache/jdtls/config\tHOME\vgetenv\aos\1\5\0\0\24jdt-language-server\19-configuration\0\n-data\njdtls\trnix\vtexlab\bhls\1\0\0\1\0\0\fplugins\1\0\0\16pycodestyle\1\0\0\vignore\1\0\1\18maxLineLength\3†\1\1\2\0\0\tW391\npylsp\bcmd\1\0\0\vgetpid\afn\rtostring\1\4\0\0\14OmniSharp\t-lsp\14--hostPID\14omnisharp\rsettings\bLua\1\0\0\14telemetry\1\0\1\venable\1\15completion\19keywordSnippet\1\0\1\tBoth\2\16callSnippet\1\0\0\1\0\1\tBoth\2\14workspace\1\0\0\1\0\1\20checkThirdParty\1\18on_new_config\1\0\0\0\nsetup\16sumneko_lua\17capabilities\1\0\0\25default_capabilities\17cmp_nvim_lsp\nforce\15tbl_extend\19default_config\29make_client_capabilities\rprotocol\blsp\bvim\19lspconfig.util\14lspconfig\frequire\0\tÄÄ¿ô\4\0" },
    loaded = true,
    path = "/home/paul/.local/share/nvim/site/pack/packer/start/nvim-lspconfig",
    url = "https://github.com/neovim/nvim-lspconfig"
  },
  ["nvim-tree"] = {
    config = { "\27LJ\2\n¥\5\0\0\a\0\28\0#6\0\0\0'\2\1\0B\0\2\0029\0\2\0005\2\3\0005\3\4\0005\4\5\0=\4\6\3=\3\a\0025\3\b\0=\3\t\0025\3\n\0=\3\v\0025\3\14\0005\4\f\0005\5\r\0=\5\6\4=\4\15\0035\4\16\0005\5\17\0005\6\18\0=\6\19\0055\6\20\0=\6\21\5=\5\22\4=\4\6\3=\3\23\2B\0\2\0016\0\24\0'\2\25\0'\3\26\0'\4\27\0004\5\0\0B\0\5\1K\0\1\0\28<cmd>NvimTreeToggle<CR>\r<Space>f\6n\bMap\rrenderer\vglyphs\vfolder\1\0\6\fdefault\bÔêì\topen\bÓóæ\fsymlink\bÔíÇ\17arrow_closed\5\15arrow_open\5\nempty\bÔÑî\bgit\1\0\5\14untracked\b‚òÖ\frenamed\b‚ûú\runstaged\b‚úó\runmerged\bÓúß\vstaged\b‚úì\1\0\2\fdefault\bÓòí\fsymlink\bÔíÅ\1\0\1\fpadding\6 \19indent_markers\1\0\0\1\0\4\tnone\6 \vcorner\b‚îî\titem\b‚îÇ\tedge\b‚îÇ\1\0\1\venable\1\tview\1\0\2\21hide_root_folder\2\18adaptive_size\2\24update_focused_file\1\0\2\15update_cwd\1\venable\2\16diagnostics\nicons\1\0\4\thint\5\nerror\bÔÅó\fwarning\bÔÅ±\tinfo\5\1\0\1\venable\2\1\0\4\15update_cwd\2\18hijack_cursor\2\17hijack_netrw\2\18disable_netrw\2\nsetup\14nvim-tree\frequire\0" },
    loaded = true,
    path = "/home/paul/.local/share/nvim/site/pack/packer/start/nvim-tree",
    url = "https://github.com/nvim-tree/nvim-tree.lua"
  },
  ["nvim-tree.lua"] = {
    loaded = true,
    path = "/home/paul/.local/share/nvim/site/pack/packer/start/nvim-tree.lua",
    url = "https://github.com/kyazdani42/nvim-tree.lua"
  },
  ["nvim-treesitter"] = {
    config = { "\27LJ\2\n®\1\0\0\4\0\6\0\t6\0\0\0'\2\1\0B\0\2\0029\0\2\0005\2\3\0005\3\4\0=\3\5\2B\0\2\1K\0\1\0\14highlight\1\0\2&additional_vim_regex_highlighting\1\venable\2\1\0\2\17sync_install\1\17auto_install\2\nsetup\28nvim-treesitter.configs\frequire\0" },
    loaded = true,
    path = "/home/paul/.local/share/nvim/site/pack/packer/start/nvim-treesitter",
    url = "https://github.com/nvim-treesitter/nvim-treesitter"
  },
  ["nvim-web-devicons"] = {
    loaded = true,
    path = "/home/paul/.local/share/nvim/site/pack/packer/start/nvim-web-devicons",
    url = "https://github.com/kyazdani42/nvim-web-devicons"
  },
  ["packer.nvim"] = {
    loaded = true,
    path = "/home/paul/.local/share/nvim/site/pack/packer/start/packer.nvim",
    url = "https://github.com/wbthomason/packer.nvim"
  },
  ["plenary.nvim"] = {
    loaded = true,
    path = "/home/paul/.local/share/nvim/site/pack/packer/start/plenary.nvim",
    url = "https://github.com/nvim-lua/plenary.nvim"
  },
  ["telescope-ui-select.nvim"] = {
    loaded = true,
    path = "/home/paul/.local/share/nvim/site/pack/packer/start/telescope-ui-select.nvim",
    url = "https://github.com/nvim-telescope/telescope-ui-select.nvim"
  },
  ["telescope.nvim"] = {
    config = { "\27LJ\2\nñ\v\0\0\b\0003\1[6\0\0\0'\2\1\0B\0\2\0029\0\2\0005\2#\0005\3\4\0005\4\3\0=\4\5\0035\4\a\0005\5\6\0=\5\b\0045\5\t\0=\5\n\4=\4\v\0036\4\0\0'\6\f\0B\4\2\0029\4\r\4=\4\14\0035\4\15\0=\4\16\0036\4\0\0'\6\f\0B\4\2\0029\4\17\4=\4\18\0035\4\19\0=\4\20\0034\4\0\0=\4\21\0035\4\22\0=\4\23\0035\4\24\0=\4\25\0036\4\0\0'\6\26\0B\4\2\0029\4\27\0049\4\28\4=\4\29\0036\4\0\0'\6\26\0B\4\2\0029\4\30\0049\4\28\4=\4\31\0036\4\0\0'\6\26\0B\4\2\0029\4 \0049\4\28\4=\4!\0036\4\0\0'\6\26\0B\4\2\0029\4\"\4=\4\"\3=\3$\0025\3%\0=\3&\0025\3)\0004\4\3\0006\5\0\0'\a'\0B\5\2\0029\5(\0054\a\0\0B\5\2\0?\5\0\0=\4*\3=\3+\2B\0\2\0016\0\0\0'\2\1\0B\0\2\0029\0,\0'\2*\0B\0\2\0016\0-\0'\2.\0'\3/\0'\0040\0004\5\0\0B\0\5\0016\0-\0'\2.\0'\0031\0'\0042\0004\5\0\0B\0\5\1K\0\1\0\"<cmd>Telescope find_files<CR>\aff!<cmd>Telescope live_grep<CR>\agf\6n\bMap\19load_extension\15extensions\14ui-select\1\0\0\17get_dropdown\21telescope.themes\20extensions_list\1\3\0\0\vthemes\nterms\rdefaults\1\0\0\27buffer_previewer_maker\21qflist_previewer\22vim_buffer_qflist\19grep_previewer\23vim_buffer_vimgrep\19file_previewer\bnew\19vim_buffer_cat\25telescope.previewers\fset_env\1\0\1\14COLORTERM\14truecolor\16borderchars\1\t\0\0\b‚îÄ\b‚îÇ\b‚îÄ\b‚îÇ\b‚ï≠\b‚ïÆ\b‚ïØ\b‚ï∞\vborder\17path_display\1\2\0\0\rtruncate\19generic_sorter\29get_generic_fuzzy_sorter\25file_ignore_patterns\1\2\0\0\17node_modules\16file_sorter\19get_fuzzy_file\22telescope.sorters\18layout_config\rvertical\1\0\1\vmirror\1\15horizontal\1\0\3\nwidth\4◊«¬Î\3äÆØˇ\3\19preview_cutoff\3x\vheight\4ö≥ÊÃ\tô≥¶ˇ\3\1\0\3\18preview_width\4ö≥ÊÃ\tô≥Üˇ\3\20prompt_position\btop\18results_width\4ö≥ÊÃ\tô≥¶ˇ\3\22vimgrep_arguments\1\0\t\rwinblend\3\0\19color_devicons\2\20layout_strategy\15horizontal\21sorting_strategy\14ascending\23selection_strategy\nreset\17initial_mode\vinsert\17entry_prefix\a  \20selection_caret\a  \18prompt_prefix\v ÔÄÇ  \1\b\0\0\arg\18--color=never\17--no-heading\20--with-filename\18--line-number\r--column\17--smart-case\nsetup\14telescope\frequire\3ÄÄ¿ô\4\0" },
    loaded = true,
    path = "/home/paul/.local/share/nvim/site/pack/packer/start/telescope.nvim",
    url = "https://github.com/nvim-telescope/telescope.nvim"
  },
  ["toggleterm.nvim"] = {
    config = { "\27LJ\2\nŒ\2\0\0\a\0\21\0\"6\0\0\0'\2\1\0B\0\2\0029\0\2\0B\0\1\0026\1\0\0'\3\3\0B\1\2\0029\1\4\0015\3\5\0005\4\6\0=\4\a\0035\4\f\0005\5\t\0009\6\b\0=\6\n\0059\6\b\0=\6\v\5=\5\r\4=\4\14\3B\1\2\0016\1\15\0'\3\16\0'\4\17\0'\5\18\0004\6\0\0B\1\5\0016\1\15\0'\3\19\0'\4\20\0'\5\18\0004\6\0\0B\1\5\1K\0\1\0\n<C-T>\6t\24<cmd>ToggleTerm<CR>\att\6n\bMap\15highlights\16FloatBorder\1\0\0\nguibg\nguifg\1\0\0\rcontrast\15float_opts\1\0\1\vborder\vsingle\1\0\2\14direction\nfloat\14autochdir\2\nsetup\15toggleterm\15get_colors\14azul.core\frequire\0" },
    loaded = true,
    path = "/home/paul/.local/share/nvim/site/pack/packer/start/toggleterm.nvim",
    url = "https://github.com/akinsho/toggleterm.nvim"
  },
  ["tree-sitter"] = {
    loaded = true,
    path = "/home/paul/.local/share/nvim/site/pack/packer/start/tree-sitter",
    url = "https://github.com/tree-sitter/tree-sitter"
  },
  ["trouble.nvim"] = {
    config = { "\27LJ\2\n‹\2\0\0\a\0\23\0%6\0\0\0'\2\1\0B\0\2\0029\0\2\0B\0\1\0026\1\0\0'\3\3\0B\1\2\0029\1\4\0015\3\6\0009\4\5\0=\4\a\0039\4\b\0=\4\t\0039\4\n\0=\4\v\0039\4\f\0=\4\r\3B\1\2\0016\1\0\0'\3\14\0B\1\2\0029\1\4\0014\3\0\0B\1\2\0016\1\15\0009\1\16\0019\1\17\0015\3\18\0B\1\2\0016\1\19\0'\3\20\0'\4\21\0'\5\22\0004\6\0\0B\1\5\1K\0\1\0\27<cmd>TroubleToggle<cr>\r<Space>t\6n\bMap\1\0\1\17virtual_text\1\vconfig\15diagnostic\bvim\ftrouble\tHint\vcolor6\16Information\vcolor4\fWarning\vcolor3\nError\1\0\0\vcolor1\nsetup\15lsp-colors\15get_colors\14azul.core\frequire\0" },
    loaded = true,
    path = "/home/paul/.local/share/nvim/site/pack/packer/start/trouble.nvim",
    url = "https://github.com/folke/trouble.nvim"
  }
}

time([[Defining packer_plugins]], false)
-- Config for: nvim-tree
time([[Config for nvim-tree]], true)
try_loadstring("\27LJ\2\n¥\5\0\0\a\0\28\0#6\0\0\0'\2\1\0B\0\2\0029\0\2\0005\2\3\0005\3\4\0005\4\5\0=\4\6\3=\3\a\0025\3\b\0=\3\t\0025\3\n\0=\3\v\0025\3\14\0005\4\f\0005\5\r\0=\5\6\4=\4\15\0035\4\16\0005\5\17\0005\6\18\0=\6\19\0055\6\20\0=\6\21\5=\5\22\4=\4\6\3=\3\23\2B\0\2\0016\0\24\0'\2\25\0'\3\26\0'\4\27\0004\5\0\0B\0\5\1K\0\1\0\28<cmd>NvimTreeToggle<CR>\r<Space>f\6n\bMap\rrenderer\vglyphs\vfolder\1\0\6\fdefault\bÔêì\topen\bÓóæ\fsymlink\bÔíÇ\17arrow_closed\5\15arrow_open\5\nempty\bÔÑî\bgit\1\0\5\14untracked\b‚òÖ\frenamed\b‚ûú\runstaged\b‚úó\runmerged\bÓúß\vstaged\b‚úì\1\0\2\fdefault\bÓòí\fsymlink\bÔíÅ\1\0\1\fpadding\6 \19indent_markers\1\0\0\1\0\4\tnone\6 \vcorner\b‚îî\titem\b‚îÇ\tedge\b‚îÇ\1\0\1\venable\1\tview\1\0\2\21hide_root_folder\2\18adaptive_size\2\24update_focused_file\1\0\2\15update_cwd\1\venable\2\16diagnostics\nicons\1\0\4\thint\5\nerror\bÔÅó\fwarning\bÔÅ±\tinfo\5\1\0\1\venable\2\1\0\4\15update_cwd\2\18hijack_cursor\2\17hijack_netrw\2\18disable_netrw\2\nsetup\14nvim-tree\frequire\0", "config", "nvim-tree")
time([[Config for nvim-tree]], false)
-- Config for: trouble.nvim
time([[Config for trouble.nvim]], true)
try_loadstring("\27LJ\2\n‹\2\0\0\a\0\23\0%6\0\0\0'\2\1\0B\0\2\0029\0\2\0B\0\1\0026\1\0\0'\3\3\0B\1\2\0029\1\4\0015\3\6\0009\4\5\0=\4\a\0039\4\b\0=\4\t\0039\4\n\0=\4\v\0039\4\f\0=\4\r\3B\1\2\0016\1\0\0'\3\14\0B\1\2\0029\1\4\0014\3\0\0B\1\2\0016\1\15\0009\1\16\0019\1\17\0015\3\18\0B\1\2\0016\1\19\0'\3\20\0'\4\21\0'\5\22\0004\6\0\0B\1\5\1K\0\1\0\27<cmd>TroubleToggle<cr>\r<Space>t\6n\bMap\1\0\1\17virtual_text\1\vconfig\15diagnostic\bvim\ftrouble\tHint\vcolor6\16Information\vcolor4\fWarning\vcolor3\nError\1\0\0\vcolor1\nsetup\15lsp-colors\15get_colors\14azul.core\frequire\0", "config", "trouble.nvim")
time([[Config for trouble.nvim]], false)
-- Config for: aerial.nvim
time([[Config for aerial.nvim]], true)
try_loadstring("\27LJ\2\nu\0\0\6\0\a\0\r6\0\0\0'\2\1\0B\0\2\0029\0\2\0004\2\0\0B\0\2\0016\0\3\0'\2\4\0'\3\5\0'\4\6\0004\5\0\0B\0\5\1K\0\1\0\26<cmd>AerialToggle<cr>\r<Space>a\6n\bMap\nsetup\vaerial\frequire\0", "config", "aerial.nvim")
time([[Config for aerial.nvim]], false)
-- Config for: indent-blankline.nvim
time([[Config for indent-blankline.nvim]], true)
try_loadstring("\27LJ\2\nr\0\0\3\0\4\0\a6\0\0\0'\2\1\0B\0\2\0029\0\2\0005\2\3\0B\0\2\1K\0\1\0\1\0\2\25space_char_blankline\6 \25show_current_context\2\nsetup\21indent_blankline\frequire\0", "config", "indent-blankline.nvim")
time([[Config for indent-blankline.nvim]], false)
-- Config for: barbar.nvim
time([[Config for barbar.nvim]], true)
try_loadstring("\27LJ\2\nA\0\0\3\0\4\0\0066\0\0\0'\2\1\0B\0\2\0029\0\2\0009\0\3\0L\0\2\0\nwidth\tView\19nvim-tree.view\frequire.\0\0\4\2\1\0\6-\0\0\0009\0\0\0-\2\1\0B\2\1\0A\0\0\1K\0\1\0\1¿\2¿\15set_offset.\0\0\4\2\1\0\6-\0\0\0009\0\0\0-\2\1\0B\2\1\0A\0\0\1K\0\1\0\1¿\2¿\15set_offset(\0\0\3\1\1\0\5-\0\0\0009\0\0\0)\2\0\0B\0\2\1K\0\1\0\1¿\15set_offsetù\2\1\0\a\0\14\0\0276\0\0\0'\2\1\0B\0\2\0029\0\2\0005\2\3\0B\0\2\0016\0\0\0'\2\4\0B\0\2\0026\1\0\0'\3\5\0B\1\2\0023\2\6\0009\3\a\0'\5\b\0003\6\t\0B\3\3\0019\3\a\0'\5\n\0003\6\v\0B\3\3\0019\3\a\0'\5\f\0003\6\r\0B\3\3\0012\0\0ÄK\0\1\0\0\14TreeClose\0\vResize\0\rTreeOpen\14subscribe\0\19bufferline.api\21nvim-tree.events\1\0\4\28icon_separator_inactive\5\26icon_separator_active\5\14auto_hide\2\14animation\1\nsetup\15bufferline\frequire\0", "config", "barbar.nvim")
time([[Config for barbar.nvim]], false)
-- Config for: nvim-treesitter
time([[Config for nvim-treesitter]], true)
try_loadstring("\27LJ\2\n®\1\0\0\4\0\6\0\t6\0\0\0'\2\1\0B\0\2\0029\0\2\0005\2\3\0005\3\4\0=\3\5\2B\0\2\1K\0\1\0\14highlight\1\0\2&additional_vim_regex_highlighting\1\venable\2\1\0\2\17sync_install\1\17auto_install\2\nsetup\28nvim-treesitter.configs\frequire\0", "config", "nvim-treesitter")
time([[Config for nvim-treesitter]], false)
-- Config for: lspsaga.nvim
time([[Config for lspsaga.nvim]], true)
try_loadstring("\27LJ\2\nè\4\0\0\6\0\22\00096\0\0\0'\2\1\0B\0\2\0029\0\2\0005\2\4\0005\3\3\0=\3\5\2B\0\2\0016\0\6\0'\2\a\0'\3\b\0'\4\t\0004\5\0\0B\0\5\0016\0\6\0'\2\a\0'\3\n\0'\4\v\0004\5\0\0B\0\5\0016\0\6\0'\2\a\0'\3\f\0'\4\r\0004\5\0\0B\0\5\0016\0\6\0'\2\14\0'\3\15\0'\4\r\0004\5\0\0B\0\5\0016\0\6\0'\2\a\0'\3\16\0'\4\17\0004\5\0\0B\0\5\0016\0\6\0'\2\a\0'\3\18\0'\4\19\0004\5\0\0B\0\5\0016\0\6\0'\2\14\0'\3\20\0'\4\21\0004\5\0\0B\0\5\0016\0\6\0'\2\a\0'\3\20\0'\4\21\0004\5\0\0B\0\5\1K\0\1\0+<cmd>Lspsaga diagnostic_jump_next <CR>\n<C-D> <cmd>Lspsaga hover_doc <CR>\6D&<cmd>Lspsaga peek_definition <CR>\agd\n<C-R>\6i\29<cmd>Lspsaga rename <CR>\agr\"<cmd>Lspsaga code_action <CR>\aca <cmd>Lspsaga lsp_finder<CR>\agt\6n\bMap\22diagnostic_header\1\0\0\1\5\0\0\b‚úã\tüëÜ\tüëâ\tü§è\18init_lsp_saga\flspsaga\frequire\0", "config", "lspsaga.nvim")
time([[Config for lspsaga.nvim]], false)
-- Config for: neovim-session-manager
time([[Config for neovim-session-manager]], true)
try_loadstring("\27LJ\2\nÛ\4\0\0\n\0\25\0*6\0\0\0'\2\1\0B\0\2\0026\1\0\0'\3\2\0B\1\2\0029\1\3\0015\3\n\0\18\6\0\0009\4\4\0006\a\5\0009\a\6\a9\a\a\a'\t\b\0B\a\2\2'\b\t\0B\4\4\2=\4\v\0036\4\0\0'\6\f\0B\4\2\0029\4\r\0049\4\14\4=\4\15\0034\4\0\0=\4\16\0035\4\17\0=\4\18\3B\1\2\0016\1\19\0'\3\20\0'\4\21\0'\5\22\0004\6\0\0B\1\5\0016\1\19\0'\3\20\0'\4\23\0'\5\24\0004\6\0\0B\1\5\1K\0\1\0+<cmd>SessionManager delete_session<cr>\ads)<cmd>SessionManager load_session<cr>\afs\6n\bMap\30autosave_ignore_filetypes\1\4\0\0\14gitcommit\rNvimTree\15toggleterm\25autosave_ignore_dirs\18autoload_mode\15CurrentDir\17AutoloadMode\27session_manager.config\17sessions_dir\1\0\6\31autosave_ignore_not_normal\2\26autosave_last_session\2\20max_path_length\3P\19colon_replacer\a++\18path_replacer\a__\29autosave_only_in_session\1\rsessions\tdata\fstdpath\afn\bvim\bnew\nsetup\20session_manager\17plenary.path\frequire\0", "config", "neovim-session-manager")
time([[Config for neovim-session-manager]], false)
-- Config for: telescope.nvim
time([[Config for telescope.nvim]], true)
try_loadstring("\27LJ\2\nñ\v\0\0\b\0003\1[6\0\0\0'\2\1\0B\0\2\0029\0\2\0005\2#\0005\3\4\0005\4\3\0=\4\5\0035\4\a\0005\5\6\0=\5\b\0045\5\t\0=\5\n\4=\4\v\0036\4\0\0'\6\f\0B\4\2\0029\4\r\4=\4\14\0035\4\15\0=\4\16\0036\4\0\0'\6\f\0B\4\2\0029\4\17\4=\4\18\0035\4\19\0=\4\20\0034\4\0\0=\4\21\0035\4\22\0=\4\23\0035\4\24\0=\4\25\0036\4\0\0'\6\26\0B\4\2\0029\4\27\0049\4\28\4=\4\29\0036\4\0\0'\6\26\0B\4\2\0029\4\30\0049\4\28\4=\4\31\0036\4\0\0'\6\26\0B\4\2\0029\4 \0049\4\28\4=\4!\0036\4\0\0'\6\26\0B\4\2\0029\4\"\4=\4\"\3=\3$\0025\3%\0=\3&\0025\3)\0004\4\3\0006\5\0\0'\a'\0B\5\2\0029\5(\0054\a\0\0B\5\2\0?\5\0\0=\4*\3=\3+\2B\0\2\0016\0\0\0'\2\1\0B\0\2\0029\0,\0'\2*\0B\0\2\0016\0-\0'\2.\0'\3/\0'\0040\0004\5\0\0B\0\5\0016\0-\0'\2.\0'\0031\0'\0042\0004\5\0\0B\0\5\1K\0\1\0\"<cmd>Telescope find_files<CR>\aff!<cmd>Telescope live_grep<CR>\agf\6n\bMap\19load_extension\15extensions\14ui-select\1\0\0\17get_dropdown\21telescope.themes\20extensions_list\1\3\0\0\vthemes\nterms\rdefaults\1\0\0\27buffer_previewer_maker\21qflist_previewer\22vim_buffer_qflist\19grep_previewer\23vim_buffer_vimgrep\19file_previewer\bnew\19vim_buffer_cat\25telescope.previewers\fset_env\1\0\1\14COLORTERM\14truecolor\16borderchars\1\t\0\0\b‚îÄ\b‚îÇ\b‚îÄ\b‚îÇ\b‚ï≠\b‚ïÆ\b‚ïØ\b‚ï∞\vborder\17path_display\1\2\0\0\rtruncate\19generic_sorter\29get_generic_fuzzy_sorter\25file_ignore_patterns\1\2\0\0\17node_modules\16file_sorter\19get_fuzzy_file\22telescope.sorters\18layout_config\rvertical\1\0\1\vmirror\1\15horizontal\1\0\3\nwidth\4◊«¬Î\3äÆØˇ\3\19preview_cutoff\3x\vheight\4ö≥ÊÃ\tô≥¶ˇ\3\1\0\3\18preview_width\4ö≥ÊÃ\tô≥Üˇ\3\20prompt_position\btop\18results_width\4ö≥ÊÃ\tô≥¶ˇ\3\22vimgrep_arguments\1\0\t\rwinblend\3\0\19color_devicons\2\20layout_strategy\15horizontal\21sorting_strategy\14ascending\23selection_strategy\nreset\17initial_mode\vinsert\17entry_prefix\a  \20selection_caret\a  \18prompt_prefix\v ÔÄÇ  \1\b\0\0\arg\18--color=never\17--no-heading\20--with-filename\18--line-number\r--column\17--smart-case\nsetup\14telescope\frequire\3ÄÄ¿ô\4\0", "config", "telescope.nvim")
time([[Config for telescope.nvim]], false)
-- Config for: fidget.nvim
time([[Config for fidget.nvim]], true)
try_loadstring("\27LJ\2\n8\0\0\3\0\3\0\a6\0\0\0'\2\1\0B\0\2\0029\0\2\0004\2\0\0B\0\2\1K\0\1\0\nsetup\vfidget\frequire\0", "config", "fidget.nvim")
time([[Config for fidget.nvim]], false)
-- Config for: nvim-colorizer.lua
time([[Config for nvim-colorizer.lua]], true)
try_loadstring("\27LJ\2\nX\0\0\4\0\5\0\b6\0\0\0'\2\1\0B\0\2\0029\0\2\0005\2\3\0005\3\4\0B\0\3\1K\0\1\0\1\0\1\tmode\15background\1\2\0\0\6*\nsetup\14colorizer\frequire\0", "config", "nvim-colorizer.lua")
time([[Config for nvim-colorizer.lua]], false)
-- Config for: dashboard-nvim
time([[Config for dashboard-nvim]], true)
try_loadstring("\27LJ\2\n¢\17\0\0\n\0\17\1'6\0\0\0'\2\1\0B\0\2\0024\1\5\0005\2\3\0>\2\1\0015\2\4\0>\2\2\0015\2\5\0>\2\3\0015\2\6\0>\2\4\1=\1\2\0005\1\b\0=\1\a\0006\1\t\0009\1\n\1'\3\v\0B\1\2\2\n\1\0\0X\2\15Ä5\2\f\0\18\5\1\0009\3\r\1B\3\2\4X\6\3Ä\21\a\2\0\22\a\0\a<\6\a\2E\6\3\2R\6˚\127=\2\14\0\18\5\1\0009\3\15\1B\3\2\1X\2\2Ä'\2\16\0=\2\14\0K\0\1\0\5\nclose\18custom_footer\nlines\1\2\0\0\5\15fortune -s\npopen\aio\1\21\0\0S=================     ===============     ===============   ========  ========S\\\\ . . . . . . .\\\\   //. . . . . . .\\\\   //. . . . . . .\\\\  \\\\. . .\\\\// . . //S||. . ._____. . .|| ||. . ._____. . .|| ||. . ._____. . .|| || . . .\\/ . . .||S|| . .||   ||. . || || . .||   ||. . || || . .||   ||. . || ||. . . . . . . ||S||. . ||   || . .|| ||. . ||   || . .|| ||. . ||   || . .|| || . | . . . . .||S|| . .||   ||. _-|| ||-_ .||   ||. . || || . .||   ||. _-|| ||-_.|\\ . . . . ||S||. . ||   ||-'  || ||  `-||   || . .|| ||. . ||   ||-'  || ||  `|\\_ . .|. .||S|| . _||   ||    || ||    ||   ||_ . || || . _||   ||    || ||   |\\ `-_/| . ||S||_-' ||  .|/    || ||    \\|.  || `-_|| ||_-' ||  .|/    || ||   | \\  / |-_.||S||    ||_-'      || ||      `-_||    || ||    ||_-'      || ||   | \\  / |  `||S||    `'         || ||         `'    || ||    `'         || ||   | \\  / |   ||S||            .===' `===.         .==='.`===.         .===' /==. |  \\/  |   ||S||         .=='   \\_|-_ `===. .==='   _|_   `===. .===' _-|/   `==  \\/  |   ||S||      .=='    _-'    `-_  `='    _-'   `-_    `='  _-'   `-_  /|  \\/  |   ||S||   .=='    _-'          '-__\\._-'         '-_./__-'         `' |. /|  |   ||S||.=='    _-'                                                     `' |  /==.||S=='    _-'                        N E O V I M                         \\/   `==S\\   _-'                                                                `-_   /S `''                                                                       ``'S                                                                              \18custom_header\1\0\4\vaction SessionManager load_session\tdesc%Select recent session           \rshortcut\afs\ticon\tÔë§ \1\0\4\vaction\24Telescope live_grep\tdesc%Live Grep with Telescope        \rshortcut\agf\ticon\tÔÄÇ \1\0\4\vaction\25Telescope find_files\tdesc%Find file with Telescope        \rshortcut\aff\ticon\tÔÄÇ \1\0\4\vaction\19NvimTreeToggle\tdesc\"Open Nvim Tree               \rshortcut\nSPC f\ticon\tÔÅª \18custom_center\14dashboard\frequire\2\0", "config", "dashboard-nvim")
time([[Config for dashboard-nvim]], false)
-- Config for: toggleterm.nvim
time([[Config for toggleterm.nvim]], true)
try_loadstring("\27LJ\2\nŒ\2\0\0\a\0\21\0\"6\0\0\0'\2\1\0B\0\2\0029\0\2\0B\0\1\0026\1\0\0'\3\3\0B\1\2\0029\1\4\0015\3\5\0005\4\6\0=\4\a\0035\4\f\0005\5\t\0009\6\b\0=\6\n\0059\6\b\0=\6\v\5=\5\r\4=\4\14\3B\1\2\0016\1\15\0'\3\16\0'\4\17\0'\5\18\0004\6\0\0B\1\5\0016\1\15\0'\3\19\0'\4\20\0'\5\18\0004\6\0\0B\1\5\1K\0\1\0\n<C-T>\6t\24<cmd>ToggleTerm<CR>\att\6n\bMap\15highlights\16FloatBorder\1\0\0\nguibg\nguifg\1\0\0\rcontrast\15float_opts\1\0\1\vborder\vsingle\1\0\2\14direction\nfloat\14autochdir\2\nsetup\15toggleterm\15get_colors\14azul.core\frequire\0", "config", "toggleterm.nvim")
time([[Config for toggleterm.nvim]], false)
-- Config for: gitsigns
time([[Config for gitsigns]], true)
try_loadstring("\27LJ\2\n6\0\0\3\0\3\0\0066\0\0\0'\2\1\0B\0\2\0029\0\2\0B\0\1\1K\0\1\0\nsetup\rgitsigns\frequire\0", "config", "gitsigns")
time([[Config for gitsigns]], false)
-- Config for: nvim-cmp
time([[Config for nvim-cmp]], true)
try_loadstring("\27LJ\2\n-\0\1\4\1\2\0\5-\1\0\0009\1\0\0019\3\1\0B\1\2\1K\0\1\0\0¿\tbody\15lsp_expand}\0\2\5\1\a\0\0229\2\0\1\n\2\0\0X\2\16Ä'\2\2\0009\3\0\1'\4\3\0&\2\4\2=\2\1\1'\2\4\0-\3\0\0009\4\0\0018\3\4\3\14\0\3\0X\4\1Ä'\3\5\0'\4\4\0&\2\4\2=\2\0\1X\2\2Ä'\2\6\0=\2\0\1L\1\2\0\2¿\t <> \a<>\6 \6)\n    (\tmenu\tkindö\1\0\1\3\2\4\0\21-\1\0\0009\1\0\1B\1\1\2\15\0\1\0X\2\4Ä-\1\0\0009\1\1\1B\1\1\1X\1\vÄ-\1\1\0009\1\2\1B\1\1\2\15\0\1\0X\2\4Ä-\1\1\0009\1\3\1B\1\1\1X\1\2Ä\18\1\0\0B\1\1\1K\0\1\0\1¿\0¿\19expand_or_jump\23expand_or_jumpable\21select_next_item\fvisible∑\a\1\0\r\0*\0G6\0\0\0'\2\1\0B\0\2\0026\1\0\0'\3\2\0B\1\2\0025\2\3\0009\3\4\0015\5\b\0005\6\6\0003\a\5\0=\a\a\6=\6\t\0055\6\v\0005\a\n\0=\a\f\6=\6\r\0055\6\15\0005\a\14\0=\a\16\0063\a\17\0=\a\18\6=\6\19\0059\6\20\0019\6\21\0069\6\22\0065\b\25\0009\t\20\0013\v\23\0005\f\24\0B\t\3\2=\t\26\b9\t\20\0019\t\27\t)\v¸ˇB\t\2\2=\t\28\b9\t\20\0019\t\27\t)\v\4\0B\t\2\2=\t\29\b9\t\20\0019\t\30\tB\t\1\2=\t\31\b9\t\20\0019\t \t5\v!\0B\t\2\2=\t\"\bB\6\2\2=\6\20\0059\6#\0019\6$\0064\b\6\0005\t%\0>\t\1\b5\t&\0>\t\2\b5\t'\0>\t\3\b5\t(\0>\t\4\b5\t)\0>\t\5\bB\6\2\2=\6$\5B\3\2\0012\0\0ÄK\0\1\0\1\0\2\19keyword_length\3\3\tname\vbuffer\1\0\1\tname\tpath\1\0\1\tname\15treesitter\1\0\1\tname\fluasnip\1\0\1\tname\rnvim_lsp\fsources\vconfig\t<CR>\1\0\1\vselect\1\fconfirm\n<C-e>\nabort\n<C-s>\n<C-w>\16scroll_docs\n<Tab>\1\0\0\1\3\0\0\6i\6s\0\vinsert\vpreset\fmapping\15formatting\vformat\0\vfields\1\0\0\1\4\0\0\tkind\tabbr\tmenu\vwindow\15completion\1\0\0\1\0\2\17side_padding\3\0\15col_offset\3˝ˇˇˇ\15\fsnippet\1\0\0\vexpand\1\0\0\0\nsetup\1\0\25\rVariable\bÔî™\rConstant\bÔ£æ\nField\bÔ∞†\vStruct\bÔ≠Ñ\16Constructor\bÔê£\nEvent\bÔÉß\rFunction\bÔûî\vFolder\bÔùä\vMethod\bÔö¶\14Reference\bÔúÜ\tText\bÔùæ\tFile\bÔúò\nColor\bÔ£ó\fSnippet\bÔëè\fKeyword\bÔ†ä\tEnum\bÔÖù\18TypeParameter\5\nValue\bÔ¢ü\rOperator\bÔöî\tUnit\bÔ•¨\rProperty\bÔ∞†\vModule\bÔíá\14Interface\bÔÉ®\15EnumMember\bÔÖù\nClass\bÔ¥Ø\bcmp\fluasnip\frequire\0", "config", "nvim-cmp")
time([[Config for nvim-cmp]], false)
-- Config for: lualine
time([[Config for lualine]], true)
try_loadstring("\27LJ\2\nH\0\0\4\0\5\0\t6\0\0\0009\0\1\0009\0\2\0006\2\0\0009\2\1\0029\2\3\2B\2\1\2'\3\4\0D\0\3\0\a:~\vgetcwd\16fnamemodify\afn\bvimÜ\14\1\0\v\0e\0Ï\0013\0\0\0005\1\2\0005\2\1\0=\2\3\0015\2\4\0004\3\3\0>\0\1\3=\3\5\2=\2\6\0015\2\a\0004\3\3\0>\0\1\3=\3\b\2=\2\t\0016\2\n\0'\4\v\0B\2\2\0029\2\f\2B\2\1\0026\3\n\0'\5\r\0B\3\2\0029\3\14\0035\5A\0005\6\16\0005\a\15\0=\a\17\0065\a \0005\b\23\0005\t\19\0009\n\18\2=\n\20\t9\n\21\2=\n\22\t=\t\24\b5\t\26\0009\n\25\2=\n\20\t9\n\27\2=\n\22\t=\t\28\b5\t\30\0009\n\29\2=\n\20\t9\n\29\2=\n\22\t=\t\31\b=\b!\a5\b$\0005\t#\0009\n\"\2=\n\20\t9\n\21\2=\n\22\t=\t\24\b5\t%\0009\n\25\2=\n\20\t9\n\27\2=\n\22\t=\t\28\b5\t&\0009\n\29\2=\n\20\t9\n\29\2=\n\22\t=\t\31\b=\b'\a5\b*\0005\t)\0009\n(\2=\n\20\t9\n\21\2=\n\22\t=\t\24\b5\t+\0009\n\25\2=\n\20\t9\n\27\2=\n\22\t=\t\28\b5\t,\0009\n\29\2=\n\20\t9\n\29\2=\n\22\t=\t\31\b=\b-\a5\b0\0005\t/\0009\n.\2=\n\20\t9\n\21\2=\n\22\t=\t\24\b5\t1\0009\n\25\2=\n\20\t9\n\27\2=\n\22\t=\t\28\b5\t2\0009\n\29\2=\n\20\t9\n\29\2=\n\22\t=\t\31\b=\b3\a5\b5\0005\t4\0009\n\27\2=\n\20\t9\n\21\2=\n\22\t=\t\24\b5\t6\0009\n\25\2=\n\20\t9\n\27\2=\n\22\t=\t\28\b5\t7\0009\n\29\2=\n\20\t9\n\29\2=\n\22\t=\t\31\b=\b8\a5\b:\0005\t9\0009\n\"\2=\n\20\t9\n\21\2=\n\22\t=\t\24\b5\t;\0009\n\25\2=\n\20\t9\n\27\2=\n\22\t=\t\28\b5\t<\0009\n\29\2=\n\20\t9\n\29\2=\n\22\t=\t\31\b=\b=\a=\a>\0065\a?\0=\a@\6=\6B\0055\6I\0004\a\3\0005\bC\0005\tD\0=\tE\b6\tF\0009\tG\t=\tH\b>\b\1\a=\a\5\0064\a\3\0005\bJ\0005\tK\0009\n\25\2=\n\20\t9\n\"\2=\n\22\t=\tL\b5\tM\0=\tN\b5\tO\0=\tP\b>\b\1\a5\bQ\0005\tR\0009\n\29\2=\n\20\t9\n\27\2=\n\22\t=\tL\b>\b\2\a=\a\b\0064\a\0\0=\aS\0064\a\0\0=\aT\0064\a\3\0005\bU\0005\tV\0009\n\29\2=\n\20\t=\tL\b5\tW\0=\tX\b5\tY\0=\t\6\b5\tZ\0=\tP\b5\t[\0=\tN\b>\b\1\a5\b\\\0005\t]\0009\n\25\2=\n\20\t9\n^\2=\n\22\t=\tL\b>\b\2\a=\a_\0064\a\0\0=\a`\6=\6\6\0055\6a\0004\a\0\0=\a\5\0065\ab\0=\a\b\0064\a\0\0=\aS\0064\a\0\0=\aT\0064\a\0\0=\a_\0064\a\0\0=\a`\6=\6\t\0054\6\0\0=\6c\0054\6\3\0>\1\1\6=\6d\5B\3\2\1K\0\1\0\15extensions\ftabline\1\2\0\0\rfilename\1\0\0\14lualine_z\14lualine_y\fcolor12\1\0\0\1\2\0\0\rfiletype\1\0\2\nright\5\tleft\5\1\0\2\nerror\t‚úó \twarn\bÔºÅ\1\3\0\0\nerror\twarn\fsources\1\3\0\0\rnvim_lsp\20nvim_diagnostic\1\0\0\1\2\2\0\16diagnostics\21update_in_insert\2\fcolored\2\14lualine_x\14lualine_c\1\0\0\1\2\0\0\vbranch\fsymbols\1\0\3\funnamed\funnamed\rreadonly\15(readonly)\rmodified\t [+]\14separator\1\0\2\nright\5\tleft\5\ncolor\1\0\0\1\2\0\0\rfilename\1\0\0\bfmt\nlower\vstring\14seperator\1\0\2\nright\5\tleft\5\1\2\0\0\tmode\foptions\1\0\0\23disabled_filetypes\1\2\0\0\vpacker\ntheme\rinactive\1\0\0\1\0\0\1\0\0\1\0\0\fcommand\1\0\0\1\0\0\1\0\0\1\0\0\freplace\1\0\0\1\0\0\1\0\0\1\0\0\vcolor1\vvisual\1\0\0\1\0\0\1\0\0\1\0\0\vcolor5\vinsert\1\0\0\1\0\0\1\0\0\1\0\0\vcolor4\vnormal\1\0\0\6c\1\0\0\rcontrast\6b\vcolor7\1\0\0\vcolor0\6a\1\0\0\afg\15background\abg\1\0\0\vcolor2\23section_separators\1\0\2\18icons_enabled\2\17globalstatus\2\1\0\2\nright\5\tleft\5\nsetup\flualine\15get_colors\14azul.core\frequire\22inactive_sections\14lualine_b\1\0\0\rsections\14lualine_a\1\0\0\14filetypes\1\0\0\1\2\0\0\rNvimTree\0\0", "config", "lualine")
time([[Config for lualine]], false)
-- Config for: nvim-lspconfig
time([[Config for nvim-lspconfig]], true)
try_loadstring("\27LJ\2\nV\0\0\6\0\6\0\f6\0\0\0009\0\1\0009\0\2\0006\2\0\0009\2\1\0029\2\3\2B\2\1\2'\3\4\0'\4\5\0'\5\5\0B\0\5\2L\0\2\0\5\t^.*/\vgetcwd\15substitute\afn\bvim˜\4\0\2\15\0$\0G6\2\0\0009\2\1\2'\4\2\0B\2\2\0016\2\0\0009\2\3\0029\2\4\2\18\4\1\0'\5\5\0'\6\6\0'\a\6\0B\2\5\0026\3\0\0009\3\1\3'\5\a\0\18\6\2\0'\a\b\0&\5\a\5B\3\2\1\a\2\t\0X\3\23Ä6\3\0\0009\3\n\3'\5\v\0\18\6\0\0005\a\25\0005\b\23\0005\t\f\0005\n\14\0005\v\r\0=\v\15\n=\n\16\t5\n\20\0006\v\17\0009\v\18\v'\r\19\0B\v\2\2=\v\21\n=\n\22\t=\t\24\b=\b\26\aB\3\4\2\18\0\3\0X\3\26Ä\a\2\27\0X\3\24Ä6\3\0\0009\3\n\3'\5\v\0\18\6\0\0005\a#\0005\b\"\0005\t\28\0005\n\30\0005\v\29\0=\v\15\n=\n\16\t5\n!\0006\v\0\0009\v\31\v9\v \v'\r\6\0+\14\2\0B\v\3\2=\v\21\n=\n\22\t=\t\24\b=\b\26\aB\3\4\2\18\0\3\0K\0\1\0\1\0\0\1\0\0\1\0\0\26nvim_get_runtime_file\bapi\1\0\0\1\2\0\0\bvim\1\0\1\fruntime\vLuaJIT\tnvim\rsettings\1\0\0\bLua\1\0\0\14workspace\flibrary\1\0\0\17AWM_LIB_PATH\vgetenv\aos\16diagnostics\fglobals\1\0\0\1\n\0\0\troot\fawesome\btag\vscreen\vclient\vmodkey\valtkey\nmouse\17mousegrabber\1\0\1\fruntime\b5.2\nforce\20tbl_deep_extend\fawesome\6'\16echo 'pwd: \5\t^.*/\15substitute\afn\"echo 'reloading lsp settings'\bcmd\bvimÄ\1\0\1\a\1\b\0\16-\1\0\0009\1\0\1'\3\1\0'\4\2\0'\5\3\0'\6\4\0B\1\5\2\18\3\0\0B\1\2\2\15\0\1\0X\2\1ÄL\1\2\0006\2\5\0009\2\6\0029\2\a\2D\2\1\0\2¿\vgetcwd\afn\bvim\6.\t.git\fpom.xml\17build.gradle\17root_pattern˙\b\1\0\f\0D\1w3\0\0\0006\1\1\0'\3\2\0B\1\2\0026\2\1\0'\4\3\0B\2\2\0026\3\4\0009\3\5\0039\3\6\0039\3\a\3B\3\1\0026\4\4\0009\4\t\4'\6\n\0009\a\b\0025\b\r\0006\t\1\0'\v\v\0B\t\2\0029\t\f\t\18\v\3\0B\t\2\2=\t\14\bB\4\4\2=\4\b\0029\4\15\0019\4\16\0045\6\18\0003\a\17\0=\a\19\0065\a\31\0005\b\21\0005\t\20\0=\t\22\b5\t\24\0005\n\23\0=\n\25\t5\n\26\0=\n\27\t=\t\28\b5\t\29\0=\t\30\b=\b \a=\a!\6B\4\2\0019\4\"\0019\4\16\0045\6'\0005\a#\0006\b$\0006\n\4\0009\n%\n9\n&\nB\n\1\0A\b\0\0?\b\0\0=\a(\6B\4\2\0019\4)\0019\4\16\0045\0062\0005\a1\0005\b/\0005\t-\0005\n+\0005\v*\0=\v,\n=\n.\t=\t0\b=\b)\a=\a!\6B\4\2\0019\0043\0019\4\16\0044\6\0\0B\4\2\0019\0044\0019\4\16\0044\6\0\0B\4\2\0019\0045\0019\4\16\0044\6\0\0B\4\2\0019\0046\0019\4\16\0045\6=\0005\a7\0006\b8\0009\b9\b'\n:\0B\b\2\2'\t;\0&\b\t\b>\b\3\a6\b8\0009\b9\b'\n:\0B\b\2\2'\t<\0&\b\t\b>\b\5\a=\a(\6B\4\2\0019\4>\0019\4\16\0045\6@\0005\a?\0=\a(\0063\aA\0=\aB\6B\4\2\0019\4C\0019\4\16\0044\6\0\0B\4\2\0012\0\0ÄK\0\1\0\tltex\rroot_dir\0\1\0\0\1\2\0\0\25java-language-server\25java_language_server\1\0\0\28/.cache/jdtls/workspace\25/.cache/jdtls/config\tHOME\vgetenv\aos\1\5\0\0\24jdt-language-server\19-configuration\0\n-data\njdtls\trnix\vtexlab\bhls\1\0\0\1\0\0\fplugins\1\0\0\16pycodestyle\1\0\0\vignore\1\0\1\18maxLineLength\3†\1\1\2\0\0\tW391\npylsp\bcmd\1\0\0\vgetpid\afn\rtostring\1\4\0\0\14OmniSharp\t-lsp\14--hostPID\14omnisharp\rsettings\bLua\1\0\0\14telemetry\1\0\1\venable\1\15completion\19keywordSnippet\1\0\1\tBoth\2\16callSnippet\1\0\0\1\0\1\tBoth\2\14workspace\1\0\0\1\0\1\20checkThirdParty\1\18on_new_config\1\0\0\0\nsetup\16sumneko_lua\17capabilities\1\0\0\25default_capabilities\17cmp_nvim_lsp\nforce\15tbl_extend\19default_config\29make_client_capabilities\rprotocol\blsp\bvim\19lspconfig.util\14lspconfig\frequire\0\tÄÄ¿ô\4\0", "config", "nvim-lspconfig")
time([[Config for nvim-lspconfig]], false)

_G._packer.inside_compile = false
if _G._packer.needs_bufread == true then
  vim.cmd("doautocmd BufRead")
end
_G._packer.needs_bufread = false

if should_profile then save_profiles() end

end)

if not no_errors then
  error_msg = error_msg:gsub('"', '\\"')
  vim.api.nvim_command('echohl ErrorMsg | echom "Error in packer_compiled: '..error_msg..'" | echom "Please check your config for correctness" | echohl None')
end
