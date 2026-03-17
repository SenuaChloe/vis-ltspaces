local BS = {
  leading_spaces = false,
  trailing_spaces = true,
  other_spaces = false,
  leading_style = 'back:#008800',
  trailing_style = 'back:#880000',
  other_style = 'back:#000088',
  base_style_id = 60
}


BS.on_win_highlight = function(win)
  local content = win.file:content(win.viewport['bytes'])
  if BS.leading_spaces then
    local matches = BS.get_matches(content, "^( +)", 1, 0)
    BS.update_style(win, matches, BS.leading_style, BS.base_style_id)
    local matches = BS.get_matches(content, "\n( +)", 1, 0)
    BS.update_style(win, matches, BS.leading_style, BS.base_style_id)
  end
  if BS.trailing_spaces then
    local matches = BS.get_matches(content, "( +)[\n\r]", 0, -1)
    BS.update_style(win, matches, BS.trailing_style, BS.base_style_id + 1)
  end
  if BS.other_spaces then
    local matches = BS.get_matches(content, "[^\n ]( +)[^\n\r ]", 1, -1)
    BS.update_style(win, matches, BS.other_style, BS.base_style_id + 2)
  end
end


BS.get_matches = function(input, pattern, start_offset, end_offset)
  local matches = {}
  local cur_match_start = 0
  local cur_match_end = 0
  local cur_match = ""
  while true do
    cur_match_start, cur_match_end, cur_match = string.find(input, pattern, cur_match_end+1)
    if cur_match_start == nil then
      break
    end   
    table.insert(matches, { mstart = cur_match_start + start_offset, mend = cur_match_end + end_offset})
  end
  return matches
end


BS.update_style = function(win, matches, style, style_id)
  local res = win:style_define(style_id, style)
  if not res then
    return
  end

  local offset = win.viewport['bytes'].start
  for _,match in ipairs(matches) do
    win:style(style_id, 
      match.mstart + offset - 1, 
      match.mend + offset - 1)
  end
end

vis.events.subscribe(vis.events.WIN_HIGHLIGHT, BS.on_win_highlight)

return BS
