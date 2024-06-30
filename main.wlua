-- REQUIRES
local ui = require("ui")                  -- graphical User Interface
local win = ui.Window("Naptua", "single") -- single = fixed + minimizable
local crypto = require("crypto")          -- we'll use this later
local net = require("net")                -- networking
local json = require("json")              -- javashit object notation

-- SETUP SYSTEM FILES
-- NAPTUA LOGS
LOGS = sys.File("logs.naptua")
if not LOGS.exists == true then
    LOGS:open("write", "utf8")
    LOGS:close()
end

function LogToNaptuaLogs(content)
    LOGS:open("append", "utf8")
    LOGS:writeln(sys.Datetime().date .. " " .. sys.Datetime().time .. " " .. tostring(content))
    LOGS:close()
end

function ErrorAndLog(message)
    ui.error(message)
    LogToNaptuaLogs("ERROR: " .. message)
end

-- NAPTUA DNS CACHE
CACHE = sys.File("cache.naptua.json")
if not CACHE.exists == true then
    CACHE:open("write", "utf8")
end
CACHE:close()

-- NAPTUA SETTINGS
SETTINGS = sys.File("preferences.naptua")

if not SETTINGS.exists == true then
    SETTINGS:open("write", "utf8")
    SETTINGS:write([[
THEME[light]
DNS[webx]
]])
    SETTINGS:close()
end

-- WEBSITE STUFF
WEBXITE = {
    title = nil,                     -- website title
    markup_present = nil,            -- if HTML++ was loaded
    styles_present = nil,            -- if CSS 3.25 was loaded
    script_present = nil,            -- if Luau was loaded
    nart_markup_compatibility = nil, -- if markup matches the Nart specification
    nart_makeup_compatibility = nil, -- if makeup matches the Nart specification
    nart_script_compatibility = nil, -- if script matches the Nart specification
    author = nil,                    -- website author
    description = nil,               -- website description
    developer_warns = nil,           -- amount of warnings
    developer_erros = nil,           -- amount of errors
    remote = nil,                    -- site ip
}

-- WINDOW PROPERTIES
-- and
-- WINDOW DEFINITION
SETTINGS:open("read")
local prefs = SETTINGS:read()
local theme = prefs:match("THEME%[(.-)%]")
SETTINGS:close()

local windowprops = {
    width = 1180,
    height = 800,
    title = "Naptua",
    theme = theme,
    isInHome = true
}

win.title = windowprops.title
win.width = windowprops.width
win.height = windowprops.height
ui.theme = windowprops.theme


-- ITEMS
local groupboxWidth = windowprops.width - 40
local groupbox = ui.Groupbox(win, "Naptua", 20, 10, groupboxWidth, 55)
local searchBar = ui.Entry(groupbox, "", 10, 20, (groupboxWidth - 120), 20)
searchBar.tooltip = "Enter a URL"
searchBar.textalign = "center"
local goButton = ui.Button(groupbox, "GO", (groupboxWidth - 100), 20, 40, 22)
local returnButton = ui.Button(groupbox, "HOME", (groupboxWidth - 50), 20, 40, 22)
local panel = ui.Panel(win, 10, 70, (windowprops.width - 20), (windowprops.height - 100))
panel.border = true
function RenderPage(p)
    if p == "home" then
        local welcome = ui.Label(panel, "Welcome to Naptua!", ((windowprops.width / 2) - 200),
            ((windowprops.height / 2) - 150))
        welcome.textalign = "center"
        welcome.fontsize = 30
        welcome.fontstyle = { ["italic"] = true, ["bold"] = false }
        welcome.fgcolor = 0x9BF4FF
        local welcome2 = ui.Label(panel,
            "Use the top search bar to search! Note that this is an in-dev browser and not all WebX sites get indexed yet",
            ((windowprops.width / 2) - 450), ((windowprops.height / 2) - 100))
        welcome2.textalign = "center"
        welcome2.fontsize = 15
        welcome2.fontstyle = { ["italic"] = true, ["bold"] = false }
        welcome2.fgcolor = 0x9BF4FF
    elseif p == "settings" then
        -- coming soon
    end
end

RenderPage("home")

-- TOPBAR MENU
win.menu = ui.Menu()
local Options = win.menu:insert(1, "Options", ui.Menu("Save page's content...", "Change theme", "About", "Quit"))
local DevOptions = win.menu:insert(2, "Developer tools",
    ui.Menu("Open Naptua Logs", "Open WebX DNS Toolkit", "Open official WebX Documentation", "Open WXE (Coming soon...)",
        "See raw files", "Inspect website", "Open Nafart WebView Inspector"))
function Options.submenu:onClick(item)
    if item.text == "Save page's content..." then
        if windowprops.isInHome == true then
            ui.warn("Not in a website! Cannot save")
        else
            local dir = ui.dirdialog("Please select a folder to save this site")
            if dir ~= nil then
                local path = dir.fullpath
                local CHTML = sys.File("index.html")
                local NHTML = CHTML:copy("saved-index.html")
                local CCSS = sys.File("style.css")
                local NCSS
                if not CCSS:open("read") then
                    local CCSS2 = sys.File("styles.css")
                    if not CCSS2:open("read") then
                        -- no action
                    else
                        NCSS = CCSS2:copy("saved-styling.css")
                    end
                else
                    NCSS = CCSS:copy("saved-styling.css")
                end
                local CLUA = sys.File("script.lua")
                local NLUA
                if not CLUA:open("read") then
                    local CLUA2 = sys.File("main.lua")
                    if not CLUA2:open("read") then
                        -- no action
                    else
                        NLUA = CLUA2:copy("saved-script.lua")
                    end
                else
                    NLUA = CLUA:copy("saved-script.lua")
                end
                NHTML:move(path)
                if NCSS then
                    NCSS:move(path)
                end
                if NLUA then
                    NLUA:move(path)
                end
                win:status("Saving page to " .. path)
            end
        end
    elseif item.text == "Change theme" then
        if ui.theme == "dark" then
            ui.theme = "light"
            SETTINGS:open("write", "utf8")
            SETTINGS:write([[
THEME[light]
DNS[webx]
]])
            LogToNaptuaLogs("Changed to light theme")
            SETTINGS:close()
        else
            ui.theme = "dark"
            SETTINGS:open("write", "utf8")
            SETTINGS:write([[
THEME[dark]
DNS[webx]
]])
            LogToNaptuaLogs("Changed to dark theme")
            SETTINGS:close()
        end
    elseif item.text == "About" then
        local aboutModal = ui.Window("About", "fixed", 300, 250)
        aboutModal.title = "About"
        aboutModal:show()
        local aboutLabel = ui.Label(aboutModal, "Naptua", ((aboutModal.width / 2) - 60), 20)
        aboutLabel.fontsize = 22
        aboutLabel.textalign = "center"
        aboutLabel.fontstyle = { ["bold"] = true }
        local otherLabel = ui.Label(aboutModal, "Like Napture, but in Lua!", ((aboutModal.width / 2) - 80), 60)
        otherLabel.fontsize = 10
        otherLabel.textalign = "center"
        local thirdLabel = ui.Label(aboutModal, "Made by ZakaHaceCosas, documenter of WebX",
            ((aboutModal.width / 2) - 120), 100)
        thirdLabel.fontsize = 8
        thirdLabel.textalign = "center"
        local fourthlabel = ui.Label(aboutModal,
            "The only WebX browser with inspect tools!",
            ((aboutModal.width / 2) - 115), 150)
        fourthlabel.fontsize = 8
        fourthlabel.textalign = "center"

        local fifthlabel = ui.Label(aboutModal,
            "Only WebX browser with built-in docs!",
            ((aboutModal.width / 2) - 100), 165)
        fifthlabel.fontsize = 8
        fifthlabel.textalign = "center"

        local sixthlabel = ui.Label(aboutModal,
            "Windows compatible (for real)!",
            ((aboutModal.width / 2) - 90), 180)
        sixthlabel.fontsize = 8
        sixthlabel.textalign = "center"

        local seventhlabel = ui.Label(aboutModal,
            "Naptua v0.0.2 and NART v1 and NAFART v1",
            ((aboutModal.width / 2) - 120), 210)
        seventhlabel.fontsize = 8
        seventhlabel.textalign = "center"
    elseif item.text == "Quit" then
        win.visible = false
    end
end

function GetSourceCode(what)
    if what == "html" then
        local f = sys.File("index.html")
        local c = f:open("read"):read()
        return c
    elseif what == "css" then
        local f = sys.File("style.css")
        if f.exists == true then
            local c = f:open("read")
            return c:read()
        else
            local f2 = sys.File("styles.css")
            if f2.exists == true then
                local c2 = f2:open("read")
                return c2:read()
            else
                return "Not provided."
            end
        end
    elseif what == "lua" then
        local f = sys.File("script.lua")
        if f.exists == true then
            local c = f:open("read")
            return c:read()
        else
            local f2 = sys.File("main.lua")
            if f2.exists == true then
                local c2 = f2:open("read")
                return c2:read()
            else
                return "Not provided."
            end
        end
    end
end

function DevOptions.submenu:onClick(item)
    if item.text == "Open Naptua Logs" then
        local naptuaLogs = ui.Window("Naptua Logs", "single")
        naptuaLogs.title = "Naptua Logs"
        naptuaLogs:show()
        LOGS:open()
        local content = LOGS:read()
        LOGS:close()
        local edit = ui.Edit(naptuaLogs, content, 10, 10, (naptuaLogs.width - 20), (naptuaLogs.height - 20))
        edit.wordwrap = true
        edit.border = false
        edit.readonly = true
    elseif item.text == "Open WebX DNS Toolkit" then
        local naptuaLogs = ui.Window("Naptua Webx DNS Toolkit", "single")
        naptuaLogs.title = "Naptua Webx DNS Toolkit"
        naptuaLogs:show()
        CACHE:open()
        local content = CACHE:read()
        CACHE:close()
        local tabs = ui.Tab(naptuaLogs, { "Naptua DNS cache", "WebX DNS API Reference" }, 10, 10, (naptuaLogs.width - 20),
            20)

        local edit = ui.Edit(naptuaLogs, content, 10, 40, (naptuaLogs.width - 20), (naptuaLogs.height - 50))
        edit.wordwrap = true
        edit.border = false
        edit.readonly = true
        edit.visible = true

        local othercontent = [[
        How to work around with the WebX DNS API (v0.3.0)

        ENDPOINTS:
        - [GET] /domains
        - [GET] /domain/{name}/{tld}
        - [POST] /domain
        - [PUT] /domain/{key}
        - [DELETE] /domain/{key}
        - [GET] /tlds

        RATELIMITS:
        - [POST] /domain - 5 requests per 10 minutes

        SOURCE CODE:
        - https://github.com/face-hh/webx/tree/master/dns

        DOCUMENTATION (OFFICIAL) (WWW):
        https://facedev.gitbook.io/bussin-web-x-how-to-make-a-website/for-developers/api-reference
        ]]

        local otheredit = ui.Edit(naptuaLogs, othercontent, 10, 40, (naptuaLogs.width - 20), (naptuaLogs.height - 50))
        otheredit.wordwrap = true
        otheredit.border = false
        otheredit.readonly = true
        otheredit.visible = false

        function tabs:onSelect(item)
            if item.text == "Naptua DNS cache" then
                edit.visible = true
                otheredit.visible = false
            elseif item.text == "WebX DNS API Reference" then
                edit.visible = false
                otheredit.visible = true
            end
        end
    elseif item.text == "Open official WebX Documentation" then
        require("webview")
        local webview = ui.Webview(panel, "https://facedev.gitbook.io")
        webview.align = "all"
        win:status("Connected to the World Wide Web via HTTPS & MS EDGE WebView2. Accessing to the WebX documentation.")
    elseif item.text == "See raw files" then
        if not windowprops.isInHome then
            local inspection = ui.Window("Naptua RawInspect", "single")
            inspection.title = "Naptua RawInspect"
            inspection:show()
            local tabs = ui.Tab(inspection, { "HTML++", "CSS 3.25", "Luau" }, 10, 10,
                (inspection.width - 20),
                20)
            local htmlpp = ui.Edit(inspection, tostring(GetSourceCode("html")), 10, 40, (inspection.width - 20),
                (inspection.height - 50))
            htmlpp.wordwrap = true
            htmlpp.border = false
            htmlpp.readonly = true
            htmlpp.visible = true

            local cssthreepointtwentyfive = ui.Edit(inspection, tostring(GetSourceCode("css")), 10, 40,
                (inspection.width - 20),
                (inspection.height - 50))
            cssthreepointtwentyfive.wordwrap = true
            cssthreepointtwentyfive.border = false
            cssthreepointtwentyfive.readonly = true
            cssthreepointtwentyfive.visible = false

            local luau = ui.Edit(inspection, tostring(GetSourceCode("lua")), 10, 40, (inspection.width - 20),
                (inspection.height - 50))
            luau.wordwrap = true
            luau.border = false
            luau.readonly = true
            luau.visible = false

            function tabs:onSelect(tab)
                if tab.text == "HTML++" then
                    htmlpp.visible = true
                    cssthreepointtwentyfive.visible = false
                    luau.visible = false
                elseif tab.text == "CSS 3.25" then
                    htmlpp.visible = false
                    cssthreepointtwentyfive.visible = true
                    luau.visible = false
                elseif tab.text == "Luau" then
                    htmlpp.visible = false
                    cssthreepointtwentyfive.visible = false
                    luau.visible = true
                end
            end
        end
    elseif item.text == "Inspect website" then
        if not windowprops.isInHome then
            local inspection = ui.Window("Naptua Inspector", "single")
            inspection.title = "Naptua Inspector"
            inspection:show()
            local tabs = ui.Tab(inspection, { "HTML++", "CSS 3.25", "Luau", "Naptua Deproin" }, 10, 10,
                (inspection.width - 20),
                20)
            local htmlpp = ui.Edit(inspection, tostring(GetSourceCode("html")), 10, 40, (inspection.width - 20),
                (inspection.height - 50))
            htmlpp.wordwrap = true
            htmlpp.border = false
            htmlpp.readonly = true
            htmlpp.visible = true

            local cssthreepointtwentyfive = ui.Edit(inspection, tostring(GetSourceCode("css")), 10, 40,
                (inspection.width - 20),
                (inspection.height - 50))
            cssthreepointtwentyfive.wordwrap = true
            cssthreepointtwentyfive.border = false
            cssthreepointtwentyfive.readonly = true
            cssthreepointtwentyfive.visible = false

            local luau = ui.Edit(inspection, tostring(GetSourceCode("lua")), 10, 40, (inspection.width - 20),
                (inspection.height - 50))
            luau.wordwrap = true
            luau.border = false
            luau.readonly = true
            luau.visible = false

            local deproinlblstepa = [[
NAPTUA DEveleoper PROperties INspector (DEPROIN)


]]

            local deproinlblstepb
            if WEBXITE.title then
                deproinlblstepb = "TITLE: " .. WEBXITE.title
            else
                deproinlblstepb = "TITLE: NOT PROVIDED or ERROR WHILE ACCESSING"
            end
            local deproinlblstepc
            if WEBXITE.remote then
                deproinlblstepc = "REMOTE URI: " .. WEBXITE.remote
            else
                deproinlblstepc = "REMOTE URI: NOT PROVIDED or ERROR WHILE ACCESSING"
            end
            local deproinlbl = deproinlblstepa .. deproinlblstepb .. "\n" .. deproinlblstepc

            local deproin = ui.Edit(inspection, deproinlbl, 10, 40, (inspection.width - 20),
                (inspection.height - 50))
            deproin.wordwrap = true
            deproin.border = false
            deproin.readonly = true
            deproin.visible = false

            function tabs:onSelect(tab)
                if tab.text == "HTML++" then
                    htmlpp.visible = true
                    cssthreepointtwentyfive.visible = false
                    luau.visible = false
                    deproin.visible = false
                elseif tab.text == "CSS 3.25" then
                    htmlpp.visible = false
                    cssthreepointtwentyfive.visible = true
                    luau.visible = false
                    deproin.visible = false
                elseif tab.text == "Luau" then
                    htmlpp.visible = false
                    cssthreepointtwentyfive.visible = false
                    luau.visible = true
                    deproin.visible = false
                elseif tab.text == "Naptua Deproin" then
                    htmlpp.visible = false
                    cssthreepointtwentyfive.visible = false
                    luau.visible = false
                    deproin.visible = true
                end
            end
        end
    end
end

-- WINDOW CREATION
function win:onClose()
    LogToNaptuaLogs("Naptua exited successfully")
end

win:show()
win:center()
LogToNaptuaLogs("Naptua started successfully")

-- MAIN SEARCH FUNCTIONS
-- SEARCH FUNCTION

-- [LEGACY SCRIPT 1]

function AccessRemote()
    CACHE:open()
    local data = CACHE:read()

    -- Si hay datos en la caché, devolverlos directamente
    if data and data ~= "" then
        CACHE:close()
        return data
    end

    -- Función para procesar y escribir los datos en la caché
    local function processAndCacheData(response)
        if response.status == 200 then
            local parsed = json.decode(response.content)
            if parsed then
                parsed.page = nil
                parsed.size = nil
                local filtered = { domains = parsed.domains }

                local encodedFiltered = json.encode(filtered)

                if encodedFiltered then
                    CACHE:open("write", "utf8")
                    CACHE:write(encodedFiltered)
                    data = encodedFiltered
                    CACHE:close()
                else
                    ErrorAndLog("Error encoding filtered data to JSON.")
                end
            else
                ErrorAndLog("Error parsing JSON from WebX DNS API.")
            end
        else
            ErrorAndLog("Received HTTP Status Code " .. tostring(response.status) .. " from WebX DNS API.")
        end
    end

    -- [LEGACY SCRIPTS 2, 3]

    local function fetchPage(pageNumber)
        local target = "/domains?page_size=5&page=" .. pageNumber
        net.Http("https://api.buss.lol"):get(target).after = function(client, response)
            processAndCacheData(response)
        end
    end

    local pageone = fetchPage(1)
    if pageone then
        LogToNaptuaLogs(pageone)
    else
        ErrorAndLog("Failed to fetch data")
    end
    LogToNaptuaLogs(pageone)
    local pagetwo = fetchPage(2)
    if pageone and pagetwo then
        for _, entry in ipairs(pagetwo.domains) do
            table.insert(pageone.domains, entry)
        end
    end
    -- LogToNaptuaLogs(json.encode(pageone))

    return data
end

-- NART rendering engine I guess
-- NA from NAPTUA / NAPTURE, RT from the framework (LuaRT)
-- what does rt stand for? no clue, no care

-- NOTE: Due to myself being impatient / lazy af and wanting to release this thing ASAP, first versions will use WebView2
-- and AT THE SAME TIME development of an actual rendering engine will be happening on nart.wlua

-- However "Nart" will get metadata an all that stuff
function PerformNartRendering(h, c, l)
    if h then
        local html = sys.File("index.html"):open("read"):read()
        local htmls = tostring(html)
        local tit = string.match(htmls, "<title>(.-)</title>")
        if tit then
            win.title = tit
            WEBXITE.title = tit
        end
        local nartMarkupCompat = string.match(htmls,
            '<meta webx-equiv=[\'"]YAP-UA-Compatible[\'"] content=[\'"]nart=(.-)[\'"]>')
        if nartMarkupCompat and nartMarkupCompat == "yap" then
            WEBXITE.nart_markup_compatibility = "YAP (Fully compatible)"
        elseif nartMarkupCompat and nartMarkupCompat == "nah" then
            WEBXITE.nart_markup_compatibility = "NAH (Compatibility specifications not met)"
        elseif nartMarkupCompat and nartMarkupCompat == "kyap" then
            WEBXITE.nart_markup_compatibility = "KYAP (Kinda compatible)"
        elseif not nartMarkupCompat then
            WEBXITE.nart_markup_compatibility =
            "NOT (Compatibility specifications' accomplishment not specified by developer)"
        end

        --[[
            for compat in string.match(h, '<meta http-equiv=[\'"]X-UA-Compatible[\'"] content=[\'"]WEBX=nart[\'"]>') do

            end
        ]]
    end

    require("webview")
    -- Nafart Engine = Naptua Fake RT engine
    local htmlpath = sys.File("index.html").fullpath
    local fakenartengine = ui.Webview(panel, "file://" .. htmlpath)
    function fakenartengine:onReady()
        fakenartengine.contextmenu = false
        fakenartengine.statusbar = false
        fakenartengine.acceleratorkeys = false
        fakenartengine.devtools = false
    end

    fakenartengine.align = "all"
    win:status("Connected to the WebX via local Nafart rendering. Accessing to " ..
        WEBXITE.title .. ", hosted on " .. WEBXITE.remote .. ".")
end

function Return()
    for _, element in ipairs(panel.childs) do
        element:hide()
    end

    searchBar.text = ""

    RenderPage("home")
end

-- GO TO URL FUNCTION
function GoToUrl(i, ip)
    windowprops.isInHome = false

    for _, element in ipairs(panel.childs) do
        element:hide()
    end

    searchBar.text = i

    if string.match(ip, "github") then
        local user = string.match(ip, "github%.com/([%w%-%_]+)/")
        LogToNaptuaLogs(user)
        local repo = string.match(ip, "github%.com/[%w%-%_]+/([%w%-%_]+)")
        LogToNaptuaLogs(repo)
        local baseuri = "https://raw.githubusercontent.com/"
        local acoplateduri = user .. "/" .. repo .. "/main"
        local uri = "https://raw.githubusercontent.com/" .. user .. "/" .. repo .. "/main" .. "/index.html"
        LogToNaptuaLogs(uri)
        local htmlclient, htmlresponse = await(net.Http(baseuri):download(acoplateduri .. "/index.html"))
        if htmlresponse then
            LogToNaptuaLogs("FETCHED " .. htmlresponse.file.name .. " FROM " .. baseuri .. acoplateduri)
        end

        local cssfilename
        local cssclient, cssresponse = await(net.Http(baseuri):download(acoplateduri .. "/style.css"))
        if cssresponse.file then
            LogToNaptuaLogs("FETCHED " .. cssresponse.file.name .. " FROM " .. baseuri .. acoplateduri)
            cssfilename = "style.css"
        else
            local cssclientsec, cssresponsesec = await(net.Http(baseuri):download(acoplateduri .. "/styles.css"))
            if cssresponsesec.file then
                LogToNaptuaLogs("FETCHED " .. cssresponsesec.file.name .. " FROM " .. baseuri .. acoplateduri)
                cssfilename = "styles.css"
            else
                ErrorAndLog("No CSS 3.25 found! Tried to fetch 'style.css', 'styles.css'. Fallback to built-in styles.")
            end
        end

        local luafilename
        local luaclient, luaresponse = await(net.Http(baseuri):download(acoplateduri .. "/script.lua"))
        if luaresponse.file then
            LogToNaptuaLogs("FETCHED " .. luaresponse.file.name .. " FROM " .. baseuri .. acoplateduri)
            luafilename = "script.lua"
        else
            local luaclientsec, luaresponsesec = await(net.Http(baseuri):download(acoplateduri .. "/main.lua"))
            if luaresponsesec.file then
                LogToNaptuaLogs("FETCHED " .. luaresponsesec.file.name .. " FROM " .. baseuri .. acoplateduri)
                luafilename = "main.lua"
            else
                ErrorAndLog("No Luau found! Tried to fetch 'script.lua', 'main.lua'. No script will be loaded.")
            end
        end

        local HTMLFILE = sys.File("index.html")
        local htmlpp
        if HTMLFILE.exists then
            HTMLFILE:open("read")
            htmlpp = HTMLFILE:read()
        else
            ErrorAndLog("This page does not have an index!")
            Return()
        end
        if cssfilename then
            local CSSFILE = sys.File(cssfilename)
            if CSSFILE.exists == true then
                CSSFILE:open("read")
                local cssthreepointtwentyfive = CSSFILE:read()
                if luafilename and sys.File(luafilename).exists == true then
                    local LUAFILE = sys.File(luafilename)
                    LUAFILE:open("read")
                    local luau = LUAFILE:read()
                    WEBXITE.remote = baseuri .. acoplateduri
                    PerformNartRendering(htmlpp, cssthreepointtwentyfive, luau)
                else
                    WEBXITE.remote = baseuri .. acoplateduri
                    PerformNartRendering(htmlpp, cssthreepointtwentyfive, nil)
                end
            else
                -- nothing
            end
        else
            WEBXITE.remote = baseuri .. acoplateduri
            PerformNartRendering(htmlpp, nil, nil)
        end
    else
        ErrorAndLog("Non-GitHub HTTP hosts are not supported yet. Could not access remote.")
    end
end

function Search(input)
    for _, element in ipairs(panel.childs) do
        element:hide()
    end

    local data = AccessRemote()

    if data then
        local jsonData = json.decode(data)
        if jsonData and jsonData.domains then
            local x = 10
            local query = input:lower()

            for _, domain in pairs(jsonData.domains) do
                local domainName = domain.name .. "." .. domain.tld
                local ip = domain.ip

                if domainName:lower():find(query, 1, true) then
                    local group = ui.Groupbox(panel, "Result", 20, x, (win.width - 100), 80)
                    local label = ui.Label(group, " " .. domainName .. " ", 10, 20)
                    label.fontsize = 22
                    label.tooltip = "buss://" .. domainName
                    label.fontstyle = { ["heavy"] = true, ["italic"] = true }
                    function group:onClick()
                        local url = "buss://" .. domainName
                        GoToUrl(url, ip)
                    end

                    function label:onClick()
                        local url = "buss://" .. domainName
                        GoToUrl(url, ip)
                    end

                    x = x + 80
                end
            end
        else
            if not CACHE or CACHE:open():read() == "" then
                local msg =
                "Warning: Domains cache not found. If this is the first time you run Naptua, try again and it should work."
                ErrorAndLog(msg)
            else
                local msg = "Error: Domains not found (or could not json.decode them)"
                ErrorAndLog(msg)
            end
        end
    else
        local msg = "Error: No data found in cache or response"
        ErrorAndLog(msg)
    end
end

-- BUTTON FUNCTION and ENTER KEY FUNCTION
function searchBar:onSelect()
    local i = searchBar.text

    if string.match(i, "^buss://") then
        GoToUrl(i, i)
    else
        Search(i)
    end
end

function goButton:onClick()
    local i = searchBar.text

    if string.match(i, "^buss://") then
        GoToUrl(i)
    else
        Search(i)
    end
end

function returnButton:onClick()
    Return()
end

ui.run(win):wait()

--[[while win.visible do
    ui.update()
end]]

repeat
    ui.update()
until not win.visible
