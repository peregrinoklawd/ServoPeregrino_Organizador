// SP_ORG_Items 0.13-A — Server Authority Foundation
// 0.9 preserves Draft Direct Manipulation and physical OFF.
// 0.9 hardens two manual interaction contracts: drag release outside the target must cancel cleanly,
// and Return/Numpad Enter must commit direct quantity edits. Responsive/visual behavior from 0.8.2 is preserved.

// Pixel-aspect-safe metrics. Width is derived from a height using pixelW/pixelH so square
// controls remain square on 16:9, 21:9 and ultrawide/32:9 displays.
#define SPORG_ITEMS_UI_CLEAR_H (0.031 * safeZoneH)
#define SPORG_ITEMS_UI_CLEAR_W (SPORG_ITEMS_UI_CLEAR_H * pixelW / pixelH)
#define SPORG_ITEMS_UI_ICON_H (0.027 * safeZoneH)
#define SPORG_ITEMS_UI_ICON_W (SPORG_ITEMS_UI_ICON_H * pixelW / pixelH)
#define SPORG_ITEMS_UI_HEADER_RIGHT_X (safeZoneX + 0.982 * safeZoneW)
#define SPORG_ITEMS_UI_HEADER_GAP_W (0.006 * safeZoneW)
#define SPORG_ITEMS_UI_HEADER_CLOSE_X (SPORG_ITEMS_UI_HEADER_RIGHT_X - SPORG_ITEMS_UI_ICON_W)
#define SPORG_ITEMS_UI_HEADER_FUTURE_X (SPORG_ITEMS_UI_HEADER_CLOSE_X - SPORG_ITEMS_UI_HEADER_GAP_W - SPORG_ITEMS_UI_ICON_W)
#define SPORG_ITEMS_UI_HEADER_ID_W (0.102 * safeZoneW)
#define SPORG_ITEMS_UI_HEADER_ID_X (SPORG_ITEMS_UI_HEADER_FUTURE_X - SPORG_ITEMS_UI_HEADER_GAP_W - SPORG_ITEMS_UI_HEADER_ID_W)
#define SPORG_ITEMS_UI_HEADER_LOAD_W (0.188 * safeZoneW)
#define SPORG_ITEMS_UI_HEADER_LOAD_X (SPORG_ITEMS_UI_HEADER_ID_X - SPORG_ITEMS_UI_HEADER_GAP_W - SPORG_ITEMS_UI_HEADER_LOAD_W)
#define SPORG_ITEMS_UI_COMPACT_H (0.030 * safeZoneH)
#define SPORG_ITEMS_UI_COMPACT_W (SPORG_ITEMS_UI_COMPACT_H * pixelW / pixelH)
#define SPORG_ITEMS_UI_COMPACT_GAP_W (0.004 * safeZoneH * pixelW / pixelH)
#define SPORG_ITEMS_UI_SEARCH_H (0.025 * safeZoneH)
#define SPORG_ITEMS_UI_SEARCH_W (SPORG_ITEMS_UI_SEARCH_H * pixelW / pixelH)
#define SPORG_ITEMS_UI_SEARCH_GAP_W (0.004 * safeZoneH * pixelW / pixelH)
#define SPORG_ITEMS_ROW_H (0.029 * safeZoneH)
#define SPORG_ITEMS_ROW_SQUARE_W (SPORG_ITEMS_ROW_H * pixelW / pixelH)
#define SPORG_ITEMS_ROW_GAP_W (0.004 * safeZoneH * pixelW / pixelH)
#define SPORG_ITEMS_ROW_PAD_W (0.004 * safeZoneH * pixelW / pixelH)
#define SPORG_ITEMS_ROW_QTY_W (1.45 * SPORG_ITEMS_ROW_SQUARE_W)
#define SPORG_ITEMS_ROW_CONTENT_W (0.222 * safeZoneW)
#define SPORG_ITEMS_ROW_DELETE_X (SPORG_ITEMS_ROW_CONTENT_W - SPORG_ITEMS_ROW_PAD_W - SPORG_ITEMS_ROW_SQUARE_W)
#define SPORG_ITEMS_ROW_PLUS_X (SPORG_ITEMS_ROW_DELETE_X - SPORG_ITEMS_ROW_GAP_W - SPORG_ITEMS_ROW_SQUARE_W)
#define SPORG_ITEMS_ROW_QTY_X (SPORG_ITEMS_ROW_PLUS_X - SPORG_ITEMS_ROW_GAP_W - SPORG_ITEMS_ROW_QTY_W)
#define SPORG_ITEMS_ROW_MINUS_X (SPORG_ITEMS_ROW_QTY_X - SPORG_ITEMS_ROW_GAP_W - SPORG_ITEMS_ROW_SQUARE_W)
#define SPORG_ITEMS_ROW_NAME_X (SPORG_ITEMS_ROW_PAD_W + SPORG_ITEMS_ROW_SQUARE_W + SPORG_ITEMS_ROW_GAP_W)
#define SPORG_ITEMS_ROW_NAME_W (SPORG_ITEMS_ROW_MINUS_X - SPORG_ITEMS_ROW_GAP_W - SPORG_ITEMS_ROW_NAME_X)

// Equipment table uses the same interaction vocabulary as Draft, but a narrower geometry.
#define SPORG_ITEMS_EQ_ROW_CONTENT_W (0.158 * safeZoneW)
#define SPORG_ITEMS_EQ_ROW_PAD_W (0.003 * safeZoneH * pixelW / pixelH)
#define SPORG_ITEMS_EQ_ROW_SQUARE_W (0.024 * safeZoneH * pixelW / pixelH)
#define SPORG_ITEMS_EQ_ROW_GAP_W (0.0025 * safeZoneH * pixelW / pixelH)
#define SPORG_ITEMS_EQ_ROW_QTY_W (1.42 * SPORG_ITEMS_EQ_ROW_SQUARE_W)
#define SPORG_ITEMS_EQ_ROW_DELETE_X (SPORG_ITEMS_EQ_ROW_CONTENT_W - SPORG_ITEMS_EQ_ROW_PAD_W - SPORG_ITEMS_EQ_ROW_SQUARE_W)
#define SPORG_ITEMS_EQ_ROW_PLUS_X (SPORG_ITEMS_EQ_ROW_DELETE_X - SPORG_ITEMS_EQ_ROW_GAP_W - SPORG_ITEMS_EQ_ROW_SQUARE_W)
#define SPORG_ITEMS_EQ_ROW_QTY_X (SPORG_ITEMS_EQ_ROW_PLUS_X - SPORG_ITEMS_EQ_ROW_GAP_W - SPORG_ITEMS_EQ_ROW_QTY_W)
#define SPORG_ITEMS_EQ_ROW_MINUS_X (SPORG_ITEMS_EQ_ROW_QTY_X - SPORG_ITEMS_EQ_ROW_GAP_W - SPORG_ITEMS_EQ_ROW_SQUARE_W)
#define SPORG_ITEMS_EQ_ROW_CAPTURE_X (SPORG_ITEMS_EQ_ROW_PAD_W)
#define SPORG_ITEMS_EQ_ROW_PICTURE_X (SPORG_ITEMS_EQ_ROW_CAPTURE_X + SPORG_ITEMS_EQ_ROW_SQUARE_W + SPORG_ITEMS_EQ_ROW_GAP_W)
#define SPORG_ITEMS_EQ_ROW_NAME_X (SPORG_ITEMS_EQ_ROW_PICTURE_X + SPORG_ITEMS_EQ_ROW_SQUARE_W + SPORG_ITEMS_EQ_ROW_GAP_W)
#define SPORG_ITEMS_EQ_ROW_NAME_W (SPORG_ITEMS_EQ_ROW_MINUS_X - SPORG_ITEMS_EQ_ROW_GAP_W - SPORG_ITEMS_EQ_ROW_NAME_X)

// Catalog real-row buttons: mesmo vocabulário visual do Equipment/APM, com ações reais nas bordas.
#define SPORG_ITEMS_CAT_ROW_CONTENT_W (0.292 * safeZoneW)
#define SPORG_ITEMS_CAT_ROW_PAD_W (0.003 * safeZoneH * pixelW / pixelH)
#define SPORG_ITEMS_CAT_ROW_SQUARE_W (0.024 * safeZoneH * pixelW / pixelH)
#define SPORG_ITEMS_CAT_ROW_GAP_W (0.003 * safeZoneH * pixelW / pixelH)
#define SPORG_ITEMS_CAT_ROW_DRAFT_X (SPORG_ITEMS_CAT_ROW_PAD_W)
#define SPORG_ITEMS_CAT_ROW_PICTURE_X (SPORG_ITEMS_CAT_ROW_DRAFT_X + SPORG_ITEMS_CAT_ROW_SQUARE_W + SPORG_ITEMS_CAT_ROW_GAP_W)
#define SPORG_ITEMS_CAT_ROW_PHYSICAL_X (SPORG_ITEMS_CAT_ROW_CONTENT_W - SPORG_ITEMS_CAT_ROW_PAD_W - SPORG_ITEMS_CAT_ROW_SQUARE_W)
#define SPORG_ITEMS_CAT_ROW_NAME_X (SPORG_ITEMS_CAT_ROW_PICTURE_X + SPORG_ITEMS_CAT_ROW_SQUARE_W + SPORG_ITEMS_CAT_ROW_GAP_W)
#define SPORG_ITEMS_CAT_ROW_NAME_W (SPORG_ITEMS_CAT_ROW_PHYSICAL_X - SPORG_ITEMS_CAT_ROW_GAP_W - SPORG_ITEMS_CAT_ROW_NAME_X)

class SPORG_Items_Text
{
    type = 0; idc = -1; style = 0; text = ""; x = 0; y = 0; w = 0; h = 0;
    font = "RobotoCondensed"; sizeEx = 0.018 * safeZoneH;
    colorText[] = {0.88,0.91,0.91,1}; colorBackground[] = {0,0,0,0}; shadow = 1; lineSpacing = 1;
};
class SPORG_Items_Title: SPORG_Items_Text {sizeEx = 0.019 * safeZoneH; colorText[] = {0.75,0.92,0.88,1};};
class SPORG_Items_Picture: SPORG_Items_Text {style = 48; colorText[] = {1,1,1,1};};
class SPORG_Items_SearchIcon: SPORG_Items_Picture {text="\a3\ui_f\data\igui\cfg\simpletasks\types\search_ca.paa"; colorText[]={0.72,0.84,0.82,0.9};};

class SPORG_Items_Button
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
class SPORG_Items_ButtonDanger: SPORG_Items_Button
{
    colorText[] = {1,0.76,0.76,1}; colorBackground[] = {0.32,0.07,0.07,0.62};
    colorBackgroundActive[] = {0.55,0.08,0.08,0.82}; colorFocused[] = {0.55,0.08,0.08,0.82};
};
class SPORG_Items_IconButton: SPORG_Items_Button {sizeEx = 0.014 * safeZoneH;};
class SPORG_Items_Edit
{
    type = 2; idc = -1; style = 64; text = ""; x = 0; y = 0; w = 0; h = 0;
    font = "RobotoCondensed"; sizeEx = 0.016 * safeZoneH; autocomplete = "";
    colorText[] = {0.92,0.94,0.94,1}; colorDisabled[] = {0.45,0.47,0.47,1};
    colorSelection[] = {0.12,0.32,0.38,1}; colorBackground[] = {0.015,0.02,0.022,0.42}; canModify = 1; shadow = 0;
};
class SPORG_Items_List
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
class SPORG_Items_VSlider
{
    type = 3; idc = -1; style = 0; text = ""; x = 0; y = 0; w = 0; h = 0;
    color[] = {0.60,0.66,0.66,0.85}; colorActive[] = {0.80,0.86,0.86,1}; colorDisabled[] = {0.35,0.38,0.38,0.45};
    sliderRange[] = {0,1}; sliderPosition = 0; sliderStep = 1; lineSize = 6; pageSize = 32; shadow = 0;
};
class SPORG_Items_Structured
{
    type = 13; idc = -1; style = 0; text = ""; x = 0; y = 0; w = 0; h = 0;
    size = 0.016 * safeZoneH; colorText[] = {0.88,0.91,0.91,1}; colorBackground[] = {0,0,0,0}; shadow = 1;
    class Attributes {font = "RobotoCondensed"; color = "#DFE6E6"; align = "left"; shadow = 1;};
};
class SPORG_Items_FooterContext: SPORG_Items_Structured {size = 0.0170 * safeZoneH;};
class SPORG_Items_FooterMessage: SPORG_Items_Structured {size = 0.0165 * safeZoneH;};
class SPORG_Items_FooterHistory: SPORG_Items_Structured {size = 0.0145 * safeZoneH;};

// Self-contained bases used by CT_CONTROLS_TABLE. The table gives every row its own real
// - / quantity / + / delete controls, avoiding global selected-item handlers.
class SPORG_Items_DraftRowBackground: SPORG_Items_Text {colorBackground[] = {0.01,0.015,0.017,0.16};};
class SPORG_Items_DraftRowPicture: SPORG_Items_Picture {colorBackground[] = {0,0,0,0};};
class SPORG_Items_DraftRowText: SPORG_Items_Text {sizeEx = 0.015 * safeZoneH;};
class SPORG_Items_DraftRowButton: SPORG_Items_Button {sizeEx = 0.015 * safeZoneH; colorBackground[] = {0.06,0.09,0.10,0.52};};
class SPORG_Items_DraftRowDelete: SPORG_Items_ButtonDanger {sizeEx = 0.014 * safeZoneH;};
class SPORG_Items_DraftRowEdit: SPORG_Items_Edit {style = 2; sizeEx = 0.015 * safeZoneH; colorBackground[] = {0.02,0.03,0.032,0.48};};
class SPORG_Items_ScrollBar
{
    color[] = {0.60,0.66,0.66,0.85}; colorActive[] = {0.80,0.86,0.86,1}; colorDisabled[] = {0.35,0.38,0.38,0.45};
    thumb = "#(argb,8,8,3)color(1,1,1,0.65)"; arrowEmpty = "#(argb,8,8,3)color(1,1,1,0.28)";
    arrowFull = "#(argb,8,8,3)color(1,1,1,0.65)"; border = "#(argb,8,8,3)color(1,1,1,0.14)";
    shadow = 0; scrollSpeed = 0.06; autoScrollEnabled = 0; autoScrollSpeed = -1; autoScrollDelay = 5; autoScrollRewind = 0;
};
class SPORG_Items_HiddenScrollBar
{
    color[] = {0,0,0,0}; colorActive[] = {0,0,0,0}; colorDisabled[] = {0,0,0,0};
    thumb = "#(argb,8,8,3)color(0,0,0,0)"; arrowEmpty = "#(argb,8,8,3)color(0,0,0,0)";
    arrowFull = "#(argb,8,8,3)color(0,0,0,0)"; border = "#(argb,8,8,3)color(0,0,0,0)";
    shadow = 0; scrollSpeed = 0; autoScrollEnabled = 0; autoScrollSpeed = -1; autoScrollDelay = 5; autoScrollRewind = 0;
};
class SPORG_Items_DraftTable
{
    type = 19; idc = -1; style = 16; x = 0; y = 0; w = 0; h = 0;
    lineSpacing = 0.0015 * safeZoneH; rowHeight = 0.035 * safeZoneH; headerHeight = 0;
    firstIDC = 22000; lastIDC = 29999;
    selectedRowColorFrom[] = {0.12,0.32,0.38,0.28}; selectedRowColorTo[] = {0.12,0.32,0.38,0.54}; selectedRowAnimLength = 1.2;
    class VScrollBar: SPORG_Items_ScrollBar {width = 0.006 * safeZoneW;};
    class HScrollBar: SPORG_Items_ScrollBar {height = 0;};
    class RowTemplate
    {
        class Background {controlBaseClassPath[] = {"SPORG_Items_DraftRowBackground"}; columnX = 0; columnW = SPORG_ITEMS_ROW_CONTENT_W; controlOffsetY = 0; controlH = 0.033 * safeZoneH;};
        class Picture {controlBaseClassPath[] = {"SPORG_Items_DraftRowPicture"}; columnX = SPORG_ITEMS_ROW_PAD_W; columnW = SPORG_ITEMS_ROW_SQUARE_W; controlOffsetY = 0.002 * safeZoneH; controlH = SPORG_ITEMS_ROW_H;};
        class Name {controlBaseClassPath[] = {"SPORG_Items_DraftRowText"}; columnX = SPORG_ITEMS_ROW_NAME_X; columnW = SPORG_ITEMS_ROW_NAME_W; controlOffsetY = 0.003 * safeZoneH; controlH = 0.027 * safeZoneH;};
        class Minus {controlBaseClassPath[] = {"SPORG_Items_DraftRowButton"}; columnX = SPORG_ITEMS_ROW_MINUS_X; columnW = SPORG_ITEMS_ROW_SQUARE_W; controlOffsetY = 0.002 * safeZoneH; controlH = SPORG_ITEMS_ROW_H;};
        class Quantity {controlBaseClassPath[] = {"SPORG_Items_DraftRowEdit"}; columnX = SPORG_ITEMS_ROW_QTY_X; columnW = SPORG_ITEMS_ROW_QTY_W; controlOffsetY = 0.002 * safeZoneH; controlH = SPORG_ITEMS_ROW_H;};
        class Plus {controlBaseClassPath[] = {"SPORG_Items_DraftRowButton"}; columnX = SPORG_ITEMS_ROW_PLUS_X; columnW = SPORG_ITEMS_ROW_SQUARE_W; controlOffsetY = 0.002 * safeZoneH; controlH = SPORG_ITEMS_ROW_H;};
        class Delete {controlBaseClassPath[] = {"SPORG_Items_DraftRowDelete"}; columnX = SPORG_ITEMS_ROW_DELETE_X; columnW = SPORG_ITEMS_ROW_SQUARE_W; controlOffsetY = 0.002 * safeZoneH; controlH = SPORG_ITEMS_ROW_H;};
    };
    class HeaderTemplate
    {
        class Background {controlBaseClassPath[] = {"SPORG_Items_DraftRowBackground"}; columnX = 0; columnW = 0.222 * safeZoneW; controlOffsetY = 0; controlH = 0;};
    };
};

class SPORG_Items_EquipmentRowBackground: SPORG_Items_Text {colorBackground[] = {0.01,0.015,0.017,0.16};};
class SPORG_Items_EquipmentRowCapture: SPORG_Items_Button {sizeEx = 0.014 * safeZoneH; colorText[] = {0.55,0.90,0.82,1}; colorBackground[] = {0.04,0.09,0.09,0.42};};
class SPORG_Items_EquipmentRowPicture: SPORG_Items_Picture {colorBackground[] = {0,0,0,0};};
class SPORG_Items_EquipmentRowText: SPORG_Items_Text {sizeEx = 0.014 * safeZoneH;};
class SPORG_Items_EquipmentRowButton: SPORG_Items_Button {sizeEx = 0.014 * safeZoneH; colorBackground[] = {0.06,0.09,0.10,0.52};};
class SPORG_Items_EquipmentRowDelete: SPORG_Items_ButtonDanger {sizeEx = 0.0135 * safeZoneH;};
class SPORG_Items_EquipmentRowEdit: SPORG_Items_Edit {style = 2; sizeEx = 0.014 * safeZoneH; colorBackground[] = {0.02,0.03,0.032,0.48};};
class SPORG_Items_EquipmentTable
{
    type = 19; idc = -1; style = 16; x = 0; y = 0; w = 0; h = 0;
    lineSpacing = 0.0015 * safeZoneH; rowHeight = 0.035 * safeZoneH; headerHeight = 0;
    firstIDC = 32000; lastIDC = 39999;
    selectedRowColorFrom[] = {0.12,0.32,0.38,0.28}; selectedRowColorTo[] = {0.12,0.32,0.38,0.54}; selectedRowAnimLength = 1.2;
    class VScrollBar: SPORG_Items_ScrollBar {width = 0.006 * safeZoneW;};
    class HScrollBar: SPORG_Items_ScrollBar {height = 0;};
    class RowTemplate
    {
        class Background {controlBaseClassPath[] = {"SPORG_Items_EquipmentRowBackground"}; columnX = 0; columnW = SPORG_ITEMS_EQ_ROW_CONTENT_W; controlOffsetY = 0; controlH = 0.033 * safeZoneH;};
        class Capture {controlBaseClassPath[] = {"SPORG_Items_EquipmentRowCapture"}; columnX = SPORG_ITEMS_EQ_ROW_CAPTURE_X; columnW = SPORG_ITEMS_EQ_ROW_SQUARE_W; controlOffsetY = 0.004 * safeZoneH; controlH = 0.024 * safeZoneH;};
        class Picture {controlBaseClassPath[] = {"SPORG_Items_EquipmentRowPicture"}; columnX = SPORG_ITEMS_EQ_ROW_PICTURE_X; columnW = SPORG_ITEMS_EQ_ROW_SQUARE_W; controlOffsetY = 0.004 * safeZoneH; controlH = 0.024 * safeZoneH;};
        class Name {controlBaseClassPath[] = {"SPORG_Items_EquipmentRowText"}; columnX = SPORG_ITEMS_EQ_ROW_NAME_X; columnW = SPORG_ITEMS_EQ_ROW_NAME_W; controlOffsetY = 0.003 * safeZoneH; controlH = 0.027 * safeZoneH;};
        class Minus {controlBaseClassPath[] = {"SPORG_Items_EquipmentRowButton"}; columnX = SPORG_ITEMS_EQ_ROW_MINUS_X; columnW = SPORG_ITEMS_EQ_ROW_SQUARE_W; controlOffsetY = 0.004 * safeZoneH; controlH = 0.024 * safeZoneH;};
        class Quantity {controlBaseClassPath[] = {"SPORG_Items_EquipmentRowEdit"}; columnX = SPORG_ITEMS_EQ_ROW_QTY_X; columnW = SPORG_ITEMS_EQ_ROW_QTY_W; controlOffsetY = 0.004 * safeZoneH; controlH = 0.024 * safeZoneH;};
        class Plus {controlBaseClassPath[] = {"SPORG_Items_EquipmentRowButton"}; columnX = SPORG_ITEMS_EQ_ROW_PLUS_X; columnW = SPORG_ITEMS_EQ_ROW_SQUARE_W; controlOffsetY = 0.004 * safeZoneH; controlH = 0.024 * safeZoneH;};
        class Delete {controlBaseClassPath[] = {"SPORG_Items_EquipmentRowDelete"}; columnX = SPORG_ITEMS_EQ_ROW_DELETE_X; columnW = SPORG_ITEMS_EQ_ROW_SQUARE_W; controlOffsetY = 0.004 * safeZoneH; controlH = 0.024 * safeZoneH;};
    };
    class HeaderTemplate
    {
        class Background {controlBaseClassPath[] = {"SPORG_Items_EquipmentRowBackground"}; columnX = 0; columnW = SPORG_ITEMS_EQ_ROW_CONTENT_W; controlOffsetY = 0; controlH = 0;};
    };
};

class SPORG_Items_CatalogRowBackground: SPORG_Items_Text {colorBackground[] = {0.01,0.015,0.017,0.16};};
class SPORG_Items_CatalogRowDraft: SPORG_Items_EquipmentRowCapture {sizeEx = 0.014 * safeZoneH;};
class SPORG_Items_CatalogRowPicture: SPORG_Items_Picture {colorBackground[] = {0,0,0,0};};
class SPORG_Items_CatalogRowText: SPORG_Items_Text {sizeEx = 0.014 * safeZoneH;};
class SPORG_Items_CatalogRowPhysical: SPORG_Items_EquipmentRowButton
{
    sizeEx = 0.014 * safeZoneH;
    colorText[] = {1,0.84,0.55,1};
    colorBackground[] = {0.24,0.13,0.03,0.48};
    colorBackgroundActive[] = {0.42,0.24,0.04,0.78};
    colorFocused[] = {0.42,0.24,0.04,0.78};
};
class SPORG_Items_CatalogTable
{
    type = 19; idc = -1; style = 16; x = 0; y = 0; w = 0; h = 0;
    lineSpacing = 0.0015 * safeZoneH; rowHeight = 0.035 * safeZoneH; headerHeight = 0;
    firstIDC = 40000; lastIDC = 49999;
    selectedRowColorFrom[] = {0.12,0.32,0.38,0.28}; selectedRowColorTo[] = {0.12,0.32,0.38,0.54}; selectedRowAnimLength = 1.2;
    class VScrollBar: SPORG_Items_HiddenScrollBar {width = 0;};
    class HScrollBar: SPORG_Items_HiddenScrollBar {height = 0;};
    class RowTemplate
    {
        class Background {controlBaseClassPath[] = {"SPORG_Items_CatalogRowBackground"}; columnX = 0; columnW = SPORG_ITEMS_CAT_ROW_CONTENT_W; controlOffsetY = 0; controlH = 0.033 * safeZoneH;};
        class ToDraft {controlBaseClassPath[] = {"SPORG_Items_CatalogRowDraft"}; columnX = SPORG_ITEMS_CAT_ROW_DRAFT_X; columnW = SPORG_ITEMS_CAT_ROW_SQUARE_W; controlOffsetY = 0.004 * safeZoneH; controlH = 0.024 * safeZoneH;};
        class Picture {controlBaseClassPath[] = {"SPORG_Items_CatalogRowPicture"}; columnX = SPORG_ITEMS_CAT_ROW_PICTURE_X; columnW = SPORG_ITEMS_CAT_ROW_SQUARE_W; controlOffsetY = 0.004 * safeZoneH; controlH = 0.024 * safeZoneH;};
        class Name {controlBaseClassPath[] = {"SPORG_Items_CatalogRowText"}; columnX = SPORG_ITEMS_CAT_ROW_NAME_X; columnW = SPORG_ITEMS_CAT_ROW_NAME_W; controlOffsetY = 0.003 * safeZoneH; controlH = 0.027 * safeZoneH;};
        class ToPhysical {controlBaseClassPath[] = {"SPORG_Items_CatalogRowPhysical"}; columnX = SPORG_ITEMS_CAT_ROW_PHYSICAL_X; columnW = SPORG_ITEMS_CAT_ROW_SQUARE_W; controlOffsetY = 0.004 * safeZoneH; controlH = 0.024 * safeZoneH;};
    };
    class HeaderTemplate
    {
        class Background {controlBaseClassPath[] = {"SPORG_Items_CatalogRowBackground"}; columnX = 0; columnW = SPORG_ITEMS_CAT_ROW_CONTENT_W; controlOffsetY = 0; controlH = 0;};
    };
};

class SP_ORG_Items_Dialog
{
    idd = 7700; movingEnable = 0; enableSimulation = 1;
    onLoad = "_this call ServoPeregrino_Organizador_Items_fnc_onInterfaceLoad";
    onUnload = "_this call ServoPeregrino_Organizador_Items_fnc_onInterfaceUnload";
    onKeyDown = "_this call ServoPeregrino_Organizador_Items_fnc_handleUIKeyDown";
    onMouseZChanged = "_this call ServoPeregrino_Organizador_Items_fnc_handleUIWheel";
    onMouseButtonDown = "['POINTER_DOWN',_this] call ServoPeregrino_Organizador_Items_fnc_handleUIDragEvent";
    onMouseButtonUp = "['MOUSE_UP',_this] call ServoPeregrino_Organizador_Items_fnc_handleUIDragEvent";
    onMouseMoving = "['POINTER_MOVE',_this] call ServoPeregrino_Organizador_Items_fnc_handleUIDragEvent";

    class controlsBackground
    {
        class Shade: SPORG_Items_Text {idc=-1; x=safeZoneX; y=safeZoneY; w=safeZoneW; h=safeZoneH; colorBackground[]={0.01,0.015,0.017,0.12};};
        class Header: SPORG_Items_Text {idc=-1; x=safeZoneX; y=safeZoneY; w=safeZoneW; h=0.049*safeZoneH; colorBackground[]={0.015,0.09,0.105,0.80};};
        class HeaderDivider: SPORG_Items_Text {idc=-1; x=safeZoneX; y=safeZoneY+0.048*safeZoneH; w=safeZoneW; h=0.0012*safeZoneH; colorBackground[]={0.22,0.46,0.43,0.42};};
        class P1: SPORG_Items_Text {idc=-1; x=safeZoneX+0.012*safeZoneW; y=safeZoneY+0.052*safeZoneH; w=0.176*safeZoneW; h=0.815*safeZoneH; colorBackground[]={0.015,0.02,0.022,0.44};};
        class P2: SPORG_Items_Text {idc=SERVO_PEREGRINO_ORGANIZADOR_ITEMS_UI_DRAFT_PANEL_IDC; x=SERVO_PEREGRINO_ORGANIZADOR_ITEMS_UI_DRAFT_PANEL_X; y=SERVO_PEREGRINO_ORGANIZADOR_ITEMS_UI_DRAFT_PANEL_Y; w=SERVO_PEREGRINO_ORGANIZADOR_ITEMS_UI_DRAFT_PANEL_W; h=SERVO_PEREGRINO_ORGANIZADOR_ITEMS_UI_DRAFT_PANEL_H; colorBackground[]={0.015,0.02,0.022,0.44};};
        class P3: SPORG_Items_Text {idc=-1; x=safeZoneX+0.456*safeZoneW; y=safeZoneY+0.052*safeZoneH; w=0.330*safeZoneW; h=0.815*safeZoneH; colorBackground[]={0.015,0.02,0.022,0.44};};
        class P4: SPORG_Items_Text {idc=SERVO_PEREGRINO_ORGANIZADOR_ITEMS_UI_EQUIPMENT_PANEL_IDC; x=SERVO_PEREGRINO_ORGANIZADOR_ITEMS_UI_EQUIPMENT_PANEL_X; y=SERVO_PEREGRINO_ORGANIZADOR_ITEMS_UI_EQUIPMENT_PANEL_Y; w=SERVO_PEREGRINO_ORGANIZADOR_ITEMS_UI_EQUIPMENT_PANEL_W; h=SERVO_PEREGRINO_ORGANIZADOR_ITEMS_UI_EQUIPMENT_PANEL_H; colorBackground[]={0.015,0.02,0.022,0.44};};
        class FooterBg: SPORG_Items_Text {idc=-1; x=safeZoneX+0.012*safeZoneW; y=safeZoneY+0.878*safeZoneH; w=0.976*safeZoneW; h=0.105*safeZoneH; colorBackground[]={0.015,0.02,0.022,0.44};};
    };

    class controls
    {
        // D.6.3: header anchored from Close toward the left, matching the APM visual rhythm.
        class HeaderTitle: SPORG_Items_Title {idc=100; text="SP_ORG — ORGANIZADOR DE ITENS  |  0.13-A"; x=safeZoneX+0.012*safeZoneW; y=safeZoneY+0.010*safeZoneH; w=0.330*safeZoneW; h=0.026*safeZoneH; sizeEx=0.0165*safeZoneH;};
        class HeaderWeightText: SPORG_Items_Text {idc=104; style=1; text="Carga: -"; tooltip="Carga global do jogador: inclui armas, itens vinculados e conteúdo de Uniforme/Colete/Mochila"; x=SPORG_ITEMS_UI_HEADER_LOAD_X; y=safeZoneY+0.006*safeZoneH; w=SPORG_ITEMS_UI_HEADER_LOAD_W; h=0.018*safeZoneH; sizeEx=0.0109*safeZoneH;};
        class HeaderWeightBarBg: SPORG_Items_Text {idc=105; x=SPORG_ITEMS_UI_HEADER_LOAD_X; y=safeZoneY+0.029*safeZoneH; w=SPORG_ITEMS_UI_HEADER_LOAD_W; h=0.006*safeZoneH; colorBackground[]={0.03,0.05,0.055,0.86};};
        class HeaderWeightBarFill: SPORG_Items_Text {idc=106; x=SPORG_ITEMS_UI_HEADER_LOAD_X; y=safeZoneY+0.029*safeZoneH; w=0.001*safeZoneW; h=0.006*safeZoneH; colorBackground[]={0.15,0.62,0.48,0.92};};
        class HeaderIdentity: SPORG_Items_Text {idc=103; style=1; text="Operador: -"; tooltip="Jogador que está usando o Organizador"; x=SPORG_ITEMS_UI_HEADER_ID_X; y=safeZoneY+0.005*safeZoneH; w=SPORG_ITEMS_UI_HEADER_ID_W; h=0.018*safeZoneH; sizeEx=0.0109*safeZoneH;};
        class HeaderUnit: SPORG_Items_Text {idc=108; style=1; text="Unidade: -"; tooltip="Grupo atual do jogador"; x=SPORG_ITEMS_UI_HEADER_ID_X; y=safeZoneY+0.024*safeZoneH; w=SPORG_ITEMS_UI_HEADER_ID_W; h=0.018*safeZoneH; sizeEx=0.0109*safeZoneH;};
        class FutureIconSlot: SPORG_Items_Text {idc=107; text=""; tooltip="Espaço reservado para uma integração futura"; x=SPORG_ITEMS_UI_HEADER_FUTURE_X; y=safeZoneY+0.009*safeZoneH; w=SPORG_ITEMS_UI_ICON_W; h=SPORG_ITEMS_UI_ICON_H; colorBackground[]={0.04,0.08,0.085,0.14};};
        class Close: SPORG_Items_IconButton {idc=102; text="X"; tooltip="Fechar o Organizador; alterações não salvas pedem confirmação"; x=SPORG_ITEMS_UI_HEADER_CLOSE_X; y=safeZoneY+0.009*safeZoneH; w=SPORG_ITEMS_UI_ICON_W; h=SPORG_ITEMS_UI_ICON_H; action="['REQUEST_CLOSE'] call ServoPeregrino_Organizador_Items_fnc_handleUIEvent";};
        // Compatibility stub: historical IDC remains addressable, but no duplicate 'Adicionar em' is visible in the header.
        class HeaderStatus: SPORG_Items_Text {idc=101; style=0; text=""; x=safeZoneX-2; y=safeZoneY-2; w=0.001; h=0.001; sizeEx=0.001;};

        // Panel 1 — Kits persistidos
        class KitsTitle: SPORG_Items_Title {idc=1000; text="MEUS KITS DE ITENS"; x=safeZoneX+0.022*safeZoneW; y=safeZoneY+0.064*safeZoneH; w=0.100*safeZoneW; h=0.026*safeZoneH;};
        class KitsActionStatus: SPORG_Items_Text {idc=1001; style=1; text=""; tooltip="Última ação concluída na biblioteca de kits"; x=safeZoneX+0.126*safeZoneW; y=safeZoneY+0.064*safeZoneH; w=0.052*safeZoneW; h=0.026*safeZoneH;};
        class KitsSearchIcon: SPORG_Items_SearchIcon {idc=1090; x=safeZoneX+0.022*safeZoneW; y=safeZoneY+0.102*safeZoneH; w=SPORG_ITEMS_UI_SEARCH_W; h=SPORG_ITEMS_UI_SEARCH_H;};
        class KitsSearch: SPORG_Items_Edit {idc=1100; tooltip="Pesquisar kits na aba atual por nome; em PÚBLICOS também busca autor e origem"; x=safeZoneX+0.022*safeZoneW+SPORG_ITEMS_UI_SEARCH_W+SPORG_ITEMS_UI_SEARCH_GAP_W; y=safeZoneY+0.099*safeZoneH; w=0.156*safeZoneW-SPORG_ITEMS_UI_CLEAR_W-SPORG_ITEMS_UI_SEARCH_W-SPORG_ITEMS_UI_SEARCH_GAP_W-0.004*safeZoneW; h=SPORG_ITEMS_UI_CLEAR_H; onKeyUp="['KIT_SEARCH',ctrlText (_this#0)] call ServoPeregrino_Organizador_Items_fnc_handleUIEvent";};
        class KitsClear: SPORG_Items_IconButton {idc=1101; text="x"; tooltip="Limpar busca de kits"; x=safeZoneX+0.178*safeZoneW-SPORG_ITEMS_UI_CLEAR_W; y=safeZoneY+0.099*safeZoneH; w=SPORG_ITEMS_UI_CLEAR_W; h=SPORG_ITEMS_UI_CLEAR_H; action="['KIT_SEARCH',''] call ServoPeregrino_Organizador_Items_fnc_handleUIEvent";};
        class KitsPrivateTab: SPORG_Items_Button {idc=1104; text="PRIVADOS"; tooltip="Kits salvos no seu perfil"; x=safeZoneX+0.022*safeZoneW; y=safeZoneY+0.139*safeZoneH; w=0.076*safeZoneW; h=0.032*safeZoneH; action="['KIT_LIBRARY_MODE','PRIVATE'] call ServoPeregrino_Organizador_Items_fnc_handleUIEvent";};
        class KitsPublicTab: SPORG_Items_Button {idc=1105; text="PÚBLICOS"; tooltip="Snapshots compartilhados nesta sessão pelo servidor ou jogadores"; x=safeZoneX+0.102*safeZoneW; y=safeZoneY+0.139*safeZoneH; w=0.076*safeZoneW; h=0.032*safeZoneH; action="['KIT_LIBRARY_MODE','PUBLIC'] call ServoPeregrino_Organizador_Items_fnc_handleUIEvent";};
        class KitsList: SPORG_Items_List
        {
            idc=1102; tooltip="Privados: clique para editar e arraste para combinar. Públicos: selecione para consultar e salvar uma cópia privada."; x=safeZoneX+0.022*safeZoneW; y=safeZoneY+0.181*safeZoneH; w=0.156*safeZoneW; h=0.534*safeZoneH; canDrag=1;
            onLBSelChanged="['KIT_SELECT',_this#1] call ServoPeregrino_Organizador_Items_fnc_handleUIEvent";
            onLBDrag="['START',_this] call ServoPeregrino_Organizador_Items_fnc_handleUIDragEvent";
            onLBDragging="['MOVE',_this] call ServoPeregrino_Organizador_Items_fnc_handleUIDragEvent";
        };
        class KitsNew: SPORG_Items_Button {idc=1110; text="NOVO"; tooltip="Criar um novo Kit Selecionado vazio"; x=safeZoneX+0.022*safeZoneW; y=safeZoneY+0.726*safeZoneH; w=0.033*safeZoneW; h=0.032*safeZoneH; action="['NEW_KIT'] call ServoPeregrino_Organizador_Items_fnc_handleUIEvent";};
        class KitsDuplicate: SPORG_Items_Button {idc=1111; text="DUPLICAR"; tooltip="Duplicar o kit privado selecionado com novo ID"; x=safeZoneX+0.058*safeZoneW; y=safeZoneY+0.726*safeZoneH; w=0.043*safeZoneW; h=0.032*safeZoneH; action="['DUPLICATE_KIT'] call ServoPeregrino_Organizador_Items_fnc_handleUIEvent";};
        class KitsDelete: SPORG_Items_ButtonDanger {idc=1112; text="EXCLUIR"; tooltip="Excluir permanentemente o kit privado selecionado"; x=safeZoneX+0.104*safeZoneW; y=safeZoneY+0.726*safeZoneH; w=0.036*safeZoneW; h=0.032*safeZoneH; action="['DELETE_KIT_REQUEST'] call ServoPeregrino_Organizador_Items_fnc_handleUIEvent";};
        class KitsPublish: SPORG_Items_Button {idc=1113; text="PUBLICAR"; tooltip="Publicar/atualizar um snapshot independente deste kit na biblioteca pública da sessão"; x=safeZoneX+0.143*safeZoneW; y=safeZoneY+0.726*safeZoneH; w=0.035*safeZoneW; h=0.032*safeZoneH; action="['PUBLISH_KIT'] call ServoPeregrino_Organizador_Items_fnc_handleUIEvent";};
        class KitsSavePrivate: SPORG_Items_Button {idc=1114; text="SALVAR NO PRIVADO"; tooltip="Criar uma cópia privada independente do kit público selecionado"; x=safeZoneX+0.022*safeZoneW; y=safeZoneY+0.726*safeZoneH; w=0.105*safeZoneW; h=0.032*safeZoneH; action="['SAVE_PUBLIC_PRIVATE'] call ServoPeregrino_Organizador_Items_fnc_handleUIEvent";};
        class KitsPublicRefresh: SPORG_Items_Button {idc=1115; text="ATUALIZAR"; tooltip="Atualizar a visualização da biblioteca pública da sessão"; x=safeZoneX+0.130*safeZoneW; y=safeZoneY+0.726*safeZoneH; w=0.048*safeZoneW; h=0.032*safeZoneH; action="['REFRESH_PUBLIC_KITS'] call ServoPeregrino_Organizador_Items_fnc_handleUIEvent";};
        class KitsStatus: SPORG_Items_Structured {idc=1103; x=safeZoneX+0.022*safeZoneW; y=safeZoneY+0.768*safeZoneH; w=0.156*safeZoneW; h=0.082*safeZoneH;};

        // Panel 2 — Draft. Nome agora fica no cabeçalho entre título e estado; busca alinha em Y=.099 com os outros painéis.
        class DraftTitle: SPORG_Items_Title {idc=2000; text="KIT SELECIONADO"; x=safeZoneX+0.206*safeZoneW; y=safeZoneY+0.064*safeZoneH; w=0.074*safeZoneW; h=0.026*safeZoneH;};
        class DraftName: SPORG_Items_Edit {idc=2100; x=safeZoneX+0.283*safeZoneW; y=safeZoneY+0.062*safeZoneH; w=0.096*safeZoneW; h=0.030*safeZoneH; tooltip="Nome do Kit Selecionado; só é gravado ao Salvar"; onKillFocus="['DRAFT_NAME',ctrlText (_this#0)] call ServoPeregrino_Organizador_Items_fnc_handleUIEvent";};
        class DraftDirty: SPORG_Items_Text {idc=2001; style=1; text="SEM KIT"; x=safeZoneX+0.382*safeZoneW; y=safeZoneY+0.064*safeZoneH; w=0.052*safeZoneW; h=0.026*safeZoneH;};
        class DraftSearchIcon: SPORG_Items_SearchIcon {idc=2090; x=safeZoneX+0.206*safeZoneW; y=safeZoneY+0.102*safeZoneH; w=SPORG_ITEMS_UI_SEARCH_W; h=SPORG_ITEMS_UI_SEARCH_H;};
        class DraftSearch: SPORG_Items_Edit {idc=2101; tooltip="Pesquisar nos itens do Kit Selecionado"; x=safeZoneX+0.206*safeZoneW+SPORG_ITEMS_UI_SEARCH_W+SPORG_ITEMS_UI_SEARCH_GAP_W; y=safeZoneY+0.099*safeZoneH; w=0.228*safeZoneW-SPORG_ITEMS_UI_CLEAR_W-SPORG_ITEMS_UI_SEARCH_W-SPORG_ITEMS_UI_SEARCH_GAP_W-0.004*safeZoneW; h=SPORG_ITEMS_UI_CLEAR_H; onKeyUp="['DRAFT_SEARCH',ctrlText (_this#0)] call ServoPeregrino_Organizador_Items_fnc_handleUIEvent";};
        class DraftClear: SPORG_Items_IconButton {idc=2102; text="x"; tooltip="Limpar busca do Kit Selecionado"; x=safeZoneX+0.434*safeZoneW-SPORG_ITEMS_UI_CLEAR_W; y=safeZoneY+0.099*safeZoneH; w=SPORG_ITEMS_UI_CLEAR_W; h=SPORG_ITEMS_UI_CLEAR_H; action="['DRAFT_SEARCH',''] call ServoPeregrino_Organizador_Items_fnc_handleUIEvent";};
        class DraftDrop: SPORG_Items_Button
        {
            idc=2103; text="ARRASTE ITENS PARA ADICIONAR AO KIT"; tooltip="Arraste um item ou outro kit e solte em qualquer lugar deste painel para adicioná-lo ao Kit Selecionado."; x=safeZoneX+0.206*safeZoneW; y=safeZoneY+0.181*safeZoneH; w=0.228*safeZoneW; h=0.034*safeZoneH;
            colorBackground[]={0.03,0.18,0.16,0.14}; colorText[]={0.48,0.69,0.64,0.72};
            onLBDrop="['DROP',_this] call ServoPeregrino_Organizador_Items_fnc_handleUIDragEvent";
        };
        class DraftList: SPORG_Items_DraftTable {idc=2104; tooltip="Itens do kit atual. Use - / quantidade / + / X para editar o kit. Os botões abaixo aplicam essas alterações ao equipamento."; x=safeZoneX+0.206*safeZoneW; y=safeZoneY+0.224*safeZoneH; w=0.228*safeZoneW; h=0.383*safeZoneH; onLBSelChanged="['DRAFT_ROW_SELECT',_this#1] call ServoPeregrino_Organizador_Items_fnc_handleUIEvent";};
        // Ações de edição do Draft ficam agrupadas em uma única linha para não misturar LIMPAR lógico com operações físicas.
        class DraftSave: SPORG_Items_Button {idc=2140; text="SALVAR"; tooltip="Salvar explicitamente as alterações do Kit Selecionado"; x=safeZoneX+0.206*safeZoneW; y=safeZoneY+0.139*safeZoneH; w=0.048*safeZoneW; h=0.032*safeZoneH; action="['DRAFT_SAVE'] call ServoPeregrino_Organizador_Items_fnc_handleUIEvent";};
        class DraftSaveAs: SPORG_Items_Button {idc=2141; text="SALVAR COMO NOVO"; tooltip="Persistir uma cópia com novo ID e manter o original independente"; x=safeZoneX+0.257*safeZoneW; y=safeZoneY+0.139*safeZoneH; w=0.085*safeZoneW; h=0.032*safeZoneH; action="['DRAFT_SAVE_AS_NEW'] call ServoPeregrino_Organizador_Items_fnc_handleUIEvent";};
        class DraftDiscard: SPORG_Items_ButtonDanger {idc=2142; text="DESCARTAR"; tooltip="Descartar alterações locais e retornar à versão persistida"; x=safeZoneX+0.345*safeZoneW; y=safeZoneY+0.139*safeZoneH; w=0.050*safeZoneW; h=0.032*safeZoneH; action="['DRAFT_DISCARD_REQUEST'] call ServoPeregrino_Organizador_Items_fnc_handleUIEvent";};
        class DraftClearContent: SPORG_Items_ButtonDanger {idc=2153; text="LIMPAR"; sizeEx=0.014*safeZoneH; tooltip="Limpar somente os itens do Kit Selecionado. Não altera o equipamento físico; exige confirmação quando há itens"; x=safeZoneX+0.398*safeZoneW; y=safeZoneY+0.139*safeZoneH; w=0.036*safeZoneW; h=0.032*safeZoneH; action="['DRAFT_CLEAR_REQUEST'] call ServoPeregrino_Organizador_Items_fnc_handleUIEvent";};
        class AppTargetLabel: SPORG_Items_Text {idc=2105; text="Onde aplicar o kit?"; tooltip="Escolha em qual equipamento os itens do Kit Selecionado serão aplicados."; x=safeZoneX+0.206*safeZoneW; y=safeZoneY+0.650*safeZoneH; w=0.150*safeZoneW; h=0.019*safeZoneH;};
        // ANY remains in the code/API for compatibility but is intentionally hidden from the player-facing selector.
        class AppAny: SPORG_Items_Button {idc=2110; text=""; sizeEx=0.001; tooltip=""; x=safeZoneX-2; y=safeZoneY-2; w=0.001; h=0.001; action="['APP_TARGET','ANY'] call ServoPeregrino_Organizador_Items_fnc_handleUIEvent";};
        class AppU: SPORG_Items_Button {idc=2111; text="UNIFORME"; sizeEx=0.013*safeZoneH; tooltip="Usar o Uniforme como destino das operações abaixo."; x=safeZoneX+0.206*safeZoneW; y=safeZoneY+0.674*safeZoneH; w=0.074*safeZoneW; h=SPORG_ITEMS_UI_COMPACT_H; action="['APP_TARGET','U'] call ServoPeregrino_Organizador_Items_fnc_handleUIEvent";};
        class AppC: SPORG_Items_Button {idc=2112; text="COLETE"; sizeEx=0.013*safeZoneH; tooltip="Usar o Colete como destino das operações abaixo."; x=safeZoneX+0.283*safeZoneW; y=safeZoneY+0.674*safeZoneH; w=0.074*safeZoneW; h=SPORG_ITEMS_UI_COMPACT_H; action="['APP_TARGET','C'] call ServoPeregrino_Organizador_Items_fnc_handleUIEvent";};
        class AppM: SPORG_Items_Button {idc=2113; text="MOCHILA"; sizeEx=0.013*safeZoneH; tooltip="Usar a Mochila como destino das operações abaixo."; x=safeZoneX+0.360*safeZoneW; y=safeZoneY+0.674*safeZoneH; w=0.074*safeZoneW; h=SPORG_ITEMS_UI_COMPACT_H; action="['APP_TARGET','M'] call ServoPeregrino_Organizador_Items_fnc_handleUIEvent";};
        class AppActionLabel: SPORG_Items_Text {idc=2106; text="O que fazer no destino?"; tooltip="Escolha a operação que será executada no equipamento selecionado acima."; x=safeZoneX+0.206*safeZoneW; y=safeZoneY+0.711*safeZoneH; w=0.185*safeZoneW; h=0.019*safeZoneH;};
        class PhysicalApply: SPORG_Items_Button {idc=2150; text="APLICAR"; tooltip="Adicionar ao destino escolhido os itens e quantidades do Kit Selecionado. Não é necessário salvar o kit antes."; x=safeZoneX+0.206*safeZoneW; y=safeZoneY+0.735*safeZoneH; w=0.050*safeZoneW; h=0.030*safeZoneH; action="['PHYSICAL_APPLY'] call ServoPeregrino_Organizador_Items_fnc_handleUIEvent";};
        class PhysicalRemove: SPORG_Items_Button {idc=2151; text="REMOVER"; tooltip="Remover do destino escolhido os itens e quantidades presentes no Kit Selecionado."; x=safeZoneX+0.259*safeZoneW; y=safeZoneY+0.735*safeZoneH; w=0.052*safeZoneW; h=0.030*safeZoneH; action="['PHYSICAL_REMOVE'] call ServoPeregrino_Organizador_Items_fnc_handleUIEvent";};
        class PhysicalReplace: SPORG_Items_Button {idc=2152; text="SUBSTITUIR"; tooltip="Deixar o destino escolhido igual ao Kit Selecionado, removendo e adicionando itens quando necessário. Exige confirmação."; x=safeZoneX+0.314*safeZoneW; y=safeZoneY+0.735*safeZoneH; w=0.066*safeZoneW; h=0.030*safeZoneH; action="['PHYSICAL_REPLACE_REQUEST'] call ServoPeregrino_Organizador_Items_fnc_handleUIEvent";};
        class DraftStatus: SPORG_Items_Structured {idc=2120; x=safeZoneX+0.206*safeZoneW; y=safeZoneY+0.772*safeZoneH; w=0.228*safeZoneW; h=0.078*safeZoneH;};

        // Panel 3 — Catalog. Lista contínua virtualizada com botões reais por linha; navegação visível simplificada para wheel + slider.
        class CatalogTitle: SPORG_Items_Title {idc=3000; text="CATÁLOGO DE ITENS"; x=safeZoneX+0.466*safeZoneW; y=safeZoneY+0.064*safeZoneH; w=0.20*safeZoneW; h=0.026*safeZoneH;};
        class CatalogSearchIcon: SPORG_Items_SearchIcon {idc=3090; x=safeZoneX+0.466*safeZoneW; y=safeZoneY+0.102*safeZoneH; w=SPORG_ITEMS_UI_SEARCH_W; h=SPORG_ITEMS_UI_SEARCH_H;};
        class CatalogSearch: SPORG_Items_Edit {idc=3100; tooltip="Pesquisar no catálogo local já indexado"; x=safeZoneX+0.466*safeZoneW+SPORG_ITEMS_UI_SEARCH_W+SPORG_ITEMS_UI_SEARCH_GAP_W; y=safeZoneY+0.099*safeZoneH; w=0.310*safeZoneW-SPORG_ITEMS_UI_CLEAR_W-SPORG_ITEMS_UI_SEARCH_W-SPORG_ITEMS_UI_SEARCH_GAP_W-0.004*safeZoneW; h=SPORG_ITEMS_UI_CLEAR_H; onKeyUp="['CATALOG_SEARCH',ctrlText (_this#0)] call ServoPeregrino_Organizador_Items_fnc_handleUIEvent";};
        class CatalogClear: SPORG_Items_IconButton {idc=3101; text="x"; tooltip="Limpar busca do catálogo"; x=safeZoneX+0.776*safeZoneW-SPORG_ITEMS_UI_CLEAR_W; y=safeZoneY+0.099*safeZoneH; w=SPORG_ITEMS_UI_CLEAR_W; h=SPORG_ITEMS_UI_CLEAR_H; action="['CATALOG_SEARCH',''] call ServoPeregrino_Organizador_Items_fnc_handleUIEvent";};
        class CatAll: SPORG_Items_Button {tooltip="Mostrar todas as categorias"; idc=3110; text="TODOS"; x=safeZoneX+0.466*safeZoneW; y=safeZoneY+0.139*safeZoneH; w=0.035*safeZoneW; h=0.029*safeZoneH; action="['CATALOG_CATEGORY','ALL'] call ServoPeregrino_Organizador_Items_fnc_handleUIEvent";};
        class CatMag: SPORG_Items_Button {tooltip="Filtrar munições"; idc=3111; text="MUNI"; x=safeZoneX+0.504*safeZoneW; y=safeZoneY+0.139*safeZoneH; w=0.035*safeZoneW; h=0.029*safeZoneH; action="['CATALOG_CATEGORY','MAGAZINES'] call ServoPeregrino_Organizador_Items_fnc_handleUIEvent";};
        class CatGren: SPORG_Items_Button {tooltip="Filtrar granadas"; idc=3112; text="GRAN"; x=safeZoneX+0.542*safeZoneW; y=safeZoneY+0.139*safeZoneH; w=0.035*safeZoneW; h=0.029*safeZoneH; action="['CATALOG_CATEGORY','GRENADES'] call ServoPeregrino_Organizador_Items_fnc_handleUIEvent";};
        class CatExp: SPORG_Items_Button {tooltip="Filtrar explosivos"; idc=3113; text="EXPL"; x=safeZoneX+0.580*safeZoneW; y=safeZoneY+0.139*safeZoneH; w=0.035*safeZoneW; h=0.029*safeZoneH; action="['CATALOG_CATEGORY','EXPLOSIVES'] call ServoPeregrino_Organizador_Items_fnc_handleUIEvent";};
        class CatTools: SPORG_Items_Button {tooltip="Filtrar ferramentas"; idc=3114; text="FERR"; x=safeZoneX+0.618*safeZoneW; y=safeZoneY+0.139*safeZoneH; w=0.035*safeZoneW; h=0.029*safeZoneH; action="['CATALOG_CATEGORY','TOOLS'] call ServoPeregrino_Organizador_Items_fnc_handleUIEvent";};
        class CatFood: SPORG_Items_Button {tooltip="Filtrar alimentos"; idc=3115; text="ALIM"; x=safeZoneX+0.656*safeZoneW; y=safeZoneY+0.139*safeZoneH; w=0.035*safeZoneW; h=0.029*safeZoneH; action="['CATALOG_CATEGORY','FOOD'] call ServoPeregrino_Organizador_Items_fnc_handleUIEvent";};
        class CatMed: SPORG_Items_Button {tooltip="Filtrar itens médicos"; idc=3116; text="MED"; x=safeZoneX+0.694*safeZoneW; y=safeZoneY+0.139*safeZoneH; w=0.035*safeZoneW; h=0.029*safeZoneH; action="['CATALOG_CATEGORY','MEDICAL'] call ServoPeregrino_Organizador_Items_fnc_handleUIEvent";};
        class CatOther: SPORG_Items_Button {tooltip="Filtrar outros itens"; idc=3117; text="OUT"; x=safeZoneX+0.732*safeZoneW; y=safeZoneY+0.139*safeZoneH; w=0.044*safeZoneW; h=0.029*safeZoneH; action="['CATALOG_CATEGORY','OTHER'] call ServoPeregrino_Organizador_Items_fnc_handleUIEvent";};
        class CatalogTable: SPORG_Items_CatalogTable
        {
            idc=3140; tooltip="Catálogo de itens. O botão da esquerda copia ao Kit Selecionado; o botão da direita adiciona ao equipamento exibido em Mostrar; nome/ícone selecionam e podem iniciar arraste.";
            x=safeZoneX+0.466*safeZoneW; y=safeZoneY+0.178*safeZoneH; w=0.298*safeZoneW; h=0.510*safeZoneH;
            onLBSelChanged="['CATALOG_TABLE_SELECT',_this#1] call ServoPeregrino_Organizador_Items_fnc_handleUIEvent";
        };
        // Superfície legada invisível: mantém contratos históricos/drag nativo dos gates antigos sem ser exibida ao jogador.
        class CatalogList: SPORG_Items_List
        {
            idc=3120; x=safeZoneX-10; y=safeZoneY-10; w=0.001; h=0.001; canDrag=1;
            onLBSelChanged="['CATALOG_SELECT',_this#1] call ServoPeregrino_Organizador_Items_fnc_handleUIEvent";
            onMouseButtonClick="['CATALOG_ARROW_CLICK',_this] call ServoPeregrino_Organizador_Items_fnc_handleUIEvent";
            onLBDrag="['START',_this] call ServoPeregrino_Organizador_Items_fnc_handleUIDragEvent";
            onLBDragging="['MOVE',_this] call ServoPeregrino_Organizador_Items_fnc_handleUIDragEvent";
        };
        class CatalogScrollUp: SPORG_Items_IconButton {idc=3121; text="▲"; sizeEx=0.013*safeZoneH; tooltip="Subir 6 itens no catálogo"; x=safeZoneX-10; y=safeZoneY-10; w=SPORG_ITEMS_UI_COMPACT_W; h=SPORG_ITEMS_UI_COMPACT_H; action="['CATALOG_SCROLL',-6] call ServoPeregrino_Organizador_Items_fnc_handleUIEvent";};
        class CatalogScroll: SPORG_Items_VSlider {idc=3124; tooltip="Use a roda do mouse, arraste o marcador ou clique no trilho para navegar pelos itens."; x=safeZoneX+0.766*safeZoneW; y=safeZoneY+0.178*safeZoneH; w=0.010*safeZoneW; h=0.510*safeZoneH; onSliderPosChanged="['CATALOG_SCROLL_ABSOLUTE',_this#1] call ServoPeregrino_Organizador_Items_fnc_handleUIEvent";};
        class CatalogScrollDown: SPORG_Items_IconButton {idc=3123; text="▼"; sizeEx=0.013*safeZoneH; tooltip="Descer 6 itens no catálogo"; x=safeZoneX-10; y=safeZoneY-10; w=SPORG_ITEMS_UI_COMPACT_W; h=SPORG_ITEMS_UI_COMPACT_H; action="['CATALOG_SCROLL',6] call ServoPeregrino_Organizador_Items_fnc_handleUIEvent";};
        class CatalogPage: SPORG_Items_Text {idc=3122; style=2; x=safeZoneX+0.466*safeZoneW; y=safeZoneY+0.697*safeZoneH; w=0.310*safeZoneW; h=SPORG_ITEMS_UI_CLEAR_H;};
        class CatalogDetails: SPORG_Items_Structured {idc=3130; x=safeZoneX+0.466*safeZoneW; y=safeZoneY+0.738*safeZoneH; w=0.310*safeZoneW; h=0.115*safeZoneH; colorBackground[]={0.01,0.015,0.017,0.28};};

        // Panel 4 — Equipment: linhas físicas com controles por linha + capacidade dedicada.
        class EquipmentTitle: SPORG_Items_Title {idc=4000; text="CONTEÚDO DO EQUIPAMENTO"; x=safeZoneX+0.804*safeZoneW; y=safeZoneY+0.064*safeZoneH; w=0.17*safeZoneW; h=0.026*safeZoneH;};
        class EquipmentSearchIcon: SPORG_Items_SearchIcon {idc=4090; x=safeZoneX+0.804*safeZoneW; y=safeZoneY+0.102*safeZoneH; w=SPORG_ITEMS_UI_SEARCH_W; h=SPORG_ITEMS_UI_SEARCH_H;};
        class EquipmentSearch: SPORG_Items_Edit {idc=4100; tooltip="Pesquisar no conteúdo do container visualizado"; x=safeZoneX+0.804*safeZoneW+SPORG_ITEMS_UI_SEARCH_W+SPORG_ITEMS_UI_SEARCH_GAP_W; y=safeZoneY+0.099*safeZoneH; w=0.164*safeZoneW-SPORG_ITEMS_UI_CLEAR_W-SPORG_ITEMS_UI_SEARCH_W-SPORG_ITEMS_UI_SEARCH_GAP_W-0.004*safeZoneW; h=SPORG_ITEMS_UI_CLEAR_H; onKeyUp="['EQUIPMENT_SEARCH',ctrlText (_this#0)] call ServoPeregrino_Organizador_Items_fnc_handleUIEvent";};
        class EquipmentClear: SPORG_Items_IconButton {idc=4101; text="x"; tooltip="Limpar busca do equipamento"; x=safeZoneX+0.968*safeZoneW-SPORG_ITEMS_UI_CLEAR_W; y=safeZoneY+0.099*safeZoneH; w=SPORG_ITEMS_UI_CLEAR_W; h=SPORG_ITEMS_UI_CLEAR_H; action="['EQUIPMENT_SEARCH',''] call ServoPeregrino_Organizador_Items_fnc_handleUIEvent";};
        class EquipLabel: SPORG_Items_Text {idc=4102; text="Mostrar:"; x=safeZoneX+0.804*safeZoneW; y=safeZoneY+0.139*safeZoneH; w=0.036*safeZoneW; h=0.030*safeZoneH; sizeEx=0.014*safeZoneH;};
        class EquipU: SPORG_Items_Button {idc=4110; text="UNIFORME"; sizeEx=0.0125*safeZoneH; tooltip="Mostrar o conteúdo do Uniforme"; x=safeZoneX+0.842*safeZoneW; y=safeZoneY+0.139*safeZoneH; w=0.041*safeZoneW; h=SPORG_ITEMS_UI_COMPACT_H; action="['EQUIPMENT_VIEW','U'] call ServoPeregrino_Organizador_Items_fnc_handleUIEvent";};
        class EquipC: SPORG_Items_Button {idc=4111; text="COLETE"; sizeEx=0.0125*safeZoneH; tooltip="Mostrar o conteúdo do Colete"; x=safeZoneX+0.885*safeZoneW; y=safeZoneY+0.139*safeZoneH; w=0.036*safeZoneW; h=SPORG_ITEMS_UI_COMPACT_H; action="['EQUIPMENT_VIEW','C'] call ServoPeregrino_Organizador_Items_fnc_handleUIEvent";};
        class EquipM: SPORG_Items_Button {idc=4112; text="MOCHILA"; sizeEx=0.0125*safeZoneH; tooltip="Mostrar o conteúdo da Mochila"; x=safeZoneX+0.923*safeZoneW; y=safeZoneY+0.139*safeZoneH; w=0.045*safeZoneW; h=SPORG_ITEMS_UI_COMPACT_H; action="['EQUIPMENT_VIEW','M'] call ServoPeregrino_Organizador_Items_fnc_handleUIEvent";};
        class EquipDrop: SPORG_Items_Button {idc=4113; text="ARRASTE ITENS PARA ADICIONAR AO EQUIPAMENTO"; tooltip="Arraste um item, uma linha do kit ou um kit salvo e solte neste painel para adicionar ao equipamento atualmente selecionado em Mostrar."; x=safeZoneX+0.804*safeZoneW; y=safeZoneY+0.178*safeZoneH; w=0.164*safeZoneW; h=0.035*safeZoneH; colorBackground[]={0.24,0.13,0.03,0.42}; colorText[]={1,0.84,0.55,1}; onLBDrop="['DROP',_this] call ServoPeregrino_Organizador_Items_fnc_handleUIDragEvent";};

        class EquipmentTable: SPORG_Items_EquipmentTable
        {
            idc=4140; tooltip="Conteúdo do equipamento mostrado. O botão da esquerda copia para o Kit Selecionado; - / quantidade / + / X alteram este equipamento. Arraste o nome ou ícone para copiar ao kit.";
            x=safeZoneX+0.804*safeZoneW; y=safeZoneY+0.223*safeZoneH; w=0.164*safeZoneW; h=0.462*safeZoneH;
            onLBSelChanged="['EQUIPMENT_SELECT',_this#1] call ServoPeregrino_Organizador_Items_fnc_handleUIEvent";
        };

        // D.6.2: APM-like single capacity row: label | bar | kg text.
        class EquipmentCapacityLabel: SPORG_Items_Text {idc=4141; text="CAPACIDADE"; x=safeZoneX+0.804*safeZoneW; y=safeZoneY+0.713*safeZoneH; w=0.042*safeZoneW; h=0.024*safeZoneH; sizeEx=0.0125*safeZoneH; colorText[]={0.70,0.84,0.81,1};};
        class EquipmentCapacityBarBg: SPORG_Items_Text {idc=4142; x=safeZoneX+0.847*safeZoneW; y=safeZoneY+0.721*safeZoneH; w=0.072*safeZoneW; h=0.008*safeZoneH; colorBackground[]={0.03,0.05,0.055,0.88};};
        class EquipmentCapacityBarFill: SPORG_Items_Text {idc=4143; x=safeZoneX+0.847*safeZoneW; y=safeZoneY+0.721*safeZoneH; w=0.001*safeZoneW; h=0.008*safeZoneH; colorBackground[]={0.15,0.62,0.48,0.92};};
        class EquipmentCapacityText: SPORG_Items_Text {idc=4144; style=1; text="n/d"; x=safeZoneX+0.922*safeZoneW; y=safeZoneY+0.713*safeZoneH; w=0.046*safeZoneW; h=0.024*safeZoneH; sizeEx=0.0125*safeZoneH; colorText[]={0.78,0.84,0.83,1};};

        // Controles legados CP-D permanecem fora da tela apenas para compatibilidade dos gates e fallbacks antigos.
        class EquipmentList: SPORG_Items_List {idc=4120; x=safeZoneX-1; y=safeZoneY-1; w=0.001; h=0.001;};
        class EquipmentMinus: SPORG_Items_IconButton {idc=4130; text="-"; x=safeZoneX-1; y=safeZoneY-1; w=0.001; h=0.001; action="['MINUS'] call ServoPeregrino_Organizador_Items_fnc_requestEquipmentRowAction";};
        class EquipmentQuantity: SPORG_Items_Edit {idc=4131; style=2; text=""; x=safeZoneX-1; y=safeZoneY-1; w=0.001; h=0.001; onKillFocus="[_this#0] call ServoPeregrino_Organizador_Items_fnc_commitEquipmentQuantityFromControl"; onKeyDown="_this call ServoPeregrino_Organizador_Items_fnc_handleEquipmentQuantityKeyDown";};
        class EquipmentPlus: SPORG_Items_IconButton {idc=4132; text="+"; x=safeZoneX-1; y=safeZoneY-1; w=0.001; h=0.001; action="['PLUS'] call ServoPeregrino_Organizador_Items_fnc_requestEquipmentRowAction";};
        class EquipmentDelete: SPORG_Items_ButtonDanger {idc=4133; text="X"; x=safeZoneX-1; y=safeZoneY-1; w=0.001; h=0.001; action="['DELETE'] call ServoPeregrino_Organizador_Items_fnc_requestEquipmentRowAction";};

        class EquipmentRefresh: SPORG_Items_Button {idc=4121; text="ATUALIZAR"; tooltip="Atualizar a lista com o conteúdo atual do equipamento mostrado"; x=safeZoneX+0.804*safeZoneW; y=safeZoneY+0.776*safeZoneH; w=0.050*safeZoneW; h=0.030*safeZoneH; action="['REFRESH'] call ServoPeregrino_Organizador_Items_fnc_handleUIEvent";};
        class EquipmentCapture: SPORG_Items_Button {idc=4123; text="CAPTURAR"; tooltip="Copiar todo o conteúdo mostrado para um novo Kit Selecionado, sem remover nada do equipamento"; x=safeZoneX+0.858*safeZoneW; y=safeZoneY+0.776*safeZoneH; w=0.050*safeZoneW; h=0.030*safeZoneH; action="['CAPTURE_EQUIPMENT'] call ServoPeregrino_Organizador_Items_fnc_handleUIEvent";};
        class EquipmentClearContent: SPORG_Items_ButtonDanger {idc=4124; text="LIMPAR"; tooltip="Remover os itens gerenciáveis do equipamento mostrado. Armas, mochilas internas e conteúdos reservados são preservados."; x=safeZoneX+0.912*safeZoneW; y=safeZoneY+0.776*safeZoneH; w=0.056*safeZoneW; h=0.030*safeZoneH; action="['EQUIPMENT_CLEAR_REQUEST'] call ServoPeregrino_Organizador_Items_fnc_handleUIEvent";};
        class EquipmentStatus: SPORG_Items_Structured {idc=4122; x=safeZoneX+0.804*safeZoneW; y=safeZoneY+0.812*safeZoneH; w=0.164*safeZoneW; h=0.060*safeZoneH;};

        class FooterContext: SPORG_Items_FooterContext {idc=5000; x=safeZoneX+0.022*safeZoneW; y=safeZoneY+0.887*safeZoneH; w=0.956*safeZoneW; h=0.025*safeZoneH;};
        class FooterMessage: SPORG_Items_FooterMessage {idc=5001; x=safeZoneX+0.022*safeZoneW; y=safeZoneY+0.916*safeZoneH; w=0.956*safeZoneW; h=0.025*safeZoneH;};
        class FooterHistory: SPORG_Items_FooterHistory {idc=5002; x=safeZoneX+0.022*safeZoneW; y=safeZoneY+0.945*safeZoneH; w=0.956*safeZoneW; h=0.026*safeZoneH;};

        // C.8.1 — nenhum ghost estático: o proxy é criado em runtime somente após o gesto entrar em ACTIVE.
    };
};
