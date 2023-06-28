# Scope.nvim

## :bookmark: About

**Revolutionize Your Neovim Tab Workflow: Introducing Enhanced Tab Scoping!**

Elevate your Neovim tab game with our cutting-edge plugin. Bye-bye cluttered
tabs, hello streamlined efficiency!

This plugin revolutionizes tab management by introducing scoped buffers.
Seamlessly navigate through buffers within each tab using commands like
`:bnext` and `:bprev`. No more buffer chaos!

Experience the power of scoped buffers, boost productivity, and reclaim your
editing flow.

![scope](https://user-images.githubusercontent.com/30515389/156297097-08208d0f-9715-4fc4-8aa0-f5980c21173d.gif)

## 📦 Installation

**Upgrade your Neovim tabs now with your favorite package manager!**

[Lazy](https://github.com/folke/lazy.nvim)

```lua
{ "tiagovla/scope.nvim" }
```

[packer](https://github.com/wbthomason/packer.nvim)

```lua
use("tiagovla/scope.nvim")
```

[vim-plug](https://github.com/junegunn/vim-plug)

```vim
Plug "tiagovla/scope.nvim"
```

## ⚙️ Configuration

```lua
-- init.lua
require("scope").setup({})

```

## 🚀 Extensions

### 🔭 Telescope

Extension to show all buffers from all tabs.

#### :electric_plug: Setup

```lua
-- init.lua
    require("telescope").load_extension("scope")
```

#### 📢 Commands

```
:Telescope scope buffers
```

### :floppy_disk: Session Support (Experimental)

Extension to allow the usage of the plugin with session managers.

#### :electric_plug: Setup

```lua
-- init.lua
vim.opt.sessionoptions = { -- required
    "buffers",
    "tabpages",
    "globals",
}
require("scope").setup({})
```

#### ⚙ Session Manager Configurations

<details>
<summary>📌 Nvim-Possession</summary>
<p></p>

```lua
{
    "gennaro-tedesco/nvim-possession",
    lazy = false,
    dependencies = {
        {
            "tiagovla/scope.nvim",
            lazy = false,
            config = true,
        },
    },
    config = function()
        require("nvim-possession").setup({
            autoload = true,
            autoswitch = {
                enable = true,
            },
            save_hook = function()
                vim.cmd([[ScopeSaveState]]) -- Scope.nvim saving
            end,
            post_hook = function()
                vim.cmd([[ScopeLoadState]]) -- Scope.nvim loading
            end,
        })
    end,
},
```

</details>

#### 📢 Commands

| Commands          | Description                                                      |
| ----------------- | ---------------------------------------------------------------- |
| `:ScopeLoadState` | load the plugin's state as a global variable from a session file |
| `:ScopeSaveState` | save the plugin's state as a global variable in a session file   |

Additionally, the API endpoints
`require("scope.session").serialize_state()` and
`require("scope.session").deserialize_state(state)` are available in case
the user prefers to handle the state manually.

## :fire: Contributing

Pull requests from contributors are warmly welcome. To ensure the highest
quality, please remember to carefully review the formatting using `stylua`.
