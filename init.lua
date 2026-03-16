local LTS = {
  leading_spaces = true,
  trailing_spaces = true,
  other_spaces = false,
  leading_color = '#00FF00',
  trailing_color = '#FF0000',
  other_color = '#0000FF',
  base_style_id = 60
}

LTS.on_win_highlight = function(win)
  local content = win.file:content(win.viewport['bytes'])
  if LTS.leading_spaces then
    local matches = LTS.get_matches(content, "^( +)")
    LTS.highlight(win, matches, LTS.leading_color, LTS.base_style_id, 1, 0)
    local matches = LTS.get_matches(content, "\n( +)")
    LTS.highlight(win, matches, LTS.leading_color, LTS.base_style_id, 1, 0)
  end
  if LTS.trailing_spaces then
    local matches = LTS.get_matches(content, "( +)\n")
    LTS.highlight(win, matches, LTS.trailing_color, LTS.base_style_id + 1, 0, -1)
    local matches = LTS.get_matches(content, "( +)\r\n")
    LTS.highlight(win, matches, LTS.trailing_color, LTS.base_style_id + 1, 0, -2)
  end
  if LTS.other_spaces then
    local matches = LTS.get_matches(content, "[^\n ]( +)[^\n\r ]")
    LTS.highlight(win, matches, LTS.other_color, LTS.base_style_id + 2, 1, -1)
  end
end


LTS.get_matches = function(input, pattern)
  local matches = {}
  local cur_match_start = 0
  local cur_match_end = 0
  local cur_match = ""
  while true do
    cur_match_start, cur_match_end, cur_match = string.find(input, pattern, cur_match_end+1)
    if cur_match_start == nil then
      break
    end   
    table.insert(matches, {mstart=cur_match_start, mend=cur_match_end})
  end
  return matches
end

local errlog = io.open("log.txt", "w")

LTS.highlight = function(win, matches, color, style_id, start_offset, end_offset)
  errlog:write(#matches .. " - " .. color .. " - " .. style_id .. "\n")
  local res = win:style_define(style_id, "back:" .. color)
  if not res then
    return
  end

  local offset = win.viewport['bytes'].start
  for _,match in ipairs(matches) do
    win:style(style_id, 
      match.mstart + offset + start_offset - 1, 
      match.mend + offset + end_offset - 1)
  end
end

vis.events.subscribe(vis.events.WIN_HIGHLIGHT, LTS.on_win_highlight)

return LTS
