#!/bin/bash

echo "🔧 Installing optional dependencies for better Neovim experience..."

# Install fd (better find alternative)
if ! command -v fd &> /dev/null; then
    echo "📁 Installing fd..."
    brew install fd
else
    echo "✅ fd already installed"
fi

# Install lazygit (if you want Git integration)
if ! command -v lazygit &> /dev/null; then
    echo "🌿 Installing lazygit..."
    brew install lazygit
else
    echo "✅ lazygit already installed"
fi

# Install ImageMagick (for image support in Snacks)
if ! command -v magick &> /dev/null; then
    echo "🎨 Installing ImageMagick..."
    brew install imagemagick
else
    echo "✅ ImageMagick already installed"
fi

# Install Ghostscript (for PDF support)
if ! command -v gs &> /dev/null; then
    echo "👻 Installing Ghostscript..."
    brew install ghostscript
else
    echo "✅ Ghostscript already installed"
fi

# Install regex treesitter parser
echo "🌳 Installing regex treesitter parser..."
nvim --headless -c "TSInstall regex" -c "qa"

echo "🎉 Optional dependencies installation complete!"
echo ""
echo "Note: These are optional and your Neovim will work fine without them."
echo "They just provide additional features like:"
echo "- fd: Faster file searching in Telescope"
echo "- lazygit: Git integration"
echo "- ImageMagick: Image rendering in markdown"
echo "- Ghostscript: PDF rendering"
