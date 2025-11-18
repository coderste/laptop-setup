# Setting up a Macbook Pro 

[Installation](#installation)

This repo contains the code to set-up a brand new Macbook Pro with all the apps and tools I use on a day-to-day basis while coding/working.

The `initial-setup.sh` does about 90% of the work. The rest of the work requires entering licensing keys for things like `Alfred` and then syninc our `VS Code` setting by signing in with GitHub.

All the apps and tools are installed using [Homebrew](https://brew.sh/) so this is the first thing installed in the set-up script.

### Font

We use the [Dank Mono Font](https://philpl.gumroad.com/l/dank-mono) but due to it's licensing we can't push to this repo therefore we have to install manually. Other than that everything else can be installed via the set-up script.

### Set Up

`apps.txt` and `tools.txt` are pretty self-explanatory in that the `app.txt` will install the macOS Applications using Homebrew flag `--cask` and the `tools.txt` will install just normal development tools wthout the `--cask` flag.

```
# Applications Installed
Google Chrome
Slack
Alfred 4
iTerm2
Visual Studio Code
Docker
GPG Keychain
1Password
Discord
Spotify

# Tools Installed
Git
ZSH
Golang
PHP
GitHub CLI
Node
Composer
Tig
PHP Code Sniffer
```
Any application or developer tool that can be installed via `Homebrew` can be installed with this set-up script. Applications **MUST** go inside the `apps.txt` file due to how we run the `brew` command and tools **MUST** go inside the `tools.txt` file.

## Installation

Clone the repo into your `$HOME` directory.

```
git clone --recurse-submodules https://github.com/coderste/mac-setup.git
```

**NB:** You need `git` installed on the environment to run this set-up because we use submodules the folders are not included when downloaded as ZIP from GitHub. Install Xcode Command Line Tools which will give you access to `git`

### GitHub CLI and more

We install and authenticate with the [GitHub CLI](https://github.com/cli/cli) towards the end of the set-up script. This gives us the option to generate a new SSH pubic/private key for the machine we are on and then it will upload the public key for us to our GitHub. This just makes the process of generating a new public/private easier and even less work for us.


### Directories

I have a personal set-up of 2 directories. One for `work` repos and one for `personal` repos. The structure is like so:
```
code
|-- personal
|   |-- repo-1
|   `-- repo-2
|-- work
|   |-- repo-1
|   `-- repo-2
```
This structure aligns with my `aliases` for running shortcut commands in the terminal.

## Screenshots of the enviroment
### Terminal Screenshot
![Terminal Screenshot](screenshots/terminal-ss.png)

### VS Code Screenshot
![VS Code Screenshot](screenshots/vs-code-ss.png)

### Dock
> *I'm picky on my dock layout so this is to remember it*

![Dock](screenshots/dock-ss.png)
