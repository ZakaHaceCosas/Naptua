### CHANGELOG

#### 0.0.3

> Fixes:
- Fixed the way Naptua checks if cache file and settings file does exist.
- Home UI not getting re-rendered when clicking the "HOME" button.

> Enhancements:
- Now the Nafart Inspector (basically WebView2's inspection tool) is accessible.

> Developer enhancements:
- Renamed a few functions so it's more clear what they do.
- Added an array in-code for app versions at the top of the file, so there's no need to search for the "About" page's string to update versioning.

#### 0.0.2

> Fixes:
- Resolved crashes caused by `GetSourceCode` and `GoToUrl` functions when HTML++, CSS 3.25, or Lua files were absent.
- Fixed program crashes due to the code not being able to access "title" or "remote" `WEBXITE` parameters.

> Enhancements:
- Cleared search bar upon returning home (excluding instances where crashes occur; issues persist with Nafart/webview).
- Introduced a home button for easier navigation.
- Added "Welcome to Naplua" text with a slightly descriptive subtext.
- Incorporated Nafart version into the about section.
- UI rendering now utilizes Lua `repeat` instead of `while`.
- Made minor adjustments to the spec draft.

#### 0.0.1

first release lol
