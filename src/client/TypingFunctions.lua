local typingFuncs = {}
local guiEr = require(script.Parent.guiEr)
local player = game.Players.LocalPlayer
local soundS = require(script.Parent.SoundS)
local typingSound = soundS.loadSound(4724428597)

local function playTypingSound()
    typingSound:Play()
end

function typingFuncs.DeleteLetter()
    local index = game:GetService("ReplicatedStorage").RE.DeleteLetter:InvokeServer()
    if index then
        playTypingSound()
        guiEr.TweenTextColor(index,Color3.fromRGB(128,128,128))
    end
end

function typingFuncs.changeColor(result,letterName)
    if result == nil then return end
    playTypingSound()
    if result then
        guiEr.TweenTextColor(letterName,Color3.fromRGB(255,255,255))
        return
    end
    guiEr.TweenTextColor(letterName,Color3.fromRGB(255,0,0))
end

local customKeybinds = {
    [Enum.KeyCode.Backspace] = typingFuncs.DeleteLetter
}

local inputRF = game:GetService("ReplicatedStorage").RE.Input

function typingFuncs.detectedKeyInput(input,gameProcessed)
    if not gameProcessed and input.KeyCode ~= Enum.KeyCode.Unknown then
        if customKeybinds[input.KeyCode] then
            customKeybinds[input.KeyCode]()
            return
        end
        print("a")
        local result,letterIndex = inputRF:InvokeServer(input.KeyCode)
        print("b")
        if result ~= nil then
            typingFuncs.changeColor(result,letterIndex)
        end
    end
end

return typingFuncs