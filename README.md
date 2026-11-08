# obsidian

One Obsidian setup shared by macOS ([hypr-mac](https://github.com/RyanAHayden/hypr-mac)) and Linux ([dotfiles](https://github.com/RyanAHayden/dotfiles)), both of which clone this to `~/obsidian` and run `setup.sh`.

The vault is `notes/` in the Syncthing folder `obsidian`, synced between devices `.obsidian` and all. `setup.sh` reads where that folder is from Syncthing's config, since it differs per machine (`~/sync/obsidian` on the Mac, `~/sync/notes` on omarchy-desktop); `$OBSIDIAN_VAULT` overrides it. `setup.sh` installs Obsidian (brew cask / pacman) and merges `vault/*.json` into the vault's `.obsidian`: the keys here win and everything else Obsidian wrote is kept, and files are only rewritten when they change. It installs the plugins in `plugins.txt` from their GitHub releases if they're missing (Obsidian updates them after that) and turns them on, and adds the vault to Obsidian's vault list if it isn't there yet, set to open next launch. If the vault hasn't synced yet it skips the vault part; re-run once it's there.

What's in it:
- vim mode on (`vimMode`), and deleting doesn't ask (`promptDelete`, Obsidian's own prompt; Vimakase still confirms `d`)
- [Vimakase](https://github.com/jelenv/obsidian-vimakase): LazyVim-style Space leader keys and neo-tree-style vim keys in the file explorer
- [Git](https://github.com/Vinzent03/obsidian-git): commits the vault (`vault backup: ...`)
- Ctrl+H focuses the file explorer on the current note, Ctrl+L goes back to the editor (`hotkeys.json`)

Keys:

| Key | Does |
| --- | --- |
| Ctrl+H / Ctrl+L | file explorer (current note highlighted) / back to the note |
| Space e | toggle the file explorer |
| j k h l, gg G | move, collapse/expand, first/last (in the explorer) |
| a / A, d, r, m, u | new file / folder, delete, rename, move, undo (in the explorer) |
| Space , / Space / / Space : | switch file / search vault / command palette |

On macOS, hypr-mac's Karabiner rule that turns Ctrl into Cmd skips Ctrl+D/U/R/L in Obsidian so vim's scrolling, redo and Ctrl+L get through.

Phones: set Settings → Files and links → Override config folder to `.obsidian-mobile`. Otherwise a phone writes its own copy of `app.json` back over the synced one (switching vim mode off everywhere) and makes `.sync-conflict` files.
