# Scope.nvim

### About
Changing the way of how to use tabs on neovim. This plugin scopes
buffers to tabs cleaning up tabline plugins like
[bufferline.nvim](https://github.com/akinsho/bufferline.nvim). 

Buffers belong to tabs, allowing a scoped use of `:bnext` and `:bprev`.

![scope](https://user-images.githubusercontent.com/30515389/156297097-08208d0f-9715-4fc4-8aa0-f5980c21173d.gif)


### Installation

Install with your favorite package manager:

[packer](https://github.com/wbthomason/packer.nvim)

``` lua
use "tiagovla/scope.nvim"
```

[vim-plug](https://github.com/junegunn/vim-plug)

``` vim
Plug "tiagovla/scope.nvim"
```
### Default configuration

``` lua
-- init.lua
require("scope").setup()
```


### Telescope
Extension to show all buffers from all tabs with ``Telescope scope buffers``.
``` lua
-- init.lua
    require("telescope").load_extension("scope")
```

