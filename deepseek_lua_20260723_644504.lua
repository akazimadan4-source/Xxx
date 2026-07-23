-- ================================
-- 3. Persiapan potato chips (async) tapi kita tunggu pot ditemukan
-- ================================
local potatoPrepDone = false
local potFound = false
task.spawn(function()
    PurchasePotatoIngredients()
    StartPotatoJob()
    CutPotato()
    BagPotato()
    MixFlourAndPotato()
    potFound = CookPotatoChips()  -- returns true jika pot ditemukan
    potatoPrepDone = true
end)

-- Tunggu sampai persiapan selesai dan pot ditemukan, dengan timeout
local waitStart = os.clock()
while not potatoPrepDone and (os.clock() - waitStart) < 60 do
    task.wait(1)
end
-- Jika potatoPrepDone sudah true tapi potFound false, restart cycle
if potatoPrepDone and not potFound then
    Configuration.State.Status = "[POTATO] No pot found, restarting cycle"
    task.wait(3)
    continue
end