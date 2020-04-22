return {
    name = "Apps",
    iconId = "shapes",
    iconType = "faSolid",
    setup = function(page)
        local loading = teverse.construct("guiTextBox", {
            parent = page,
            size = guiCoord(1.0, 100, 1.0, 100),
            position = guiCoord(0, -50, 0, -50),
            backgroundAlpha = 0.4,
            backgroundColour = colour(0, 0, 0),
            text = "Working...",
            textColour = colour(0,0,0),
            textAlign = "middle",
            visible = false,
            zIndex = 10000
        })

        teverse.construct("guiTextBox", {
            parent = page,
            size = guiCoord(1.0, -20, 0, 48),
            position = guiCoord(0, 10, 0, 10),
            backgroundAlpha = 0,
            text = "Apps",
            textSize = 48,
            textAlign = "middleLeft"
        })

        local subtitle = teverse.construct("guiTextBox", {
            parent = page,
            size = guiCoord(1.0, -20, 0, 18),
            position = guiCoord(0, 10, 0, 58),
            backgroundAlpha = 0,
            text = "Loading Apps",
            textSize = 18,
            textAlign = "middleLeft"
        })

        local appsContainer = teverse.construct("guiFrame", {
            parent = page,
            size = guiCoord(1.0, -20, 1, -100),
            position = guiCoord(0, 10, 0, 90),
            backgroundAlpha = 0
        })

        teverse.guiHelper
            .gridConstraint(appsContainer, {
                cellSize = guiCoord(0, 150, 0, 80),
                cellMargin = guiCoord(0, 15, 0, 25)
            })

        teverse.http:get("https://teverse.com/api/apps", {
            ["Authorization"] = "BEARER " .. teverse.userToken
        }, function(code, body)
            if code == 200 then
                local apps = teverse.json:decode(body)
                subtitle.text = "Found " .. #apps .. " public apps."
                for _,app in pairs(apps) do
                    local appGui = teverse.construct("guiFrame", {
                        parent = appsContainer,
                        strokeAlpha = 0.1,
                        strokeRadius = 4
                    })

                    teverse.guiHelper.hoverColour(appGui, colour.rgb(247, 247, 247))
                    appGui:on("mouseLeftUp", function()
                        if not loading.visible then
                            loading.text = "Working..."
                            loading.visible = true
                            teverse.http:get("https://teverse.com/api/apps/" .. app.id .. "/script", {
                                ["Authorization"] = "BEARER " .. teverse.userToken
                            }, function(code, body)
                                if code == 200 then
                                    loading.visible = false
                                    teverse.apps:loadString(body)
                                else
                                    loading.text = "Unable to load app."
                                    sleep(1.5)
                                    loading.visible = false
                                end
                            end)
                        end
                    end)

                    teverse.construct("guiTextBox", {
                        parent = appGui,
                        size = guiCoord(1.0, -20, 0, 22),
                        position = guiCoord(0, 10, 0, 5),
                        backgroundAlpha = 0,
                        text = app.name,
                        textSize = 22,
                        textAlign = "middleLeft",
                        textFont = "tevurl:fonts/openSansBold.ttf",
                        active = false
                    })

                    teverse.construct("guiTextBox", {
                        parent = appGui,
                        size = guiCoord(1.0, -20, 0, 16),
                        position = guiCoord(0, 10, 0, 24),
                        backgroundAlpha = 0,
                        textAlpha = 0.5,
                        text = "by " .. app.owner.username,
                        textSize = 16,
                        active = false
                    })

                    teverse.construct("guiIcon", {
                        parent = appGui,
                        size = guiCoord(1, 0, 1, -45),
                        position = guiCoord(0, 0, 0, 45),
                        iconMax = 20,
                        iconColour = colour(1, 1, 1),
                        iconType = "faSolid",
                        iconId = "code",
                        iconAlpha = 0.9,
                        backgroundAlpha = 1.0,
                        backgroundColour = colour.rgb(216, 100, 89),
                        active = false
                    })
                end
            else
                subtitle.text = "Server error."
            end
        end)
    end
}