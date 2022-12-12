local nnoremap = require("elavigne.keymap").nnoremap

local ui = require("harpoon.ui")
local mark = require("harpoon.mark")

nnoremap("<leader>a", function() mark.add_file() end)
nnoremap("<C-e>", function() ui.toggle_quick_menu() end)
nnoremap("<A-1>", function() ui.nav_file(1) end)
nnoremap("<A-2>", function() ui.nav_file(2) end)
nnoremap("<A-3>", function() ui.nav_file(3) end)
nnoremap("<A-4>", function() ui.nav_file(4) end)

