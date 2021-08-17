-- https://github.com/mhartington/formatter.nvim --

return function()
	require('formatter').setup {
		logging = false,
		filetype = {
			-- general remove whitespace
			javascript = {
        -- prettier
       function()
          return {
            exe = "prettier",
            args = {"--stdin-filepath", vim.api.nvim_buf_get_name(0), '--single-quote'},
            stdin = true
          }
        end
    },
		lua = {
        -- luafmt
        function()
          return {
            exe = "luafmt",
            args = {"--indent-count", 2, "--stdin"},
            stdin = true
          }
        end
    },
    cpp = {
        -- clang-format
       function()
          return {
            exe = "clang-format",
            args = {"--assume-filename", vim.api.nvim_buf_get_name(0)},
            stdin = true,
            cwd = vim.fn.expand('%:p:h')  -- Run clang-format in cwd of the file.
          }
        end
    },
		python = {
			-- black
			function()
				return {
					exe = "black",
					stdin = true,
				}
			end
		}
		}
	}
	-- Format on save
	-- vim.api.nvim_exec([[
-- augroup FormatAutogroup
  -- autocmd!
  -- autocmd BufWritePost *.js,*.rs,*.lua FormatWrite
-- augroup END
-- ]], true)
end