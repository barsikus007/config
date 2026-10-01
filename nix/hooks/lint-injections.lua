#!/usr/bin/env -S nvim -l

--? extract and lint embedded shell code from .nix and .md files via tree-sitter and shellcheck
vim.treesitter.language.register("bash", { "shell", "sh", "console" })

local nix_query = vim.treesitter.query.get("nix", "injections")
local md_query = vim.treesitter.query.parse("markdown", [[
(fenced_code_block
  (info_string
    (language) @lang)
  (code_fence_content) @content)
]])

local default_nix_exclude = "SC2154,SC1091"
local default_md_exclude = "SC2154,SC1091,SC2164,SC2046,SC2086"
local severity = "warning"
local extra_exclude = nil
local extra_md_exclude = nil
local target_files = {}

-- parse CLI args
for _, a in ipairs(arg) do
  local sev = a:match("^%-%-severity=(.+)$")
  local exc = a:match("^%-%-exclude=(.+)$")
  local md_exc = a:match("^%-%-md%-exclude=(.+)$")
  if sev then
    severity = sev
  elseif md_exc then
    extra_md_exclude = md_exc
  elseif exc then
    extra_exclude = exc
  elseif not a:match("^%-") then
    table.insert(target_files, a)
  end
end

local nix_exclude_flags = default_nix_exclude
if extra_exclude then
  nix_exclude_flags = nix_exclude_flags .. "," .. extra_exclude
end

local md_exclude_flags = default_md_exclude
if extra_exclude then
  md_exclude_flags = md_exclude_flags .. "," .. extra_exclude
end
if extra_md_exclude then
  md_exclude_flags = md_exclude_flags .. "," .. extra_md_exclude
end

if vim.fn.executable("shellcheck") == 0 then
  io.stderr:write("error: shellcheck not found in PATH\n")
  os.exit(1)
end

-- reconstruct indented_string_expression into virtual buffer
local function process_string_node(node, lines)
  local srow, scol, erow, ecol = node:range()
  local open_delim_len = (node:type() == "indented_string_expression") and 2 or 1
  local edits = {}
  local function add_edit(r, c1, c2, repl, is_rem)
    edits[r] = edits[r] or {}
    table.insert(edits[r], { c1 = c1, c2 = c2, repl = repl, is_rem = is_rem })
  end

  local function collect_edits(n)
    local ntype = n:type()
    if ntype == "dollar_escape" then
      local r1, c1, _, c2 = n:range()
      add_edit(r1, c1, c2, "", true)
    elseif ntype == "interpolation" then
      local r1, c1, r2, c2 = n:range()
      if r1 == r2 then
        local len = c2 - c1
        local orig_line = lines[r1 + 1] or ""
        local prefix = orig_line:sub(1, c1):match("%s*([%-%a]+)%s*$")
        local is_num = prefix and (prefix == "-ge" or prefix == "-gt" or prefix == "-le" or prefix == "-lt" or prefix == "-eq" or prefix == "-ne")
        local placeholder
        if is_num then
          placeholder = "1" .. string.rep("0", math.max(0, len - 1))
        else
          placeholder = "_" .. string.rep("x", math.max(0, len - 2)) .. "_"
          if len == 1 then placeholder = "_" end
        end
        add_edit(r1, c1, c2, placeholder, false)
      else
        local orig_line1 = lines[r1 + 1] or ""
        local len1 = #orig_line1 - c1
        add_edit(r1, c1, #orig_line1, "_" .. string.rep("x", math.max(0, len1 - 1)), false)
        for mid_r = r1 + 1, r2 - 1 do
          add_edit(mid_r, 0, #(lines[mid_r + 1] or ""), "#" .. string.rep(" ", math.max(0, #(lines[mid_r + 1] or "") - 1)), false)
        end
        add_edit(r2, 0, c2, "_" .. string.rep("x", math.max(0, c2 - 2)) .. "_", false)
      end
    else
      for child in n:iter_children() do collect_edits(child) end
    end
  end

  collect_edits(node)
  local out_lines = {}
  for _ = 1, srow do table.insert(out_lines, "") end
  local col_shifts = {}
  local heredoc_delim = nil

  for r = srow, erow do
    local orig = lines[r + 1] or ""
    local line_edits = edits[r] or {}
    table.sort(line_edits, function(a, b) return a.c1 < b.c1 end)
    local res = {}
    local last_idx = 0
    if r == srow then
      table.insert(res, string.rep(" ", scol + open_delim_len))
      last_idx = scol + open_delim_len
    end
    local line_shift_list = {}
    local current_shift = 0
    for _, e in ipairs(line_edits) do
      if e.c1 >= last_idx then
        table.insert(res, orig:sub(last_idx + 1, e.c1))
        table.insert(res, e.repl)
        if e.is_rem then
          local rem_len = e.c2 - e.c1
          current_shift = current_shift + rem_len
          table.insert(line_shift_list, { col = e.c1 + 1 - (current_shift - rem_len), shift = rem_len })
        end
        last_idx = e.c2
      end
    end
    local end_bound = (r == erow) and (ecol - open_delim_len) or #orig
    if last_idx < end_bound then
      table.insert(res, orig:sub(last_idx + 1, end_bound))
    end
    local line_text = table.concat(res, "")

    -- normalize indented heredoc end token
    local h_start = line_text:match("<<%-?%s*['\"]?([%a_][%w_]*)['\"]?")
    if h_start then
      heredoc_delim = h_start
    elseif heredoc_delim then
      local stripped = line_text:match("^%s*(" .. heredoc_delim .. ")%s*$")
      if stripped then
        line_text = stripped
        heredoc_delim = nil
      end
    end

    -- convert non-shebang comments like #! to ##
    local indent, after_bang = line_text:match("^(%s*)#!([^/].*)$")
    if indent and after_bang then
      line_text = indent .. "##" .. after_bang
    end

    out_lines[r + 1] = line_text
    if #line_shift_list > 0 then col_shifts[r + 1] = line_shift_list end
  end
  return out_lines, col_shifts
end

local function map_col(line_num, col, shifts)
  local line_shifts = shifts[line_num]
  if not line_shifts then return col end
  local res = col
  for _, s in ipairs(line_shifts) do
    if col >= s.col then res = res + s.shift end
  end
  return res
end

local total_issues = 0

local function lint_nix_file(path)
  local f = io.open(path, "r")
  if not f then return end
  local content = f:read("*all")
  f:close()
  local lines = vim.split(content, "\n", { plain = true })
  local buf = vim.api.nvim_create_buf(false, true)
  vim.api.nvim_buf_set_lines(buf, 0, -1, false, lines)
  local ok, parser = pcall(vim.treesitter.get_parser, buf, "nix")
  if not ok or not parser or not nix_query then
    vim.api.nvim_buf_delete(buf, { force = true })
    return
  end

  local query = nix_query
  local tree = parser:parse(true)[1]
  local root = tree:root()
  local scripts = {}

  for _, match, metadata in query:iter_matches(root, buf, 0, -1) do
    local lang = metadata["injection.language"]
    for id, nodes in pairs(match) do
      local cname = query.captures[id]
      if cname == "injection.language" then
        for _, n in ipairs(nodes) do
          local text = vim.treesitter.get_node_text(n, buf)
          local extracted = text:match("/%*%s*([%w%p]+)%s*%*/") or text:match("#%s*([%w%p]+)%s*")
          lang = extracted or text
        end
      end
    end

    if lang ~= "bash" and lang ~= "shell" and lang ~= "sh" then
      goto continue_nix
    end

    for id, nodes in pairs(match) do
      local cname = query.captures[id]
      if cname == "injection.content" then
        for _, node in ipairs(nodes) do
          if node:type() ~= "string_fragment" then goto continue_node end
          local p = node:parent()
          if not p then goto continue_node end
          local srow, scol, erow, ecol = p:range()
          local key = string.format("%d:%d-%d:%d", srow, scol, erow, ecol)
          if not scripts[key] then scripts[key] = p end
          ::continue_node::
        end
      end
    end
    ::continue_nix::
  end

  for _, node in pairs(scripts) do
    local ol, shifts = process_string_node(node, lines)
    local text = table.concat(ol, "\n") .. "\n"
    local proc = vim.system({
      "shellcheck",
      "--shell=bash",
      "--severity=" .. severity,
      "--exclude=" .. nix_exclude_flags,
      "--format=json1",
      "-"
    }, { stdin = text }):wait()
    if proc.stdout and #proc.stdout > 0 then
      local res = vim.json.decode(proc.stdout)
      for _, c in ipairs(res.comments) do
        total_issues = total_issues + 1
        local orig_col = map_col(c.line, c.column, shifts)
        print(string.format("%s:%d:%d: %s: %s [SC%s]",
          path, c.line, orig_col, c.level, c.message, c.code))
      end
    end
  end

  vim.api.nvim_buf_delete(buf, { force = true })
end

local function sanitize_md_line(line)
  local res = line:gsub("([^<])<([%w_.-][^<>\r\n]*)>", function(pre, inner)
    if inner:sub(1, 1) == "(" then return nil end
    local clean = inner:gsub("%s", "_")
    return pre .. "_" .. clean .. "_"
  end):gsub("^<([%w_.-][^<>\r\n]*)>", function(inner)
    if inner:sub(1, 1) == "(" then return nil end
    local clean = inner:gsub("%s", "_")
    return "_" .. clean .. "_"
  end)
  return res
end

local function lint_md_file(path)
  local f = io.open(path, "r")
  if not f then return end
  local content = f:read("*all")
  f:close()
  local lines = vim.split(content, "\n", { plain = true })
  local buf = vim.api.nvim_create_buf(false, true)
  vim.api.nvim_buf_set_lines(buf, 0, -1, false, lines)
  local ok, parser = pcall(vim.treesitter.get_parser, buf, "markdown")
  if not ok or not parser then
    vim.api.nvim_buf_delete(buf, { force = true })
    return
  end
  local tree = parser:parse(true)[1]
  local root = tree:root()

  for _, match in md_query:iter_matches(root, buf, 0, -1) do
    local lang_node, content_node
    for id, nodes in pairs(match) do
      local name = md_query.captures[id]
      if name == "lang" then
        lang_node = nodes[1]
      elseif name == "content" then
        content_node = nodes[1]
      end
    end
    if not lang_node or not content_node then
      goto continue_md
    end

    local lang = vim.treesitter.get_node_text(lang_node, buf)
    local resolved_lang = vim.treesitter.language.get_lang(lang) or lang
    if resolved_lang ~= "bash" then
      goto continue_md
    end

    local srow, _, erow, _ = content_node:range()
    local out_lines = {}
    for _ = 1, srow do table.insert(out_lines, "") end
    for r = srow, erow - 1 do
      local line = lines[r + 1] or ""
      table.insert(out_lines, sanitize_md_line(line))
    end
    local text = table.concat(out_lines, "\n") .. "\n"
    local proc = vim.system({
      "shellcheck",
      "--shell=bash",
      "--severity=" .. severity,
      "--exclude=" .. md_exclude_flags,
      "--format=json1",
      "-"
    }, { stdin = text }):wait()
    if proc.stdout and #proc.stdout > 0 then
      local res = vim.json.decode(proc.stdout)
      for _, c in ipairs(res.comments) do
        total_issues = total_issues + 1
        print(string.format("%s:%d:%d: %s: %s [SC%s]",
          path, c.line, c.column, c.level, c.message, c.code))
      end
    end
    ::continue_md::
  end
  vim.api.nvim_buf_delete(buf, { force = true })
end

local files_to_lint = {}
if #target_files > 0 then
  files_to_lint = target_files
else
  local p = io.popen("git ls-files '*.nix' '*.md'")
  if p then
    for line in p:lines() do table.insert(files_to_lint, line) end
    p:close()
  end
end

for _, file in ipairs(files_to_lint) do
  if file:match("%.nix$") then
    lint_nix_file(file)
  elseif file:match("%.md$") then
    lint_md_file(file)
  end
end

if total_issues > 0 then
  os.exit(1)
end
