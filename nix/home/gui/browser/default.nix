{ lib, ... }:
{
  imports = [
    ./chromium.nix
    ./firefox.nix
  ];
  xdg.mimeApps =
    let
      mappedDefaults =
        lib.genAttrs
          [
            # "x-scheme-handler/about"
            # "x-scheme-handler/unknown"
            "application/pdf"
            "application/x-extension-htm"
            "application/x-extension-html"
            "application/x-extension-shtml"
            "application/x-extension-xht"
            "application/x-extension-xhtml"
            "application/xhtml+xml"
            "text/html"
            "x-scheme-handler/chrome"
            "x-scheme-handler/http"
            "x-scheme-handler/https"
          ]
          (key: [
            "firefox.desktop"
            # "microsoft-edge.desktop"
            # "com.microsoft.Edge.desktop"
            "brave-browser.desktop"
            "com.brave.Browser.desktop"
          ]);
    in
    {
      defaultApplications = mappedDefaults;
      associations.added = mappedDefaults;
    };
}
