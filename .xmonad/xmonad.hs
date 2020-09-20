-----------------------------------------------------------------------------
-- xmonad config file
-- author : Everett
-- github : https://github.com/edisonslightbulbs
-- created: 2020-09-2020 17:59
-----------------------------------------------------------------------------


-----------------------------------------------------------------------------
-- IMPORTS:
-----------------------------------------------------------------------------
import XMonad
import System.Exit
import XMonad.Hooks.ManageDocks
import XMonad.Util.Run
import XMonad.Util.SpawnOnce
import Data.Monoid

import qualified XMonad.StackSet as W
import qualified Data.Map        as M

import XMonad.Layout.Spacing
import XMonad.Hooks.FadeWindows

-----------------------------------------------------------------------------
-- INTERFACE:
-----------------------------------------------------------------------------
-- terminal
myTerminal      = "tilix"

-- mouse-following focus
myClickJustFocuses :: Bool
myFocusFollowsMouse :: Bool
myClickJustFocuses = False
myFocusFollowsMouse = True

-- window border width (pixels) and color
myBorderWidth   = 1
myNormalBorderColor  = "#dddddd"
myFocusedBorderColor = "#1ABC9C"

-- windows mod key
myModMask       = mod4Mask

-- workspaces
myWorkspaces    = ["1","2","3","4","5","6","7","8","9"]


-----------------------------------------------------------------------------
-- KEY BINDINGS:
-----------------------------------------------------------------------------
myKeys conf@(XConfig {XMonad.modMask = modm}) = M.fromList $

    -------------------------------------------------------------------------
    -- UTILITY:
    -------------------------------------------------------------------------
    [
    -- dmenu
    ((modm, xK_d), spawn "dmenu_run")

    -- terminal
    , ((modm, xK_t), spawn $ XMonad.terminal conf)

    -- gmrun
    , ((modm .|. shiftMask, xK_p     ), spawn "gmrun")


    -- quit
    , ((modm .|. shiftMask, xK_q), io (exitWith ExitSuccess))

    -- restart
    , ((modm, xK_q), spawn "xmonad --recompile; xmonad --restart")

    -------------------------------------------------------------------------
    -- WINDOW TILE NAVIGATION:
    -------------------------------------------------------------------------
    -- close focused window
    , ((modm, xK_c), kill)

    -- focus master
    , ((modm, xK_m), windows W.focusMaster)

    -- navigate focus
    , ((modm, xK_k), windows W.focusUp)
    , ((modm, xK_j), windows W.focusDown)

    -- swap focused window with master window
    , ((modm,xK_Return), windows W.swapMaster)

    -- swap focused window with next window
    , ((modm .|. shiftMask, xK_j), windows W.swapDown)

    -- swap focused window with previous window
    , ((modm .|. shiftMask, xK_k), windows W.swapUp)

    -------------------------------------------------------------------------
    -- LAYOUT:
    -------------------------------------------------------------------------
    -- equalize window sizes
    , ((modm, xK_n), refresh)

    --  increase master area size
    , ((modm, xK_h), sendMessage Shrink)

    --  decrease master area size
    , ((modm, xK_l), sendMessage Expand)

    -- clockwise cycle through windows
    , ((modm, xK_Tab), windows W.focusDown)

    -- rotate through layout algorithms
    , ((modm, xK_space), sendMessage NextLayout)

    -- move window in master space back into tiling
    , ((modm, xK_t), withFocused $ windows . W.sink)

    -- add number of windows in master area
    , ((modm, xK_comma), sendMessage (IncMasterN 1))

    -- remove number of windows in master area
    , ((modm, xK_period), sendMessage (IncMasterN (-1)))

    -- reset current workspace layout to default
    , ((modm .|. shiftMask, xK_space), setLayout $ XMonad.layoutHook conf)

    -- toggle the status bar gap
    , ((modm, xK_b), sendMessage ToggleStruts)

    -- show keymaps (to update)
    , ((modm .|. shiftMask, xK_slash ), spawn ("echo \"" ++ help ++ "\" | xmessage -file -"))
    ]
    ++


    -------------------------------------------------------------------------
    --  WORKSPACE NAVIGATION:
    -------------------------------------------------------------------------
    [((m .|. modm, k), windows $ f i)
        | (i, k) <- zip (XMonad.workspaces conf) [xK_1 .. xK_9]
        , (f, m) <- [(W.greedyView, 0), (W.shift, shiftMask)]]
    ++

    [((m .|. modm, key), screenWorkspace sc >>= flip whenJust (windows . f))
        | (key, sc) <- zip [xK_w, xK_e, xK_r] [0..]
        , (f, m) <- [(W.view, 0), (W.shift, shiftMask)]]


-----------------------------------------------------------------------------
-- MOUSE BINDINGS:
-----------------------------------------------------------------------------
myMouseBindings (XConfig {XMonad.modMask = modm}) = M.fromList $

    -- mod-button1, Set the window to floating mode and move by dragging
    [ ((modm, button1), (\w -> focus w >> mouseMoveWindow w
                                       >> windows W.shiftMaster))

    -- mod-button2, Raise the window to the top of the stack
    , ((modm, button2), (\w -> focus w >> windows W.shiftMaster))

    -- mod-button3, Set the window to floating mode and resize by dragging
    , ((modm, button3), (\w -> focus w >> mouseResizeWindow w
                                       >> windows W.shiftMaster))

    -- you may also bind events to the mouse scroll wheel (button4 and button5)
    ]


-----------------------------------------------------------------------------
-- WORKSPACE LAYOUT:
--   If you change layout bindings be sure to use 'mod-shift-space' after
--   restarting (with 'mod-q') to reset your layout state to the new.
-----------------------------------------------------------------------------
myLayout = avoidStruts (tiled ||| Mirror tiled ||| Full)
  where
     -- default tiling algorithm partitions the screen into two panes
     tiled = spacingRaw True (Border 8 8 8 8) True (Border 8 8 8 8) True $
             layoutHook def

     -- The default number of windows in the master pane
     nmaster = 1

     -- Default proportion of screen occupied by master pane
     ratio   = 1/2

     -- Percent of screen to increment by when resizing panes
     delta   = 3/100


-----------------------------------------------------------------------------
-- WINDOW RULES:
-----------------------------------------------------------------------------
myManageHook = composeAll
    [ className =? "MPlayer"        --> doFloat
    , className =? "Gimp"           --> doFloat
    , resource  =? "desktop_window" --> doIgnore
    , resource  =? "kdesktop"       --> doIgnore ]


-----------------------------------------------------------------------------
-- AUTO EVENTS:
-----------------------------------------------------------------------------
myEventHook = mempty


-----------------------------------------------------------------------------
-- TRANSPARENCY HOOK:
-----------------------------------------------------------------------------

-----------------------------------------------------------------------------
-- LOGGING:
-----------------------------------------------------------------------------
myLogHook = return ()


-----------------------------------------------------------------------------
-- STARTUP DEFAULTS:
-----------------------------------------------------------------------------
myStartupHook = do
    spawnOnce "nitrogen --restore &"
    spawnOnce "compton -f &"
    spawnOnce "tilix &"
    spawnOnce "chromium &"


-----------------------------------------------------------------------------
-- RUN CONFIG:
-----------------------------------------------------------------------------
main = do
    xmproc <- spawnPipe "xmobar -x 0 ~/.config/xmobar/xmobar.config"
    xmproc <- spawnPipe "xmobar -x 1 ~/.config/xmobar/xmobar.config"
    xmproc <- spawnPipe "xmobar -x 2 ~/.config/xmobar/xmobar.config"
    xmonad $ docks defaults

defaults = def {
        terminal           = myTerminal,
        focusFollowsMouse  = myFocusFollowsMouse,
        clickJustFocuses   = myClickJustFocuses,
        borderWidth        = myBorderWidth,
        modMask            = myModMask,
        workspaces         = myWorkspaces,
        normalBorderColor  = myNormalBorderColor,
        focusedBorderColor = myFocusedBorderColor,
        keys               = myKeys,
        mouseBindings      = myMouseBindings,
        layoutHook         = myLayout,
        manageHook         = myManageHook,
        handleEventHook    = myEventHook,
        logHook            = myLogHook,
        startupHook        = myStartupHook
    }


-----------------------------------------------------------------------------
-- HELP:
-----------------------------------------------------------------------------
help :: String
help = unlines ["The default modifier key is 'alt'. Default keybindings:",
    "",
    "-- launching and killing programs",
    "mod-Shift-Enter  Launch xterminal",
    "mod-p            Launch dmenu",
    "mod-Shift-p      Launch gmrun",
    "mod-Shift-c      Close/kill the focused window",
    "mod-Space        Rotate through the available layout algorithms",
    "mod-Shift-Space  Reset the layouts on the current workSpace to default",
    "mod-n            Resize/refresh viewed windows to the correct size",
    "",
    "-- move focus up or down the window stack",
    "mod-Tab        Move focus to the next window",
    "mod-Shift-Tab  Move focus to the previous window",
    "mod-j          Move focus to the next window",
    "mod-k          Move focus to the previous window",
    "mod-m          Move focus to the master window",
    "",
    "-- modifying the window order",
    "mod-Return   Swap the focused window and the master window",
    "mod-Shift-j  Swap the focused window with the next window",
    "mod-Shift-k  Swap the focused window with the previous window",
    "",
    "-- resizing the master/slave ratio",
    "mod-h  Shrink the master area",
    "mod-l  Expand the master area",
    "",
    "-- floating layer support",
    "mod-t  Push window back into tiling; unfloat and re-tile it",
    "",
    "-- increase or decrease number of windows in the master area",
    "mod-comma  (mod-,)   Increment the number of windows in the master area",
    "mod-period (mod-.)   Deincrement the number of windows in the master area",
    "",
    "-- quit, or restart",
    "mod-Shift-q  Quit xmonad",
    "mod-q        Restart xmonad",
    "mod-[1..9]   Switch to workSpace N",
    "",
    "-- Workspaces & screens",
    "mod-Shift-[1..9]   Move client to workspace N",
    "mod-{w,e,r}        Switch to physical/Xinerama screens 1, 2, or 3",
    "mod-Shift-{w,e,r}  Move client to screen 1, 2, or 3",
    "",
    "-- Mouse bindings: default actions bound to mouse events",
    "mod-button1  Set the window to floating mode and move by dragging",
    "mod-button2  Raise the window to the top of the stack",
    "mod-button3  Set the window to floating mode and resize by dragging"]
