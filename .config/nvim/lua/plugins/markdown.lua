return {
  {
    "MeanderingProgrammer/render-markdown.nvim",
    dependencies = { "nvim-treesitter/nvim-treesitter" },
    ft = { "markdown" },
    opts = {
      heading   = { enabled = true },
      code      = { enabled = true },
      dash      = { enabled = true },
      bullet    = { enabled = true },
      checkbox  = { enabled = true },
      quote     = { enabled = true },
      link      = { enabled = true },
    },
  },
}
