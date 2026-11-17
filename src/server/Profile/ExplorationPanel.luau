-- Server-owned per-player exploration HUD. Visual only: never grants rewards.
-- Independent of GLM's upper-left objective panel and seal HUD.
local Players = game:GetService("Players")
local State = require(script.Parent.ExplorationState)
local Journey = require(script.Parent.JourneyGuide)
local Panel = {}
local sessions = {}

local function draw(session)
    if not session.gui or not session.gui.Parent then return end
    session.counter.Text = ("LATÚNIA · %d/5 DESCOBERTAS"):format(session.state.total)
    local nextStep, completed, total = Journey.next(session.objectives, session.ember)
    session.nextObjective.Text = ("JORNADA %d/%d · %s"):format(completed, total, nextStep)
    for _, entry in ipairs(State.order) do
        local label = session.rows[entry.id]
        local visited = session.state.visited[entry.id] == true
        label.Text = (visited and "✓ " or "○ ") .. entry.name
        label.TextColor3 = visited and Color3.fromRGB(178, 237, 190)
            or Color3.fromRGB(196, 187, 210)
    end
end

local function build(player, session)
    local playerGui = player:FindFirstChildOfClass("PlayerGui")
        or player:WaitForChild("PlayerGui", 30)
    if not playerGui or player.Parent ~= Players or sessions[player] ~= session then return end

    local previous = playerGui:FindFirstChild("MythragonExploration")
    if previous then previous:Destroy() end

    local gui = Instance.new("ScreenGui")
    gui.Name = "MythragonExploration"
    gui.ResetOnSpawn = false
    gui.DisplayOrder = 6
    gui.Parent = playerGui

    local frame = Instance.new("ScrollingFrame")
    frame.Name = "Panel"
    frame.Position = UDim2.new(0, 12, 0, 180)
    frame.Size = UDim2.new(0.34, 0, 1, -194)
    frame.CanvasSize = UDim2.new(1, 0, 0, 215)
    frame.ScrollingDirection = Enum.ScrollingDirection.Y
    frame.ScrollBarThickness = 5
    frame.BackgroundColor3 = Color3.fromRGB(25, 22, 42)
    frame.BackgroundTransparency = 0.18
    frame.BorderSizePixel = 0
    frame.Parent = gui

    local limit = Instance.new("UISizeConstraint")
    limit.MinSize = Vector2.new(145, 0)
    limit.MaxSize = Vector2.new(235, 215)
    limit.Parent = frame

    local corner = Instance.new("UICorner")
    corner.CornerRadius = UDim.new(0, 8)
    corner.Parent = frame

    local heading = Instance.new("TextLabel")
    heading.Name = "Counter"
    heading.Position = UDim2.fromOffset(8, 5)
    heading.Size = UDim2.new(1, -16, 0, 27)
    heading.BackgroundTransparency = 1
    heading.Font = Enum.Font.GothamBold
    heading.TextXAlignment = Enum.TextXAlignment.Left
    heading.TextSize = 12
    heading.TextWrapped = true
    heading.TextColor3 = Color3.fromRGB(241, 218, 165)
    heading.Parent = frame

    local rows = {}
    for i, entry in ipairs(State.order) do
        local label = Instance.new("TextLabel")
        label.Name = "Island" .. i
        label.Position = UDim2.fromOffset(10, 32 + (i - 1) * 24)
        label.Size = UDim2.new(1, -20, 0, 22)
        label.BackgroundTransparency = 1
        label.Font = Enum.Font.GothamMedium
        label.TextSize = 13
        label.TextXAlignment = Enum.TextXAlignment.Left
        label.TextWrapped = true
        label.Parent = frame
        rows[entry.id] = label
    end
    local nextObjective = Instance.new("TextLabel")
    nextObjective.Name = "NextJourneyObjective"
    nextObjective.Position = UDim2.fromOffset(9, 155)
    nextObjective.Size = UDim2.new(1, -18, 0, 52)
    nextObjective.BackgroundTransparency = 1
    nextObjective.Font = Enum.Font.GothamMedium
    nextObjective.TextSize = 11
    nextObjective.TextWrapped = true
    nextObjective.TextXAlignment = Enum.TextXAlignment.Left
    nextObjective.TextYAlignment = Enum.TextYAlignment.Center
    nextObjective.TextColor3 = Color3.fromRGB(244, 214, 150)
    nextObjective.Parent = frame

    session.gui, session.counter, session.rows = gui, heading, rows
    session.nextObjective = nextObjective
    draw(session)
end

function Panel.attach(player)
    if sessions[player] then return end
    local session = { state = State.new(), objectives = {}, ember = false }
    sessions[player] = session
    task.spawn(build, player, session)
end

function Panel.hydrate(player, done)
    if player.Parent ~= Players then return end
    Panel.attach(player)
    local session = sessions[player]
    session.state:hydrate(done)
    if type(done) == "table" then
        for id, completed in pairs(done) do
            if completed == true then session.objectives[id] = true end
        end
    end
    draw(session)
end

function Panel.mark(player, id)
    if player.Parent ~= Players then return false end
    Panel.attach(player)
    local session = sessions[player]
    local changed = session.state:mark(id)
    if changed then
        session.objectives[id] = true
        draw(session)
    end
    return changed
end

-- Display-only hooks, invoked after server-authoritative callbacks.
function Panel.markObjective(player, id)
    if player.Parent ~= Players then return end
    Panel.attach(player)
    local session = sessions[player]
    session.objectives[id] = true
    draw(session)
end

function Panel.markEmber(player)
    if player.Parent ~= Players then return end
    Panel.attach(player)
    local session = sessions[player]
    session.ember = true
    draw(session)
end

-- Read-only server guidance for an interactive village noticeboard.
-- Never creates progress or grants a reward.
function Panel.nextObjective(player)
    local session = sessions[player]
    if not session then return "Observe um Guardião do Éter" end
    local label = Journey.next(session.objectives, session.ember)
    return label
end

function Panel.remove(player)
    local session = sessions[player]
    if not session then return end
    sessions[player] = nil
    if session.gui then session.gui:Destroy() end
end

return Panel
