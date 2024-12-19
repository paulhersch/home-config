local a = vim.api

local function create_and_delete_buf()
    local buf = a.nvim_create_buf(false, true)
    print(buf)
    a.nvim_buf_set_name(buf, "some-test-name")
    a.nvim_buf_delete(buf, { force = true, unload = false })
    return buf
end

print(a.nvim_buf_is_valid(create_and_delete_buf()))
print(a.nvim_buf_is_valid(create_and_delete_buf()))
print(a.nvim_buf_is_valid(create_and_delete_buf()))

-- we check if the the buf is valid and then create and
-- delete one again
-- local isvalid = a.nvim_buf_is_valid(id)
-- print("buffer is valid: " .. tostring(isvalid))
