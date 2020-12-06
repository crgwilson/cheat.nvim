fun! Cheat()
  lua for k in pairs(package.loaded) do if k:match("^cheat") then package.loaded[k] = nil end end
  lua require("cheat").cheat()
endfun

augroup Cheat
  autocmd!
augroup END
