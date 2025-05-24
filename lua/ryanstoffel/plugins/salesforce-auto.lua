-- lua/ryanstoffel/plugins/salesforce-auto.lua
return {
  "nvim-lua/plenary.nvim",
  config = function()
    
    -- Salesforce file templates
    local templates = {
      -- Permission Set template
      permission_set = {
        extension = "permissionset-meta.xml",
        content = function(name)
          return {
            '<?xml version="1.0" encoding="UTF-8"?>',
            '<PermissionSet xmlns="http://soap.sforce.com/2006/04/metadata">',
            '    <description>' .. (name or 'Custom Permission Set') .. '</description>',
            '    <label>' .. (name or 'Custom Permission Set') .. '</label>',
            '    <license>Salesforce</license>',
            '    <hasActivationRequired>false</hasActivationRequired>',
            '    ',
            '    <!-- Object Permissions -->',
            '    <objectPermissions>',
            '        <allowCreate>true</allowCreate>',
            '        <allowDelete>false</allowDelete>',
            '        <allowEdit>true</allowEdit>',
            '        <allowRead>true</allowRead>',
            '        <modifyAllRecords>false</modifyAllRecords>',
            '        <object>Account</object>',
            '        <viewAllRecords>false</viewAllRecords>',
            '    </objectPermissions>',
            '</PermissionSet>'
          }
        end
      },

      -- Custom Object template
      custom_object = {
        extension = "object-meta.xml",
        content = function(name)
          return {
            '<?xml version="1.0" encoding="UTF-8"?>',
            '<CustomObject xmlns="http://soap.sforce.com/2006/04/metadata">',
            '    <deploymentStatus>Deployed</deploymentStatus>',
            '    <enableActivities>true</enableActivities>',
            '    <enableReports>true</enableReports>',
            '    <enableSearch>true</enableSearch>',
            '    <label>' .. (name or 'Custom Object') .. '</label>',
            '    <nameField>',
            '        <label>' .. (name or 'Custom Object') .. ' Name</label>',
            '        <type>Text</type>',
            '    </nameField>',
            '    <pluralLabel>' .. (name and (name .. "s") or 'Custom Objects') .. '</pluralLabel>',
            '    <sharingModel>ReadWrite</sharingModel>',
            '</CustomObject>'
          }
        end
      },

      -- Flow template
      flow = {
        extension = "flow-meta.xml",
        content = function(name)
          return {
            '<?xml version="1.0" encoding="UTF-8"?>',
            '<Flow xmlns="http://soap.sforce.com/2006/04/metadata">',
            '    <apiVersion>60.0</apiVersion>',
            '    <description>' .. (name or 'Custom Flow') .. ' Description</description>',
            '    <label>' .. (name or 'Custom Flow') .. '</label>',
            '    <processType>Flow</processType>',
            '    <status>Draft</status>',
            '</Flow>'
          }
        end
      }
    }

    -- Function to create template files
    local function create_template(template_type, name)
      local template = templates[template_type]
      if not template then
        vim.notify("Template type '" .. template_type .. "' not found", vim.log.levels.ERROR)
        return
      end

      local filename = name and (name .. "." .. template.extension) or ("NewFile." .. template.extension)
      local content = template.content(name)
      
      -- Write file
      vim.fn.writefile(content, filename)
      vim.notify("Created " .. template_type .. ": " .. filename, vim.log.levels.INFO)
      
      -- Open the file
      vim.cmd("edit " .. filename)
    end

    -- Salesforce auto-formatting and helpers
    local salesforce_group = vim.api.nvim_create_augroup("SalesforceAuto", { clear = true })

    -- Auto-insert copyright header for new Apex files
    vim.api.nvim_create_autocmd("BufNewFile", {
      group = salesforce_group,
      pattern = "*.cls,*.trigger",
      callback = function()
        local file_type = vim.fn.expand("%:e") == "trigger" and "Trigger" or "Class"
        local class_name = vim.fn.expand("%:t:r")
        
        local lines = {
          "/**",
          " * @description " .. file_type .. " for " .. class_name,
          " * @author " .. (vim.env.USER or "Your Name"),
          " * @date " .. os.date("%Y-%m-%d"),
          " * @version 1.0",
          " */",
          ""
        }
        vim.api.nvim_buf_set_lines(0, 0, 0, false, lines)
      end,
    })

    -- SOQL auto-completion
    vim.api.nvim_create_autocmd("FileType", {
      group = salesforce_group,
      pattern = "soql",
      callback = function()
        vim.opt_local.commentstring = "-- %s"
        vim.opt_local.tabstop = 4
        vim.opt_local.shiftwidth = 4
      end,
    })

    -- Smart Apex method generation
    local function generate_apex_method()
      local method_type = vim.fn.input("Method type (public/private/global): ", "public")
      local return_type = vim.fn.input("Return type: ", "void")
      local method_name = vim.fn.input("Method name: ")
      local parameters = vim.fn.input("Parameters: ")
      
      if method_name == "" then
        vim.notify("Method name is required", vim.log.levels.WARN)
        return
      end
      
      local lines = {
        "",
        "/**",
        " * @description " .. method_name,
        " * @param " .. (parameters ~= "" and parameters or "No parameters"),
        " * @return " .. return_type,
        " */",
        method_type .. " " .. return_type .. " " .. method_name .. "(" .. parameters .. ") {",
        "    " .. (return_type ~= "void" and "return null;" or "// Implementation"),
        "}"
      }
      
      vim.api.nvim_put(lines, 'l', true, true)
    end

    -- Test class generator
    local function generate_test_class()
      local class_name = vim.fn.input("Class to test: ")
      if class_name == "" then
        vim.notify("Class name is required", vim.log.levels.WARN)
        return
      end
      
      local test_class_name = class_name .. "Test"
      local filename = test_class_name .. ".cls"
      
      local content = {
        "/**",
        " * @description Test class for " .. class_name,
        " * @author " .. (vim.env.USER or "Your Name"),
        " * @date " .. os.date("%Y-%m-%d"),
        " */",
        "@IsTest",
        "public class " .. test_class_name .. " {",
        "",
        "    @TestSetup",
        "    static void makeData() {",
        "        // Create test data here",
        "    }",
        "",
        "    @IsTest",
        "    static void testMethod() {",
        "        // Given",
        "        ",
        "        // When",
        "        Test.startTest();",
        "        // Call method being tested",
        "        Test.stopTest();",
        "        ",
        "        // Then",
        "        // Add assertions",
        "    }",
        "}"
      }
      
      vim.fn.writefile(content, filename)
      vim.notify("Created test class: " .. filename, vim.log.levels.INFO)
      vim.cmd("edit " .. filename)
    end

    -- Governor limit checker
    local function check_governor_limits()
      local lines = vim.api.nvim_buf_get_lines(0, 0, -1, false)
      local content = table.concat(lines, "\n"):lower()
      
      local issues = {}
      
      -- Check for SOQL in loops
      if content:match("for%s*%(.*%)%s*{.-select") then
        table.insert(issues, "⚠️  Potential SOQL in loop detected")
      end
      
      -- Check for DML in loops
      if content:match("for%s*%(.*%)%s*{.-insert%s") or content:match("for%s*%(.*%)%s*{.-update%s") then
        table.insert(issues, "⚠️  Potential DML in loop detected")
      end
      
      if #issues > 0 then
        vim.notify("Governor Limit Issues:\n" .. table.concat(issues, "\n"), vim.log.levels.WARN)
      else
        vim.notify("✅ No obvious governor limit issues found", vim.log.levels.INFO)
      end
    end

    -- Enhanced file type detection
    vim.filetype.add({
      extension = {
        cls = "apex",
        trigger = "apex",
        soql = "soql",
        sosl = "sosl",
      },
      pattern = {
        [".*%.cls"] = "apex",
        [".*%.trigger"] = "apex",
        [".*%.soql"] = "soql",
        [".*%.sosl"] = "sosl",
      },
    })

    -- Keymaps for functionality
    vim.keymap.set("n", "<leader>scm", generate_apex_method, { desc = "Generate Apex Method" })
    vim.keymap.set("n", "<leader>sct", generate_test_class, { desc = "Generate Test Class" })
    vim.keymap.set("n", "<leader>scg", check_governor_limits, { desc = "Check Governor Limits" })
    
    -- Template creation commands
    vim.keymap.set("n", "<leader>scp", function()
      local name = vim.fn.input("Permission Set name: ")
      if name and name ~= "" then
        create_template("permission_set", name)
      end
    end, { desc = "Create Permission Set" })
    
    vim.keymap.set("n", "<leader>sco", function()
      local name = vim.fn.input("Custom Object name: ")
      if name and name ~= "" then
        create_template("custom_object", name)
      end
    end, { desc = "Create Custom Object" })
    
    vim.keymap.set("n", "<leader>scf", function()
      local name = vim.fn.input("Flow name: ")
      if name and name ~= "" then
        create_template("flow", name)
      end
    end, { desc = "Create Flow Template" })

    vim.notify("🚀 Salesforce auto-commands loaded!", vim.log.levels.INFO)
  end,
}
