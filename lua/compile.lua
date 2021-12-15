local api = vim.api
local Job = require'plenary.job'

local function cargo_build()
  local stdout_results = {}
  local job = Job:new {
    command = "cargo",
    args = { "build" },
    on_stdout = function(_, line)
      table.insert(stdout_results, line)
    end,
  }
  job:sync()
  print(vim.inspect.inspect(stdout_results))
end

local function go_build()
  local stdout_results = {}
  local job = Job:new {
    command = "go",
    args = { "build" },
    on_stdout = function(_, line)
      table.insert(stdout_results, line)
    end,
  }
  job:sync()
  print(vim.inspect.inspect(stdout_results))
end

local filetype_compile = {
    ["rust"] = cargo_build,
    ["go"] = go_build,
}

local function compile()
    local ftype = vim.bo.filetype
    print('COMPILE.nvim!')
    print(ftype)
    if filetype_compile[ftype] then
        filetype_compile[ftype]()
    end
end

return {
    compile = compile
}
