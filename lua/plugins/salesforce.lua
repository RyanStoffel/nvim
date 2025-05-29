return {
  {
    "akinsho/toggleterm.nvim",
    version = "*",
    config = function()
      require("toggleterm").setup({
        size = 20,
        open_mapping = [[<c-\>]],
        hide_numbers = true,
        shade_terminals = true,
        shading_factor = 2,
        start_in_insert = true,
        insert_mappings = true,
        persist_size = true,
        direction = "horizontal",
        close_on_exit = true,
        shell = vim.o.shell,
        float_opts = {
          border = "curved",
          winblend = 0,
          highlights = {
            border = "Normal",
            background = "Normal",
          },
        },
      })

      local Terminal = require("toggleterm.terminal").Terminal
      local sfdx_deploy = Terminal:new({
        cmd = "sf project deploy start",
        dir = "git_dir",
        direction = "horizontal",
        close_on_exit = false,
      })
      local sfdx_retrieve = Terminal:new({
        cmd = "sf project retrieve start",
        dir = "git_dir",
        direction = "horizontal",
        close_on_exit = false,
      })

      local sfdx_test = Terminal:new({
        cmd = "sf apex run test",
        dir = "git_dir",
        direction = "horizontal",
        close_on_exit = false,
      })

      local sfdx_org_open = Terminal:new({
        cmd = "sf org open",
        dir = "git_dir",
        direction = "horizontal",
        close_on_exit = false,
      })

      vim.keymap.set("n", "<leader>sd", function() sfdx_deploy:toggle() end, { desc = "SFDX Deploy" })
      vim.keymap.set("n", "<leader>sr", function() sfdx_retrieve:toggle() end, { desc = "SFDX Retrieve" })
      vim.keymap.set("n", "<leader>st", function() sfdx_test:toggle() end, { desc = "SFDX Run Tests" })
      vim.keymap.set("n", "<leader>so", function() sfdx_org_open:toggle() end, { desc = "SFDX Open Org" })
      vim.keymap.set("n", "<leader>tt", "<cmd>ToggleTerm<CR>", { desc = "Toggle Terminal" })
    end,
  },

  {
    "stevearc/oil.nvim",
    config = function()
      require("oil").setup({
        columns = {
          "icon",
          "permissions",
          "size",
          "mtime",
        },
        keymaps = {
          ["g?"] = "actions.show_help",
          ["<CR>"] = "actions.select",
          ["<C-s>"] = "actions.select_vsplit",
          ["<C-h>"] = "actions.select_split",
          ["<C-t>"] = "actions.select_tab",
          ["<C-p>"] = "actions.preview",
          ["<C-c>"] = "actions.close",
          ["<C-l>"] = "actions.refresh",
          ["-"] = "actions.parent",
          ["_"] = "actions.open_cwd",
          ["`"] = "actions.cd",
          ["~"] = "actions.tcd",
          ["gs"] = "actions.change_sort",
          ["gx"] = "actions.open_external",
          ["g."] = "actions.toggle_hidden",
        },
        use_default_keymaps = true,
        view_options = {
          show_hidden = false,
          is_hidden_file = function(name, bufnr)
            return vim.startswith(name, ".")
          end,
          is_always_hidden = function(name, bufnr)
            return false
          end,
        },
      })
      vim.keymap.set("n", "<leader>eo", "<CMD>Oil<CR>", { desc = "Open Oil file explorer" })
    end,
  },

  {
    "kdheepak/lazygit.nvim",
    dependencies = {
      "nvim-lua/plenary.nvim",
    },
    config = function()
      vim.keymap.set("n", "<leader>gg", "<cmd>LazyGit<CR>", { desc = "Open LazyGit" })
    end,
  },

  {
    "mfussenegger/nvim-dap",
    config = function()
      local dap = require("dap")
      dap.adapters.apex = {
        type = "executable",
        command = "sf",
        args = { "apex", "debug", "start" },
      }
      dap.configurations.apex = {
        {
          type = "apex",
          request = "launch",
          name = "Launch Apex Debug",
          program = "${workspaceFolder}",
        },
      }
      vim.keymap.set("n", "<leader>db", dap.toggle_breakpoint, { desc = "Toggle Breakpoint" })
      vim.keymap.set("n", "<leader>dc", dap.continue, { desc = "Debug Continue" })
      vim.keymap.set("n", "<leader>ds", dap.step_over, { desc = "Debug Step Over" })
      vim.keymap.set("n", "<leader>di", dap.step_into, { desc = "Debug Step Into" })
      vim.keymap.set("n", "<leader>do", dap.step_out, { desc = "Debug Step Out" })
    end,
  },
}
