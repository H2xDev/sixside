set wildignore+=*.png,*.jpg,*.png,*.tif,*.glp,*.gltf,*.wav,*.tga,*.obj,*\\addons\\*,*.import
set tabstop=4
set shiftwidth=4

lua << EOF
require("nvim-tree").setup({
  sort_by = "case_sensitive",
  view = {
    width = 30,
    mappings = {
      list = {
        { key = "u", action = "dir_up" },
				{ key = "s", action = "vsplit"}
      },
    },
  },
  renderer = {
    group_empty = true,
  },
  filters = {
    dotfiles = true,
		custom = {
			"*.import",
			"*.wav",
			"*.obj",
			"Scenes\\"
		},
  },
})
EOF
