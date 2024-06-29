-- REQUIRES
local ui = require("ui")                  -- graphical User Interface
local win = ui.Window("Naptua", "single") -- single = fixed + minimizable
local crypto = require("crypto")          -- we'll use this later
local net = require("net")                -- networking
local json = require("json")              -- javashit object notation

-- NAPTUA LOGS
LOGS = sys.File("logs.naptua")
function LOG(content)
    LOGS:open("append", "utf8")
    LOGS:writeln(sys.Datetime().date .. " " .. sys.Datetime().time .. " " .. tostring(content))
    LOGS:close()
end

function ERROR(message)
    ui.error(message)
    LOG("ERROR: " .. message)
end

-- NAPTUA DNS CACHE
CACHE = sys.File("cache.naptua.json")
if not CACHE:open("read") then
    CACHE:open("write", "utf8")
end
CACHE:close()

-- NAPTUA SETTINGS
SETTINGS = sys.File("preferences.naptua")
local opened = SETTINGS:open("read", "utf8")

if not opened then
    SETTINGS = sys.File("preferences.naptua")
    SETTINGS:open("write", "utf8")
    SETTINGS:write([[
THEME[light]
DNS[webx]
]])
    SETTINGS:close()
else
    SETTINGS:open()
    local content = SETTINGS:read()
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
local theme

SETTINGS:open("read")
local prefs = SETTINGS:read()
SETTINGS:close()

theme = prefs:match("THEME%[(.-)%]")

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
local goButton = ui.Button(groupbox, "GO", (groupboxWidth - 100), 20, 80, 22)
local panel = ui.Panel(win, 10, 70, (windowprops.width - 20), (windowprops.height - 100))
panel.border = true

-- TOPBAR MENU
win.menu = ui.Menu()
local Options = win.menu:insert(1, "Options", ui.Menu("Save page's content...", "Change theme", "About", "Quit"))
local DevOptions = win.menu:insert(2, "Developer tools",
    ui.Menu("Open Naptua Logs", "Open WebX DNS Toolkit", "Open official WebX Documentation", "Open WXE (Coming soon...)",
        "See raw files", "Inspect website"))
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
            LOG("Changed to light theme")
            SETTINGS:close()
        else
            ui.theme = "dark"
            SETTINGS:open("write", "utf8")
            SETTINGS:write([[
THEME[dark]
DNS[webx]
]])
            LOG("Changed to dark theme")
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
            "Naptua v0.0.1 and NART v1",
            ((aboutModal.width / 2) - 80), 210)
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
        local c = f:open("read")
        if not c then
            local f2 = sys.File("styles.css")
            local c2 = f2:open("read")
            if not c2 then
                return "Not provided."
            else
                return c2:read()
            end
        else
            return c:read()
        end
    elseif what == "lua" then
        local f = sys.File("script.lua")
        local c = f:open("read")
        if not c then
            local f2 = sys.File("main.lua")
            local c2 = f2:open("read")
            if not c2 then
                return "Not provided."
            else
                return c2:read()
            end
        else
            return c:read()
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

            local deproinlblstepb = "TITLE: " .. WEBXITE.title .. "\n" .. "REMOTE URI: " .. WEBXITE.remote
            local deproinlbl = deproinlblstepa .. deproinlblstepb

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
    LOG("Naptua exited successfully")
end

win:show()
win:center()
LOG("Naptua started successfully")

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
    local function processAndCacheData(response, append)
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
                    ERROR("Error encoding filtered data to JSON.")
                end
            else
                ERROR("Error parsing JSON from WebX DNS API.")
            end
        else
            ERROR("Received HTTP Status Code " .. tostring(response.status) .. " from WebX DNS API.")
        end
    end

    -- [LEGACY SCRIPTS 2, 3]

    local function fetchPage(pageNumber)
        net.Http("https://api.buss.lol"):get("/domains?page_size=5&page=" .. pageNumber).after = function(client,
                                                                                                          response)
            processAndCacheData(response)
        end
    end

    local pageone = fetchPage(1)
    if pageone then
        LOG(pageone)
    else
        ERROR("Failed to fetch data")
    end
    LOG(pageone)
    local pagetwo = fetchPage(2)
    if pageone and pagetwo then
        for _, entry in ipairs(pagetwo.domains) do
            table.insert(pageone.domains, entry)
        end
    end
    -- LOG(json.encode(pageone))

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
        if nartMarkupCompat and nartMarkupCompat == "true" then
            WEBXITE.nart_markup_compatibility = "YEP"
        elseif nartMarkupCompat and nartMarkupCompat == "false" then
            WEBXITE.nart_markup_compatibility = "NAH"
        elseif nartMarkupCompat and nartMarkupCompat == "kinda" then
            WEBXITE.nart_markup_compatibility = "KYEP"
        elseif not nartMarkupCompat then
            WEBXITE.nart_markup_compatibility = "NOT"
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

-- GO TO URL FUNCTION
function GoToUrl(i, ip)
    windowprops.isInHome = false

    for _, element in ipairs(panel.childs) do
        element:hide()
    end

    searchBar.text = i

    if string.match(ip, "github") then
        local user = string.match(ip, "github%.com/([%w%-%_]+)/")
        LOG(user)
        local repo = string.match(ip, "github%.com/[%w%-%_]+/([%w%-%_]+)")
        LOG(repo)
        local baseuri = "https://raw.githubusercontent.com/"
        local acoplateduri = user .. "/" .. repo .. "/main"
        local uri = "https://raw.githubusercontent.com/" .. user .. "/" .. repo .. "/main" .. "/index.html"
        LOG(uri)
        local htmlclient, htmlresponse = await(net.Http(baseuri):download(acoplateduri .. "/index.html"))
        if htmlresponse then
            LOG("FETCHED " .. htmlresponse.file.name .. " FROM " .. baseuri .. acoplateduri)
        end

        local cssfilename
        local cssclient, cssresponse = await(net.Http(baseuri):download(acoplateduri .. "/style.css"))
        if cssresponse.file then
            LOG("FETCHED " .. cssresponse.file.name .. " FROM " .. baseuri .. acoplateduri)
            cssfilename = "style.css"
        else
            local cssclientsec, cssresponsesec = await(net.Http(baseuri):download(acoplateduri .. "/styles.css"))
            if cssresponsesec.file then
                LOG("FETCHED " .. cssresponsesec.file.name .. " FROM " .. baseuri .. acoplateduri)
                cssfilename = "styles.css"
            else
                ERROR("No CSS 3.25 found! Tried to fetch 'style.css', 'styles.css'. Fallback to built-in styles.")
            end
        end

        local luafilename
        local luaclient, luaresponse = await(net.Http(baseuri):download(acoplateduri .. "/script.lua"))
        if luaresponse.file then
            LOG("FETCHED " .. luaresponse.file.name .. " FROM " .. baseuri .. acoplateduri)
            luafilename = "script.lua"
        else
            local luaclientsec, luaresponsesec = await(net.Http(baseuri):download(acoplateduri .. "/main.lua"))
            if luaresponsesec.file then
                LOG("FETCHED " .. luaresponsesec.file.name .. " FROM " .. baseuri .. acoplateduri)
                luafilename = "main.lua"
            else
                ERROR("No Luau found! Tried to fetch 'script.lua', 'main.lua'. No script will be loaded.")
            end
        end

        local HTMLFILE = sys.File("index.html")
        HTMLFILE:open("read")
        local htmlpp = HTMLFILE:read()
        if cssfilename then
            local CSSFILE = sys.File(cssfilename)
            CSSFILE:open("read")
            local cssthreepointtwentyfive = CSSFILE:read()
            if luafilename then
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
            WEBXITE.remote = baseuri .. acoplateduri
            PerformNartRendering(htmlpp, nil, nil)
        end
    else
        ERROR("Non-GitHub HTTP hosts are not supported yet. Could not access remote.")
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
                ERROR(msg)
            else
                local msg = "Error: Domains not found (or could not json.decode them)"
                ERROR(msg)
            end
        end
    else
        local msg = "Error: No data found in cache or response"
        ERROR(msg)
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

ui.run(win):wait()

while win.visible do
    ui.update()
end
