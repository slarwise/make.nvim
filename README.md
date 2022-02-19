# make.nvim

Run makers and do stuff with the output. Requires plenary.

## Example

This example runs `ls` in the current working directory and sets the quickfix
list to the outputted files.

```lua
local make = require "make"

local maker = {
    command = "ls",
    cwd = vim.fn.getcwd(),
}
local on_done = function(output)
    local files = make.parse(output, "%f")
    make.send_to_qflist(files)
    vim.cmd [[cwindow]]
end
make.run(maker, on_done)
```
