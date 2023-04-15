return {
  "hrsh7th/nvim-cmp",
  opts = function(_, opts)
    local cmp = require("cmp")
    local sources = opts.sources
    for i = #sources, 1, -1 do
      if sources[i].name == "luasnip" then
        table.remove(sources, i)
      end
    end
    opts.sources = cmp.config.sources(sources)
  end,
}
