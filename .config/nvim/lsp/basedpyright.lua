return {
  settings = {
    basedpyright = {
      disableOrganizeImports = true,
    },
    python = {
      analysis = {
        typeCheckingMode = "standard",
        diagnosticMode = "workspace", -- "openFilesOnly", "workspace"
        autoImportCompletions = true,
        inlayHints = {
          variableTypes = true,
          callArgumentNames = true,
        },
      },
    },
  },
}
