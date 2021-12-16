local api = vim.api
local Job = require'plenary.job'

local function build(command, args)
  -- write the entire result into an output buffer
  local output = {}
  local job = Job:new {
    command = command,
    args = args,
    on_stdout = function(err, line)
      table.insert(output, line)
      table.insert(output, err)
    end,
    on_stderr = function(err, line)
      table.insert(output, line)
      table.insert(output, err)
    end,
  }
  -- wait for the job to finish
  job:sync()
  -- return the output
  return output
end

local function cargo_build()
  return build("cargo", { "build" })
end

local function go_build()
  return build("go", { "build" })
end

local function python_run()
  local curr_filename = vim.fn.expand('%')
  return build("python", { curr_filename })
end

local function spawn_buffer(compile_func)
  -- check if buffer exists and yeet it
  local buf_key = vim.fn.bufnr('*COMPILE*')
  if buf_key > -1 then
    vim.api.nvim_buf_delete(buf_key, {force = true})
  end

  -- compile the function
  local res = compile_func()
  local win = api.nvim_get_current_win()
  local buf = api.nvim_create_buf(true, true)

  -- create buffer and throw text into it
  api.nvim_win_set_buf(win, buf)
  -- make the buffer modifiable just in case some buffer options are persisting
  api.nvim_command('set ma')
  -- set buffer name
  api.nvim_buf_set_name(0, "*COMPILE*")
  -- write the text
  api.nvim_buf_set_text(0, 0, 0, 0, 0, res)
  -- make it unmodifiable
  api.nvim_command('set noma')
end

-- table to match filetypes
local filetype_compile = {
    ["rust"] = cargo_build,
    ["go"] = go_build,
    ["python"] = python_run,
}

-- main function that gets exported
local function compile()
    local ftype = vim.bo.filetype
    if filetype_compile[ftype] then
        spawn_buffer(filetype_compile[ftype])
    end
end

-- export the function(s)
return {
    compile = compile
}
