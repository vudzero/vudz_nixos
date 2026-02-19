-- Buffer line (tabs showing open buffers at the top)
return {
  "akinsho/bufferline.nvim",
  dependencies = { "nvim-tree/nvim-web-devicons" },
  config = function()
    require("bufferline").setup({
      options = {
        mode = "buffers",
        separator_style = "slant",
        always_show_bufferline = false,
        show_buffer_close_icons = true,
        show_close_icon = false,
        color_icons = true,
        hover = {
          enabled = true,
          delay = 200,
          reveal = { "close" },
        },
      },
      highlights = {
        fill = {
          bg = "#1e1e2e",
        },
        background = {
          bg = "#313244",
          fg = "#cdd6f4",
        },
        buffer_visible = {
          bg = "#313244",
          fg = "#cdd6f4",
        },
        buffer_selected = {
          bg = "#cba6f7",
          fg = "#1e1e2e",
          bold = true,
          italic = false,
        },
        close_button = {
          bg = "#313244",
          fg = "#cdd6f4",
        },
        close_button_visible = {
          bg = "#313244",
          fg = "#cdd6f4",
        },
        close_button_selected = {
          bg = "#cba6f7",
          fg = "#1e1e2e",
        },
        separator = {
          bg = "#313244",
          fg = "#1e1e2e",
        },
        separator_visible = {
          bg = "#313244",
          fg = "#1e1e2e",
        },
        separator_selected = {
          bg = "#cba6f7",
          fg = "#1e1e2e",
        },
        indicator_visible = {
          bg = "#313244",
        },
        indicator_selected = {
          bg = "#cba6f7",
        },
        modified = {
          bg = "#313244",
          fg = "#f9e2af",
        },
        modified_visible = {
          bg = "#313244",
          fg = "#f9e2af",
        },
        modified_selected = {
          bg = "#cba6f7",
          fg = "#1e1e2e",
        },
        tab = {
          bg = "#313244",
          fg = "#cdd6f4",
        },
        tab_selected = {
          bg = "#cba6f7",
          fg = "#1e1e2e",
        },
        tab_close = {
          bg = "#313244",
          fg = "#cdd6f4",
        },
      },
    })
  end,
}
