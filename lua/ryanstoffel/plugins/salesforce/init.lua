-- lua/ryanstoffel/plugins/salesforce/init.lua
-- This file initializes all Salesforce-related configurations

return {
  -- Salesforce file type detection and basic settings
  {
    "nvim-treesitter/nvim-treesitter",
    opts = function(_, opts)
      -- Ensure Salesforce parsers are included
      vim.list_extend(opts.ensure_installed or {}, {
        "apex",
        "soql", 
        "sosl",
        "xml"
      })
    end,
  },

  -- Auto-commands for Salesforce development
  {
    "nvim-lua/plenary.nvim",
    config = function()
      -- Set up Salesforce file types
      vim.filetype.add({
        extension = {
          cls = "apex",
          trigger = "apex",
          page = "html",
          component = "html",
          soql = "soql",
          sosl = "sosl",
        },
        pattern = {
          [".*%.apex"] = "apex",
          [".*%.cls"] = "apex", 
          [".*%.trigger"] = "apex",
          [".*%.soql"] = "soql",
          [".*%.sosl"] = "sosl",
        },
      })

      -- Salesforce project detection
      local function is_salesforce_project()
        return vim.fn.filereadable("sfdx-project.json") == 1 or
               vim.fn.isdirectory("force-app") == 1 or
               vim.fn.isdirectory(".sfdx") == 1
      end

      -- Auto-commands for Salesforce projects
      vim.api.nvim_create_autocmd("VimEnter", {
        callback = function()
          if is_salesforce_project() then
            vim.notify("Salesforce project detected! Use <leader>s for Salesforce commands", vim.log.levels.INFO)
            
            -- Set up project-specific settings
            vim.opt_local.tabstop = 4
            vim.opt_local.shiftwidth = 4
            vim.opt_local.expandtab = true
            
            -- Add Salesforce-specific paths to search
            vim.opt.path:append("force-app/main/default/**")
          end
        end,
      })

      -- Apex-specific settings
      vim.api.nvim_create_autocmd("FileType", {
        pattern = "apex",
        callback = function()
          -- Apex-specific options
          vim.opt_local.commentstring = "// %s"
          vim.opt_local.tabstop = 4
          vim.opt_local.shiftwidth = 4
          vim.opt_local.expandtab = true
          
          -- Enable spell check for comments
          vim.opt_local.spell = true
          vim.opt_local.spelllang = "en_us"
          
          -- Set up Apex-specific abbreviations
          vim.cmd([[
            iabbrev <buffer> sout System.out.println
            iabbrev <buffer> sysd System.debug
            iabbrev <buffer> sysassert System.assert
            iabbrev <buffer> testmethod @IsTest<CR>static void testMethod() {<CR><CR>}
          ]])
        end,
      })

      -- SOQL-specific settings
      vim.api.nvim_create_autocmd("FileType", {
        pattern = { "soql", "sosl" },
        callback = function()
          vim.opt_local.commentstring = "-- %s"
          vim.opt_local.tabstop = 2
          vim.opt_local.shiftwidth = 2
          vim.opt_local.expandtab = true
        end,
      })

      -- Lightning Web Component settings
      vim.api.nvim_create_autocmd("BufRead", {
        pattern = { "**/lwc/**/*.js", "**/lwc/**/*.html", "**/lwc/**/*.css" },
        callback = function()
          -- LWC-specific settings
          vim.opt_local.tabstop = 2
          vim.opt_local.shiftwidth = 2
          vim.opt_local.expandtab = true
          
          -- Enable Emmet for LWC HTML files
          if vim.bo.filetype == "html" then
            vim.b.emmet_install_global = 0
            vim.b.emmet_install_only_for_filetype = 1
          end
        end,
      })
    end,
  },

  -- Enhanced commenting for Salesforce files
  {
    "numToStr/Comment.nvim",
    opts = function(_, opts)
      local ft = require("Comment.ft")
      ft.apex = "//%s"
      ft.soql = "--%s"
      ft.sosl = "--%s"
      return opts
    end,
  },

  -- Telescope configuration for Salesforce
  {
    "nvim-telescope/telescope.nvim",
    dependencies = {
      {
        "nvim-telescope/telescope-fzf-native.nvim",
        build = "make",
      },
    },
    opts = function(_, opts)
      local actions = require("telescope.actions")
      
      opts.pickers = opts.pickers or {}
      
      -- Custom picker for Salesforce files
      opts.pickers.salesforce_files = {
        find_command = { "find", "force-app", "-type", "f", "-name", "*.cls", "-o", "-name", "*.trigger", "-o", "-name", "*.page", "-o", "-name", "*.component" },
        prompt_title = "Salesforce Files",
      }
      
      return opts
    end,
  },
}
