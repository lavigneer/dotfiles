# Key mappings for nixvim
[
  # Basic keymaps
  {
    mode = ["n" "v"];
    key = "<Space>";
    action = "<Nop>";
    options.silent = true;
  }
  {
    mode = "i";
    key = "<S-Up>";
    action = "<Nop>";
    options.silent = true;
  }
  {
    mode = "i";
    key = "<S-Down>";
    action = "<Nop>";
    options.silent = true;
  }

  # Completion keymaps
  {
    mode = "i";
    key = "<C-]>";
    action = "<C-X><C-]>";
  }
  {
    mode = "i";
    key = "<C-F>";
    action = "<C-X><C-F>";
  }
  {
    mode = "i";
    key = "<C-D>";
    action = "<C-X><C-D>";
  }
  {
    mode = "i";
    key = "<C-L>";
    action = "<C-X><C-L>";
  }

  # Word wrap navigation
  {
    mode = "n";
    key = "k";
    action = "v:count == 0 ? 'gk' : 'k'";
    options = {
      expr = true;
      silent = true;
    };
  }
  {
    mode = "n";
    key = "j";
    action = "v:count == 0 ? 'gj' : 'j'";
    options = {
      expr = true;
      silent = true;
    };
  }

  # Centering movements
  {
    mode = "n";
    key = "<C-d>";
    action = "<C-d>zz";
  }
  {
    mode = "n";
    key = "<C-u>";
    action = "<C-u>zz";
  }
  {
    mode = "n";
    key = "n";
    action = "nzzzv";
  }
  {
    mode = "n";
    key = "N";
    action = "Nzzzv";
  }

  # Paste without copying
  {
    mode = "x";
    key = "<leader>p";
    action = "\"_dP";
  }

  # Delete to void register
  {
    mode = "n";
    key = "<leader>d";
    action = "\"_d";
  }
  {
    mode = "v";
    key = "<leader>d";
    action = "\"_d";
  }

  # Better up/down
  {
    mode = ["n" "x"];
    key = "j";
    action = "v:count == 0 ? 'gj' : 'j'";
    options = {
      expr = true;
      silent = true;
    };
  }
  {
    mode = ["n" "x"];
    key = "<Down>";
    action = "v:count == 0 ? 'gj' : 'j'";
    options = {
      expr = true;
      silent = true;
    };
  }
  {
    mode = ["n" "x"];
    key = "k";
    action = "v:count == 0 ? 'gk' : 'k'";
    options = {
      expr = true;
      silent = true;
    };
  }
  {
    mode = ["n" "x"];
    key = "<Up>";
    action = "v:count == 0 ? 'gk' : 'k'";
    options = {
      expr = true;
      silent = true;
    };
  }

  # Clear search highlight
  {
    mode = "n";
    key = "<Esc>";
    action = "<cmd>nohlsearch<CR>";
  }

  # Diagnostic keymaps
  {
    mode = "n";
    key = "<leader>q";
    action.__raw = "vim.diagnostic.setloclist";
    options.desc = "Open diagnostic [Q]uickfix list";
  }

  # Terminal mode
  {
    mode = "t";
    key = "<Esc><Esc>";
    action = "<C-\\><C-n>";
    options.desc = "Exit terminal mode";
  }

  # Mini.files
  {
    mode = "n";
    key = "<leader>e";
    action.__raw = "function() require('mini.files').open(vim.api.nvim_buf_get_name(0), true) end";
    options.desc = "Open mini.files (directory of current file)";
  }

  # Mini.pick keymaps
  {
    mode = "n";
    key = "<leader>?";
    action = "<cmd>Pick oldfiles<CR>";
    options.desc = "[?] Find recently opened files";
  }
  {
    mode = "n";
    key = "<leader><space>";
    action = "<cmd>Pick buffers<CR>";
    options.desc = "[ ] Find existing buffers";
  }
  {
    mode = "n";
    key = "<leader>/";
    action = "<cmd>Pick buf_lines scope='current'<CR>";
    options.desc = "[/] Fuzzily search in current buffer";
  }
  {
    mode = "n";
    key = "<leader>gf";
    action = "<cmd>Pick git_files<CR>";
    options.desc = "Search [G]it [F]iles";
  }
  {
    mode = "n";
    key = "<leader>gc";
    action = "<cmd>Pick git_commits<CR>";
    options.desc = "Search [G]it [C]ommits";
  }
  {
    mode = "n";
    key = "<leader>gm";
    action = "<cmd>Pick git_files scope='modified'<CR>";
    options.desc = "Search [G]it [M]odified";
  }
  {
    mode = "n";
    key = "<leader>sf";
    action = "<cmd>Pick files<CR>";
    options.desc = "[S]earch [F]iles";
  }
  {
    mode = "n";
    key = "<leader>sh";
    action = "<cmd>Pick help<CR>";
    options.desc = "[S]earch [H]elp";
  }
  {
    mode = "n";
    key = "<leader>sw";
    action = "<cmd>Pick grep pattern='<cword>'<CR>";
    options.desc = "[S]earch current [W]ord";
  }
  {
    mode = "n";
    key = "<leader>sg";
    action = "<cmd>Pick grep_live<CR>";
    options.desc = "[S]earch by [G]rep";
  }
  {
    mode = "n";
    key = "<leader>sd";
    action = "<cmd>Pick diagnostic scope='all'<CR>";
    options.desc = "[S]earch [D]iagnostics";
  }
  {
    mode = "n";
    key = "<leader>sq";
    action = "<cmd>Pick list scope='quickfix'<CR>";
    options.desc = "[S]earch [Q]uickfix";
  }
  {
    mode = "n";
    key = "<leader>sr";
    action = "<cmd>Pick resume<CR>";
    options.desc = "[S]earch [R]esume";
  }
  {
    mode = "n";
    key = "<leader>se";
    action = "<cmd>Pick explorer<CR>";
    options.desc = "[S]earch [E]xplorer";
  }
  {
    mode = "n";
    key = "<leader>sv";
    action = "<cmd>Pick visit_paths<CR>";
    options.desc = "[S]earch [V]isit Paths";
  }

  # Buffer management
  {
    mode = "n";
    key = "<leader>bd";
    action.__raw = "function() require('mini.bufremove').delete() end";
    options.desc = "[B]uffer [D]elete";
  }
  {
    mode = "n";
    key = "<leader>bD";
    action.__raw = "function() require('mini.bufremove').delete(0, true) end";
    options.desc = "Force [B]uffer [D]elete";
  }

  # Conform formatting
  {
    mode = "n";
    key = "<leader>cf";
    action.__raw = "function() require('conform').format({ async = true, lsp_fallback = true }) end";
    options.desc = "[C]ode [F]ormat";
  }

  # Spectre find/replace
  {
    mode = "n";
    key = "<leader>rs";
    action.__raw = "function() require('spectre').open() end";
    options.desc = "Find/Replace in Spectre";
  }

  # Sidekick keymaps
  {
    mode = "n";
    key = "<Tab>";
    action.__raw = ''
      function()
        if not require("sidekick").nes_jump_or_apply() then
          return "<Tab>"
        end
      end
    '';
    options = {
      expr = true;
      desc = "Goto/Apply Next Edit Suggestion";
    };
  }
  {
    mode = "n";
    key = "<leader>aa";
    action.__raw = "function() require('sidekick.cli').toggle() end";
    options.desc = "Sidekick Toggle CLI";
  }
  {
    mode = "n";
    key = "<leader>as";
    action.__raw = "function() require('sidekick.cli').select() end";
    options.desc = "Select CLI";
  }
  {
    mode = ["x" "n"];
    key = "<leader>at";
    action.__raw = "function() require('sidekick.cli').send({ msg = '{this}' }) end";
    options.desc = "Send This";
  }
  {
    mode = "x";
    key = "<leader>av";
    action.__raw = "function() require('sidekick.cli').send({ msg = '{selection}' }) end";
    options.desc = "Send Visual Selection";
  }
  {
    mode = ["n" "x"];
    key = "<leader>ap";
    action.__raw = "function() require('sidekick.cli').prompt() end";
    options.desc = "Sidekick Select Prompt";
  }
  {
    mode = ["n" "x" "i" "t"];
    key = "<C-.>";
    action.__raw = "function() require('sidekick.cli').focus() end";
    options.desc = "Sidekick Switch Focus";
  }
  {
    mode = "n";
    key = "<leader>ac";
    action.__raw = "function() require('sidekick.cli').toggle({ name = 'claude', focus = true }) end";
    options.desc = "Sidekick Toggle Claude";
  }

  # Neotest keymaps
  {
    mode = "n";
    key = "<leader>tt";
    action.__raw = "function() require('neotest').run.run(vim.fn.expand('%')) end";
    options.desc = "Run File (Neotest)";
  }
  {
    mode = "n";
    key = "<leader>tT";
    action.__raw = "function() require('neotest').run.run(vim.uv.cwd()) end";
    options.desc = "Run All Test Files (Neotest)";
  }
  {
    mode = "n";
    key = "<leader>tr";
    action.__raw = "function() require('neotest').run.run() end";
    options.desc = "Run Nearest (Neotest)";
  }
  {
    mode = "n";
    key = "<leader>tl";
    action.__raw = "function() require('neotest').run.run_last() end";
    options.desc = "Run Last (Neotest)";
  }
  {
    mode = "n";
    key = "<leader>ts";
    action.__raw = "function() require('neotest').summary.toggle() end";
    options.desc = "Toggle Summary (Neotest)";
  }
  {
    mode = "n";
    key = "<leader>to";
    action.__raw = "function() require('neotest').output.open({ enter = true, auto_close = true }) end";
    options.desc = "Show Output (Neotest)";
  }
  {
    mode = "n";
    key = "<leader>tO";
    action.__raw = "function() require('neotest').output_panel.toggle() end";
    options.desc = "Toggle Output Panel (Neotest)";
  }
  {
    mode = "n";
    key = "<leader>tS";
    action.__raw = "function() require('neotest').run.stop() end";
    options.desc = "Stop (Neotest)";
  }
  {
    mode = "n";
    key = "<leader>td";
    action.__raw = "function() require('neotest').run.run({strategy = 'dap'}) end";
    options.desc = "Debug Nearest (Neotest)";
  }
  {
    mode = "n";
    key = "<leader>tw";
    action.__raw = "function() require('neotest').watch.toggle(vim.fn.expand('%')) end";
    options.desc = "Toggle Watch (Neotest)";
  }
]
