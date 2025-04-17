print("aaa")

local res = vim.tbl_deep_extend("force", { test = 1 }, { test = 2 })
for k, v in pairs(res) do
	print(k, v)
end
