-- lua/plugins/salesforce-snippets.lua (FIXED VERSION)
-- Simple, reliable Salesforce snippets

return {
  "L3MON4D3/LuaSnip",
  dependencies = {
    "rafamadriz/friendly-snippets",
  },
  config = function()
    local ls = require("luasnip")
    local s = ls.snippet
    local t = ls.text_node
    local i = ls.insert_node
    local f = ls.function_node

    -- Helper function to get filename without extension
    local function get_filename()
      return vim.fn.expand("%:t:r")
    end

    -- Apex Class Snippets (using simple concatenation instead of fmt)
    ls.add_snippets("apex", {
      -- Simple Apex Class
      s("apexclass", {
        t("/**"), t({"", " * @description "}), i(1, "Class description"),
        t({"", " * @author "}), i(2, vim.fn.getenv("USER") or "Your Name"),
        t({"", " * @date "}), t(os.date("%Y-%m-%d")),
        t({"", " */", "public class "}), f(get_filename, {}), t({" {", "    "}), i(0), t({"", "}"})
      }),

      -- Test Class
      s("testclass", {
        t("/**"), t({"", " * @description Test class"}),
        t({"", " * @author "}), i(1, vim.fn.getenv("USER") or "Your Name"),
        t({"", " * @date "}), t(os.date("%Y-%m-%d")),
        t({"", " */", "@isTest", "public class "}), f(get_filename, {}), t({" {", "", "    @TestSetup", "    static void makeData() {", "        // Create test data", "        "}), i(2),
        t({"", "    }", "", "    @isTest", "    static void "}), i(3, "testMethod"), t({"() {", "        // Given", "        "}), i(4),
        t({"", "        // When", "        Test.startTest();", "        "}), i(5),
        t({"", "        Test.stopTest();", "", "        // Then", "        "}), i(0, "System.assert(true);"),
        t({"", "    }", "}"})
      }),

      -- Simple Method
      s("method", {
        t("/**"), t({"", " * @description "}), i(1, "Method description"),
        t({"", " */", "public static void "}), i(2, "methodName"), t({"("}), i(3), t({") {", "    "}), i(0), t({"", "}"})
      }),

      -- SOQL Query
      s("soql", {
        t("List<"), i(1, "SObject"), t("> "), i(2, "records"), t({" = [", "    SELECT "}), i(3, "Id, Name"),
        t({"", "    FROM "}), i(4, "SObject"),
        t({"", "    WHERE "}), i(5, "Id != null"),
        t({"", "    LIMIT "}), i(0, "100"), t({"", "];"})
      }),

      -- Try-Catch
      s("trycatch", {
        t({"try {", "    "}), i(1, "// Code that might throw exception"),
        t({"", "} catch (Exception e) {", "    "}), i(0, "System.debug('Error: ' + e.getMessage());"),
        t({"", "}"})
      }),

      -- Trigger Template
      s("trigger", {
        t("/**"), t({"", " * @description Trigger for "}), i(1, "SObject"), t(" object"),
        t({"", " * @author "}), i(2, vim.fn.getenv("USER") or "Your Name"),
        t({"", " * @date "}), t(os.date("%Y-%m-%d")),
        t({"", " */", "trigger "}), f(get_filename, {}), t(" on "), i(3, "SObject"), t({" (before insert, before update, after insert, after update) {", "", "    if (Trigger.isBefore) {", "        if (Trigger.isInsert) {", "            "}), i(4, "// Before Insert logic"),
        t({"", "        }", "        if (Trigger.isUpdate) {", "            "}), i(5, "// Before Update logic"),
        t({"", "        }", "    }", "", "    if (Trigger.isAfter) {", "        if (Trigger.isInsert) {", "            "}), i(6, "// After Insert logic"),
        t({"", "        }", "        if (Trigger.isUpdate) {", "            "}), i(0, "// After Update logic"),
        t({"", "        }", "    }", "}"})
      }),
    })

    -- JavaScript Snippets for LWC (simplified)
    ls.add_snippets("javascript", {
      -- LWC Component
      s("lwc", {
        t({"import { LightningElement } from 'lwc';", "", "export default class "}),
        f(function()
          local filename = vim.fn.expand("%:t:r")
          return filename:gsub("%-(%l)", string.upper):gsub("^%l", string.upper)
        end, {}),
        t({" extends LightningElement {", "    "}), i(1, "// Properties"),
        t({"", "", "    connectedCallback() {", "        "}), i(2, "// Initialization"),
        t({"", "    }", "", "    "}), i(0, "// Methods"), t({"", "}"})
      }),

      -- LWC Method
      s("lwcmethod", {
        i(1, "methodName"), t({"("}), i(2), t({") {", "    "}), i(0, "// Implementation"), t({"", "}"})
      }),

      -- LWC Wire
      s("lwcwire", {
        t("@wire("), i(1, "getRecords"), t(", "), i(2, "{}"), t({")", ""}), i(3, "wiredData"), t({"({ error, data }) {", "    if (data) {", "        "}), i(4, "// Handle data"),
        t({"", "    } else if (error) {", "        "}), i(0, "// Handle error"), t({"", "    }", "}"})
      }),
    })

    -- HTML Snippets for LWC
    ls.add_snippets("html", {
      -- LWC Template
      s("lwctemplate", {
        t({"<template>", "    <lightning-card title=\""}), i(1, "Card Title"), t({"\">", "        <div class=\"slds-p-horizontal_small\">", "            "}), i(0, "<!-- Content -->"),
        t({"", "        </div>", "    </lightning-card>", "</template>"})
      }),

      -- Lightning Input
      s("input", {
        t({"<lightning-input", "    label=\""}), i(1, "Label"), t({"\"", "    name=\""}), i(2, "fieldName"), t({"\"", "    value={"}), i(3, "value"), t({"}", "    onchange={"}), i(4, "handleChange"), t({"}", "    type=\""}), i(0, "text"), t({"\">", "</lightning-input>"})
      }),
    })

    -- Set up keymaps for snippet navigation (simplified)
    vim.keymap.set({"i"}, "<C-K>", function() ls.expand() end, {silent = true, desc = "Expand snippet"})
    vim.keymap.set({"i", "s"}, "<C-L>", function() ls.jump(1) end, {silent = true, desc = "Jump to next snippet field"})
    vim.keymap.set({"i", "s"}, "<C-J>", function() ls.jump(-1) end, {silent = true, desc = "Jump to previous snippet field"})
  end,
}
