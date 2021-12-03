local module = {}

function module.DisableReset()
    local SG = game:GetService("StarterGui")
    local maxRetries = 3
    for i = 1,maxRetries do
        local success,result = pcall(function()
            SG:SetCore("ResetButtonCallback", false)
        end)
        if success then
            break
        else
            print("retrying to set reset button to disabled")
        end
        wait(1)
    end
end

return module