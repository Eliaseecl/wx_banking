function Notify(message)
    lib.notify({
        title = "Banking",
        description = message,
        type = "info",
        icon = "piggy-bank"
    })
end

function Withdraw()
    local balance = lib.callback.await('wx_banking:getBalance')
    local withdraw = lib.inputDialog('Retirar',
        {
            {
                type = 'number',
                label = 'Cantidad',
                description = 'Cuanto quieres retirar?',
                required = true,
                min = 1,
                max = balance
            }
        }
    )
    if not withdraw then return end
    local success = lib.callback.await('wx_banking:withdraw', false, withdraw[1])
    if success then
        Notify(("You have successfully withdrew %s$"):format(withdraw[1]))
    else
        Notify("Couldn't withdraw")
    end
end

function Deposit()
    local balance = lib.callback.await('wx_banking:getCash')
    local deposit = lib.inputDialog('Depositar',
        {
            {
                type = 'number',
                label = 'Cantidad',
                description = 'Cuanto quieres depositar?',
                required = true,
                min = 1,
                max = balance
            }
        }
    )
    if not deposit then return end
    local success = lib.callback.await('wx_banking:deposit', false, deposit[1])
    if success then
        Notify(("Depositaste %s$ al banco"):format(deposit[1]))
    else
        Notify("Couldn't deposit")
    end
end

function Transfer()
    local balance = lib.callback.await('wx_banking:getBalance')
    print(balance)
    local idotro = lib.inputDialog('Transfer',
        {
            {
                type = 'number',
                label = 'Player ID',
                description = 'Target Player ID',
                required = true,
                min = 1,
            },
        }
    )

    local cantidad = lib.inputDialog('Transfer',
        {
            {
                type = 'number',
                label = 'Cantidad',
                description = 'Cuanto quieres transferir?',
                required = true,
                min = 1,
                max = balance,
            },
        }
        
    )

    -- if not transfer then return end
    -- print(json.encode(transfer))
    TriggerServerEvent('wx_banking:transfer', idotro[1], cantidad[1])
end

function Blip(x, y, z, sprite, name)
    local blip = AddBlipForCoord(x, y, z)
    SetBlipSprite(blip, sprite)
    SetBlipScale(blip, 0.8)
    SetBlipColour(blip, 2)
    SetBlipAsShortRange(blip, true)
    BeginTextCommandSetBlipName('STRING')
    AddTextComponentSubstringPlayerName(name)
    EndTextCommandSetBlipName(blip)
end

CreateThread(function()
    for k, v in pairs(wx.Banks) do
        Blip(v.x, v.y, v.z, 108, wx.BlipNames.bank)
        exports.ox_target:addBoxZone({
            coords = vec3(v.x, v.y, v.z),
            size = vec3(1.0, 1.0, 1.0),
            rotation = 0.0,
            debug = false,
            options = {
                {
                    name = "open_bank",
                    icon = 'fa-solid fa-building-columns',
                    label = "Abrir Banco",
                    distance = 2.0,
                    onSelect = function()
                        local balance = lib.callback.await('wx_banking:getBalance')
                        lib.registerContext({
                            id = 'open_bank',
                            title = 'BANCO',
                            options = {
                                {
                                    title = ('Balance: %s$'):format(balance),
                                    icon = "money-check-dollar",
                                },
                                {
                                    title = 'Depositar',
                                    description = "Haga click para depositar dinero en su cuenta",
                                    onSelect = function()
                                        Deposit()
                                    end,
                                    icon = "hand-holding-dollar",
                                },
                                {
                                    title = 'Retirar',
                                    description = "Haga click para retirar dinero de su cuenta",
                                    onSelect = function()
                                        Withdraw()
                                    end,
                                    icon = "wallet",
                                },
                                {
                                    title = 'Transferir',
                                    description = "Haga click para transferir dinero desde su cuenta a otra persona",
                                    onSelect = function()
                                        Transfer()
                                    end,
                                    icon = "money-bill-transfer",
                                },
                            }
                        })
                        lib.progressBar({
                            duration = 2000,
                            label = 'Abriendo Banco',
                            useWhileDead = false,
                            canCancel = false,
                            disable = {
                                car = false,
                                move = true,
                                combat = true,
                            },
                            anim = {
                                dict = 'mp_common',
                                clip = 'givetake1_a'
                            },
                        })
                        lib.showContext('open_bank')
                    end
                }
            }
        }
        )
    end

    -- if #wx.ATMs.models > 0 then
    exports.ox_target:addModel(wx.ATMs.models, {
        name = "open_bank",
        icon = 'fa-solid fa-building-columns',
        label = "ATM",
        distance = 1.0,
        onSelect = function()
            local balance = lib.callback.await('wx_banking:getBalance')

            lib.registerContext({
                id = 'open_atm',
                title = 'ATM',
                options = {
                    {
                        title = ('Balance: %s$'):format(balance),
                        icon = "money-check-dollar",
                    },
                    {
                        title = 'Retirar',
                        description = "Click to withdraw money from your account",
                        onSelect = function()
                            Withdraw()
                        end,
                        icon = "wallet",
                    },
                }
            })
            lib.progressBar({
                duration = 2000,
                label = 'Abriendo Cajero',
                useWhileDead = false,
                canCancel = false,
                disable = {
                    car = false,
                    move = true,
                    combat = true,
                },
                anim = {
                    dict = 'mp_common',
                    clip = 'givetake1_a'
                },
            })
            lib.showContext('open_atm')
        end
    })

    for _, loc in pairs(wx.ATMs.manualLocations) do
        Blip(loc.x, loc.y, loc.z, 108, wx.BlipNames.atm)
        exports.ox_target:addBoxZone({
            coords = vec3(loc.x, loc.y, loc.z),
            size = vec3(1.0, 1.0, 1.0),
            rotation = 0.0,
            debug = false,
            options = {
                {
                    name = "open_atm",
                    icon = 'fa-solid fa-building-columns',
                    label = "Open ATM",
                    distance = 2.0,
                    onSelect = function()
                        local balance = lib.callback.await('wx_banking:getBalance')
                        lib.registerContext({
                            id = 'open_atm',
                            title = 'ATM',
                            options = {
                                {
                                    title = ('Balance: %s$'):format(balance),
                                    icon = "money-check-dollar",
                                },
                                {
                                    title = 'Retirar',
                                    description = "Click to withdraw money from your account",
                                    onSelect = function()
                                        Withdraw()
                                    end,
                                    icon = "wallet",
                                },
                            }
                        })
                        lib.progressBar({
                            duration = 2000,
                            label = 'Abriendo Cajero',
                            useWhileDead = false,
                            canCancel = false,
                            disable = {
                                car = false,
                                move = true,
                                combat = true,
                            },
                            anim = {
                                dict = 'mp_common',
                                clip = 'givetake1_a'
                            },
                        })
                        lib.showContext('open_atm')
                    end
                }
            }
        }
        )
    end
    -- end
end)
