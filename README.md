# Homebrew tap for Megawren

```sh
brew install def324/tap/megawren
```

Run `megawren` to open the file browser. [Megawren documentation](https://github.com/def324/megawren)

## Updating the formula

Open a pull request with the new release URL and SHA-256. If the release changes the MEGA SDK submodule, update its source archive and checksum too. The tests build bottles from source and run the installed client on macOS and Linux.

Once the checks pass, run the **brew pr-pull** workflow with the pull request number and its head SHA. It publishes the bottles and updates the formula on `main`.
