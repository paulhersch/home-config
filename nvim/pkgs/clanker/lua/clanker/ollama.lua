---
--  Interface to local Ollama server
---
local curl = require("plenary").curl

local M = {}
local P = {}

M.parse_return_body = function(body)
    local json = vim.json.decode(body)
    return json.response
end

---@param ollama_opts OllamaOpts
---@param prompt string
---@param on_stdout function
---@return Job
M.generate_job = function(ollama_opts, prompt, on_stdout)
    local job = curl.post {
        url = string.format("http://%s:%s/api/generate", ollama_opts.host, ollama_opts.port),
        accept = "application/json",
        stream = on_stdout,
        body = vim.json.encode({
            prompt = prompt,
            model = ollama_opts.model,
            stream = false,
            think = false,
        })
    }

    return job
end

return M
