local settings = {
    -- every line should be same width without escaped \
    header = {
        type = "text",
        oldfiles_directory = false,
        align = "center",
        fold_section = false,
        title = "Header",
        margin = 5,
        content = {
            " ███╗   ███╗ ███████╗ ██╗     ██╗ ██╗   ██╗ ██╗ ███╗   ███╗",
            " ████╗ ████║ ██╔════╝ ██║ ██╗ ██║ ██║   ██║ ██║ ████╗ ████║",
            " ██╔████╔██║ █████╗   ██║████╗██║ ██║   ██║ ██║ ██╔████╔██║",
            " ██║╚██╔╝██║ ██╔══╝   ████╔═████║ ╚██╗ ██╔╝ ██║ ██║╚██╔╝██║",
            " ██║ ╚═╝ ██║ ███████╗ ███╔╝ ╚███║  ╚████╔╝  ██║ ██║ ╚═╝ ██║",
            " ╚═╝     ╚═╝ ╚══════╝ ╚══╝   ╚══╝   ╚═══╝   ╚═╝ ╚═╝     ╚═╝",
        },
        highlight = "BlinkIndentBlue",
        default_color = "#458588",
        oldfiles_amount = 0,
    },
    -- name which will be displayed and command
    body = {
        type = "mapping",
        oldfiles_directory = false,
        align = "center",
        fold_section = false,
        title = "Commands",
        margin = 5,
        content = {
            { " Find File", "Telescope find_files", "<leader>ff" },
            { "󰍉 Find Word", "Telescope live_grep", "<leader>lg" },
            { " Recent Files", "Telescope oldfiles", "<leader>of" },
            { " File Browser", "Telescope file_browser", "<leader>fb" },
            { " Colorschemes", "Telescope colorscheme", "<leader>cs" },
            { " New File", "lua require'startup'.new_file()", "<leader>nf" },
        },
        highlight = "NvimNot",
        default_color = "#689D6A",
        oldfiles_amount = 0,
    },
    footer = {
        type = "text",
        oldfiles_directory = false,
        align = "center",
        fold_section = false,
        title = "Footer",
        margin = 5,
        content = { "hello world" },
        highlight = "TSString",
        default_color = "#DEDEDE",
        oldfiles_amount = 0,
    },

    clock = {
        type = "text",
        content = function()
            local clock = " " .. os.date("%H:%M")
            local date = " " .. os.date("%d.%m.%Y")
            return { clock, date }
        end,
        oldfiles_directory = false,
        align = "center",
        fold_section = false,
        title = "",
        margin = 5,
        highlight = "TSString",
        default_color = "#EBDBB2",
        oldfiles_amount = 10,
    },

    options = {
        mapping_keys = true,
        cursor_column = 0.5,
        empty_lines_between_mappings = true,
        disable_statuslines = true,
        paddings = { 10, 3, 3, 7 },
    },
    mappings = {
        execute_command = "<CR>",
        open_file = "o",
        open_file_split = "<c-o>",
        open_section = "<TAB>",
        open_help = "?",
    },
    colors = {
        background = "#1f2227",
        folded_section = "#56b6c2",
    },
    -- parts = { "header", "body", "footer", "clock" },
    parts = { "header", "body" },
}
return settings
