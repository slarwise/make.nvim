local make = require "make"

describe("parse", function()
    it("should parse the output into a table", function()
        local lines = { "file1:3:message1", "file2:5:message2" }
        local errorformat = "%f:%l:%m"
        local results = make.parse(lines, errorformat)
        local result1 = results[1]
        local result2 = results[2]
        assert.are.same("file1", vim.fn.fnamemodify(result1.filename, ":t"))
        assert.are.same(3, result1.lnum)
        assert.are.same("message1", result1.message)
        assert.are.same("file2", vim.fn.fnamemodify(result2.filename, ":t"))
        assert.are.same(5, result2.lnum)
        assert.are.same("message2", result2.message)
    end)
end)

describe("send_to_qflist", function()
    it("should send the results to the quickfix list", function()
        local results = {
            {
                filename = "file1",
                lnum = 3,
                message = "message1",
            },
            {
                filename = "file2",
                lnum = 5,
                message = "message2",
            },
        }
        make.send_to_qflist(results)
        local qf_items = vim.fn.getqflist()
        local item1 = qf_items[1]
        local item2 = qf_items[2]
        assert.are.same("file1", vim.fn.fnamemodify(vim.api.nvim_buf_get_name(item1.bufnr), ":t"))
        assert.are.same(3, item1.lnum)
        assert.are.same("message1", item1.text)
        assert.are.same("file2", vim.fn.fnamemodify(vim.api.nvim_buf_get_name(item2.bufnr), ":t"))
        assert.are.same(5, item2.lnum)
        assert.are.same("message2", item2.text)
    end)
end)
