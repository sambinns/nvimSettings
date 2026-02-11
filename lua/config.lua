vim.g.have_nerd_font=true
vim.opt.number=true
vim.opt.relativenumber=true
vim.opt.signcolumn="number"

if ('Darwin' == vim.loop.os_uname().sysname) then
	vim.g.coq_settings = {
		auto_start = 'shut-up',
	}
	require'coq'
end

dockerBuildContainer='rocky-8-build'
dockerUser='root'
if not ('Darwin' == vim.loop.os_uname().sysname) then
	require'lspconfig'.clangd.setup{
		cmd={'docker', 'exec', '--user', 'dockerUser', '-i', dockerBuildContainer, '/usr/bin/clangd', '--background-index', '2>/dev/null'}
	}
else
	require'lspconfig'.clangd.setup{}
end

require'lspconfig'.lua_ls.setup {
  on_init = function(client)
    if client.workspace_folders then
      local path = client.workspace_folders[1].name
      if path ~= vim.fn.stdpath('config') and (vim.loop.fs_stat(path..'/.luarc.json') or vim.loop.fs_stat(path..'/.luarc.jsonc')) then
        return
      end
    end

    client.config.settings.Lua = vim.tbl_deep_extend('force', client.config.settings.Lua, {
      runtime = {
        -- Tell the language server which version of Lua you're using
        -- (most likely LuaJIT in the case of Neovim)
        version = 'LuaJIT'
      },
      -- Make the server aware of Neovim runtime files
      workspace = {
        checkThirdParty = false,
        library = {
          vim.env.VIMRUNTIME
          -- Depending on the usage, you might want to add additional paths here.
          -- "${3rd}/luv/library"
          -- "${3rd}/busted/library",
        }
        -- or pull in all of 'runtimepath'. NOTE: this is a lot slower and will cause issues when working on your own configuration (see https://github.com/neovim/nvim-lspconfig/issues/3189)
        -- library = vim.api.nvim_get_runtime_file("", true)
      }
    })
  end,
  settings = {
    Lua = {}
  }
}

-- LSP keybingings
vim.keymap.set("n", "gra", vim.lsp.buf.code_action)
vim.keymap.set("n", "gri", vim.lsp.buf.implementation)
vim.keymap.set("n", "grn", vim.lsp.buf.rename)
vim.keymap.set("n", "grr", vim.lsp.buf.references)
vim.keymap.set("n", "grt", vim.lsp.buf.type_definition)
vim.keymap.set("n", "gO",  vim.lsp.buf.document_symbol)
vim.keymap.set("i", "CTRL-S", vim.lsp.buf.signature_help)

require'marks'.setup()
-- Marks keymappings
--     mx              Set mark x
--	   m,              Set the next available alphabetical (lowercase) mark
--     m;              Toggle the next available mark at the current line
--     dmx             Delete mark x
--     dm-             Delete all marks on the current line
--     dm<space>       Delete all marks in the current buffer
--     m]              Move to next mark
--     m[              Move to previous mark
--     m:              Preview mark. This will prompt you for a specific mark to
--                     preview; press <cr> to preview the next mark.
--                     
--     m[0-9]          Add a bookmark from bookmark group[0-9].
--     dm[0-9]         Delete all bookmarks from bookmark group[0-9].
--     m}              Move to the next bookmark having the same type as the bookmark under
--                     the cursor. Works across buffers.
--     m{              Move to the previous bookmark having the same type as the bookmark under
--                     the cursor. Works across buffers.
--     dm=             Delete the bookmark under the cursor.

require'lualine'.setup()
