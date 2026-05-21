
<div align="center">
  <img alt="An icon representing a stack of little squared blue sticky notes. The first one, and the second one hinted below, have scribbles over them" src="data/icons/default/hicolor/128.png" />
  <h1>Cargo Write</h1>
  <h3>A sticky notes app for elementary OS</h3>

  <span align="center">A sticky notes app for colourful little squares.</span>
</div>

<br/>

## 🦺 Installation

You can download and install Cargo Write from various sources:

[![Get it on AppCenter](https://appcenter.elementary.io/badge.svg?new)](https://appcenter.elementary.io/io.github.cargowrite.CargoWrite) 

[<img src="https://flathub.org/assets/badges/flathub-badge-en.svg" width="160" alt="Download on Flathub">](https://flathub.org/apps/io.github.cargowrite.CargoWrite)


On Windows:
Grab the Exe installer in Release


## ❓ Questions, building, etc

For local Linux builds on Ubuntu 26.04 and similar hosts: Cargo Write vendors the elementary stylesheet source in `third_party/elementary-stylesheet/` and ships compiled GTK4 note-theme resources from `data/elementary/`, so you keep the elementary look without relying on a host-installed `io.elementary.stylesheet` package. If you want to refresh those vendored theme files after pulling upstream changes, run `cd third_party/elementary-stylesheet && npm install --no-save sass`, then run `data/update-elementary-theme.sh` from the repo root.

Build and run locally:

```bash
meson setup builddir --reconfigure
meson compile -C builddir
./builddir/src/io.github.cargowrite.CargoWrite --new-note
```

Install locally for your user:

```bash
meson setup builddir-user --prefix="<user-local-prefix>"
meson compile -C builddir-user
meson install -C builddir-user
```

Install to a system prefix:

```bash
meson setup builddir-system --prefix="<system-prefix>"
meson compile -C builddir-system
sudo meson install -C builddir-system
```



## 🛣️ Roadmap

Cargo Write is a cute simple and lightweight little notes app, and i wanna keep it this way
Top priority is to have the clearest, simplest, most efficient code ever



## 💝 Donations

On the right you can donate to various project contributors.


## 💾 Notes Storage


Notes are stored in the app's user data directory.

`saved_state.json` contains all notes in JSON format. The structure is quite simple, if not pretty.

The app reads from it only during startup (rest of the time it writes in) so you could quite easily swap it up to swap between sets of notes.
