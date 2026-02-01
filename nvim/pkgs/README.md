# Warning: Jank ahead

These are some "internal plugins" i wrote myself because they severely change
certain aspects of how Neovim operates or they solve problems that have already
been solved in a slightly different way, thus it didn't really make sense to
publish them as "proper" plugins or i didn't feel like maintaining them.

- bffrmgr: LRU buffer unloader thing that keeps track of the recently used
  buffers, +UI to quickly switch with keys on the homerow

- colors: Colorscheme meta-manager thing, because i have my own colors and
  wanted to experiment with different ways of generating themes

- evaluator: unused nowadays, wanted something to execute lua directly inside
  the neovim lua runtime to quickly iterate on plugins, but gave that one up.
  Still kept around so i don't have to dig through other configs/plugins for
  range related query stuff

- presenter: very basic plugin similar to presenting.nvim but without the part
  where the plugin opens three seperate popups and with simpler UI (all the
  plugins to quickly present markdown fucked up my highlighting)

- winstatabline: my own metaframework thing to create bars that are formed like
the statusline. It annoyed me, that almost all the popular plugins don't allow
You finegrained control over the redraw timing or just updated expensive stuff
too often. Very similar to galaxyline, but every component You add is
implicitly a part.
    - If You want to use it: `line.lua` has the base class to add a line,
      and there are premade modules in `modules`. Be aware that all the
      premade modules use custom highlighting groups...
