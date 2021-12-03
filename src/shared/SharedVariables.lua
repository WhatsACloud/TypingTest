local variables = {}

local keymap = {
    [Enum.KeyCode.A] = "a",
    [Enum.KeyCode.B] = "b",
    [Enum.KeyCode.C] = "c",
    [Enum.KeyCode.D] = "d",
    [Enum.KeyCode.E] = "e",
    [Enum.KeyCode.F] = "f",
    [Enum.KeyCode.G] = "g",
    [Enum.KeyCode.H] = "h",
    [Enum.KeyCode.I] = "i",
    [Enum.KeyCode.J] = "j",
    [Enum.KeyCode.K] = "k",
    [Enum.KeyCode.L] = "l",
    [Enum.KeyCode.M] = "m",
    [Enum.KeyCode.N] = "n",
    [Enum.KeyCode.O] = "o",
    [Enum.KeyCode.P] = "p",
    [Enum.KeyCode.Q] = "q",
    [Enum.KeyCode.R] = "r",
    [Enum.KeyCode.S] = "s",
    [Enum.KeyCode.T] = "t",
    [Enum.KeyCode.U] = "u",
    [Enum.KeyCode.V] = "v",
    [Enum.KeyCode.W] = "w",
    [Enum.KeyCode.X] = "x",
    [Enum.KeyCode.Y] = "y",
    [Enum.KeyCode.Z] = "z",
    [Enum.KeyCode.Space] = " "
}

local keymapkeys = {}

local keyWidth = {

}

for i,_ in pairs(keymap) do
    keymapkeys[#keymapkeys+1] = i
end

variables.keyMapKeys = keymapkeys
variables.KeyMap = keymap
variables.keyWidths = keyWidth

return variables