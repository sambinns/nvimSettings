vim.g.have_nerd_font=true
vim.opt.number=true
vim.opt.relativenumber=true
vim.opt.signcolumn="number"
vim.opt.exrc = true

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
  require'lspconfig'.clangd.setup({})
  require('lspconfig').sourcekit_lsp.setup({
    -- Standard setup for sourcekit-lsp
    -- It should automatically detect the buildServer.json
  })

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

require'lspconfig'.pyright.setup({})

-- LSP keybingings
vim.keymap.set("n", "gra", vim.lsp.buf.code_action)
vim.keymap.set("n", "gri", vim.lsp.buf.implementation)
vim.keymap.set("n", "grn", vim.lsp.buf.rename)
vim.keymap.set("n", "grr", vim.lsp.buf.references)
vim.keymap.set("n", "grt", vim.lsp.buf.definition)
vim.keymap.set("n", "gO",  vim.lsp.buf.document_symbol)
vim.keymap.set("i", "CTRL-S", vim.lsp.buf.signature_help)

-- DAP (Debug Adapter Protocol)
local dap = require('dap')
local dapui = require('dapui')

-- C/C++ adapter: Apple lldb-dap (ships with Xcode)
local lldb_dap_path = vim.fn.system('xcrun --find lldb-dap'):gsub('\n', '')
dap.adapters.lldb = {
  type = 'executable',
  command = lldb_dap_path,
  name = 'lldb',
}

-- Default C/C++ launch config (prompts for executable)
dap.configurations.cpp = {
  {
    name = 'Launch (select executable)',
    type = 'lldb',
    request = 'launch',
    program = function()
      return vim.fn.input('Executable: ', vim.fn.getcwd() .. '/', 'file')
    end,
    cwd = '${workspaceFolder}',
    stopOnEntry = false,
    args = function()
      local input = vim.fn.input('Args (space-separated): ')
      if input == '' then return {} end
      return vim.split(input, ' ')
    end,
  },
}
dap.configurations.c = dap.configurations.cpp
dap.configurations.objcpp = dap.configurations.cpp

-- Python adapter via debugpy
require('dap-python').setup('python3')

-- DAP UI
dapui.setup()
dap.listeners.before.event_initialized['dapui_config'] = function() dapui.open() end
dap.listeners.before.event_terminated['dapui_config'] = function() dapui.close() end
dap.listeners.before.event_exited['dapui_config'] = function() dapui.close() end

-- DAP keybindings
vim.keymap.set('n', '<F5>', dap.continue, { desc = 'Debug: continue/start' })
vim.keymap.set('n', '<F10>', dap.step_over, { desc = 'Debug: step over' })
vim.keymap.set('n', '<F11>', dap.step_into, { desc = 'Debug: step into' })
vim.keymap.set('n', '<F12>', dap.step_out, { desc = 'Debug: step out' })
vim.keymap.set('n', '<Leader>b', dap.toggle_breakpoint, { desc = 'Toggle breakpoint' })
vim.keymap.set('n', '<Leader>B', function()
  dap.set_breakpoint(vim.fn.input('Condition: '))
end, { desc = 'Conditional breakpoint' })
vim.keymap.set('n', '<Leader>dr', dap.repl.open, { desc = 'Debug REPL' })
vim.keymap.set('n', '<Leader>dl', dap.run_last, { desc = 'Re-run last debug' })
vim.keymap.set('n', '<Leader>du', dapui.toggle, { desc = 'Toggle DAP UI' })

-- AI tools (new tab)
vim.keymap.set('n', '<Leader>cc', function() vim.cmd('tabnew | terminal claude') end, { desc = 'Claude Code (new tab)' })
vim.keymap.set('n', '<Leader>oc', function() vim.cmd('tabnew | terminal opencode') end, { desc = 'opencode (new tab)' })

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

require('telescope').load_extension('fzf')

local builtin = require('telescope.builtin')
vim.keymap.set('n', '<leader>ff', builtin.find_files, { desc = 'Telescope find files' })
vim.keymap.set('n', '<leader>fg', builtin.live_grep, { desc = 'Telescope live grep' })
vim.keymap.set('n', '<leader>fb', builtin.buffers, { desc = 'Telescope buffers' })
vim.keymap.set('n', '<leader>fh', builtin.help_tags, { desc = 'Telescope help tags' })
