# Homebrew tap for Megawren

```sh
brew install def324/tap/megawren
```

Run `megawren` to open the file browser. [Megawren documentation](https://github.com/def324/megawren)

Prebuilt Homebrew packages are available for Apple Silicon and x86-64 Linux. On an Intel Mac, download the tested [Intel archive](https://github.com/def324/megawren/releases/latest).

## Updating the formula

Open a pull request with the new release URL and SHA-256. If the release changes the MEGA SDK submodule, update its source archive and checksum too. The tests build bottles from source and run the installed client on macOS and Linux.

Once the checks pass, run the **brew pr-pull** workflow with the pull request number and its head SHA. It publishes the bottles and updates the formula on `main`.

## Moving to homebrew/core

Check the project's age and adoption against [Homebrew’s acceptance policy](https://docs.brew.sh/Package-Acceptance-Policy#notability) before opening a submission. For an eligible release, copy the formula to `Formula/m/megawren.rb` in a fork of `homebrew/core` and remove the tap's `bottle` block. Core builds and hosts its own bottles.

Run the source install, `brew test megawren`, and `brew lgtm --online` in the core checkout. Use Homebrew’s [formula submission guide](https://docs.brew.sh/How-To-Open-a-Homebrew-Pull-Request) for the pull request. Open a linked [tap migration](https://docs.brew.sh/Migrating-A-Formula-To-A-Tap) pull request here so maintainers can coordinate the switch for existing installations.
