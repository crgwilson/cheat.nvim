# Cheat.nvim

Query [Cheat.sh][cheatsh] directly within Neovim.

## Disclaimer

This is my first crack at writing a plugin mostly for my own use with a nightly
build of Neovim. Your mileage may vary.

## Installation

You can install this with your plugin manager of choice, I use [vim-plug](https://github.com/junegunn/vim-plug).

```vim
Plug 'crgwilson/cheat.nvim'
```

## Usage

This plugin provides one command `:Cheat` which will open a floating window accepting
an arbitrary string which will be sent to `cheat.sh` along with the `filetype`
of your current active buffer.

After entering your question and pressing the enter key another window will
popup (hopefully) containing your answer.

### Keybindings

| Keybind | Description |
| ------- | ----------- |
| `escape` | Close the currently active floating window |
| `enter` | Execute query |

## TODO

* Make keybinds configurable
* Optionally open query windows as splits rather than floating windows

[cheatsh]:https://cheat.sh/ "https://cheat.sh/"
