#ifndef SPORG_UICOMMON_SHARED_VISUAL_HPP
#define SPORG_UICOMMON_SHARED_VISUAL_HPP

// UICommon 0.2-D R1 — compile-time visual foundation.
// Generic presentation only. No Items/Weapons domain semantics or event routing.

// Pixel-aspect-safe common metrics.
#define SPORG_UICOMMON_UI_CLEAR_H (0.031 * safeZoneH)
#define SPORG_UICOMMON_UI_CLEAR_W (SPORG_UICOMMON_UI_CLEAR_H * pixelW / pixelH)
#define SPORG_UICOMMON_UI_ICON_H (0.027 * safeZoneH)
#define SPORG_UICOMMON_UI_ICON_W (SPORG_UICOMMON_UI_ICON_H * pixelW / pixelH)
#define SPORG_UICOMMON_UI_HEADER_RIGHT_X (safeZoneX + 0.982 * safeZoneW)
#define SPORG_UICOMMON_UI_HEADER_GAP_W (0.006 * safeZoneW)
#define SPORG_UICOMMON_UI_HEADER_CLOSE_X (SPORG_UICOMMON_UI_HEADER_RIGHT_X - SPORG_UICOMMON_UI_ICON_W)
#define SPORG_UICOMMON_UI_HEADER_FUTURE_X (SPORG_UICOMMON_UI_HEADER_CLOSE_X - SPORG_UICOMMON_UI_HEADER_GAP_W - SPORG_UICOMMON_UI_ICON_W)
#define SPORG_UICOMMON_UI_HEADER_ID_W (0.102 * safeZoneW)
#define SPORG_UICOMMON_UI_HEADER_ID_X (SPORG_UICOMMON_UI_HEADER_FUTURE_X - SPORG_UICOMMON_UI_HEADER_GAP_W - SPORG_UICOMMON_UI_HEADER_ID_W)
#define SPORG_UICOMMON_UI_SEARCH_H (0.025 * safeZoneH)
#define SPORG_UICOMMON_UI_SEARCH_W (SPORG_UICOMMON_UI_SEARCH_H * pixelW / pixelH)
#define SPORG_UICOMMON_UI_SEARCH_GAP_W (0.004 * safeZoneH * pixelW / pixelH)

class SPORG_UICommon_Text
{
    type = 0; idc = -1; style = 0; text = ""; x = 0; y = 0; w = 0; h = 0;
    font = "RobotoCondensed"; sizeEx = 0.018 * safeZoneH;
    colorText[] = {0.88,0.91,0.91,1}; colorBackground[] = {0,0,0,0}; shadow = 1; lineSpacing = 1;
};
class SPORG_UICommon_Title: SPORG_UICommon_Text
{
    sizeEx = 0.019 * safeZoneH; colorText[] = {0.75,0.92,0.88,1};
};
class SPORG_UICommon_Picture: SPORG_UICommon_Text
{
    style = 48; colorText[] = {1,1,1,1};
};
class SPORG_UICommon_PictureKeepAspect: SPORG_UICommon_Text
{
    style = 2096; colorText[] = {1,1,1,1};
};
class SPORG_UICommon_SearchIcon: SPORG_UICommon_Picture
{
    text = "\a3\ui_f\data\igui\cfg\simpletasks\types\search_ca.paa";
    colorText[] = {0.72,0.84,0.82,0.9};
};
class SPORG_UICommon_SearchIconKeepAspect: SPORG_UICommon_PictureKeepAspect
{
    text = "\a3\ui_f\data\igui\cfg\simpletasks\types\search_ca.paa";
    colorText[] = {0.72,0.84,0.82,0.9};
};

class SPORG_UICommon_Button
{
    type = 1; idc = -1; style = 2; text = ""; x = 0; y = 0; w = 0; h = 0;
    font = "RobotoCondensed"; sizeEx = 0.016 * safeZoneH;
    colorText[] = {0.88,0.91,0.91,1}; colorDisabled[] = {0.40,0.43,0.43,1};
    colorBackground[] = {0.08,0.11,0.12,0.58}; colorBackgroundDisabled[] = {0.04,0.05,0.05,0.34};
    colorBackgroundActive[] = {0.12,0.19,0.18,0.76}; colorFocused[] = {0.12,0.19,0.18,0.76};
    colorShadow[] = {0,0,0,0}; colorBorder[] = {0,0,0,0};
    soundEnter[] = {"",0.09,1}; soundPush[] = {"",0.09,1}; soundClick[] = {"",0.09,1}; soundEscape[] = {"",0.09,1};
    offsetX = 0; offsetY = 0; offsetPressedX = 0; offsetPressedY = 0; borderSize = 0; shadow = 0;
};
class SPORG_UICommon_ButtonDanger: SPORG_UICommon_Button
{
    colorText[] = {1,0.76,0.76,1}; colorBackground[] = {0.32,0.07,0.07,0.62};
    colorBackgroundActive[] = {0.55,0.08,0.08,0.82}; colorFocused[] = {0.55,0.08,0.08,0.82};
};
class SPORG_UICommon_IconButton: SPORG_UICommon_Button
{
    sizeEx = 0.014 * safeZoneH;
};
class SPORG_UICommon_Edit
{
    type = 2; idc = -1; style = 64; text = ""; x = 0; y = 0; w = 0; h = 0;
    font = "RobotoCondensed"; sizeEx = 0.016 * safeZoneH; autocomplete = "";
    colorText[] = {0.92,0.94,0.94,1}; colorDisabled[] = {0.45,0.47,0.47,1};
    colorSelection[] = {0.12,0.32,0.38,1}; colorBackground[] = {0.015,0.02,0.022,0.42}; canModify = 1; shadow = 0;
};
class SPORG_UICommon_List
{
    type = 5; idc = -1; style = 16; x = 0; y = 0; w = 0; h = 0;
    font = "RobotoCondensed"; sizeEx = 0.016 * safeZoneH; rowHeight = 0.027 * safeZoneH;
    colorText[] = {0.86,0.89,0.89,1}; colorDisabled[] = {0.45,0.47,0.47,1}; colorScrollbar[] = {0.60,0.66,0.66,1};
    colorSelect[] = {1,1,1,1}; colorSelect2[] = {1,1,1,1};
    colorSelectBackground[] = {0.12,0.32,0.38,0.64}; colorSelectBackground2[] = {0.12,0.32,0.38,0.64};
    colorPicture[] = {1,1,1,1}; colorPictureSelected[] = {1,1,1,1}; colorPictureDisabled[] = {0.62,0.62,0.62,1};
    colorPictureRight[] = {1,1,1,1}; colorPictureRightSelected[] = {1,1,1,1}; colorPictureRightDisabled[] = {0.62,0.62,0.62,1};
    colorBackground[] = {0.01,0.015,0.017,0.34}; soundSelect[] = {"",0.10,1};
    period = 1.2; maxHistoryDelay = 1; autoScrollSpeed = -1; autoScrollDelay = 5; autoScrollRewind = 0; shadow = 0;
    class ListScrollBar {color[] = {0.60,0.66,0.66,1}; autoScrollEnabled = 1;};
};
class SPORG_UICommon_Structured
{
    type = 13; idc = -1; style = 0; text = ""; x = 0; y = 0; w = 0; h = 0;
    size = 0.016 * safeZoneH; colorText[] = {0.88,0.91,0.91,1}; colorBackground[] = {0,0,0,0}; shadow = 1;
    class Attributes {font = "RobotoCondensed"; color = "#DFE6E6"; align = "left"; shadow = 1;};
};
class SPORG_UICommon_FooterContext: SPORG_UICommon_Structured {size = 0.0170 * safeZoneH;};
class SPORG_UICommon_FooterMessage: SPORG_UICommon_Structured {size = 0.0165 * safeZoneH;};
class SPORG_UICommon_FooterHistory: SPORG_UICommon_Structured {size = 0.0145 * safeZoneH;};
class SPORG_UICommon_VSlider
{
    type = 3; idc = -1; style = 0; text = ""; x = 0; y = 0; w = 0; h = 0;
    color[] = {0.60,0.66,0.66,0.85}; colorActive[] = {0.80,0.86,0.86,1}; colorDisabled[] = {0.35,0.38,0.38,0.45};
    sliderRange[] = {0,1}; sliderPosition = 0; sliderStep = 1; lineSize = 6; pageSize = 32; shadow = 0;
};

#endif
