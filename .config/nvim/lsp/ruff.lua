return {
  on_attach = function(client, bufnr)
    -- This specific block runs on top of your main custom_on_attach
    client.server_capabilities.hoverProvider = false
  end,
}
