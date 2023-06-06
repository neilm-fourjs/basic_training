# =============================================================================
# Generated using Genero Ghost Client 4.01.01-202209161147
# =============================================================================
IMPORT FGL ggc

MAIN
    CALL ggc.setApplicationName("menu")
    CALL ggc.parseOptions()

    # Register scenario functions
    CALL ggc.registerScenario(FUNCTION play_0)

    # Start execution and exits when the scenario ends
    # Exit status is 1 in case of error, 0 on success.
    CALL ggc.play()
END MAIN

# Scenario menu_test1 id : 0
PRIVATE FUNCTION play_0()
    CALL ggc.setTableSize("menu", 20)

    CALL ggc.setTableSize("menu", 19)

    CALL ggc.mediaSize("large")

    CALL ggc.action("quit") -- Quit

    CALL ggc.end()
END FUNCTION

