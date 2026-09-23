# [browser](../README.md)

## [extensions](../nix/home/gui/browser/firefox.nix#L51)

### [uBlock](../nix/home/gui/browser/firefox.nix#L98)

### [userscripts](../nix/home/gui/browser/firefox-test.nix#L15)

## applets

- downdetector
  - `javascript:window.open(location.href.replace(/^(https?:\/\/)/i, "https://check-host.net/check-ping?host=$1"), "_blank")`
- WebArchive
  - `javascript:window.open(location.href.replace(/^(https?:\/\/)/i, "https://web.archive.org/web/0/$1"), "_blank")`
- Reddit undelete
  - `javascript:window.open(location.href.replace(/:\/\/([\w-]+.)?(reddit\.com\/r|reveddit\.com\/v)\//i, "://undelete.pullpush.io/r/"), "_blank")`
- Shikimori to `yummy-anime.ru`
  - `javascript:window.open(location.href.replace(/https:\/\/shiki\.one\/animes\/\w?\d*-/i, "https://yummy-anime.ru/search?word="), "_blank")`
- <https://www.syncwithtech.org/github-repos-size-creation-date/#bookmarklet>
- frameless window
  - `javascript:window.open(location.href, '_blank', 'menubar=no,location=no,status=no,toolbar=no')`
