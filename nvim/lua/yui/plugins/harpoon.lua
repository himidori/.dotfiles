return {
    "ThePrimeagen/harpoon",
    dependencies = { "nvim-telescope/telescope.nvim" },
    branch = "harpoon2",
    config = function ()
        local harpoon = require("harpoon")
        harpoon.setup()

        vim.keymap.set("n", "<leader>h", function () harpoon:list():add() end)
        vim.keymap.set("n", "<C-e>", function() harpoon:list():select(1) end)
        vim.keymap.set("n", "<C-r>", function() harpoon:list():select(2) end)
        vim.keymap.set("n", "<C-t>", function() harpoon:list():select(3) end)
        vim.keymap.set("n", "<C-y>", function() harpoon:list():select(4) end)

        -- vim.keymap.set("n", "<C-p>", function() harpoon:list():prev() end)
        -- vim.keymap.set("n", "<C-n>", function() harpoon:list():next() end)

        vim.keymap.set("n", "<C-m>", function() harpoon.ui:toggle_quick_menu(harpoon:list()) end)
    end
}
