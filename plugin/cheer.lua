if vim.g.loaded_cheer then
    return
end
vim.g.loaded_cheer = true

require('cheer').setup()
