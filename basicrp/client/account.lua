
-- =========================================================
-- KCD:MP BASICRP - ACCOUNT GUI
-- Registration / Login
-- MySQL authentication through existing BasicRP server code
-- =========================================================

local mode = nil
local password = ""
local confirmPassword = ""
local activeField = 1
local waiting = false
local authOpened = false

local MAX_LENGTH = 32
local MIN_LENGTH = 4

-- =========================================================
-- REGULAMIN - EDYTUJ W TYM MIEJSCU
-- =========================================================

local RULES_TITLE = "REGULAMIN SERWERA"

local RULES = {
    "1. Szanuj innych graczy i administracje.",
    "2. Zakaz cheatowania i wykorzystywania bledow.",
    "3. Przestrzegaj zasad RolePlay.",
    "4. Nie przeszkadzaj innym w rozgrywce.",
    "5. Nie wykorzystuj bugow serwera.",
    "6. Stosuj sie do polecen administracji."
}

local RULES_FOOTER =
    "Rejestrujac konto, akceptujesz regulamin serwera."

-- =========================================================
-- WYGLAD
-- =========================================================

local W = 820
local X, Y, H = 0, 0, 0

local GOLD = COLOR_GOLD
local WHITE = COLOR_WHITE
local GREY = 0xA0A0A0
local DARK = 0x111111
local PANEL = 0x24211C
local FIELD = 0x292929
local BUTTON = 0x765326

local function playerName()
    return GetPlayerName() or "Unknown"
end

local function charCount(s)
    if utf8 and utf8.len then
        local n = utf8.len(s)
        if n then return n end
    end
    return #s
end

local function mask(s)
    return string.rep("*", charCount(s))
end

local function note(s)
    if mode then
        SetUiText("acc_note", s or "")
    end
end

local function removeLastChar(s)
    local i = #s

    while i > 0 do
        local b = s:byte(i)
        if b < 128 or b > 191 then break end
        i = i - 1
    end

    if i <= 0 then return "" end
    return s:sub(1, i - 1)
end

local function rect(id, x, y, w, h, color, alpha)
    CreateUiRect(id, x, y, w, h, color, alpha, "acc")
end

local function label(id, x, y, text, color, scale, align)
    CreateUiText(
        id, x, y, text, color, scale,
        align or UI_ALIGN_CENTRE, "acc"
    )
end

local function button(id, x, y, w, h, text, selected)
    rect(
        id .. "_bg",
        x, y, w, h,
        selected and 0x765326 or 0x292929,
        100
    )

    rect(
        id .. "_top",
        x, y, w, 2,
        selected and GOLD or 0x555555,
        100
    )

    label(
        id .. "_text",
        x + w / 2,
        y + h / 2 - 9,
        text,
        selected and GOLD or WHITE,
        0.85
    )
end

local function drawFields()
    local fieldY = mode == "register" and Y + 445 or Y + 255

    SetUiText(
        "acc_password",
        (activeField == 1 and "> " or "  ") ..
        "HASLO: " .. mask(password) ..
        (activeField == 1 and "_" or "")
    )

    if mode == "register" then
        SetUiText(
            "acc_confirm",
            (activeField == 2 and "> " or "  ") ..
            "POWTORZ HASLO: " .. mask(confirmPassword) ..
            (activeField == 2 and "_" or "")
        )
    end
end

-- =========================================================
-- BUDOWANIE OKNA
-- =========================================================

local function build()
    local sw = GetScreenSize()

    H = mode == "register" and 720 or 540
    X = math.floor((sw - W) / 2)
    Y = math.floor((1080 - H) / 2)

    DestroyUiElement("acc")
    CreateUiClip("acc")

    -- Tlo i obramowanie
    rect("acc_bg", X, Y, W, H, DARK, 96)
    rect("acc_top", X, Y, W, 3, GOLD, 100)
    rect("acc_bottom", X, Y + H - 3, W, 3, GOLD, 100)

    -- Naglowek
    label(
        "acc_title",
        X + W / 2,
        Y + 24,
        "KINGDOM COME",
        GOLD,
        1.35
    )

    label(
        "acc_subtitle",
        X + W / 2,
        Y + 65,
        "SYSTEM KONTA SERWERA",
        WHITE,
        0.75
    )

    -- Zakladki
    button(
        "acc_tab_register",
        X + 55, Y + 105, 340, 48,
        "REJESTRACJA",
        mode == "register"
    )

    button(
        "acc_tab_login",
        X + 425, Y + 105, 340, 48,
        "LOGOWANIE",
        mode == "login"
    )

    -- Nick - tylko do odczytu
    rect(
        "acc_name_bg",
        X + 85, Y + 170, W - 170, 55,
        0x303030, 100
    )

    label(
        "acc_name_label",
        X + W / 2,
        Y + 178,
        "NICK KCD:MP - NIE MOZNA GO ZMIENIC",
        GREY,
        0.62
    )

    label(
        "acc_name",
        X + W / 2,
        Y + 198,
        playerName(),
        GOLD,
        0.9
    )

    -- Regulamin tylko podczas rejestracji
    if mode == "register" then
        rect(
            "acc_rules_bg",
            X + 65, Y + 245, W - 130, 180,
            PANEL, 100
        )

        label(
            "acc_rules_title",
            X + W / 2,
            Y + 255,
            RULES_TITLE,
            GOLD,
            0.85
        )

        for i, rule in ipairs(RULES) do
            label(
                "acc_rule_" .. i,
                X + 95,
                Y + 282 + ((i - 1) * 21),
                rule,
                WHITE,
                0.65,
                UI_ALIGN_LEFT
            )
        end

        label(
            "acc_rules_footer",
            X + W / 2,
            Y + 405,
            RULES_FOOTER,
            GOLD,
            0.62
        )
    end

    -- Pola hasla
    local fieldY = mode == "register" and Y + 445 or Y + 255

    rect(
        "acc_password_bg",
        X + 85, fieldY, W - 170, 50,
        FIELD, 100
    )

    label(
        "acc_password_title",
        X + 110,
        fieldY + 8,
        "HASLO",
        GREY,
        0.55,
        UI_ALIGN_LEFT
    )

    CreateUiText(
        "acc_password",
        X + W / 2,
        fieldY + 27,
        "",
        WHITE, 0.78,
        UI_ALIGN_CENTRE,
        "acc"
    )

    if mode == "register" then
        rect(
            "acc_confirm_bg",
            X + 85, fieldY + 65, W - 170, 50,
            FIELD, 100
        )

        label(
            "acc_confirm_title",
            X + 110,
            fieldY + 73,
            "POWTORZ HASLO",
            GREY,
            0.55,
            UI_ALIGN_LEFT
        )

        CreateUiText(
            "acc_confirm",
            X + W / 2,
            fieldY + 92,
            "",
            WHITE, 0.78,
            UI_ALIGN_CENTRE,
            "acc"
        )
    end

    -- Przycisk zatwierdzenia
    local buttonY = mode == "register" and Y + 575 or Y + 345

    button(
        "acc_submit",
        X + 220, buttonY, 380, 48,
        mode == "register" and "UTWORZ KONTO" or "ZALOGUJ SIE",
        true
    )

    -- Komunikaty
    local noteY = mode == "register" and Y + 642 or Y + 410
    local hintY = mode == "register" and Y + 675 or Y + 460

    label(
        "acc_note",
        X + W / 2,
        noteY,
        "",
        COLOR_YELLOW,
        0.68
    )

    label(
        "acc_hint",
        X + W / 2,
        hintY,
        "TAB - zmiana pola | ENTER - zatwierdz | ESC - wyjdz",
        GREY,
        0.58
    )

    drawFields()
end

-- =========================================================
-- OTWIERANIE / ZAMYKANIE
-- =========================================================

local function open(k, message)
    if k ~= "register" and k ~= "login" then return end

    mode = k
    password = ""
    confirmPassword = ""
    activeField = 1
    waiting = false
    authOpened = true

    build()

    note(message or "")

    SetKeyboardCapture(true)
    SetCursorShown(true)
end

local function close()
    if not mode then return end

    mode = nil
    password = ""
    confirmPassword = ""
    waiting = false

    DestroyUiElement("acc")

    SetCursorShown(false)
    SetKeyboardCapture(false)
end

-- =========================================================
-- WYSYLANIE DO SERWERA
-- =========================================================

local function submit()
    if not mode or waiting then return end

    if charCount(password) < MIN_LENGTH then
        note("Haslo musi miec minimum 4 znaki.")
        return
    end

    if charCount(password) > MAX_LENGTH then
        note("Haslo moze miec maksymalnie 32 znaki.")
        return
    end

    if mode == "register" then
        if charCount(confirmPassword) == 0 then
            activeField = 2
            drawFields()
            note("Powtorz haslo.")
            return
        end

        if password ~= confirmPassword then
            confirmPassword = ""
            activeField = 2
            drawFields()
            note("Hasla nie sa identyczne!")
            return
        end
    end

    SendServerEvent("auth_" .. mode, password)

    waiting = true
    note(mode == "register"
        and "Tworzenie konta..."
        or "Sprawdzanie hasla...")

    Script.SetTimer(10000, function()
        if waiting and mode then
            waiting = false
            note("Brak odpowiedzi serwera. Sprobuj ponownie.")
        end
    end)
end

-- =========================================================
-- ZMIANA TRYBU
-- =========================================================

local function switchMode(k)
    if not mode or waiting then return end
    if k ~= "register" and k ~= "login" then return end

    if mode == k then return end

    mode = k
    password = ""
    confirmPassword = ""
    activeField = 1
    waiting = false

    build()
    note(k == "register"
        and "Wybierz haslo i zaakceptuj regulamin."
        or "Wpisz haslo do swojego konta.")
end

-- =========================================================
-- KLIKANIE MYSZA
-- =========================================================

function OnCursorClick(buttonName, x, y)
    if not mode then
        if nextCursor then return nextCursor(buttonName, x, y) end
        return
    end

    if buttonName ~= "left" or waiting then return end

    -- Zakladka rejestracji
    if x >= X + 55 and x <= X + 395
       and y >= Y + 105 and y <= Y + 153 then
        switchMode("register")
        return
    end

    -- Zakladka logowania
    if x >= X + 425 and x <= X + 765
       and y >= Y + 105 and y <= Y + 153 then
        switchMode("login")
        return
    end

    local fieldY = mode == "register" and Y + 445 or Y + 255

    -- Pole hasla
    if x >= X + 85 and x <= X + W - 85
       and y >= fieldY and y <= fieldY + 50 then
        activeField = 1
        drawFields()
        return
    end

    -- Pole powtorzenia hasla
    if mode == "register"
       and x >= X + 85 and x <= X + W - 85
       and y >= fieldY + 65 and y <= fieldY + 115 then
        activeField = 2
        drawFields()
        return
    end

    -- Przycisk zatwierdzenia
    local buttonY = mode == "register" and Y + 575 or Y + 345

    if x >= X + 220 and x <= X + 600
       and y >= buttonY and y <= buttonY + 48 then
        submit()
        return
    end
end

-- =========================================================
-- KLAWIATURA
-- =========================================================

local nextEvent = OnServerEvent
local nextKey = OnKey
local nextText = OnTextInput
local nextCursor = OnCursorClick

function OnServerEvent(name, payload)
    if name ~= "auth" then
        if nextEvent then return nextEvent(name, payload) end
        return
    end

    payload = payload or ""

    local k, message = payload:match("^(%a+);?(.*)$")

    if k == "close" then
        close()
        return
    end

    if k == "register" or k == "login" then
        open(k, message)
        return
    end
end

function OnKey(key, pressed)
    if not mode then
        if nextKey then return nextKey(key, pressed) end
        return
    end

    if not pressed then return end

    if key == "escape" then
        QuitGame()
        return
    end

    if waiting then return end

    if key == "tab" then
        if mode == "register" then
            activeField = activeField == 1 and 2 or 1
            drawFields()
        end
        return
    end

    if key == "enter" or key == "np_enter" then
        if mode == "register" and activeField == 1 then
            activeField = 2
            drawFields()
            note("Powtorz haslo.")
        else
            submit()
        end
        return
    end

    if key == "backspace" then
        if activeField == 1 then
            password = removeLastChar(password)
        elseif mode == "register" then
            confirmPassword = removeLastChar(confirmPassword)
        end

        drawFields()
        return
    end
end

function OnTextInput(text)
    if not mode then
        if nextText then return nextText(text) end
        return
    end

    if waiting or not text or text:find("%s") then return end

    if activeField == 1 then
        if charCount(password) + charCount(text) <= MAX_LENGTH then
            password = password .. text
        end
    elseif mode == "register" then
        if charCount(confirmPassword) + charCount(text) <= MAX_LENGTH then
            confirmPassword = confirmPassword .. text
        end
    end

    drawFields()
end

-- =========================================================
-- ODPORNE ZGLOSZENIE GOTOWOSCI
-- Kilka prob, gdyby pierwsze auth_ready dotarlo przed
-- utworzeniem danych gracza po stronie serwera.
-- =========================================================

local readyAttempts = 0

local function announceReady()
    if authOpened or readyAttempts >= 20 then return end

    readyAttempts = readyAttempts + 1
    SendServerEvent("auth_ready", "")

    Script.SetTimer(1000, announceReady)
end

announceReady()
