# Homebrew VLBI

Homebrew formulae for PGPLOT, NRAO SCHED, and DIFMAP on macOS.
This tap consolidates `kazuakiyama/pgplot`, `kazuakiyama/sched`, and
`kazuakiyama/difmap`.

## Installation

```sh
brew tap kazuakiyama/vlbi
brew install kazuakiyama/vlbi/pgplot kazuakiyama/vlbi/sched kazuakiyama/vlbi/difmap
```

You can also install just SCHED or DIFMAP; PGPLOT is installed as a dependency.
In zsh, use `nsched` to avoid the shell's built-in `sched` command.

## Migration from the old taps

The old taps contain `tap_migrations.json` entries pointing here. Run:

```sh
brew tap kazuakiyama/vlbi
brew update
```

Homebrew uses these entries to migrate installed formulae from the old taps.
Follow any trust prompts displayed by your Homebrew version. You can then use
`brew upgrade` normally. After migration, the old taps can be removed:

```sh
brew untap kazuakiyama/difmap
brew untap kazuakiyama/sched
brew untap kazuakiyama/pgplot
```

Only untap repositories you previously added. If Homebrew reports that an
installed formula still belongs to an old tap, leave that tap in place and
report the migration problem in this repository's Issues.

## Environment

Add the settings you need to `~/.zshrc` or `~/.bash_profile`:

```sh
export PGPLOT_DIR="$(brew --prefix pgplot)/share/pgplot"
export PGPLOT_DEV=/xwin
export SCHED="$(brew --prefix sched)"
```

`PGPLOT_DEV=/xwin` selects interactive X11 plotting, which requires a running
X server such as XQuartz. You can choose another PGPLOT device instead.
SCHED's catalogs, setups, examples, and documentation are installed under
`brew --prefix sched`; DIFMAP's help files are under `$(brew --prefix difmap)/help`.

## Formula provenance and validation

The initial formulae come from the published versions of the three old taps:

| Formula | Version | Source commit |
| --- | --- | --- |
| PGPLOT | 5.2.2, revision 13 | `02ac725fde41fa7db44af19f64aceb3282e84543` |
| SCHED | 11.8, revision 1 | `18f6f5ed259eef8300176209d5dced9d6b3ae455` |
| DIFMAP | 2.5r | `558806940f56bd441801c1d386b8c37f77c464f2` |

SCHED and DIFMAP explicitly depend on this tap's PGPLOT. Existing patch URLs
remain pinned to commits in `hb-pgplot-patches` and `hb-difmap-patches`.
Those repositories must remain available.

GitHub Actions builds all three packages from source on macOS 15 for Apple
Silicon and Intel, and runs DIFMAP's existing startup, expression, and help-file
test. The published PGPLOT test has known Fortran/C output-comparison issues;
the published SCHED test is a failing placeholder. They are retained unchanged
and are not run by this migration's workflow. Interactive X11 plotting and
SCHED observation output are not validated by this workflow.

## Support

Report packaging issues in [this repository's Issues](https://github.com/kazuakiyama/homebrew-vlbi/issues).
For issues with the software itself, contact the corresponding upstream project:

- [PGPLOT](https://www.astro.caltech.edu/~tjp/pgplot/)
- [NRAO SCHED](https://www.aoc.nrao.edu/software/sched/index.html)
- [DIFMAP](https://sites.astro.caltech.edu/~tjp/citvlb/index.html)
