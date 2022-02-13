-- Run a maker and return the output
-- Parse the results
-- Send the results to the quickfix list (or diagnostics, does it make sense?)
-- Return if a maker is running
-- make.run(maker, on_done)
-- maker = {cmd, [args], [cwd]}
-- Send the output to on_done = function(output, return_val)
-- parse(lines, errorformat) -> list of results that can be sent to quickfix
-- on_done = function(lines) parse, send to quickfix, notify, cwindow etc. end
-- Pass arguments to a maker. :Make echo hej should run the `echo` maker and
-- should add "hej" to the args table

local Job = require "plenary.job"

local M = {}

M.running_makers = {}

M.run = function(maker, on_done)
    local job = Job:new {
        command = maker.command,
        args = maker.args or {},
        cwd = maker.cwd,
        on_exit = function(job, return_val)
            vim.defer_fn(function()
                M.running_makers[job.pid] = nil
                on_done(job:result(), return_val)
            end, 0)
        end,
    }
    job:start()
    M.running_makers[job.pid] = true
end

M.parse = function(lines, errorformat)
    local qflist = vim.fn.getqflist { lines = lines, efm = errorformat }
    local items = qflist.items
    local results = {}
    for _, item in ipairs(items) do
        local result = {
            filename = vim.api.nvim_buf_get_name(item.bufnr),
            lnum = item.lnum,
            message = item.text,
        }
        table.insert(results, result)
    end
    return results
end

M.send_to_qflist = function(results)
    local items = {}
    for _, result in ipairs(results) do
        local item = {
            filename = result.filename,
            lnum = result.lnum,
            text = result.message,
            valid = true,
        }
        table.insert(items, item)
    end
    vim.fn.setqflist(items)
end

return M
