
local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local TweenService = game:GetService("TweenService")
local UserInputService = game:GetService("UserInputService")
local RunService = game:GetService("RunService")
local Lighting = game:GetService("Lighting")
local HttpService = game:GetService("HttpService")
local Stats = game:GetService("Stats")

local LP = Players.LocalPlayer
if not LP then
    repeat
        task.wait(0.1)
        LP = Players.LocalPlayer
    until LP ~= nil
end
local PlayerGui = LP:WaitForChild("PlayerGui")

print("[BestClient] v10.13 · loading...")

local M = {
    alive = true,
    guis = {},
    conns = {},
    painters = {},
    themeListeners = {},
    binds = {},
}

local VERSION = {}
local WHITE = Color3.fromRGB(255, 255, 255)

local function track(conn)
    table.insert(M.conns, conn)
    return conn
end

local function new(class, props, parent)
    local inst = Instance.new(class)
    if props then
        for k, v in pairs(props) do
            inst[k] = v
        end
    end
    if parent then
        inst.Parent = parent
    end
    return inst
end

local function corner(inst, radius)
    local c = Instance.new("UICorner")
    c.CornerRadius = UDim.new(0, radius)
    c.Parent = inst
    return c
end

local function addStroke(inst, color, thickness, transparency)
    local s = Instance.new("UIStroke")
    s.Color = color
    s.Thickness = thickness or 1
    s.Transparency = transparency or 0
    s.Parent = inst
    return s
end

local function executor(name)
    local ok, fn = pcall(function()
        return rawget(_G, name)
    end)
    if ok and type(fn) == "function" then
        return fn
    end
    ok, fn = pcall(function()
        return getgenv()[name]
    end)
    if ok and type(fn) == "function" then
        return fn
    end
    return nil
end

-- ═══ UNINJECT ПРЕДЫДУЩЕЙ КОПИИ ═══
if _G.__BESTCLIENT_UNINJECT then
    pcall(_G.__BESTCLIENT_UNINJECT)
end
_G.__BestClientVersion = VERSION

-- ═══ СТАРЫЙ МУСОР ═══
do
    local restore = executor("restorefunction")
    if _G.__AUTOMATION_SILENT_OLD and restore then
        pcall(function()
            restore(_G.__AUTOMATION_SILENT_OLD)
        end)
    end
    _G.__AUTOMATION_SILENT_OLD = nil
    _G.__AUTOMATION_OLD_DRAWINGS = nil

    for _, obj in pairs(workspace:GetDescendants()) do
        if obj:IsA("Highlight") and (obj.Name:match("^ESP_") or obj.Name == "GunESP") then
            pcall(function()
                obj:Destroy()
            end)
        end
    end
    for _, name in ipairs({ "BestClientMenu", "BestClientNotifs", "BestClientWatermark",
                            "BestClientAdmin", "BestClientESP", "AutomationMenu", "AutomationNotifs" }) do
        local old = PlayerGui:FindFirstChild(name)
        if old then
            old:Destroy()
        end
    end
    for _, obj in pairs(workspace:GetChildren()) do
        if obj.Name == "HB_Real" or obj.Name:match("^HB_") then
            obj:Destroy()
        end
    end
end

-- ═══ CONFIG ═══
M.Config = {
    theme = "Midnight",
    activeTab = "esp",
    killauraMode = "medium",
    language = "ru",
    toggles = {},
    sliders = {},
    binds = {},
    windowPos = nil,
    watermark = { visible = true, pos = nil },
}

do
    local FILE = "best_client_v1.json"
    local writefile = executor("writefile")
    local readfile = executor("readfile")
    local isfile = executor("isfile")
    local delfile = executor("delfile")

    function M.saveConfig()
        if not writefile then
            return
        end
        local ok, encoded = pcall(function()
            return HttpService:JSONEncode(M.Config)
        end)
        if ok and type(encoded) == "string" then
            pcall(writefile, FILE, encoded)
        end
    end

    local scheduled = false
    function M.saveDebounced()
        if scheduled then
            return
        end
        scheduled = true
        task.delay(0.35, function()
            scheduled = false
            M.saveConfig()
        end)
    end

    function M.deleteConfig()
        if delfile then
            pcall(delfile, FILE)
        elseif writefile then
            pcall(writefile, FILE, "{}")
        end
    end

    if readfile and isfile then
        local okExists, exists = pcall(isfile, FILE)
        if okExists and exists then
            local okRead, content = pcall(readfile, FILE)
            if okRead and type(content) == "string" then
                local okDecode, data = pcall(function()
                    return HttpService:JSONDecode(content)
                end)
                if okDecode and type(data) == "table" then
                    local C = M.Config
                    if type(data.theme) == "string" then C.theme = data.theme end
                    if type(data.activeTab) == "string" then C.activeTab = data.activeTab end
                    if type(data.killauraMode) == "string" then C.killauraMode = data.killauraMode end
                    if type(data.language) == "string" then C.language = data.language end
                    if type(data.toggles) == "table" then C.toggles = data.toggles end
                    if type(data.sliders) == "table" then C.sliders = data.sliders end
                    if type(data.binds) == "table" then C.binds = data.binds end
                    if type(data.windowPos) == "table" then C.windowPos = data.windowPos end
                    if type(data.watermark) == "table" then
                        if type(data.watermark.visible) == "boolean" then
                            C.watermark.visible = data.watermark.visible
                        end
                        if type(data.watermark.pos) == "table" then
                            C.watermark.pos = data.watermark.pos
                        end
                    end
                end
            end
        end
    end
end

-- ═══ ТЕМЫ ═══
do
    local Themes = {
        Midnight = { title = "Полночь", preview = Color3.fromRGB(140, 110, 255),
            bg = Color3.fromRGB(14, 14, 20), bgDeep = Color3.fromRGB(9, 9, 14), bgLight = Color3.fromRGB(20, 20, 28),
            card = Color3.fromRGB(24, 24, 34), cardHover = Color3.fromRGB(34, 34, 46), cardActive = Color3.fromRGB(45, 40, 70),
            accent = Color3.fromRGB(140, 110, 255), accentSoft = Color3.fromRGB(180, 155, 255), accentDim = Color3.fromRGB(90, 70, 170),
            text = Color3.fromRGB(240, 240, 250), textDim = Color3.fromRGB(170, 170, 190), textMuted = Color3.fromRGB(105, 105, 125),
            success = Color3.fromRGB(85, 220, 130), danger = Color3.fromRGB(255, 90, 110), warning = Color3.fromRGB(255, 200, 80),
            info = Color3.fromRGB(90, 175, 255), stroke = Color3.fromRGB(45, 45, 60), strokeSoft = Color3.fromRGB(32, 32, 45) },
        Sakura = { title = "Сакура", preview = Color3.fromRGB(240, 130, 180),
            bg = Color3.fromRGB(22, 14, 20), bgDeep = Color3.fromRGB(16, 10, 14), bgLight = Color3.fromRGB(30, 20, 28),
            card = Color3.fromRGB(36, 24, 34), cardHover = Color3.fromRGB(48, 34, 44), cardActive = Color3.fromRGB(65, 40, 58),
            accent = Color3.fromRGB(240, 130, 180), accentSoft = Color3.fromRGB(255, 175, 210), accentDim = Color3.fromRGB(160, 80, 120),
            text = Color3.fromRGB(255, 240, 250), textDim = Color3.fromRGB(220, 180, 200), textMuted = Color3.fromRGB(145, 110, 130),
            success = Color3.fromRGB(120, 230, 160), danger = Color3.fromRGB(255, 100, 130), warning = Color3.fromRGB(255, 200, 120),
            info = Color3.fromRGB(130, 180, 255), stroke = Color3.fromRGB(60, 40, 52), strokeSoft = Color3.fromRGB(42, 28, 38) },
        Cyber = { title = "Киберпанк", preview = Color3.fromRGB(0, 240, 255),
            bg = Color3.fromRGB(8, 12, 20), bgDeep = Color3.fromRGB(4, 6, 12), bgLight = Color3.fromRGB(12, 18, 28),
            card = Color3.fromRGB(16, 24, 36), cardHover = Color3.fromRGB(22, 34, 48), cardActive = Color3.fromRGB(0, 50, 70),
            accent = Color3.fromRGB(0, 240, 255), accentSoft = Color3.fromRGB(100, 255, 255), accentDim = Color3.fromRGB(0, 140, 160),
            text = Color3.fromRGB(230, 250, 255), textDim = Color3.fromRGB(140, 200, 220), textMuted = Color3.fromRGB(70, 110, 130),
            success = Color3.fromRGB(0, 255, 140), danger = Color3.fromRGB(255, 60, 120), warning = Color3.fromRGB(255, 220, 60),
            info = Color3.fromRGB(0, 200, 255), stroke = Color3.fromRGB(0, 80, 100), strokeSoft = Color3.fromRGB(0, 45, 60) },
        Blood = { title = "Кровь", preview = Color3.fromRGB(220, 50, 60),
            bg = Color3.fromRGB(18, 10, 12), bgDeep = Color3.fromRGB(12, 6, 8), bgLight = Color3.fromRGB(24, 14, 18),
            card = Color3.fromRGB(32, 18, 22), cardHover = Color3.fromRGB(44, 26, 32), cardActive = Color3.fromRGB(60, 30, 40),
            accent = Color3.fromRGB(220, 50, 60), accentSoft = Color3.fromRGB(255, 100, 110), accentDim = Color3.fromRGB(140, 30, 40),
            text = Color3.fromRGB(255, 235, 240), textDim = Color3.fromRGB(220, 170, 180), textMuted = Color3.fromRGB(140, 100, 110),
            success = Color3.fromRGB(120, 230, 150), danger = Color3.fromRGB(255, 60, 80), warning = Color3.fromRGB(255, 200, 100),
            info = Color3.fromRGB(140, 180, 255), stroke = Color3.fromRGB(55, 30, 36), strokeSoft = Color3.fromRGB(40, 22, 28) },
        Ocean = { title = "Океан", preview = Color3.fromRGB(60, 180, 240),
            bg = Color3.fromRGB(10, 20, 30), bgDeep = Color3.fromRGB(6, 14, 22), bgLight = Color3.fromRGB(14, 28, 42),
            card = Color3.fromRGB(18, 32, 46), cardHover = Color3.fromRGB(26, 44, 60), cardActive = Color3.fromRGB(36, 60, 80),
            accent = Color3.fromRGB(60, 180, 240), accentSoft = Color3.fromRGB(120, 215, 255), accentDim = Color3.fromRGB(40, 120, 170),
            text = Color3.fromRGB(230, 245, 255), textDim = Color3.fromRGB(160, 200, 225), textMuted = Color3.fromRGB(100, 140, 165),
            success = Color3.fromRGB(100, 220, 150), danger = Color3.fromRGB(255, 90, 110), warning = Color3.fromRGB(255, 200, 90),
            info = Color3.fromRGB(120, 200, 255), stroke = Color3.fromRGB(40, 60, 80), strokeSoft = Color3.fromRGB(28, 44, 60) },
        Forest = { title = "Лес", preview = Color3.fromRGB(90, 200, 120),
            bg = Color3.fromRGB(10, 20, 14), bgDeep = Color3.fromRGB(6, 14, 10), bgLight = Color3.fromRGB(14, 28, 20),
            card = Color3.fromRGB(20, 34, 26), cardHover = Color3.fromRGB(28, 46, 36), cardActive = Color3.fromRGB(40, 64, 50),
            accent = Color3.fromRGB(90, 200, 120), accentSoft = Color3.fromRGB(140, 230, 160), accentDim = Color3.fromRGB(50, 140, 80),
            text = Color3.fromRGB(230, 250, 235), textDim = Color3.fromRGB(170, 210, 180), textMuted = Color3.fromRGB(110, 150, 120),
            success = Color3.fromRGB(110, 230, 140), danger = Color3.fromRGB(255, 90, 110), warning = Color3.fromRGB(255, 210, 90),
            info = Color3.fromRGB(120, 180, 240), stroke = Color3.fromRGB(36, 56, 42), strokeSoft = Color3.fromRGB(24, 40, 30) },
        Matrix = { title = "Матрица", preview = Color3.fromRGB(0, 255, 80),
            bg = Color3.fromRGB(4, 10, 4), bgDeep = Color3.fromRGB(2, 6, 2), bgLight = Color3.fromRGB(8, 16, 8),
            card = Color3.fromRGB(12, 26, 12), cardHover = Color3.fromRGB(18, 36, 18), cardActive = Color3.fromRGB(24, 48, 24),
            accent = Color3.fromRGB(0, 255, 80), accentSoft = Color3.fromRGB(100, 255, 150), accentDim = Color3.fromRGB(0, 150, 50),
            text = Color3.fromRGB(210, 255, 215), textDim = Color3.fromRGB(140, 200, 145), textMuted = Color3.fromRGB(70, 120, 75),
            success = Color3.fromRGB(0, 255, 100), danger = Color3.fromRGB(255, 60, 60), warning = Color3.fromRGB(255, 220, 0),
            info = Color3.fromRGB(0, 200, 255), stroke = Color3.fromRGB(20, 50, 20), strokeSoft = Color3.fromRGB(14, 32, 14) },
        Mono = { title = "Моно", preview = Color3.fromRGB(200, 200, 210),
            bg = Color3.fromRGB(16, 16, 18), bgDeep = Color3.fromRGB(10, 10, 12), bgLight = Color3.fromRGB(22, 22, 24),
            card = Color3.fromRGB(26, 26, 30), cardHover = Color3.fromRGB(36, 36, 42), cardActive = Color3.fromRGB(50, 50, 58),
            accent = Color3.fromRGB(200, 200, 210), accentSoft = Color3.fromRGB(230, 230, 240), accentDim = Color3.fromRGB(140, 140, 150),
            text = Color3.fromRGB(240, 240, 245), textDim = Color3.fromRGB(170, 170, 180), textMuted = Color3.fromRGB(110, 110, 120),
            success = Color3.fromRGB(180, 220, 180), danger = Color3.fromRGB(220, 140, 140), warning = Color3.fromRGB(230, 210, 140),
            info = Color3.fromRGB(170, 200, 230), stroke = Color3.fromRGB(50, 50, 56), strokeSoft = Color3.fromRGB(32, 32, 38) },
    }

    local ORDER = { "Midnight", "Sakura", "Cyber", "Blood", "Ocean", "Forest", "Matrix", "Mono" }
    local current = M.Config.theme
    if not Themes[current] then
        current = "Midnight"
    end
    M.Config.theme = current

    M.Themes = Themes
    M.ThemeOrder = ORDER
    M.Theme = Themes[current]

    function M.paint(inst, prop, role)
        table.insert(M.painters, { inst = inst, prop = prop, role = role })
    end

    function M.onTheme(fn)
        table.insert(M.themeListeners, fn)
    end

    function M.setTheme(name)
        local t = Themes[name]
        if not t then
            return
        end
        current = name
        M.Theme = t
        M.Config.theme = name
        M.saveConfig()
        for _, entry in ipairs(M.painters) do
            if entry.inst and entry.inst.Parent then
                pcall(function()
                    entry.inst[entry.prop] = t[entry.role]
                end)
            end
        end
        for _, fn in ipairs(M.themeListeners) do
            pcall(fn, t)
        end
    end
end

-- ═══ ЛОКАЛИЗАЦИЯ (RU / EN) ═══
do
    local PACKS = {
        ru = {
            logo = "BEST CLIENT",
            tagline = "v10.13 · community edition",
            role_unknown = "НЕИЗВЕСТНО",

            tab_visual = "Визуал", tab_combat = "Бой", tab_hvh = "HVH",
            tab_farm = "Фарм", tab_move = "Движение", tab_util = "Прочее",
            tab_look = "Вид", tab_dev = "DEV",

            sub_visual = "ESP, никнеймы, оружие",
            sub_combat = "KillAura и режимы",
            sub_hvh = "Хитбоксы и массовые действия",
            sub_farm = "Авто-сбор монет",
            sub_move = "Fly, noclip, скорость",
            sub_util = "Утилиты, конфиг и игроки",
            sub_look = "Темы и язык интерфейса",
            sub_dev = "Команда проекта",

            sec_players = "ESP игроков",
            sec_gun = "Gun ESP",
            sec_modes = "Режим KillAura",
            sec_aura = "Kill Aura",
            sec_hitbox = "Хитбокс (HVH)",
            sec_actions = "Действия",
            sec_coins = "Фарм монет",
            sec_move = "Movement",
            sec_wm = "Watermark",
            sec_util = "Утилиты",
            sec_config = "Конфиг",
            sec_players_list = "Игроки",
            sec_themes = "Темы оформления",
            sec_lang = "Язык интерфейса",
            sec_dev = "Разработчик",
            sec_beta = "Бета-тестеры",
            sec_about = "О проекте",

            esp_players = "Player ESP",
            esp_players_d = "Подсветка игроков по роли",
            esp_tags = "Name Tags",
            esp_tags_d = "Имя, HP и роль над головой",
            gun_esp = "Gun ESP",
            gun_esp_d = "Подсветка выпавших пистолетов",
            tp_gun = "TP к пистолету и назад",
            auto_grab = "Auto Grab Gun",
            auto_grab_d = "Авто-TP к пистолету",
            killaura = "KILL AURA",
            killaura_d = "Sheriff — аим, Murderer — флай + удар",
            kill_cd = "Cooldown (сек)",
            aim_smooth = "Aim Smoothness",
            fly_speed = "Murderer Fly Speed",
            hitbox_size = "Hitbox Size (1-20x)",
            remove_hb = "Убрать хитбоксы",
            diagnostic = "ДИАГНОСТИКА (F9)",
            autofarm = "Auto Farm Coins",
            autofarm_d = "Лимит попыток — слайдером ниже",
            attempts = "Попыток на монету",
            reset_coins = "Сбросить память монет",
            farm_info = "ПОПЫТОК НА МОНЕТУ: %d.\nЕсли после последней попытки монета всё ещё существует —\nона помечается как плохая. Сброс — кнопкой выше.",
            fly = "Fly (WASD)",
            fly_d = "Полёт камерой, Space / Ctrl",
            noclip = "Noclip",
            noclip_d = "Проход сквозь стены",
            walkspeed = "WalkSpeed",
            walkspeed_d = "Своя скорость ходьбы",
            speed_value = "Speed Value",
            watermark = "Watermark",
            watermark_d = "FPS, пинг и режим",
            wm_reset = "Сбросить позицию watermark",
            fullbright = "Fullbright",
            fullbright_d = "Яркое освещение",
            refresh_roles = "Обновить роли",
            fix_col = "Починить коллизии",
            save_cfg = "Сохранить конфиг",
            reset_cfg = "Сбросить настройки",
            uninject = "UNINJECT (конфиг сохранить)",
            uninject_clear = "UNINJECT + очистить конфиг",
            mode_legit = "LEGIT",
            mode_medium = "MEDIUM",
            mode_hvh = "HVH",
            mode_desc = "legit — честно · medium — баланс · hvh — хардкор",
            theme_pick = "Клик по карточке — применить тему",
            lang_hint = "Язык применяется сразу ко всему меню",
            apply = "Применить",
            about_text = "3 режима KillAura · авто-фарм монет · ESP · KillAura\nАдмин-панель (O) · темы и языки\nСделано для комьюнити",
            copy_hint = "Клик по карточке — скопировать ник",
            role_lead = "Главный разработчик",
            role_beta = "Бета-тестер",
            press_key = "Нажмите клавишу...",
            bind_cancel = "ESC — отмена · Backspace — удалить",
            yes = "да",
            no = "нет",
            on = "вкл",
            off = "выкл",
            loaded = "BEST CLIENT v10.13 · загружено",
            theme_toast = "Тема: %s",
            lang_toast = "Язык: Русский",
            roles_updated = "Роли обновлены",
            cfg_saved = "Конфиг сохранён",
            cfg_reset = "Настройки сброшены (перезапусти)",
            wm_reset_toast = "Watermark сброшен",
            coins_reset = "Память монет сброшена",
            hb_removed = "Хитбоксы убраны",
            no_weapon = "KillAura ON · но оружия нет",
            diag_msg = "Вывод в консоль (F9)",
            cols_fixed = "Коллизии восстановлены",
            sec_aim = "KILLAURA · SHERIFF",
            sec_melee = "KILLAURA · MURDERER",
            aim_camera = "Camera Aimbot",
            aim_camera_d = "Плавно доводит камеру на цель",
            aim_shoot = "Auto Shoot · Camera",
            aim_shoot_d = "Стрелять, когда камера наведена",
            cross_enable = "Crosshair Aimbot",
            cross_enable_d = "Двигает прицел (курсор), не камеру",
            cross_shoot = "Auto Shoot · Crosshair",
            cross_shoot_d = "Стрелять, когда прицел на цели",
            cross_tol = "Порог прицела (px)",
            no_mousemove = "mousemoverel не поддерживается — прицел не двигается",
            aim_only = "Только мурдер",
            aim_only_d = "Стрелять только в мурдера",
            aim_wall = "Wall Check",
            aim_wall_d = "Не стрелять через стены",
            aim_fov = "FOV (градусы)",
            aim_cd = "Cooldown выстрела",
            aim_pred = "Prediction (сек)",
            melee_enable = "Murderer Aura",
            melee_enable_d = "Легит: прицел + хитбокс, без ТП и полёта",
            melee_aim = "Наводить прицел",
            melee_aim_d = "Двигать курсор на цель",
            melee_range = "Range (дистанция удара)",
            melee_cd = "Задержка удара",
            melee_tp = "Teleport",
            melee_tp_d = "Подлетать к цели",
            no_gun = "KillAura · нет пистолета",
            mode_toast = "KillAura · %s",
        },
        en = {
            logo = "BEST CLIENT",
            tagline = "v10.13 · community edition",
            role_unknown = "UNKNOWN",

            tab_visual = "Visual", tab_combat = "Combat", tab_hvh = "HVH",
            tab_farm = "Farm", tab_move = "Movement", tab_util = "Misc",
            tab_look = "Look", tab_dev = "DEV",

            sub_visual = "ESP, nametags, weapons",
            sub_combat = "KillAura and modes",
            sub_hvh = "Hitboxes and mass actions",
            sub_farm = "Automatic coin farming",
            sub_move = "Fly, noclip, speed",
            sub_util = "Utilities, config and players",
            sub_look = "Themes and interface language",
            sub_dev = "Project team",

            sec_players = "Player ESP",
            sec_gun = "Gun ESP",
            sec_modes = "KillAura mode",
            sec_aura = "Kill Aura",
            sec_hitbox = "Hitbox (HVH)",
            sec_actions = "Actions",
            sec_coins = "Coin farm",
            sec_move = "Movement",
            sec_wm = "Watermark",
            sec_util = "Utilities",
            sec_config = "Config",
            sec_players_list = "Players",
            sec_themes = "Interface themes",
            sec_lang = "Interface language",
            sec_dev = "Developer",
            sec_beta = "Beta testers",
            sec_about = "About",

            esp_players = "Player ESP",
            esp_players_d = "Highlight players by role",
            esp_tags = "Name Tags",
            esp_tags_d = "Name, HP and role above head",
            gun_esp = "Gun ESP",
            gun_esp_d = "Highlight dropped guns",
            tp_gun = "TP to gun and back",
            auto_grab = "Auto Grab Gun",
            auto_grab_d = "Auto-TP to a gun",
            killaura = "KILL AURA",
            killaura_d = "Sheriff — aim, Murderer — fly + stab",
            kill_cd = "Cooldown (sec)",
            aim_smooth = "Aim Smoothness",
            fly_speed = "Murderer Fly Speed",
            hitbox_size = "Hitbox Size (1-20x)",
            remove_hb = "Remove hitboxes",
            diagnostic = "DIAGNOSTICS (F9)",
            autofarm = "Auto Farm Coins",
            autofarm_d = "Attempt limit — slider below",
            attempts = "Attempts per coin",
            reset_coins = "Reset coin memory",
            farm_info = "ATTEMPTS PER COIN: %d.\nIf the coin still exists after the last attempt,\nit is marked as bad. Reset — button above.",
            fly = "Fly (WASD)",
            fly_d = "Camera flight, Space / Ctrl",
            noclip = "Noclip",
            noclip_d = "Walk through walls",
            walkspeed = "WalkSpeed",
            walkspeed_d = "Custom walking speed",
            speed_value = "Speed Value",
            watermark = "Watermark",
            watermark_d = "FPS, ping and mode",
            wm_reset = "Reset watermark position",
            fullbright = "Fullbright",
            fullbright_d = "Bright lighting",
            refresh_roles = "Refresh roles",
            fix_col = "Fix collisions",
            save_cfg = "Save config",
            reset_cfg = "Reset settings",
            uninject = "UNINJECT (keep config)",
            uninject_clear = "UNINJECT + clear config",
            mode_legit = "LEGIT",
            mode_medium = "MEDIUM",
            mode_hvh = "HVH",
            mode_desc = "legit — fair · medium — balanced · hvh — rage",
            theme_pick = "Click a card to apply the theme",
            lang_hint = "Language applies to the whole menu instantly",
            apply = "Apply",
            about_text = "3 KillAura modes · auto coin farm · ESP · KillAura\nAdmin panel (O) · themes and languages\nMade for the community",
            copy_hint = "Click a card to copy the nickname",
            role_lead = "Lead Developer",
            role_beta = "Beta Tester",
            press_key = "Press a key...",
            bind_cancel = "ESC — cancel · Backspace — clear",
            yes = "yes",
            no = "no",
            on = "on",
            off = "off",
            loaded = "BEST CLIENT v10.13 · loaded",
            theme_toast = "Theme: %s",
            lang_toast = "Language: English",
            roles_updated = "Roles refreshed",
            cfg_saved = "Config saved",
            cfg_reset = "Settings reset (restart)",
            wm_reset_toast = "Watermark reset",
            coins_reset = "Coin memory reset",
            hb_removed = "Hitboxes removed",
            no_weapon = "KillAura ON · no weapon",
            diag_msg = "Printed to console (F9)",
            cols_fixed = "Collisions restored",
            sec_aim = "KILLAURA · SHERIFF",
            sec_melee = "KILLAURA · MURDERER",
            aim_camera = "Camera Aimbot",
            aim_camera_d = "Smoothly rotates the camera to the target",
            aim_shoot = "Auto Shoot · Camera",
            aim_shoot_d = "Shoot when the camera is aimed",
            cross_enable = "Crosshair Aimbot",
            cross_enable_d = "Moves the crosshair (cursor), not the camera",
            cross_shoot = "Auto Shoot · Crosshair",
            cross_shoot_d = "Shoot when the crosshair is on target",
            cross_tol = "Crosshair tolerance (px)",
            no_mousemove = "mousemoverel is not supported — crosshair can't move",
            aim_only = "Murderer only",
            aim_only_d = "Shoot the murderer only",
            aim_wall = "Wall Check",
            aim_wall_d = "Don't shoot through walls",
            aim_fov = "FOV (degrees)",
            aim_cd = "Shot cooldown",
            aim_pred = "Prediction (sec)",
            melee_enable = "Murderer Aura",
            melee_enable_d = "Legit: crosshair + hitbox, no TP/fly",
            melee_aim = "Aim crosshair",
            melee_aim_d = "Move the cursor onto the target",
            melee_range = "Range (stab distance)",
            melee_cd = "Stab delay",
            melee_tp = "Teleport",
            melee_tp_d = "Fly to the target",
            no_gun = "KillAura · no gun",
            mode_toast = "KillAura · %s",
        },
    }

    local listeners = {}
    local current = M.Config.language
    if current ~= "en" then
        current = "ru"
    end
    M.Config.language = current

    function M.t(key, ...)
        local pack = PACKS[current] or PACKS.ru
        local value = pack[key]
        if value == nil then
            value = PACKS.ru[key] or tostring(key)
        end
        if select("#", ...) > 0 then
            local ok, formatted = pcall(string.format, value, ...)
            if ok then
                return formatted
            end
        end
        return value
    end

    function M.getLang()
        return current
    end

    function M.onLang(fn)
        table.insert(listeners, fn)
    end

    function M.setLang(code)
        if code ~= "ru" and code ~= "en" then
            return
        end
        if code == current then
            return
        end
        current = code
        M.Config.language = code
        M.saveConfig()
        for _, fn in ipairs(listeners) do
            pcall(fn, code)
        end
    end
end

-- ═══ КЛЮЧИ РОЛЕЙ ═══
local SHERIFF_KEYS = { "gun", "revolver", "pistol", "firearm" }
local MURDERER_KEYS = { "knife", "bat", "axe", "chainsaw", "sword", "cleaver", "machete",
    "scythe", "pickaxe", "wrench", "crowbar", "screwdriver", "hammer", "sabre", "spiked", "dagger" }

local function containsAny(str, list)
    local lower = string.lower(str)
    for _, key in ipairs(list) do
        if string.find(lower, key, 1, true) then
            return true
        end
    end
    return false
end

-- ═══ РОЛИ ═══
do
    local cache = {}
    local lastFetch = 0

    M.roleCache = cache
    M.ROLE_COLORS = {
        Murderer = Color3.fromRGB(255, 80, 100),
        Sheriff = Color3.fromRGB(80, 155, 255),
        Innocent %2
