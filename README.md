# Neovim Configuration

My personal Neovim configuration built with Lua and lazy.nvim.
## Features

- **Plugin Manager**: [lazy.nvim](https://github.com/folke/lazy.nvim) for fast startup
- **LSP**: Full Language Server Protocol support with Mason
- **Completion**: nvim-cmp with multiple sources
- **Fuzzy Finding**: Telescope for files, grep, and more
- **Git Integration**: Gitsigns for git status in buffers
- **Syntax Highlighting**: Treesitter for better syntax highlighting
- **Salesforce Development**: Custom Salesforce snippets and keymaps

## Installation

This configuration is managed as part of my [dotfiles](https://github.com/RyanStoffel/dotfiles):

```bash
# Clone dotfiles
git clone git@github.com:RyanStoffel/dotfiles.git ~/dotfiles
cd ~/dotfiles

# Stow nvim config
stow .config

# Or clone this repo directly
git clone git@github.com:RyanStoffel/nvim.git ~/.config/nvim
```

## Plugin List

### Core
- **lazy.nvim** - Plugin manager
- **which-key.nvim** - Keybinding helper
- **telescope.nvim** - Fuzzy finder

### LSP & Completion
- **nvim-lspconfig** - LSP configuration
- **mason.nvim** - LSP server installer
- **nvim-cmp** - Completion engine
- **nvim-autopairs** - Auto-close brackets

### UI & Appearance
- **lualine.nvim** - Status line
- **noice.nvim** - Enhanced UI
- **modicator.nvim** - Mode indicator
- **snacks.nvim** - UI enhancements

### Development
- **nvim-treesitter** - Syntax highlighting
- **gitsigns.nvim** - Git integration
- **comment.nvim** - Easy commenting
- **nvim-surround** - Surround text objects

### Salesforce
- **salesforce.lua** - Custom Salesforce utilities
- **salesforce-snippets.lua** - Salesforce code snippets

## Configuration Structure
```bash
~/.config/nvim/
├── init.lua                        # Entry point
├── lua/
│   ├── rstof/
│   │   ├── lazy.lua                # Lazy.nvim setup
│   │   ├── options.lua             # Neovim options
│   │   └── salesforce-keymaps.lua  # Salesforce keybindings
│   └── plugins/
│       ├── lsp/
│       │   ├── lspconfig.lua       # LSP configuration
│       │   └── mason.lua           # LSP server management
│       ├── autopairs.lua           # Auto-pairing
│       ├── colorscheme.lua         # Color scheme
│       ├── comment.lua             # Commenting
│       ├── gitsigns.lua            # Git signs
│       ├── lualine.lua             # Status line
│       ├── nvim-cmp.lua            # Completion
│       ├── salesforce.lua          # Salesforce tools
│       ├── telescope.lua           # Fuzzy finder
│       ├── treesitter.lua          # Syntax highlighting
│       └── which-key.lua           # Key mappings
├── lazy-lock.json                  # Plugin versions
└── install-deps.sh                 # Dependency installer
```

## Key Features

### Salesforce Development
- Custom snippets for Apex, LWC, and Aura components
- Salesforce-specific keymaps and utilities
- Integrated development workflow

### LSP Support
- Automatic LSP server installation via Mason
- Configured for multiple languages
- Jump to definition, references, and more

### Fuzzy Finding
- File finder with Telescope
- Live grep across project
- Buffer and help tag searching

## Requirements

- Neovim >= 0.9.0
- Git
- A Nerd Font (for icons)
- ripgrep (for Telescope grep)
- Node.js (for some LSP servers)

## Customization

The configuration is modular - each plugin has its own file in `lua/plugins/`. Modify individual plugin configurations as needed.

Personal settings are in `lua/rstof/` - update the namespace if you fork this config.

---

*Part of my [dotfiles](https://github.com/RyanStoffel/dotfiles) setup*
