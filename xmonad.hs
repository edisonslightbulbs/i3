-- xmonad config file
-- author : Everett
-- github : https://github.com/edisonslightbulbs
-- created: 2020-09-2020 17:59


-----------------------------------------------------------------------------
-- IMPORTS:
-----------------------------------------------------------------------------
import XMonad
import System.Exit
import XMonad.Hooks.ManageDocks
import XMonad.Util.Run
import XMonad.Util.SpawnOnce
import Data.Monoid
import XMonad.Layout.Spacing
import XMonad.Layout.IndependentScreens

import qualified XMonad.StackSet as W
import qualified Data.Map        as M

import qualified XMonad.Actions.DynamicWorkspaceOrder as DO
import XMonad.Actions.CycleWS
-----------------------------------------------------------------------------
-- INTERFACE:
-----------------------------------------------------------------------------
-- terminal
myTerminal = "tilix"

-- mouse focus
myClickJustFocuses :: Bool
myFocusFollowsMouse :: Bool
myClickJustFocuses = False
myFocusFollowsMouse = True

-- window border width (pixels) and color
myBorderWidth   = 2
myNormalBorderColor  ="#FDFEFE"
myFocusedBorderColor ="#2E4053"

-- windows mod key
myModMask       = mod4Mask

-- workspaces
myWorkspaces    = ["1","2","3","4","5","6","7","8","9"]

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
    ]


-----------------------------------------------------------------------------
-- KEY BINDINGS:
-----------------------------------------------------------------------------
myKeys conf@(XConfig {XMonad.modMask = modm}) = M.fromList $
    -----------
    -- UTILITY:
    -----------
    [
    -- dmenu
    ((modm, xK_d), spawn "dmenu_run")

    -- google
    , ((modm, xK_g), spawn "chromium")

    -- rofi
    , ((modm, xK_space), spawn "rofi -show run -theme Monokai")

    -- terminal
    , ((modm, xK_t), spawn $ XMonad.terminal conf)

    -- gmrun
    , ((modm .|. shiftMask, xK_p     ), spawn "gmrun")


    -- quit
    , ((modm .|. shiftMask, xK_q), io (exitWith ExitSuccess))

    -- restart
    , ((modm, xK_q), spawn "xmonad --recompile; xmonad --restart")

    ---------------------
    -- WINDOW NAVIGATION:
    ---------------------
    -- close focused window
    , ((modm, xK_c), kill)

    -- navigate focus
    , ((modm, xK_k), windows W.focusUp)
    , ((modm, xK_j), windows W.focusDown)

    -- clockwise cycle through windows
    , ((modm, xK_l), windows W.focusDown)

    -- focus master
    , ((modm, xK_h), windows W.focusMaster)

    -- swap focused window with master window
    , ((modm,xK_Return), windows W.swapMaster)

    -- swap focused window with next window
    , ((modm .|. shiftMask, xK_j), windows W.swapDown)

    -- swap focused window with previous window
    , ((modm .|. shiftMask, xK_k), windows W.swapUp)

    ----------
    -- LAYOUT:
    ----------
    -- equalize window sizes
    , ((modm, xK_n), refresh)

    --  increase master area size
    , ((modm .|. shiftMask, xK_h), sendMessage Shrink)

    --  decrease master area size
    , ((modm .|. shiftMask, xK_l), sendMessage Expand)

    -- rotate through layout algorithms
    , ((modm, xK_Tab), sendMessage NextLayout)

    -- reset current workspace layout to default
    , ((modm .|. shiftMask, xK_space), setLayout $ XMonad.layoutHook conf)

    -- toggle the status bar gap
    , ((modm, xK_b), sendMessage ToggleStruts)
    ]
    ++

    ----------------------
    --  SCREEN NAVIGATION:
    ----------------------
    -- using a single screen (default)
    -- [((m .|. modm, k), windows $ f i)
    --     | (i, k) <- zip (XMonad.workspaces conf) [xK_1 .. xK_9]
    --     , (f, m) <- [(W.greedyView, 0), (W.shift, shiftMask)]]

    -- using multiple screens
    [((m .|. modm, k), windows $ onCurrentScreen f i)
        | (i, k) <- zip (workspaces' conf) [xK_1 .. xK_9]
        , (f, m) <- [(W.greedyView, 0), (W.shift, shiftMask)]]
    ++

    -- specifying the order of the screens [0, 1, 2]
    [((m .|. modm, key), screenWorkspace sc >>= flip whenJust (windows . f))
        | (key, sc) <- zip [xK_comma, xK_period, xK_r] [0, 2, 1] -- was [0..] ** default
        , (f, m) <- [(W.view, 0), (W.shift, shiftMask)]]


-----------------------------------------------------------------------------
-- WORKSPACE LAYOUT:
-----------------------------------------------------------------------------
myLayout = avoidStruts (tiled ||| Mirror tiled ||| Full)
  where
     tiled   = spacingRaw True (Border 8 8 8 8) True (Border 8 8 8 8) True $ layoutHook def
     nmaster = 1
     ratio   = 1/2
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
-- ON STARTUP:
-----------------------------------------------------------------------------
myStartupHook = do
    spawnOnce "$HOME/.xmonad/util/screen-config.sh &"
    spawnOnce "compton -f &"
    spawnOnce "nitrogen --restore &"


-----------------------------------------------------------------------------
-- RUN XMONAD:
-----------------------------------------------------------------------------
main = do
    xmproc <- spawnPipe "xmobar -x 0 ~/.config/xmobar/xmobar-0.config"
    xmproc <- spawnPipe "xmobar -x 2 ~/.config/xmobar/xmobar-1.config"
    xmonad $ docks defaults

defaults = def {
        terminal           = myTerminal,
        focusFollowsMouse  = myFocusFollowsMouse,
        clickJustFocuses   = myClickJustFocuses,
        borderWidth        = myBorderWidth,
        modMask            = myModMask,
        workspaces         = withScreens 3 (myWorkspaces),
        normalBorderColor  = myNormalBorderColor,
        focusedBorderColor = myFocusedBorderColor,
        keys               = myKeys,
        mouseBindings      = myMouseBindings,
        layoutHook         = myLayout,
        manageHook         = myManageHook,
        startupHook        = myStartupHook
    }
