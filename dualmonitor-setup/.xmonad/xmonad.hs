-- xmonad config file
-- author : Everett
-- github : https://github.com/edisonslightbulbs
-- created: 2020-09-2020 17:59

-- essential defaults
import XMonad
import System.Exit
import XMonad.Hooks.ManageDocks
import XMonad.Util.Run
import XMonad.Util.SpawnOnce
import Data.Monoid
import XMonad.Layout.Spacing
import qualified XMonad.StackSet as W
import qualified Data.Map        as M

-- for managing screen-workspaces
import qualified XMonad.Actions.DynamicWorkspaceOrder as DO
import XMonad.Layout.IndependentScreens
import XMonad.Actions.CycleWS

-- for dynamic logging for xmobar
import XMonad.Hooks.DynamicLog

-- for fading windows
import XMonad.Hooks.FadeInactive (fadeInactiveLogHook)

-- for sound keys
import Graphics.X11.ExtraTypes.XF86

-- for border-less windows
import XMonad.Layout.NoBorders

-- for finding the number of X11 screens
import Graphics.X11.Xinerama (getScreenInfo)

-- for dynamic handling of xmobar
import XMonad.Hooks.DynamicBars

-- for handing full screen modes from web browsers
import XMonad.Hooks.EwmhDesktops

-- ESSENTIALS:
-----------------------------------------------------------------------------
myTerminal           = "tilix"
myModMask            = mod4Mask
myWorkspaces         = ["1","2","3","4","5","6","7","8","9"]


-- THEME:
-----------------------------------------------------------------------------
myBorderWidth        = 0
myNormalBorderColor  ="#CACFD2"
myFocusedBorderColor ="#8E44AD"


-- MOUSE ACTIONS:
-----------------------------------------------------------------------------
myClickJustFocuses   :: Bool
myFocusFollowsMouse  :: Bool

myClickJustFocuses   = False
myFocusFollowsMouse  = True

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


-- KEY MAPPING:
-----------------------------------------------------------------------------
myKeys conf@(XConfig {XMonad.modMask = modm}) = M.fromList $
    [
    -- APPS:
    --------
    -- dmenu
    ((modm, xK_d), spawn "dmenu_run")

    -- google
    , ((modm, xK_g), spawn "chromium")

    -- logout
    , ((modm, xK_q), io (exitWith ExitSuccess))

    -- terminal
    , ((modm, xK_t), spawn $ XMonad.terminal conf)

    -- gmrun
    , ((modm .|. shiftMask, xK_p     ), spawn "gmrun")

    -- rofi
    , ((modm, xK_space), spawn "rofi -show run -theme Monokai")


    -- NAVIGATION:
    --------------
    -- reload
    , ((modm, xK_r), spawn "xmonad --recompile; xmonad --restart")

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

    -- sound keys
    , ((0, xF86XK_AudioMute), spawn "pactl set-sink-mute @DEFAULT_SINK@ toggle")
    , ((0, xF86XK_AudioLowerVolume), spawn "pactl set-sink-volume @DEFAULT_SINK@ -10%")
    , ((0, xF86XK_AudioRaiseVolume), spawn "pactl set-sink-volume @DEFAULT_SINK@ +10%")
    ]
    ++

    --  SINGLE MONITOR-WORKSPACE CONFIG:
    ------------------------------------
    -- [((m .|. modm, k), windows $ f i)
    --     | (i, k) <- zip (XMonad.workspaces conf) [xK_1 .. xK_9]
    --     , (f, m) <- [(W.greedyView, 0), (W.shift, shiftMask)]]
    -- ++

    -- [((m .|. modm, key), screenWorkspace sc >>= flip whenJust (windows . f))
    --     | (key, sc) <- zip [xK_w, xK_e, xK_0] [0..]
    --     , (f, m) <- [(W.view, 0), (W.shift, shiftMask)]]


    --  DOUBLE MONITOR-WORKSPACE CONFIG:
    ------------------------------------
    [((m .|. modm, k), windows $ onCurrentScreen f i)
        | (i, k) <- zip (workspaces' conf) [xK_1 .. xK_9]
        , (f, m) <- [(W.greedyView, 0), (W.shift, shiftMask)]]
    ++

    -- switch screens 1 and 2 using mod + [<] and [>]
    [((m .|. modm, key), screenWorkspace sc >>= flip whenJust (windows . f))
        | (key, sc) <- zip [xK_period, xK_comma] [1, 0]
        , (f, m) <- [(W.view, 0), (W.shift, shiftMask)]]



-- LAYOUT:
-----------------------------------------------------------------------------
myLayout = avoidStruts $ noBorders $ tiled ||| Mirror tiled ||| Full

   where
      tiled   = spacingRaw True (Border 5 5 5 5) True (Border 5 5 5 5) True $ layoutHook def
      nmaster = 1
      ratio   = 1/2
      delta   = 3/100


-- WINDOW RULES:
-----------------------------------------------------------------------------
myManageHook = composeAll
    [ className =? "MPlayer"        --> doFloat
    , className =? "Gimp"           --> doFloat
    , resource  =? "desktop_window" --> doIgnore
    , resource  =? "kdesktop"       --> doIgnore ]

myFadeHook = do
    fadeInactiveLogHook 0.7

-- ON STARTUP:
-----------------------------------------------------------------------------
myStartupHook = do
    spawnOnce "$HOME/.xmonad/util/layout.sh &"


-- MAIN:
-----------------------------------------------------------------------------

main = do
    -- unique instances of xmobar
    xmobarScreenOne <- spawnPipe "xmobar -x 0"
    xmobarScreenTwo <- spawnPipe "xmobar -x 1"

    xmonad $ docks def {
    --xmonad $ def {

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

        -- hooks --
        layoutHook         = myLayout,
        manageHook         = myManageHook,
        startupHook        = myStartupHook,
        handleEventHook    = fullscreenEventHook,

        logHook            = composeAll [
            myFadeHook,
            dynamicLogWithPP xmobarPP {
                ppOutput   = \x -> hPutStrLn xmobarScreenOne x  >> hPutStrLn xmobarScreenTwo x,
                ppCurrent  = xmobarColor "#979A9A" "" . wrap "" "",
                ppTitle    = xmobarColor "#979A9A" "" . shorten 100
            }
        ]
    }

-----------------------------------------------------------------------------
