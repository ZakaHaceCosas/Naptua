# Naptua
Like Napture, but in Lua!

<div align="center">
<img src="https://raw.githubusercontent.com/ZakaHaceCosas/Naptua/main/broIsBeingToldWelcomeByNaplua.png" width=400 />
<img src="https://raw.githubusercontent.com/ZakaHaceCosas/Naptua/main/broUsesLightMode.png" width=400 />
<img src="https://raw.githubusercontent.com/ZakaHaceCosas/Naptua/main/developerHatesCommonJs.png" width=400 />
</div>

> [!NOTE]
> This is a work in progress. Many features are not done and it's not yet "usable".

> [!WARNING]
> TERRIBLE CODE WARNING

A WebX browser made for Windows with exclusive developer tools such as built-in documentation, Naptua RawInspect, and Naptua Deproin!

### PROS and CONS of NAPTUA

| PROS 🙂 | CONS 💀 |
| ---- | ---- |
| Has many tools for developers | Mostly unfinished |
| Less broken on Windows than Napture | Uses Windows native GUI without styling |
| Written in a language that makes it easy to work with | Code is not so good, though |
| Custom rendering engine | (Not really a custom rendering engine) |
| ... | Broken (mostly) |
| ... | (for now) requires self compiling (downloading the framework) |

As said, **it is not finished**, so don't expect it to work properly and don't get surpirsed by it having more cons than pros. It's a two day project and a messy code. Later I'll take my time to clean it.

### FEATURES:

Both implemented ones and WIPs

> - [ ] Rendering
>     - [X] Nafart (MS) rendering
>         - [ ] Styling load
>         - [ ] Script load
>     - [ ] Nart (NATIVE) Rendering
>         - [ ] HTML#
>             - [ ] WebX User-Agent propietary implementation
>         - [ ] CSS 4
>         - [ ] LuaRT support (of course limited access to avoid `sys.Directory("C:\Windows\system32\"):remove()`)
> - [ ] Developer Tools
>     - [X] Naptua Logs
>         - [ ] Make Naptua Logs better
>     - [ ] Naptua WebX API
>         - [X] Reference
>         - [ ] Built-in Toolkit
>         - [ ] [WebX Plus DNS support](https://github.com/webx-plus)
>         - [ ] Naptua Registrar
>     - [ ] Naptua Docs
>         - [X] WebX Docs Built-in
>         - [ ] WXE
>     - [ ] Inspectioning
>         - [ ] Naptua RawInspect
>             - [ ] Syntax Highlighting
>             - [ ] Saving files ("implemented", but broken so doesn't work)
>             - [ ] Saving each file individually
>         - [X] Naptua Inpsector
>             - [X] Same features as RawInspect
>               - [ ] Same features as RawInspect with planned features
>             - [ ] Interactive WebView-like inspecting
>             - [ ] Interactive WebView-like local editing
>         - [X] Naptua Deproin
>             - [ ] Finishing it
>             - [ ] (i gotta think how to make it better)
> - [ ] User customisation
>     - [X] Light and dark mode
>     - [ ] Preferred DNS
>     - [ ] UI language (I will only add Spanish (my native lang) and English (mastered). Other langs will rely on this repo or just never get added lol.)

### HOW TO RUN

- Download the [LuaRT](https://luart.org/doc/install.html) framework
- Clone this repo and `cd` into it.
- Run `wluart main.wlua`.
- Naptua will open. **Warning for developers: defaults to light mode**.

### KNOWN BUGS

(writing this kind of things is when you realise how good / bad of a developer you are)

- When rendering with Nafart, any interaction with the search bar crashes the program. When it is the WebX documentation, the topbar / action menu makes it crash aswell.
- CSS not loaded by Nafart.
- DNS cache limited to 5 entries (if more, sometimes JSON gets cropped for unknown reasons).
- Entering a `buss://` URL in the search bar crashes the program.
- ~~Some websites do not open, return a Lua error and crash the program. For example, [`buss://chat.dev`](https://github.com/TheAspectDev/webx-chat.lol) or [`fuckcommonjs.fr`](https://github.com/efekos/webx-fuckcommonjs).~~ **Fixed!**
- Clicking GO on an already loaded website (as [`chat.it`](https://github.com/PixelFacts/chatroom) somehow does work) crashes the program.

### CONTRIBUTING

Alright, I know this codebase sucks, but I do believe I can get this to work. Obviusly, I won't _actively_ develop it, but won't let it abandoned either and will actually check PRs as soon as I receive them. So if you do also have faith that this "thing" can get somewhere, feel free to make any contribution! Thanks.

Made by Zaka with pure hate towards HTTP* and pure reconsidering too many things about life :]

> * spent more time getting that f^cking thing to work and fetch WebX sites than writing all the rest of the program - and still doesnt work
