local M = {}

function M.setup()
	-- Ensure FTerm is available
	local fterm = require("FTerm")

	-- Persistent terminal instance
	local my_term = nil

	-- Function to initialize the terminal if not already created
	local function initialize_my_term()
		if not my_term then
			print("Initializing my_term instance") -- Debugging message
			my_term = fterm:new({
				cmd = "tt-setup", -- Command to run in the terminal
				dimensions = {
					height = 1,
					width = 1,
				},
			})
			print("my_term initialized")
		end
	end

	-- Function to toggle the terminal
	function M.toggle_my_term()
		-- Make sure my_term is initialized before using it
		initialize_my_term()

		if my_term:is_open() then
			print("Toggling terminal (closing)") -- Debugging message
			my_term:toggle()
		else
			print("Toggling terminal (opening)") -- Debugging message
			my_term:toggle()
		end
	end

	-- Function to start 'tt-setup' in FTerm on startup
	local function start_tt_setup_in_fterm()
		initialize_my_term()

		-- Open the terminal to run tt-setup
		print("Opening terminal for tt-setup") -- Debugging message
		my_term:open()

		-- Optionally hide the terminal after running tt-setup
		vim.defer_fn(function()
			-- Make sure the terminal instance is still valid
			if my_term:is_open() then
				print("Hiding the terminal after tt-setup") -- Debugging message
				my_term:toggle() -- Hide the terminal without closing it
			end
		end, 100) -- Adjust the delay as needed
	end

	-- Automatically run 'tt-setup' in FTerm on Neovim startup if the temp file exists
	vim.api.nvim_create_autocmd("VimEnter", {
		callback = function()
			local file = io.open("/tmp/nvim_first_run", "r")
			if file ~= nil then
				io.close(file)
				print("Starting tt-setup from temp file") -- Debugging message
				start_tt_setup_in_fterm()
				-- Remove the temp file after the first run
				os.remove("/tmp/nvim_first_run")
			end
		end,
	})

	-- Ensure the terminal is reused when toggling, even across buffers
	vim.api.nvim_create_autocmd({ "BufEnter" }, {
		callback = function()
			if my_term then
				-- Check if the terminal is still alive; if not, skip toggling
				if not my_term:is_open() then
					print("Terminal was closed, skipping re-initialization")
				end
			end
		end,
	})
end

return M
