local make = require "make"

local M = {}

M.sleep = function()
    local maker = {
        command = "sleep",
        args = { "3" },
    }
    local on_done = function(output, return_val)
        vim.notify(string.format("%d", return_val))
    end
    make.run(maker, on_done)
end

M.ls_cwd = function()
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
end

M.select_and_run_maker = function()
    local on_choice = function(item, idx)
        if not item then
            return
        end
        item.fn()
    end
    local opts = {
        prompt = "Run maker",
        format_item = function(item) return item.name end,
    }
    vim.ui.select(M.available_makers, opts, on_choice)
end

M.available_makers = {
    { name = "sleep", fn = M.sleep },
    { name = "ls_cwd", fn = M.ls_cwd },
}

return M
