return {
    "mfussenegger/nvim-dap",
    dependencies = {
        "rcarriga/nvim-dap-ui",
        "nvim-neotest/nvim-nio",
        "leoluz/nvim-dap-go",
        "theHamsta/nvim-dap-virtual-text"
    },
    config = function ()
        local dap, dapui = require("dap"), require("dapui")

        require("dapui").setup()
        require("dap-go").setup()
        require("nvim-dap-virtual-text").setup()

        dap.listeners.before.attach.dapui_config = function()
            dapui.open()
        end
        dap.listeners.before.launch.dapui_config = function()
            dapui.open()
        end
        dap.listeners.before.event_terminated.dapui_config = function()
            dapui.close()
        end
        dap.listeners.before.event_exited.dapui_config = function()
            dapui.close()
        end

        require("dap.ext.vscode").load_launchjs()
        -- local continue = function ()
        --     if vim.fn.filereadable(".vscode/launch.json") then
        --         print("launch json found")
        --         require("dap.ext.vscode").load_launchjs()
        --     end
        --     print("launch json not found")
        --     dap.continue()
        -- end

        vim.keymap.set('n', '<leader>db', dap.toggle_breakpoint)
        vim.keymap.set('n', '<leader>dc', dap.continue)

        vim.keymap.set("n", "<leader>?", function ()
            require("dapui").eval(nil, { enter = true })
        end)

        local dapgo = require("dap-go")
        vim.keymap.set("n", "<leader>td", dapgo.debug_test)
    end
}
