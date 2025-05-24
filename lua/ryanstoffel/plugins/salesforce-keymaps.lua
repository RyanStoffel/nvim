-- lua/ryanstoffel/plugins/salesforce-keymaps.lua
return {
  "folke/which-key.nvim",
  event = "VeryLazy",
  dependencies = {
    "nvim-telescope/telescope.nvim",
  },
  config = function()
    local wk = require("which-key")
    
    -- Helper function to check if we're in a Salesforce project
    local function is_salesforce_project()
      return vim.fn.filereadable("sfdx-project.json") == 1 or
             vim.fn.isdirectory("force-app") == 1 or
             vim.fn.isdirectory(".sfdx") == 1
    end

    -- Helper function to get CLI command
    local function get_cli_cmd()
      return vim.fn.executable("sf") == 1 and "sf" or "sfdx"
    end

    -- Helper function to run Salesforce commands with error handling
    local function run_sf_command(cmd, description)
      if not is_salesforce_project() then
        vim.notify("Not in a Salesforce project directory", vim.log.levels.WARN)
        return
      end
      
      vim.notify("Running: " .. description, vim.log.levels.INFO)
      vim.cmd(cmd)
    end

    -- Salesforce-specific keymaps
    wk.add({
      { "<leader>s", group = "Salesforce" },
      
      -- Files/Deploy group
      { "<leader>sf", group = "Files/Deploy" },
      { "<leader>sfd", function()
        local file_path = vim.fn.expand("%:p")
        if file_path == "" then
          vim.notify("No file is currently open", vim.log.levels.WARN)
          return
        end
        
        local cli_cmd = get_cli_cmd()
        local cmd = cli_cmd == "sf" and 
          ("!sf project deploy start --source-dir \"" .. file_path .. "\"") or
          ("!sfdx force:source:deploy -p \"" .. file_path .. "\"")
        run_sf_command(cmd, "Deploy current file")
      end, desc = "Deploy current file" },
      
      { "<leader>sfD", function()
        local cli_cmd = get_cli_cmd()
        local cmd = cli_cmd == "sf" and 
          "!sf project deploy start" or
          "!sfdx force:source:deploy"
        run_sf_command(cmd, "Deploy all source")
      end, desc = "Deploy all source" },
      
      { "<leader>sfr", function()
        local file_path = vim.fn.expand("%:p")
        if file_path == "" then
          vim.notify("No file is currently open", vim.log.levels.WARN)
          return
        end
        
        local cli_cmd = get_cli_cmd()
        local cmd = cli_cmd == "sf" and 
          ("!sf project retrieve start --source-dir \"" .. file_path .. "\"") or
          ("!sfdx force:source:retrieve -p \"" .. file_path .. "\"")
        run_sf_command(cmd, "Retrieve current file")
      end, desc = "Retrieve current file" },
      
      { "<leader>sfR", function()
        local cli_cmd = get_cli_cmd()
        local cmd = cli_cmd == "sf" and 
          "!sf project retrieve start --metadata ApexClass" or
          "!sfdx force:source:retrieve -m ApexClass"
        run_sf_command(cmd, "Retrieve all Apex classes")
      end, desc = "Retrieve all Apex classes" },
      
      { "<leader>sfp", function()
        local cli_cmd = get_cli_cmd()
        local cmd = cli_cmd == "sf" and 
          "!sf project deploy start" or
          "!sfdx force:source:push"
        run_sf_command(cmd, "Push source")
      end, desc = "Push source to scratch org" },
      
      { "<leader>sfP", function()
        local cli_cmd = get_cli_cmd()
        local cmd = cli_cmd == "sf" and 
          "!sf project retrieve start" or
          "!sfdx force:source:pull"
        run_sf_command(cmd, "Pull source")
      end, desc = "Pull source from scratch org" },

      -- Org management group
      { "<leader>so", group = "Org" },
      { "<leader>soo", function()
        local cli_cmd = get_cli_cmd()
        local cmd = cli_cmd == "sf" and "!sf org open" or "!sfdx force:org:open"
        run_sf_command(cmd, "Open default org")
      end, desc = "Open default org" },
      
      { "<leader>sol", function()
        local cli_cmd = get_cli_cmd()
        local cmd = cli_cmd == "sf" and "!sf org list" or "!sfdx force:org:list"
        vim.cmd(cmd)
      end, desc = "List orgs" },
      
      { "<leader>soc", function()
        local cli_cmd = get_cli_cmd()
        local cmd = cli_cmd == "sf" and 
          "!sf org create scratch --definition-file config/project-scratch-def.json" or
          "!sfdx force:org:create -f config/project-scratch-def.json"
        run_sf_command(cmd, "Create scratch org")
      end, desc = "Create scratch org" },
      
      { "<leader>sod", function()
        local cli_cmd = get_cli_cmd()
        -- Prompt for org alias to delete
        local org_alias = vim.fn.input("Enter org alias to delete: ")
        if org_alias == "" then
          vim.notify("No org alias provided", vim.log.levels.WARN)
          return
        end
        
        local cmd = cli_cmd == "sf" and 
          ("!sf org delete scratch --target-org " .. org_alias) or
          ("!sfdx force:org:delete -u " .. org_alias)
        run_sf_command(cmd, "Delete scratch org: " .. org_alias)
      end, desc = "Delete scratch org" },

      -- Testing group
      { "<leader>st", group = "Tests" },
      { "<leader>str", function()
        local cli_cmd = get_cli_cmd()
        local cmd = cli_cmd == "sf" and 
          "!sf apex run test --wait 10" or
          "!sfdx force:apex:test:run --wait 10"
        run_sf_command(cmd, "Run all tests")
      end, desc = "Run all tests" },
      
      { "<leader>stc", function()
        local file_name = vim.fn.expand("%:t:r")
        if file_name == "" then
          vim.notify("No file is currently open", vim.log.levels.WARN)
          return
        end
        
        local cli_cmd = get_cli_cmd()
        local cmd = cli_cmd == "sf" and 
          ("!sf apex run test --class-names " .. file_name .. " --wait 10") or
          ("!sfdx force:apex:test:run -n " .. file_name .. " --wait 10")
        run_sf_command(cmd, "Run test class: " .. file_name)
      end, desc = "Run current test class" },
      
      { "<leader>stm", function()
        local method_name = vim.fn.expand("<cword>")
        if method_name == "" then
          vim.notify("No method name under cursor", vim.log.levels.WARN)
          return
        end
        
        local class_name = vim.fn.expand("%:t:r")
        local full_method = class_name .. "." .. method_name
        
        local cli_cmd = get_cli_cmd()
        local cmd = cli_cmd == "sf" and 
          ("!sf apex run test --tests " .. full_method .. " --wait 10") or
          ("!sfdx force:apex:test:run -t " .. full_method .. " --wait 10")
        run_sf_command(cmd, "Run test method: " .. method_name)
      end, desc = "Run test method under cursor" },
      
      { "<leader>stv", function()
        local cli_cmd = get_cli_cmd()
        local cmd = cli_cmd == "sf" and 
          "!sf apex get test --test-run-id" or
          "!sfdx force:apex:test:report"
        run_sf_command(cmd, "View test results")
      end, desc = "View test results" },

      -- Anonymous Apex group
      { "<leader>sa", group = "Anonymous Apex" },
      { "<leader>sae", function()
        local file_path = vim.fn.expand("%")
        if file_path == "" then
          vim.notify("No file is currently open", vim.log.levels.WARN)
          return
        end
        
        local cli_cmd = get_cli_cmd()
        local cmd = cli_cmd == "sf" and 
          ("!sf apex run --file \"" .. file_path .. "\"") or
          ("!sfdx force:apex:execute -f \"" .. file_path .. "\"")
        run_sf_command(cmd, "Execute anonymous Apex")
      end, desc = "Execute current file as anonymous Apex" },
      
      { "<leader>sal", function()
        local cli_cmd = get_cli_cmd()
        local cmd = cli_cmd == "sf" and 
          "!sf apex tail log" or
          "!sfdx force:apex:log:tail"
        run_sf_command(cmd, "Tail debug logs")
      end, desc = "Tail debug logs" },
      
      { "<leader>sag", function()
        local cli_cmd = get_cli_cmd()
        local cmd = cli_cmd == "sf" and 
          "!sf apex get log --number 1" or
          "!sfdx force:apex:log:get -n 1"
        run_sf_command(cmd, "Get latest debug log")
      end, desc = "Get latest debug log" },

      -- Data operations group
      { "<leader>sd", group = "Data" },
      { "<leader>sdq", function()
        local query = vim.fn.input("Enter SOQL query: ")
        if query == "" then
          vim.notify("No query provided", vim.log.levels.WARN)
          return
        end
        
        local cli_cmd = get_cli_cmd()
        local cmd = cli_cmd == "sf" and 
          ("!sf data query --query \"" .. query .. "\"") or
          ("!sfdx force:data:soql:query -q \"" .. query .. "\"")
        run_sf_command(cmd, "Execute SOQL query")
      end, desc = "Execute SOQL query" },
      
      { "<leader>sdi", function()
        local plan_file = "data/sample-data-plan.json"
        if vim.fn.filereadable(plan_file) == 0 then
          vim.notify("Data plan file not found: " .. plan_file, vim.log.levels.WARN)
          return
        end
        
        local cli_cmd = get_cli_cmd()
        local cmd = cli_cmd == "sf" and 
          ("!sf data import tree --plan " .. plan_file) or
          ("!sfdx force:data:tree:import -p " .. plan_file)
        run_sf_command(cmd, "Import sample data")
      end, desc = "Import sample data" },

      -- Project operations group
      { "<leader>sp", group = "Project" },
      { "<leader>spc", function()
        local project_name = vim.fn.input("Enter project name: ")
        if project_name == "" then
          vim.notify("No project name provided", vim.log.levels.WARN)
          return
        end
        
        local cli_cmd = get_cli_cmd()
        local cmd = cli_cmd == "sf" and 
          ("!sf project generate --name " .. project_name) or
          ("!sfdx force:project:create -n " .. project_name)
        vim.cmd(cmd)
      end, desc = "Create new project" },

      -- Code generation group
      { "<leader>sc", group = "Create/Generate" },
      { "<leader>sca", function()
        if not is_salesforce_project() then
          vim.notify("Not in a Salesforce project directory", vim.log.levels.WARN)
          return
        end
        
        local class_name = vim.fn.input("Enter Apex class name: ")
        if class_name == "" then
          vim.notify("No class name provided", vim.log.levels.WARN)
          return
        end
        
        -- Ensure classes directory exists
        local classes_dir = "force-app/main/default/classes"
        vim.fn.mkdir(classes_dir, "p")
        
        local class_file = classes_dir .. "/" .. class_name .. ".cls"
        local meta_file = classes_dir .. "/" .. class_name .. ".cls-meta.xml"
        
        -- Check if file already exists
        if vim.fn.filereadable(class_file) == 1 then
          vim.notify("Class " .. class_name .. " already exists", vim.log.levels.WARN)
          return
        end
        
        -- Create the Apex class content
        local class_content = {
          "/**",
          " * @description " .. class_name,
          " * @author " .. (vim.env.USER or "Your Name"),
          " * @date " .. os.date("%Y-%m-%d"),
          " */",
          "public class " .. class_name .. " {",
          "\t",
          "\t/**",
          "\t * @description Constructor for " .. class_name,
          "\t */",
          "\tpublic " .. class_name .. "() {",
          "\t\t// Constructor logic here",
          "\t}",
          "\t",
          "\t/**",
          "\t * @description Example method",
          "\t * @return String example return",
          "\t */",
          "\tpublic String exampleMethod() {",
          "\t\treturn 'Hello from " .. class_name .. "';",
          "\t}",
          "}"
        }
        
        -- Create the metadata file content
        local meta_content = {
          '<?xml version="1.0" encoding="UTF-8"?>',
          '<ApexClass xmlns="http://soap.sforce.com/2006/04/metadata">',
          '\t<apiVersion>60.0</apiVersion>',
          '\t<status>Active</status>',
          '</ApexClass>'
        }
        
        -- Write files
        vim.fn.writefile(class_content, class_file)
        vim.fn.writefile(meta_content, meta_file)
        
        vim.notify("Created Apex class: " .. class_name, vim.log.levels.INFO)
        
        -- Open the new file
        vim.cmd("edit " .. class_file)
        
        -- Position cursor at the constructor
        vim.fn.search("Constructor logic here")
        vim.cmd("normal! zz")
      end, desc = "Create Apex Class" },
      
      { "<leader>sct", function()
        if not is_salesforce_project() then
          vim.notify("Not in a Salesforce project directory", vim.log.levels.WARN)
          return
        end
        
        local trigger_name = vim.fn.input("Enter Apex trigger name: ")
        if trigger_name == "" then
          vim.notify("No trigger name provided", vim.log.levels.WARN)
          return
        end
        
        local sobject_name = vim.fn.input("Enter SObject name (e.g., Account, Contact): ")
        if sobject_name == "" then
          vim.notify("No SObject name provided", vim.log.levels.WARN)
          return
        end
        
        -- Ensure triggers directory exists
        local triggers_dir = "force-app/main/default/triggers"
        vim.fn.mkdir(triggers_dir, "p")
        
        local trigger_file = triggers_dir .. "/" .. trigger_name .. ".trigger"
        local meta_file = triggers_dir .. "/" .. trigger_name .. ".trigger-meta.xml"
        
        -- Check if file already exists
        if vim.fn.filereadable(trigger_file) == 1 then
          vim.notify("Trigger " .. trigger_name .. " already exists", vim.log.levels.WARN)
          return
        end
        
        -- Create the trigger content
        local trigger_content = {
          "/**",
          " * @description Trigger for " .. sobject_name,
          " * @author " .. (vim.env.USER or "Your Name"),
          " * @date " .. os.date("%Y-%m-%d"),
          " */",
          "trigger " .. trigger_name .. " on " .. sobject_name .. " (before insert, before update, after insert, after update) {",
          "\t",
          "\tif (Trigger.isBefore) {",
          "\t\tif (Trigger.isInsert) {",
          "\t\t\t// Before insert logic",
          "\t\t}",
          "\t\tif (Trigger.isUpdate) {",
          "\t\t\t// Before update logic",
          "\t\t}",
          "\t}",
          "\t",
          "\tif (Trigger.isAfter) {",
          "\t\tif (Trigger.isInsert) {",
          "\t\t\t// After insert logic",
          "\t\t}",
          "\t\tif (Trigger.isUpdate) {",
          "\t\t\t// After update logic",
          "\t\t}",
          "\t}",
          "}"
        }
        
        -- Create the metadata file content
        local meta_content = {
          '<?xml version="1.0" encoding="UTF-8"?>',
          '<ApexTrigger xmlns="http://soap.sforce.com/2006/04/metadata">',
          '\t<apiVersion>60.0</apiVersion>',
          '\t<status>Active</status>',
          '</ApexTrigger>'
        }
        
        -- Write files
        vim.fn.writefile(trigger_content, trigger_file)
        vim.fn.writefile(meta_content, meta_file)
        
        vim.notify("Created Apex trigger: " .. trigger_name, vim.log.levels.INFO)
        
        -- Open the new file
        vim.cmd("edit " .. trigger_file)
        
        -- Position cursor at the first logic section
        vim.fn.search("Before insert logic")
        vim.cmd("normal! zz")
      end, desc = "Create Apex Trigger" },
      
      { "<leader>scl", function()
        if not is_salesforce_project() then
          vim.notify("Not in a Salesforce project directory", vim.log.levels.WARN)
          return
        end
        
        local component_name = vim.fn.input("Enter Lightning Web Component name: ")
        if component_name == "" then
          vim.notify("No component name provided", vim.log.levels.WARN)
          return
        end
        
        -- Convert to camelCase if needed
        local camelCase_name = component_name:gsub("^%l", string.upper):gsub("[-_](%l)", string.upper):gsub("[-_]", "")
        local kebab_name = component_name:lower():gsub("_", "-")
        
        -- Ensure LWC directory exists
        local lwc_dir = "force-app/main/default/lwc"
        local component_dir = lwc_dir .. "/" .. kebab_name
        vim.fn.mkdir(component_dir, "p")
        
        local js_file = component_dir .. "/" .. kebab_name .. ".js"
        local html_file = component_dir .. "/" .. kebab_name .. ".html"
        local css_file = component_dir .. "/" .. kebab_name .. ".css"
        local meta_file = component_dir .. "/" .. kebab_name .. ".js-meta.xml"
        
        -- Check if component already exists
        if vim.fn.filereadable(js_file) == 1 then
          vim.notify("Component " .. component_name .. " already exists", vim.log.levels.WARN)
          return
        end
        
        -- Create JavaScript file content
        local js_content = {
          "import { LightningElement } from 'lwc';",
          "",
          "export default class " .. camelCase_name .. " extends LightningElement {",
          "\t// Component properties",
          "\tmessage = 'Hello from " .. camelCase_name .. "!';",
          "\t",
          "\t// Lifecycle hooks",
          "\tconnectedCallback() {",
          "\t\t// Component initialization logic",
          "\t}",
          "\t",
          "\t// Event handlers",
          "\thandleClick(event) {",
          "\t\tconsole.log('Button clicked!');",
          "\t}",
          "}"
        }
        
        -- Create HTML file content
        local html_content = {
          "<template>",
          "\t<div class=\"container\">",
          "\t\t<h1 class=\"title\">{message}</h1>",
          "\t\t<button onclick={handleClick} class=\"btn\">",
          "\t\t\tClick Me",
          "\t\t</button>",
          "\t</div>",
          "</template>"
        }
        
        -- Create CSS file content
        local css_content = {
          ".container {",
          "\tpadding: 1rem;",
          "\tborder: 1px solid #ddd;",
          "\tborder-radius: 0.25rem;",
          "}",
          "",
          ".title {",
          "\tfont-size: 1.5rem;",
          "\tfont-weight: bold;",
          "\tmargin-bottom: 1rem;",
          "\tcolor: #333;",
          "}",
          "",
          ".btn {",
          "\tbackground-color: #0176d3;",
          "\tcolor: white;",
          "\tborder: none;",
          "\tpadding: 0.5rem 1rem;",
          "\tborder-radius: 0.25rem;",
          "\tcursor: pointer;",
          "}",
          "",
          ".btn:hover {",
          "\tbackground-color: #014486;",
          "}"
        }
        
        -- Create metadata file content
        local meta_content = {
          '<?xml version="1.0" encoding="UTF-8"?>',
          '<LightningComponentBundle xmlns="http://soap.sforce.com/2006/04/metadata">',
          '\t<apiVersion>60.0</apiVersion>',
          '\t<isExposed>false</isExposed>',
          '\t<targets>',
          '\t\t<target>lightning__RecordPage</target>',
          '\t\t<target>lightning__AppPage</target>',
          '\t\t<target>lightning__HomePage</target>',
          '\t</targets>',
          '</LightningComponentBundle>'
        }
        
        -- Write all files
        vim.fn.writefile(js_content, js_file)
        vim.fn.writefile(html_content, html_file)
        vim.fn.writefile(css_content, css_file)
        vim.fn.writefile(meta_content, meta_file)
        
        vim.notify("Created Lightning Web Component: " .. component_name, vim.log.levels.INFO)
        
        -- Open the JavaScript file
        vim.cmd("edit " .. js_file)
        
        -- Position cursor at the message property
        vim.fn.search("message = ")
        vim.cmd("normal! zz")
      end, desc = "Create Lightning Web Component" },

      -- Authentication
      { "<leader>sA", group = "Auth" },
      { "<leader>sAl", function()
        local cli_cmd = get_cli_cmd()
        local cmd = cli_cmd == "sf" and "!sf org login web" or "!sfdx auth:web:login"
        vim.cmd(cmd)
      end, desc = "Login to org" },
      
      { "<leader>sAo", function()
        local cli_cmd = get_cli_cmd()
        local cmd = cli_cmd == "sf" and "!sf org logout" or "!sfdx auth:logout"
        vim.cmd(cmd)
      end, desc = "Logout from org" },
    })

    -- Telescope extensions for Salesforce
    vim.keymap.set("n", "<leader>sfa", function()
      if not is_salesforce_project() then
        vim.notify("Not in a Salesforce project directory", vim.log.levels.WARN)
        return
      end
      
      require("telescope.builtin").find_files({
        prompt_title = "Find Apex Files",
        cwd = vim.fn.getcwd() .. "/force-app/main/default/classes",
        find_command = { "find", ".", "-name", "*.cls", "-o", "-name", "*.trigger" },
      })
    end, { desc = "Find Apex files" })

    vim.keymap.set("n", "<leader>sfl", function()
      if not is_salesforce_project() then
        vim.notify("Not in a Salesforce project directory", vim.log.levels.WARN)
        return
      end
      
      require("telescope.builtin").find_files({
        prompt_title = "Find Lightning Components",
        cwd = vim.fn.getcwd() .. "/force-app/main/default/lwc",
      })
    end, { desc = "Find Lightning Web Components" })

    vim.keymap.set("n", "<leader>sfm", function()
      if not is_salesforce_project() then
        vim.notify("Not in a Salesforce project directory", vim.log.levels.WARN)
        return
      end
      
      require("telescope.builtin").find_files({
        prompt_title = "Find Metadata",
        cwd = vim.fn.getcwd() .. "/force-app/main/default",
        find_command = { "find", ".", "-name", "*.xml" },
      })
    end, { desc = "Find metadata files" })

    -- Live grep in Apex files only
    vim.keymap.set("n", "<leader>sfs", function()
      if not is_salesforce_project() then
        vim.notify("Not in a Salesforce project directory", vim.log.levels.WARN)
        return
      end
      
      require("telescope.builtin").live_grep({
        prompt_title = "Search in Apex Files",
        cwd = vim.fn.getcwd() .. "/force-app/main/default/classes",
      })
    end, { desc = "Search in Apex files" })
  end,
}
