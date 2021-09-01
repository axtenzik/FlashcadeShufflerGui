GamePath = ".\\sessions\\CurrentRoms\\"
SavePath = ".\\sessions\\CurrentSaves\\"
RomSet = {}

function GetVariables()
    file = io.open("luaVariables.txt", "r")
    for line in file:lines() do
        var1, var2 = line:match("([^:]+):([^:]+)")
        --console.log(var1)
        --console.log(var2)
        --console.log(line)
        if var1 == "SuperString" then
            if var2 == "yes" then
                SuperSwap = true
            else
                SuperSwap = false
            end
        elseif var1 == "SuperSwapCount" then
            SuperSwapCount = var2
        elseif var1 == "CurrentGame" then
            if var2 == "unknown" then
                CurrentGame = nil
            else
                CurrentGame = var2
            end
        end
    end
    file:close()
end

function SetVariables()
    if SuperSwap == true then
        SuperString = "yes"
    else
        SuperString = "no"
    end
    if CurrentGame == nil then
        CurrentGame = "unknown"
    end

    file = io.open("luaVariables.txt", "w")
    file:write("SuperString", ":", SuperString, "\n")
    file:write("SuperSwapCount", ":", SuperSwapCount, "\n")
    file:write("CurrentGame", ":", CurrentGame, "\n")
    file:close()
end


FPS = 60
Extended = false

--Min and Max time games can last
MinTime = 180 * FPS --seconds * fps
MaxTime = 300 * FPS --seconds * fps

--counter stuffs
TimerCount = 0
TimerLimit = math.random(MinTime, MaxTime)
console.log("timerLimit is")
console.log(TimerLimit)

--superswapper stuffs
SuperSwapTimer = 15 * FPS --seconds * fps
SuperSwapLimit = 8 --The amount of games that superswap lasts
SuperSwap = false
SuperSwapCount = 0

CurrentGame = nil
console.log(CurrentGame)

GetVariables()

if SuperSwap == true then
    console.log("superswap is true")
    TimerLimit = SuperSwapTimer
else
    console.log("superswap is false")
end

--gets the file suffix
function Ends_with(str, ending)
    return ending == "" or str:sub(-#ending) == ending
end

--Gets all the roms in the CurrentRoms folder
RomList = 0
for directory in io.popen([[dir .\sessions\CurrentRoms\ /b]]):lines() do
	if Ends_with(directory, ".bin") then
		console.log("SKIP: " .. directory)
	else
		console.log("ROM: " .. directory)
		RomList = RomList + 1
		RomSet[RomList] = directory
	end
end

console.log("Rom 1 is", RomSet[1])
console.log("Rom 2 is", RomSet[2])

if CurrentGame ~= nil then
    savestate.load(SavePath ..  CurrentGame .. ".state")
else
    number = math.random(1, RomList)
    console.log(number)
    NextRom = RomSet[number]
    CurrentGame = NextRom
    SetVariables()
    client.openrom(GamePath .. NextRom)
end

--Swap Rom
function Swap()
    client.speedmode(100)

    if CurrentGame ~= nil then
        savestate.save(SavePath .. CurrentGame  .. ".state")
    end

    if SuperSwap == true then
        SuperSwapCount = SuperSwapCount + 1
        if SuperSwapCount >= SuperSwapLimit then
            SuperSwap = false
            SuperSwapCount = 0
        end
    else
        TimerLimit = math.random(MinTime, MaxTime)
    end
    
    number = math.random(1, RomList)
    console.log(number)
    NextRom = RomSet[number]
    console.log(NextRom)
    CurrentGame = NextRom
    SetVariables()
    client.openrom(GamePath .. NextRom)
end

--Extend the timer
function Extend()
    if Extended == false then
        console.log(TimerLimit)
        TimerLimit = TimerLimit + (300 * FPS)
        console.log("new timer limit ", TimerLimit)
        Extended = true
    end
end

--Activates superswap
function Superswapper()
    SuperSwap = true
    console.log("SuperSwap set to true")
end

--speeds up the game
function Speed()
    client.speedmode(400)
    console.log(TimerLimit)
    TimerLimit = TimerLimit * 4
    console.log("New TimerLimit ", TimerLimit)
end

--main
while true do
    --console.log("main")
    if (TimerCount % 180) == 0 then
        comm.socketServerSend("ping <EOF>")
        strig = comm.socketServerResponse()
        --console.log("modulus successful")
        if string.find(strig, "superswap") then
            console.log(strig)
            Superswapper()
            Swap()
        elseif string.find(strig, "extend") then
            console.log(strig)
            Extend()
        elseif string.find(strig, "swap") then
            console.log(strig)
            Swap()
        end
        if string.find(strig, "speed") then
            console.log(strig)
            Speed()
        end
        
    elseif TimerCount >= TimerLimit then
        console.clear()
        Swap()
    end

    TimerCount = TimerCount + 1
    emu.frameadvance()
end