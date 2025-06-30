if vim.fn.executable('evergreenlsp') == 1 then
  return {
    cmd = { 'evergreenlsp', 'lsp' },
    root_markers = { 'evergreenlsp.config.yml', '.git' },
    filetypes = { 'yaml' },
    on_attach = function(client, bufnr)
      vim.lsp.completion.enable(true, client.id, bufnr, {
        autotrigger = true,
      })
    end,
  }
end
