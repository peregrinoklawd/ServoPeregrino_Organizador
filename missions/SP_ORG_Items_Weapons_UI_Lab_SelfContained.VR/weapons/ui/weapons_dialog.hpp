// SP_ORG Weapons 0.6-F R5 — Final Visual Adaptation / Regression
// R4 keeps the R3 authoring/search contracts and adds non-distorting weapon previews
// plus a uniform text-button grammar for Catalog filters.
// Visual grammar intentionally converges with SP_ORG Items Multiplayer Lab R3:
// same transparency, four-panel safeZone grid, RobotoCondensed, search/filter hierarchy,
// visible continuous catalog scrollbar and three distinct footer bands.
// Domain-specific content remains Weapons-owned; current equipment panel is read-only until 0.7.

#define SPORG_WEAPONS_UI_CLEAR_H SPORG_UICOMMON_UI_CLEAR_H
#define SPORG_WEAPONS_UI_CLEAR_W SPORG_UICOMMON_UI_CLEAR_W
#define SPORG_WEAPONS_UI_ICON_H SPORG_UICOMMON_UI_ICON_H
#define SPORG_WEAPONS_UI_ICON_W SPORG_UICOMMON_UI_ICON_W
#define SPORG_WEAPONS_UI_HEADER_RIGHT_X SPORG_UICOMMON_UI_HEADER_RIGHT_X
#define SPORG_WEAPONS_UI_HEADER_GAP_W SPORG_UICOMMON_UI_HEADER_GAP_W
#define SPORG_WEAPONS_UI_HEADER_CLOSE_X SPORG_UICOMMON_UI_HEADER_CLOSE_X
#define SPORG_WEAPONS_UI_HEADER_FUTURE_X SPORG_UICOMMON_UI_HEADER_FUTURE_X
#define SPORG_WEAPONS_UI_HEADER_ID_W SPORG_UICOMMON_UI_HEADER_ID_W
#define SPORG_WEAPONS_UI_HEADER_ID_X SPORG_UICOMMON_UI_HEADER_ID_X
#define SPORG_WEAPONS_UI_HEADER_CONTEXT_W (0.126 * safeZoneW)
#define SPORG_WEAPONS_UI_HEADER_CONTEXT_X (SPORG_WEAPONS_UI_HEADER_ID_X - SPORG_WEAPONS_UI_HEADER_GAP_W - SPORG_WEAPONS_UI_HEADER_CONTEXT_W)
#define SPORG_WEAPONS_UI_SEARCH_H SPORG_UICOMMON_UI_SEARCH_H
#define SPORG_WEAPONS_UI_SEARCH_W SPORG_UICOMMON_UI_SEARCH_W
#define SPORG_WEAPONS_UI_SEARCH_GAP_W SPORG_UICOMMON_UI_SEARCH_GAP_W

class SPORG_Weapons_Text: SPORG_UICommon_Text {};
class SPORG_Weapons_Title: SPORG_UICommon_Title {};
class SPORG_Weapons_Picture: SPORG_UICommon_PictureKeepAspect {};
class SPORG_Weapons_SearchIcon: SPORG_UICommon_SearchIconKeepAspect {};
class SPORG_Weapons_RoundedSurface: SPORG_UICommon_RoundedSurface {};
class SPORG_Weapons_SearchSurface: SPORG_UICommon_SearchSurface {};
class SPORG_Weapons_Button: SPORG_UICommon_Button {};
class SPORG_Weapons_ButtonFlat: SPORG_UICommon_ButtonFlat {};
class SPORG_Weapons_ButtonDanger: SPORG_UICommon_ButtonDanger {};
class SPORG_Weapons_IconButton: SPORG_UICommon_IconButton {};
class SPORG_Weapons_Edit: SPORG_UICommon_Edit {};
class SPORG_Weapons_SearchEdit: SPORG_UICommon_SearchEdit {};
class SPORG_Weapons_SearchClear: SPORG_UICommon_SearchClear {};
class SPORG_Weapons_List: SPORG_UICommon_List {rowHeight=0.033*safeZoneH;};
class SPORG_Weapons_KitList: SPORG_UICommon_KitList {};
class SPORG_Weapons_Combo
{
 type=4; idc=-1; style=16; text=""; x=0; y=0; w=0; h=0;
 font="RobotoCondensed"; sizeEx=0.016*safeZoneH; shadow=0;
 colorSelect[]={1,1,1,1}; colorText[]={0.88,0.91,0.91,1};
 colorBackground[]={0.08,0.11,0.12,0.78}; colorScrollbar[]={0.60,0.66,0.66,1}; colorDisabled[]={0.40,0.43,0.43,1};
 colorPicture[]={1,1,1,1}; colorPictureSelected[]={1,1,1,1}; colorPictureDisabled[]={1,1,1,0.25};
 colorPictureRight[]={1,1,1,1}; colorPictureRightSelected[]={1,1,1,1}; colorPictureRightDisabled[]={1,1,1,0.25};
 colorTextRight[]={1,1,1,1}; colorSelectRight[]={1,1,1,1}; colorSelect2Right[]={1,1,1,1};
 colorSelectBackground[]={0.12,0.32,0.38,0.72}; colorActive[]={0.75,0.92,0.88,1};
 tooltipColorText[]={1,1,1,1}; tooltipColorBox[]={0,0,0,0}; tooltipColorShade[]={0,0,0,0.72};
 soundSelect[]={"\A3\ui_f\data\sound\RscCombo\soundSelect",0.1,1};
 soundExpand[]={"\A3\ui_f\data\sound\RscCombo\soundExpand",0.1,1};
 soundCollapse[]={"\A3\ui_f\data\sound\RscCombo\soundCollapse",0.1,1};
 maxHistoryDelay=1; wholeHeight=0.34*safeZoneH;
 arrowEmpty="\A3\ui_f\data\GUI\RscCommon\RscCombo\arrow_combo_ca.paa";
 arrowFull="\A3\ui_f\data\GUI\RscCommon\RscCombo\arrow_combo_active_ca.paa";
 class ComboScrollBar
 {
  color[]={0.60,0.66,0.66,1}; colorActive[]={0.80,0.86,0.86,1}; colorDisabled[]={0.35,0.38,0.38,0.45};
  thumb="\A3\ui_f\data\gui\cfg\scrollbar\thumb_ca.paa";
  arrowEmpty="\A3\ui_f\data\gui\cfg\scrollbar\arrowEmpty_ca.paa";
  arrowFull="\A3\ui_f\data\gui\cfg\scrollbar\arrowFull_ca.paa";
  border="\A3\ui_f\data\gui\cfg\scrollbar\border_ca.paa";
  shadow=0; scrollSpeed=0.06; width=0; height=0;
  autoScrollEnabled=0; autoScrollSpeed=-1; autoScrollDelay=5; autoScrollRewind=0;
 };
};
class SPORG_Weapons_Structured: SPORG_UICommon_Structured {};
class SPORG_Weapons_FooterContext: SPORG_UICommon_FooterContext {};
class SPORG_Weapons_FooterMessage: SPORG_UICommon_FooterMessage {};
class SPORG_Weapons_FooterHistory: SPORG_UICommon_FooterHistory {};


class SPORG_Weapons_VSlider: SPORG_UICommon_VSlider {};
class SPORG_Weapons_CatalogList: SPORG_Weapons_List
{
 colorScrollbar[]={0,0,0,0};
 class ListScrollBar {color[]={0,0,0,0}; autoScrollEnabled=0;};
};

class SP_ORG_Weapons_Dialog
{
 idd=7800; movingEnable=0; enableSimulation=1;
 onLoad="_this call ServoPeregrino_Organizador_Weapons_fnc_onInterfaceLoad";
 onUnload="_this call ServoPeregrino_Organizador_Weapons_fnc_onInterfaceUnload";
 onMouseZChanged="_this call ServoPeregrino_Organizador_Weapons_fnc_handleUIWheel";

 class controlsBackground
 {
  class Shade: SPORG_Weapons_Text {idc=-1; x=safeZoneX; y=safeZoneY; w=safeZoneW; h=safeZoneH; colorBackground[]={0.01,0.015,0.017,0.12};};
  class Header: SPORG_Weapons_Text {idc=-1; x=safeZoneX; y=safeZoneY; w=safeZoneW; h=0.049*safeZoneH; colorBackground[]={0.015,0.09,0.105,0.80};};
  class HeaderDivider: SPORG_Weapons_Text {idc=-1; x=safeZoneX; y=safeZoneY+0.048*safeZoneH; w=safeZoneW; h=0.0012*safeZoneH; colorBackground[]={0.22,0.46,0.43,0.42};};
  class P1: SPORG_Weapons_RoundedSurface {idc=-1; x=safeZoneX+0.012*safeZoneW; y=safeZoneY+0.052*safeZoneH; w=0.176*safeZoneW; h=0.815*safeZoneH; colorText[]={0.015,0.02,0.022,0.44};};
  class P2: SPORG_Weapons_RoundedSurface {idc=-1; x=safeZoneX+0.196*safeZoneW; y=safeZoneY+0.052*safeZoneH; w=0.252*safeZoneW; h=0.815*safeZoneH; colorText[]={0.015,0.02,0.022,0.44};};
  class P3: SPORG_Weapons_RoundedSurface {idc=-1; x=safeZoneX+0.456*safeZoneW; y=safeZoneY+0.052*safeZoneH; w=0.330*safeZoneW; h=0.815*safeZoneH; colorText[]={0.015,0.02,0.022,0.44};};
  class P4: SPORG_Weapons_RoundedSurface {idc=-1; x=safeZoneX+0.794*safeZoneW; y=safeZoneY+0.052*safeZoneH; w=0.194*safeZoneW; h=0.815*safeZoneH; colorText[]={0.015,0.02,0.022,0.44};};
  class FooterBg: SPORG_Weapons_Text {idc=-1; x=safeZoneX+0.012*safeZoneW; y=safeZoneY+0.878*safeZoneH; w=0.976*safeZoneW; h=0.105*safeZoneH; colorBackground[]={0,0,0,0};};
  class FooterContextBg: SPORG_Weapons_RoundedSurface {idc=-1; x=safeZoneX+0.012*safeZoneW; y=safeZoneY+0.884*safeZoneH; w=0.976*safeZoneW; h=0.027*safeZoneH; colorText[]={0.02,0.055,0.055,0.25};};
  class FooterMessageBg: SPORG_Weapons_RoundedSurface {idc=-1; x=safeZoneX+0.012*safeZoneW; y=safeZoneY+0.914*safeZoneH; w=0.976*safeZoneW; h=0.027*safeZoneH; colorText[]={0.025,0.035,0.040,0.28};};
  class FooterHistoryBg: SPORG_Weapons_RoundedSurface {idc=-1; x=safeZoneX+0.012*safeZoneW; y=safeZoneY+0.944*safeZoneH; w=0.976*safeZoneW; h=0.027*safeZoneH; colorText[]={0.020,0.030,0.032,0.16};};
 };

 class controls
 {
  // Header operacional ancorado da direita para a esquerda, seguindo o padrão APM/Items.
  // O X é a âncora; nenhum bloco usa percentuais independentes próximos à borda direita.
  class HeaderTitle: SPORG_Weapons_Title {idc=100; text="SP_ORG — ORGANIZADOR DE ARMAS  |  0.6-F R5"; x=safeZoneX+0.012*safeZoneW; y=safeZoneY+0.010*safeZoneH; w=SPORG_WEAPONS_UI_HEADER_CONTEXT_X-(safeZoneX+0.018*safeZoneW); h=0.026*safeZoneH; sizeEx=0.0165*safeZoneH;};
  class HeaderContext: SPORG_Weapons_Text {idc=104; style=1; text="Equipamento: -"; tooltip="Slot de arma atualmente visualizado no painel Conteúdo do Equipamento"; x=SPORG_WEAPONS_UI_HEADER_CONTEXT_X; y=safeZoneY+0.014*safeZoneH; w=SPORG_WEAPONS_UI_HEADER_CONTEXT_W; h=0.019*safeZoneH; sizeEx=0.0109*safeZoneH;};
  class HeaderOperator: SPORG_Weapons_Text {idc=101; style=1; text="Operador: -"; tooltip="Jogador que está usando o Organizador de Armas"; x=SPORG_WEAPONS_UI_HEADER_ID_X; y=safeZoneY+0.005*safeZoneH; w=SPORG_WEAPONS_UI_HEADER_ID_W; h=0.018*safeZoneH; sizeEx=0.0109*safeZoneH;};
  class HeaderUnit: SPORG_Weapons_Text {idc=103; style=1; text="Unidade: -"; tooltip="Grupo atual do jogador"; x=SPORG_WEAPONS_UI_HEADER_ID_X; y=safeZoneY+0.024*safeZoneH; w=SPORG_WEAPONS_UI_HEADER_ID_W; h=0.018*safeZoneH; sizeEx=0.0109*safeZoneH;};
  class FutureIconSlot: SPORG_Weapons_Text {idc=107; text=""; tooltip="Espaço reservado para integração futura"; x=SPORG_WEAPONS_UI_HEADER_FUTURE_X; y=safeZoneY+0.009*safeZoneH; w=SPORG_WEAPONS_UI_ICON_W; h=SPORG_WEAPONS_UI_ICON_H; colorBackground[]={0.04,0.08,0.085,0.14};};
  class Close: SPORG_Weapons_IconButton {idc=102; text="X"; tooltip="Fechar o Organizador de Armas"; x=SPORG_WEAPONS_UI_HEADER_CLOSE_X; y=safeZoneY+0.009*safeZoneH; w=SPORG_WEAPONS_UI_ICON_W; h=SPORG_WEAPONS_UI_ICON_H; action="['REQUEST_CLOSE'] call ServoPeregrino_Organizador_Weapons_fnc_handleUIEvent";};

  class KitsTitle: SPORG_Weapons_Title {idc=1000; text="MEUS KITS DE ARMAS"; x=safeZoneX+0.022*safeZoneW; y=safeZoneY+0.064*safeZoneH; w=0.118*safeZoneW; h=0.026*safeZoneH;  sizeEx=0.017*safeZoneH;};
  class KitsPublicos: SPORG_Weapons_Button {idc=1107; text="PÚBLICOS"; sizeEx=0.0105*safeZoneH; tooltip="Biblioteca pública de WeaponKits — reservada para gate futuro"; x=safeZoneX+0.142*safeZoneW; y=safeZoneY+0.061*safeZoneH; w=0.036*safeZoneW; h=0.030*safeZoneH; action="['PUBLIC_LIBRARY'] call ServoPeregrino_Organizador_Weapons_fnc_handleUIEvent";};
  class KitsSearchBg: SPORG_Weapons_SearchSurface {idc=1091; x=safeZoneX+0.022*safeZoneW; y=safeZoneY+0.099*safeZoneH; w=0.156*safeZoneW; h=SPORG_UICOMMON_UI_SEARCH_BAR_H;};
  class KitsSearchIcon: SPORG_Weapons_SearchIcon {idc=1090; x=safeZoneX+0.022*safeZoneW+SPORG_UICOMMON_UI_SEARCH_PAD_W; y=safeZoneY+0.1055*safeZoneH; w=SPORG_UICOMMON_UI_SEARCH_ICON_W; h=SPORG_UICOMMON_UI_SEARCH_ICON_H;};
  class KitsSearch: SPORG_Weapons_SearchEdit {idc=1100; tooltip="Buscar WeaponKits pelo nome"; x=safeZoneX+0.022*safeZoneW+SPORG_UICOMMON_UI_SEARCH_PAD_W+SPORG_UICOMMON_UI_SEARCH_ICON_W+SPORG_UICOMMON_UI_SEARCH_PAD_W; y=safeZoneY+0.099*safeZoneH; w=0.156*safeZoneW-SPORG_UICOMMON_UI_SEARCH_ICON_W-SPORG_UICOMMON_UI_SEARCH_CLEAR_W-(4*SPORG_UICOMMON_UI_SEARCH_PAD_W); h=SPORG_UICOMMON_UI_SEARCH_BAR_H; onKeyUp="['KIT_SEARCH',ctrlText (_this#0)] call ServoPeregrino_Organizador_Weapons_fnc_handleUIEvent";};
  class KitsClear: SPORG_Weapons_SearchClear {idc=1101; text="x"; tooltip="Limpar busca de kits"; x=safeZoneX+0.178*safeZoneW-SPORG_UICOMMON_UI_SEARCH_CLEAR_W-SPORG_UICOMMON_UI_SEARCH_PAD_W; y=safeZoneY+0.1025*safeZoneH; w=SPORG_UICOMMON_UI_SEARCH_CLEAR_W; h=SPORG_UICOMMON_UI_SEARCH_CLEAR_H; action="['KIT_SEARCH',''] call ServoPeregrino_Organizador_Weapons_fnc_handleUIEvent";};
  class KitsTypeLabel: SPORG_Weapons_Text {idc=1102; text="Tipo:"; x=safeZoneX+0.022*safeZoneW; y=safeZoneY+0.141*safeZoneH; w=0.017*safeZoneW; h=0.027*safeZoneH; sizeEx=0.013*safeZoneH;};
  class KitsTodos: SPORG_Weapons_Button {idc=1103; text="TODOS"; sizeEx=0.0105*safeZoneH; x=safeZoneX+0.041*safeZoneW; y=safeZoneY+0.139*safeZoneH; w=0.030*safeZoneW; h=0.030*safeZoneH; action="['KIT_TYPE','ALL'] call ServoPeregrino_Organizador_Weapons_fnc_handleUIEvent";};
  class KitsPrincipal: SPORG_Weapons_Button {idc=1104; text="PRINC."; sizeEx=0.0105*safeZoneH; tooltip="Principal / PRIMARY"; x=safeZoneX+0.073*safeZoneW; y=safeZoneY+0.139*safeZoneH; w=0.033*safeZoneW; h=0.030*safeZoneH; action="['KIT_TYPE','PRIMARY'] call ServoPeregrino_Organizador_Weapons_fnc_handleUIEvent";};
  class KitsPorte: SPORG_Weapons_Button {idc=1105; text="PORTE"; sizeEx=0.0105*safeZoneH; tooltip="Porte / HANDGUN"; x=safeZoneX+0.108*safeZoneW; y=safeZoneY+0.139*safeZoneH; w=0.029*safeZoneW; h=0.030*safeZoneH; action="['KIT_TYPE','HANDGUN'] call ServoPeregrino_Organizador_Weapons_fnc_handleUIEvent";};
  class KitsSecundaria: SPORG_Weapons_Button {idc=1106; text="SEC."; sizeEx=0.0105*safeZoneH; tooltip="Secundária / SECONDARY"; x=safeZoneX+0.139*safeZoneW; y=safeZoneY+0.139*safeZoneH; w=0.033*safeZoneW; h=0.030*safeZoneH; action="['KIT_TYPE','SECONDARY'] call ServoPeregrino_Organizador_Weapons_fnc_handleUIEvent";};
  class KitsList: SPORG_Weapons_KitList {idc=1110; tooltip="WeaponKits da sessão filtrados pelo tipo selecionado"; x=safeZoneX+0.022*safeZoneW; y=safeZoneY+0.181*safeZoneH; w=0.156*safeZoneW; h=0.532*safeZoneH; onLBSelChanged="['KIT_SELECT',_this#1] call ServoPeregrino_Organizador_Weapons_fnc_handleUIEvent";};
  class KitsNew: SPORG_Weapons_Button {idc=1120; text="NOVO"; sizeEx=0.011*safeZoneH; tooltip="Preparar um novo rascunho aguardando uma arma do Catálogo"; x=safeZoneX+0.022*safeZoneW; y=safeZoneY+0.726*safeZoneH; w=0.033*safeZoneW; h=0.032*safeZoneH; action="['NEW_KIT'] call ServoPeregrino_Organizador_Weapons_fnc_handleUIEvent";};
  class KitsDuplicate: SPORG_Weapons_Button {idc=1122; text="DUPLICAR"; sizeEx=0.0105*safeZoneH; tooltip="Duplicar o conteúdo SALVO do WeaponKit selecionado"; x=safeZoneX+0.058*safeZoneW; y=safeZoneY+0.726*safeZoneH; w=0.039*safeZoneW; h=0.032*safeZoneH; action="['DUPLICATE_KIT'] call ServoPeregrino_Organizador_Weapons_fnc_handleUIEvent";};
  class KitsDelete: SPORG_Weapons_ButtonDanger {idc=1123; text="EXCLUIR"; sizeEx=0.0105*safeZoneH; tooltip="Excluir o WeaponKit selecionado do repositório desta sessão"; x=safeZoneX+0.100*safeZoneW; y=safeZoneY+0.726*safeZoneH; w=0.036*safeZoneW; h=0.032*safeZoneH; action="['DELETE_KIT'] call ServoPeregrino_Organizador_Weapons_fnc_handleUIEvent";};
  class KitsPublish: SPORG_Weapons_Button {idc=1124; text="PUBLICAR"; sizeEx=0.0105*safeZoneH; tooltip="Reservado para biblioteca pública autoritativa de Weapons"; x=safeZoneX+0.139*safeZoneW; y=safeZoneY+0.726*safeZoneH; w=0.039*safeZoneW; h=0.032*safeZoneH; action="['PUBLISH_KIT'] call ServoPeregrino_Organizador_Weapons_fnc_handleUIEvent";};

  class SelectedTitle: SPORG_Weapons_Title {idc=2000; text="ARMAS DO KIT"; x=safeZoneX+0.206*safeZoneW; y=safeZoneY+0.064*safeZoneH; w=0.073*safeZoneW; h=0.026*safeZoneH;  sizeEx=0.017*safeZoneH;};
  class SelectedName: SPORG_Weapons_Edit {idc=2001; text="Nenhum kit selecionado"; tooltip="Nome do WeaponKit. SALVAR confirma nome + Recipe."; x=safeZoneX+0.281*safeZoneW; y=safeZoneY+0.061*safeZoneH; w=0.098*safeZoneW; h=0.030*safeZoneH; onKeyUp="['DRAFT_NAME_INPUT',ctrlText (_this#0)] call ServoPeregrino_Organizador_Weapons_fnc_handleUIEvent";};
  class SelectedDirty: SPORG_Weapons_Text {idc=2002; style=1; text="SEM KIT"; x=safeZoneX+0.382*safeZoneW; y=safeZoneY+0.064*safeZoneH; w=0.056*safeZoneW; h=0.026*safeZoneH; colorText[]={0.70,0.78,0.77,1};};
  class DraftSearchBg: SPORG_Weapons_SearchSurface {idc=2053; x=safeZoneX+0.206*safeZoneW; y=safeZoneY+0.099*safeZoneH; w=0.228*safeZoneW; h=SPORG_UICOMMON_UI_SEARCH_BAR_H;};
  class DraftSearchIcon: SPORG_Weapons_SearchIcon {idc=2050; x=safeZoneX+0.206*safeZoneW+SPORG_UICOMMON_UI_SEARCH_PAD_W; y=safeZoneY+0.1055*safeZoneH; w=SPORG_UICOMMON_UI_SEARCH_ICON_W; h=SPORG_UICOMMON_UI_SEARCH_ICON_H;};
  class DraftSearch: SPORG_Weapons_SearchEdit {idc=2051; tooltip="Pesquisar somente em ARMAS DO KIT"; x=safeZoneX+0.206*safeZoneW+SPORG_UICOMMON_UI_SEARCH_PAD_W+SPORG_UICOMMON_UI_SEARCH_ICON_W+SPORG_UICOMMON_UI_SEARCH_PAD_W; y=safeZoneY+0.099*safeZoneH; w=0.228*safeZoneW-SPORG_UICOMMON_UI_SEARCH_ICON_W-SPORG_UICOMMON_UI_SEARCH_CLEAR_W-(4*SPORG_UICOMMON_UI_SEARCH_PAD_W); h=SPORG_UICOMMON_UI_SEARCH_BAR_H; onKeyUp="['P2_SEARCH',ctrlText (_this#0)] call ServoPeregrino_Organizador_Weapons_fnc_handleUIEvent";};
  class DraftSearchClear: SPORG_Weapons_SearchClear {idc=2052; text="x"; tooltip="Limpar busca de ARMAS DO KIT"; x=safeZoneX+0.434*safeZoneW-SPORG_UICOMMON_UI_SEARCH_CLEAR_W-SPORG_UICOMMON_UI_SEARCH_PAD_W; y=safeZoneY+0.1025*safeZoneH; w=SPORG_UICOMMON_UI_SEARCH_CLEAR_W; h=SPORG_UICOMMON_UI_SEARCH_CLEAR_H; action="['P2_SEARCH',''] call ServoPeregrino_Organizador_Weapons_fnc_handleUIEvent";};
  class SelectedSave: SPORG_Weapons_Button {idc=2141; text="SALVAR"; tooltip="Salvar nome + Recipe no WeaponKit selecionado. Não equipa a arma."; x=safeZoneX+0.206*safeZoneW; y=safeZoneY+0.139*safeZoneH; w=0.044*safeZoneW; h=0.032*safeZoneH; action="['SAVE_DRAFT'] call ServoPeregrino_Organizador_Weapons_fnc_handleUIEvent";};
  class SelectedSaveAs: SPORG_Weapons_Button {idc=2142; text="SALVAR COMO NOVO"; tooltip="Criar outro WeaponKit usando o Recipe atual do rascunho"; x=safeZoneX+0.253*safeZoneW; y=safeZoneY+0.139*safeZoneH; w=0.077*safeZoneW; h=0.032*safeZoneH; action="['SAVE_AS_NEW'] call ServoPeregrino_Organizador_Weapons_fnc_handleUIEvent";};
  class SelectedDiscard: SPORG_Weapons_ButtonDanger {idc=2140; text="DESCARTAR"; tooltip="Descartar alterações locais; em NOVO sem arma cancela o rascunho"; x=safeZoneX+0.333*safeZoneW; y=safeZoneY+0.139*safeZoneH; w=0.055*safeZoneW; h=0.032*safeZoneH; action="['DRAFT_DISCARD'] call ServoPeregrino_Organizador_Weapons_fnc_handleUIEvent";};
  class SelectedClear: SPORG_Weapons_ButtonDanger {idc=2143; text="LIMPAR"; tooltip="Preservar a arma-base e remover acessórios/carregador do rascunho"; x=safeZoneX+0.391*safeZoneW; y=safeZoneY+0.139*safeZoneH; w=0.043*safeZoneW; h=0.032*safeZoneH; action="['DRAFT_CLEAR'] call ServoPeregrino_Organizador_Weapons_fnc_handleUIEvent";};
  // 0.6-F R2: P2 mirrors P4 vertically so a future 3D preview can reuse the same visual grammar.
  class SelectedSlotLabel: SPORG_Weapons_Text {idc=2003; style=2; text="Tipo: -"; x=safeZoneX+0.216*safeZoneW; y=safeZoneY+0.374*safeZoneH; w=0.218*safeZoneW; h=0.018*safeZoneH; sizeEx=0.0115*safeZoneH; colorText[]={0.70,0.84,0.81,1};};
  class SelectedWeaponPicture: SPORG_Weapons_Picture {idc=2010; tooltip="Preview 2D centralizado com proporção preservada. A área permanece preparada para futuro Preview 3D sem distorção."; x=safeZoneX+0.242*safeZoneW; y=safeZoneY+0.181*safeZoneH; w=0.160*safeZoneW; h=0.135*safeZoneH;};

  // Transparent semantic backgrounds. R2 paints only rows whose current Recipe differs from baseRecipe.
  class DraftWeaponChangedBg: SPORG_Weapons_Text {idc=2060; x=safeZoneX+0.216*safeZoneW; y=safeZoneY+0.319*safeZoneH; w=0.218*safeZoneW; h=0.054*safeZoneH; colorBackground[]={0,0,0,0};};
  class DraftOpticChangedBg: SPORG_Weapons_Text {idc=2061; x=safeZoneX+0.211*safeZoneW; y=safeZoneY+0.399*safeZoneH; w=0.223*safeZoneW; h=0.033*safeZoneH; colorBackground[]={0,0,0,0};};
  class DraftMuzzleChangedBg: SPORG_Weapons_Text {idc=2062; x=safeZoneX+0.211*safeZoneW; y=safeZoneY+0.436*safeZoneH; w=0.223*safeZoneW; h=0.033*safeZoneH; colorBackground[]={0,0,0,0};};
  class DraftPointerChangedBg: SPORG_Weapons_Text {idc=2063; x=safeZoneX+0.211*safeZoneW; y=safeZoneY+0.473*safeZoneH; w=0.223*safeZoneW; h=0.033*safeZoneH; colorBackground[]={0,0,0,0};};
  class DraftBipodChangedBg: SPORG_Weapons_Text {idc=2064; x=safeZoneX+0.211*safeZoneW; y=safeZoneY+0.510*safeZoneH; w=0.223*safeZoneW; h=0.033*safeZoneH; colorBackground[]={0,0,0,0};};
  class DraftMagazineChangedBg: SPORG_Weapons_Text {idc=2065; x=safeZoneX+0.211*safeZoneW; y=safeZoneY+0.547*safeZoneH; w=0.223*safeZoneW; h=0.033*safeZoneH; colorBackground[]={0,0,0,0};};

  // Weapon summary follows the Equipment panel: preview -> centered name -> class -> slot/context.
  class WeaponLabel: SPORG_Weapons_Text {idc=2020; text=""; x=0; y=0; w=0; h=0;};
  class WeaponValue: SPORG_Weapons_ButtonFlat {idc=2021; style=2; text="Nenhuma"; tooltip="Usa a ARMA atualmente selecionada no Catálogo no rascunho"; x=safeZoneX+0.216*safeZoneW; y=safeZoneY+0.320*safeZoneH; w=0.218*safeZoneW; h=0.028*safeZoneH; colorBackground[]={0,0,0,0}; colorBackgroundActive[]={0.12,0.19,0.18,0.40}; colorFocused[]={0.12,0.19,0.18,0.40}; action="['CATALOG_TO_DRAFT'] call ServoPeregrino_Organizador_Weapons_fnc_handleUIEvent";};
  class WeaponClass: SPORG_Weapons_Text {idc=2032; style=2; text="-"; x=safeZoneX+0.216*safeZoneW; y=safeZoneY+0.349*safeZoneH; w=0.218*safeZoneW; h=0.023*safeZoneH; sizeEx=0.0115*safeZoneH; colorText[]={0.65,0.74,0.73,1};};

  class OpticLabel: SPORG_Weapons_Text {idc=2022; text="Mira"; x=safeZoneX+0.216*safeZoneW; y=safeZoneY+0.402*safeZoneH; w=0.047*safeZoneW; h=0.027*safeZoneH; sizeEx=0.0145*safeZoneH;};
  class OpticValue: SPORG_Weapons_Combo {idc=2023; tooltip="Miras compatíveis; altera somente o rascunho local."; x=safeZoneX+0.266*safeZoneW; y=safeZoneY+0.399*safeZoneH; w=0.168*safeZoneW; h=0.033*safeZoneH; onLBSelChanged="['COMPAT_SELECT',['optic',_this#1]] call ServoPeregrino_Organizador_Weapons_fnc_handleUIEvent"; sizeEx=0.0145*safeZoneH;};
  class MuzzleLabel: SPORG_Weapons_Text {idc=2024; text="Boca"; x=safeZoneX+0.216*safeZoneW; y=safeZoneY+0.439*safeZoneH; w=0.047*safeZoneW; h=0.027*safeZoneH; sizeEx=0.0145*safeZoneH;};
  class MuzzleValue: SPORG_Weapons_Combo {idc=2025; tooltip="Acessórios de boca compatíveis; altera somente o rascunho local."; x=safeZoneX+0.266*safeZoneW; y=safeZoneY+0.436*safeZoneH; w=0.168*safeZoneW; h=0.033*safeZoneH; onLBSelChanged="['COMPAT_SELECT',['muzzle',_this#1]] call ServoPeregrino_Organizador_Weapons_fnc_handleUIEvent"; sizeEx=0.0145*safeZoneH;};
  class PointerLabel: SPORG_Weapons_Text {idc=2026; text="Apontador"; x=safeZoneX+0.216*safeZoneW; y=safeZoneY+0.476*safeZoneH; w=0.047*safeZoneW; h=0.027*safeZoneH; sizeEx=0.0145*safeZoneH;};
  class PointerValue: SPORG_Weapons_Combo {idc=2027; tooltip="Apontadores/lasers compatíveis; altera somente o rascunho local."; x=safeZoneX+0.266*safeZoneW; y=safeZoneY+0.473*safeZoneH; w=0.168*safeZoneW; h=0.033*safeZoneH; onLBSelChanged="['COMPAT_SELECT',['pointer',_this#1]] call ServoPeregrino_Organizador_Weapons_fnc_handleUIEvent"; sizeEx=0.0145*safeZoneH;};
  class BipodLabel: SPORG_Weapons_Text {idc=2028; text="Bipé/Emp."; x=safeZoneX+0.216*safeZoneW; y=safeZoneY+0.513*safeZoneH; w=0.047*safeZoneW; h=0.027*safeZoneH; sizeEx=0.0145*safeZoneH;};
  class BipodValue: SPORG_Weapons_Combo {idc=2029; tooltip="Bipés/empunhaduras compatíveis; altera somente o rascunho local."; x=safeZoneX+0.266*safeZoneW; y=safeZoneY+0.510*safeZoneH; w=0.168*safeZoneW; h=0.033*safeZoneH; onLBSelChanged="['COMPAT_SELECT',['bipod',_this#1]] call ServoPeregrino_Organizador_Weapons_fnc_handleUIEvent"; sizeEx=0.0145*safeZoneH;};
  class MagazineLabel: SPORG_Weapons_Text {idc=2030; text="Carregador"; x=safeZoneX+0.216*safeZoneW; y=safeZoneY+0.550*safeZoneH; w=0.047*safeZoneW; h=0.027*safeZoneH; sizeEx=0.0145*safeZoneH;};
  class MagazineValue: SPORG_Weapons_Combo {idc=2031; tooltip="Carregadores compatíveis; altera somente o rascunho local."; x=safeZoneX+0.266*safeZoneW; y=safeZoneY+0.547*safeZoneH; w=0.168*safeZoneW; h=0.033*safeZoneH; onLBSelChanged="['COMPAT_SELECT',['magazineClass',_this#1]] call ServoPeregrino_Organizador_Weapons_fnc_handleUIEvent"; sizeEx=0.0145*safeZoneH;};
  class SelectedHint: SPORG_Weapons_Structured {idc=2040; x=safeZoneX+0.216*safeZoneW; y=safeZoneY+0.657*safeZoneH; w=0.218*safeZoneW; h=0.148*safeZoneH; colorBackground[]={0.01,0.015,0.017,0.20};};

  class CatalogTitle: SPORG_Weapons_Title {idc=3000; text="CATÁLOGO DE ARMAS"; x=safeZoneX+0.466*safeZoneW; y=safeZoneY+0.064*safeZoneH; w=0.200*safeZoneW; h=0.026*safeZoneH; sizeEx=0.017*safeZoneH;};
  class CatalogSearchBg: SPORG_Weapons_SearchSurface {idc=3091; x=safeZoneX+0.466*safeZoneW; y=safeZoneY+0.099*safeZoneH; w=0.310*safeZoneW; h=SPORG_UICOMMON_UI_SEARCH_BAR_H;};
  class CatalogSearchIcon: SPORG_Weapons_SearchIcon {idc=3090; x=safeZoneX+0.466*safeZoneW+SPORG_UICOMMON_UI_SEARCH_PAD_W; y=safeZoneY+0.1055*safeZoneH; w=SPORG_UICOMMON_UI_SEARCH_ICON_W; h=SPORG_UICOMMON_UI_SEARCH_ICON_H;};
  class CatalogSearch: SPORG_Weapons_SearchEdit {idc=3100; tooltip="Busca global no Catálogo por nome ou classe. Enquanto houver texto, filtros de Tipo/Acessório são ignorados."; x=safeZoneX+0.466*safeZoneW+SPORG_UICOMMON_UI_SEARCH_PAD_W+SPORG_UICOMMON_UI_SEARCH_ICON_W+SPORG_UICOMMON_UI_SEARCH_PAD_W; y=safeZoneY+0.099*safeZoneH; w=0.310*safeZoneW-SPORG_UICOMMON_UI_SEARCH_ICON_W-SPORG_UICOMMON_UI_SEARCH_CLEAR_W-(4*SPORG_UICOMMON_UI_SEARCH_PAD_W); h=SPORG_UICOMMON_UI_SEARCH_BAR_H; onKeyUp="['CATALOG_SEARCH',ctrlText (_this#0)] call ServoPeregrino_Organizador_Weapons_fnc_handleUIEvent";};
  class CatalogClear: SPORG_Weapons_SearchClear {idc=3101; text="x"; tooltip="Limpar busca do catálogo"; x=safeZoneX+0.776*safeZoneW-SPORG_UICOMMON_UI_SEARCH_CLEAR_W-SPORG_UICOMMON_UI_SEARCH_PAD_W; y=safeZoneY+0.1025*safeZoneH; w=SPORG_UICOMMON_UI_SEARCH_CLEAR_W; h=SPORG_UICOMMON_UI_SEARCH_CLEAR_H; action="['CATALOG_SEARCH',''] call ServoPeregrino_Organizador_Weapons_fnc_handleUIEvent";};
  class CatalogTypeLabel: SPORG_Weapons_Text {idc=3110; text="Tipo:"; x=safeZoneX+0.466*safeZoneW; y=safeZoneY+0.141*safeZoneH; w=0.017*safeZoneW; h=0.027*safeZoneH; sizeEx=0.013*safeZoneH;};
  // R6: uniform-width text buttons with compact label-to-filter spacing. Icon-button grammar remains a future UI evolution.
  class CatalogTodos: SPORG_Weapons_Button {idc=3111; text="TODOS"; sizeEx=0.0102*safeZoneH; x=safeZoneX+0.485*safeZoneW; y=safeZoneY+0.139*safeZoneH; w=0.0675*safeZoneW; h=0.030*safeZoneH; tooltip="Todos os tipos"; action="['CATALOG_TYPE','ALL'] call ServoPeregrino_Organizador_Weapons_fnc_handleUIEvent";};
  class CatalogPrincipal: SPORG_Weapons_Button {idc=3112; text="PRINC."; sizeEx=0.0102*safeZoneH; x=safeZoneX+0.5555*safeZoneW; y=safeZoneY+0.139*safeZoneH; w=0.0675*safeZoneW; h=0.030*safeZoneH; tooltip="Principal / PRIMARY"; action="['CATALOG_TYPE','PRIMARY'] call ServoPeregrino_Organizador_Weapons_fnc_handleUIEvent";};
  class CatalogPorte: SPORG_Weapons_Button {idc=3113; text="PORTE"; sizeEx=0.0102*safeZoneH; x=safeZoneX+0.626*safeZoneW; y=safeZoneY+0.139*safeZoneH; w=0.0675*safeZoneW; h=0.030*safeZoneH; tooltip="Porte / HANDGUN"; action="['CATALOG_TYPE','HANDGUN'] call ServoPeregrino_Organizador_Weapons_fnc_handleUIEvent";};
  class CatalogSecundaria: SPORG_Weapons_Button {idc=3114; text="SEC."; sizeEx=0.0102*safeZoneH; x=safeZoneX+0.6965*safeZoneW; y=safeZoneY+0.139*safeZoneH; w=0.0675*safeZoneW; h=0.030*safeZoneH; tooltip="Secundária / SECONDARY"; action="['CATALOG_TYPE','SECONDARY'] call ServoPeregrino_Organizador_Weapons_fnc_handleUIEvent";};
  class CatalogCategoryLabel: SPORG_Weapons_Text {idc=3131; text="Acessório:"; x=safeZoneX+0.466*safeZoneW; y=safeZoneY+0.179*safeZoneH; w=0.034*safeZoneW; h=0.027*safeZoneH; sizeEx=0.0125*safeZoneH;};
  // R6: accessory filters keep identical width/height/font grammar and start closer to the label.
  class CatalogKindAll: SPORG_Weapons_Button {idc=3132; text="TODOS"; sizeEx=0.0094*safeZoneH; x=safeZoneX+0.5020*safeZoneW; y=safeZoneY+0.177*safeZoneH; w=0.0360*safeZoneW; h=0.029*safeZoneH; tooltip="Todos os itens do Catálogo"; action="['CATALOG_CATEGORY','ALL'] call ServoPeregrino_Organizador_Weapons_fnc_handleUIEvent";};
  class CatalogKindWeapon: SPORG_Weapons_Button {idc=3133; text="ARMA"; sizeEx=0.0094*safeZoneH; x=safeZoneX+0.5398*safeZoneW; y=safeZoneY+0.177*safeZoneH; w=0.0360*safeZoneW; h=0.029*safeZoneH; tooltip="Armas"; action="['CATALOG_CATEGORY','WEAPON'] call ServoPeregrino_Organizador_Weapons_fnc_handleUIEvent";};
  class CatalogKindOptic: SPORG_Weapons_Button {idc=3134; text="ÓTICA"; sizeEx=0.0094*safeZoneH; x=safeZoneX+0.5776*safeZoneW; y=safeZoneY+0.177*safeZoneH; w=0.0360*safeZoneW; h=0.029*safeZoneH; tooltip="Óticas / miras"; action="['CATALOG_CATEGORY','OPTIC'] call ServoPeregrino_Organizador_Weapons_fnc_handleUIEvent";};
  class CatalogKindPointer: SPORG_Weapons_Button {idc=3135; text="APONT."; sizeEx=0.0094*safeZoneH; x=safeZoneX+0.6154*safeZoneW; y=safeZoneY+0.177*safeZoneH; w=0.0360*safeZoneW; h=0.029*safeZoneH; tooltip="Apontadores / lasers"; action="['CATALOG_CATEGORY','POINTER'] call ServoPeregrino_Organizador_Weapons_fnc_handleUIEvent";};
  class CatalogKindBipod: SPORG_Weapons_Button {idc=3136; text="BIPÉ"; sizeEx=0.0094*safeZoneH; x=safeZoneX+0.6532*safeZoneW; y=safeZoneY+0.177*safeZoneH; w=0.0360*safeZoneW; h=0.029*safeZoneH; tooltip="Bipés"; action="['CATALOG_CATEGORY','BIPOD'] call ServoPeregrino_Organizador_Weapons_fnc_handleUIEvent";};
  class CatalogKindMagazine: SPORG_Weapons_Button {idc=3137; text="CARREG."; sizeEx=0.0094*safeZoneH; x=safeZoneX+0.6910*safeZoneW; y=safeZoneY+0.177*safeZoneH; w=0.0360*safeZoneW; h=0.029*safeZoneH; tooltip="Carregadores"; action="['CATALOG_CATEGORY','MAGAZINE'] call ServoPeregrino_Organizador_Weapons_fnc_handleUIEvent";};
  class CatalogKindGrip: SPORG_Weapons_Button {idc=3138; text="EMPUNH."; sizeEx=0.0094*safeZoneH; x=safeZoneX+0.7288*safeZoneW; y=safeZoneY+0.177*safeZoneH; w=0.0360*safeZoneW; h=0.029*safeZoneH; tooltip="Empunhaduras / UnderBarrelSlot sem bipé"; action="['CATALOG_CATEGORY','GRIP'] call ServoPeregrino_Organizador_Weapons_fnc_handleUIEvent";};
  class CatalogList: SPORG_Weapons_CatalogList {idc=3120; tooltip="Catálogo contínuo virtualizado. ← envia ao ARMAS DO KIT; → permanece reservado para 0.7. Duplo clique envia ao rascunho."; x=safeZoneX+0.466*safeZoneW; y=safeZoneY+0.216*safeZoneH; w=0.300*safeZoneW; h=0.364*safeZoneH; onLBSelChanged="['CATALOG_SELECT',_this#1] call ServoPeregrino_Organizador_Weapons_fnc_handleUIEvent"; onLBDblClick="['CATALOG_TO_DRAFT'] call ServoPeregrino_Organizador_Weapons_fnc_handleUIEvent";};
  class CatalogScroll: SPORG_Weapons_VSlider {idc=3124; tooltip="Use a roda do mouse, arraste o marcador ou clique no trilho para navegar pelo catálogo."; x=safeZoneX+0.766*safeZoneW; y=safeZoneY+0.216*safeZoneH; w=0.010*safeZoneW; h=0.364*safeZoneH; onSliderPosChanged="['CATALOG_SCROLL_ABSOLUTE',_this#1] call ServoPeregrino_Organizador_Weapons_fnc_handleUIEvent";};
  class CatalogPage: SPORG_Weapons_Text {idc=3122; style=2; text=""; x=safeZoneX+0.466*safeZoneW; y=safeZoneY+0.584*safeZoneH; w=0.310*safeZoneW; h=0.026*safeZoneH; sizeEx=0.0125*safeZoneH;};
  class CatalogToDraft: SPORG_Weapons_Button {idc=3150; text="← EQUIPAR NO RASCUNHO"; tooltip="Enviar a arma/acessório selecionado diretamente para ARMAS DO KIT"; x=safeZoneX+0.466*safeZoneW; y=safeZoneY+0.615*safeZoneH; w=0.151*safeZoneW; h=0.034*safeZoneH; action="['CATALOG_TO_DRAFT'] call ServoPeregrino_Organizador_Weapons_fnc_handleUIEvent";};
  class CatalogToEquipment: SPORG_Weapons_Button {idc=3151; text="EQUIPAMENTO →"; tooltip="Reservado para aplicação física slot-safe em Weapons 0.7"; x=safeZoneX+0.620*safeZoneW; y=safeZoneY+0.615*safeZoneH; w=0.156*safeZoneW; h=0.034*safeZoneH; action="['CATALOG_TO_EQUIPMENT'] call ServoPeregrino_Organizador_Weapons_fnc_handleUIEvent";};
  class CatalogDetails: SPORG_Weapons_Structured {idc=3130; x=safeZoneX+0.466*safeZoneW; y=safeZoneY+0.657*safeZoneH; w=0.310*safeZoneW; h=0.148*safeZoneH; colorBackground[]={0.01,0.015,0.017,0.28};};

  class EquipmentTitle: SPORG_Weapons_Title {idc=4000; text="CONTEÚDO DO EQUIPAMENTO"; x=safeZoneX+0.804*safeZoneW; y=safeZoneY+0.064*safeZoneH; w=0.174*safeZoneW; h=0.026*safeZoneH;  sizeEx=0.017*safeZoneH;};
  class EquipmentSearchBg: SPORG_Weapons_SearchSurface {idc=4091; x=safeZoneX+0.804*safeZoneW; y=safeZoneY+0.099*safeZoneH; w=0.174*safeZoneW; h=SPORG_UICOMMON_UI_SEARCH_BAR_H;};
  class EquipmentSearchIcon: SPORG_Weapons_SearchIcon {idc=4090; x=safeZoneX+0.804*safeZoneW+SPORG_UICOMMON_UI_SEARCH_PAD_W; y=safeZoneY+0.1055*safeZoneH; w=SPORG_UICOMMON_UI_SEARCH_ICON_W; h=SPORG_UICOMMON_UI_SEARCH_ICON_H;};
  class EquipmentSearch: SPORG_Weapons_SearchEdit {idc=4100; tooltip="Pesquisar somente em CONTEÚDO DO EQUIPAMENTO"; x=safeZoneX+0.804*safeZoneW+SPORG_UICOMMON_UI_SEARCH_PAD_W+SPORG_UICOMMON_UI_SEARCH_ICON_W+SPORG_UICOMMON_UI_SEARCH_PAD_W; y=safeZoneY+0.099*safeZoneH; w=0.174*safeZoneW-SPORG_UICOMMON_UI_SEARCH_ICON_W-SPORG_UICOMMON_UI_SEARCH_CLEAR_W-(4*SPORG_UICOMMON_UI_SEARCH_PAD_W); h=SPORG_UICOMMON_UI_SEARCH_BAR_H; onKeyUp="['P4_SEARCH',ctrlText (_this#0)] call ServoPeregrino_Organizador_Weapons_fnc_handleUIEvent";};
  class EquipmentSearchClear: SPORG_Weapons_SearchClear {idc=4101; text="x"; tooltip="Limpar busca de CONTEÚDO DO EQUIPAMENTO"; x=safeZoneX+0.978*safeZoneW-SPORG_UICOMMON_UI_SEARCH_CLEAR_W-SPORG_UICOMMON_UI_SEARCH_PAD_W; y=safeZoneY+0.1025*safeZoneH; w=SPORG_UICOMMON_UI_SEARCH_CLEAR_W; h=SPORG_UICOMMON_UI_SEARCH_CLEAR_H; action="['P4_SEARCH',''] call ServoPeregrino_Organizador_Weapons_fnc_handleUIEvent";};
  class EquipmentViewLabel: SPORG_Weapons_Text {idc=4001; text="Visualizar:"; x=safeZoneX+0.804*safeZoneW; y=safeZoneY+0.141*safeZoneH; w=0.038*safeZoneW; h=0.030*safeZoneH; sizeEx=0.0115*safeZoneH;};
  class EquipmentPrimary: SPORG_Weapons_Button {idc=4011; text="PRINC."; sizeEx=0.0098*safeZoneH; x=safeZoneX+0.842*safeZoneW; y=safeZoneY+0.139*safeZoneH; w=0.043*safeZoneW; h=0.030*safeZoneH; action="['EQUIPMENT_SLOT','PRIMARY'] call ServoPeregrino_Organizador_Weapons_fnc_handleUIEvent";};
  class EquipmentHandgun: SPORG_Weapons_Button {idc=4012; text="PORTE"; sizeEx=0.0098*safeZoneH; x=safeZoneX+0.888*safeZoneW; y=safeZoneY+0.139*safeZoneH; w=0.038*safeZoneW; h=0.030*safeZoneH; action="['EQUIPMENT_SLOT','HANDGUN'] call ServoPeregrino_Organizador_Weapons_fnc_handleUIEvent";};
  class EquipmentSecondary: SPORG_Weapons_Button {idc=4013; text="SEC."; sizeEx=0.0098*safeZoneH; x=safeZoneX+0.929*safeZoneW; y=safeZoneY+0.139*safeZoneH; w=0.049*safeZoneW; h=0.030*safeZoneH; action="['EQUIPMENT_SLOT','SECONDARY'] call ServoPeregrino_Organizador_Weapons_fnc_handleUIEvent";};
  class EquipmentWeaponPicture: SPORG_Weapons_Picture {idc=4020; tooltip="Arma atualmente equipada no slot visualizado; imagem centralizada com proporção preservada"; x=safeZoneX+0.826*safeZoneW; y=safeZoneY+0.181*safeZoneH; w=0.130*safeZoneW; h=0.135*safeZoneH;};
  class EquipmentWeaponName: SPORG_Weapons_Title {idc=4021; style=2; text="Nenhuma arma"; x=safeZoneX+0.804*safeZoneW; y=safeZoneY+0.320*safeZoneH; w=0.174*safeZoneW; h=0.028*safeZoneH;};
  class EquipmentWeaponClass: SPORG_Weapons_Text {idc=4022; style=2; text="-"; x=safeZoneX+0.804*safeZoneW; y=safeZoneY+0.349*safeZoneH; w=0.174*safeZoneW; h=0.025*safeZoneH; sizeEx=0.012*safeZoneH; colorText[]={0.65,0.74,0.73,1};};
  class EqOpticLabel: SPORG_Weapons_Text {idc=4030; text="Mira"; x=safeZoneX+0.804*safeZoneW; y=safeZoneY+0.393*safeZoneH; w=0.048*safeZoneW; h=0.027*safeZoneH; sizeEx=0.0145*safeZoneH;};
  class EqOpticValue: SPORG_Weapons_Text {idc=4031; text="Nenhum"; x=safeZoneX+0.853*safeZoneW; y=safeZoneY+0.393*safeZoneH; w=0.125*safeZoneW; h=0.027*safeZoneH; sizeEx=0.0145*safeZoneH;};
  class EqMuzzleLabel: SPORG_Weapons_Text {idc=4032; text="Boca"; x=safeZoneX+0.804*safeZoneW; y=safeZoneY+0.428*safeZoneH; w=0.048*safeZoneW; h=0.027*safeZoneH; sizeEx=0.0145*safeZoneH;};
  class EqMuzzleValue: SPORG_Weapons_Text {idc=4033; text="Nenhum"; x=safeZoneX+0.853*safeZoneW; y=safeZoneY+0.428*safeZoneH; w=0.125*safeZoneW; h=0.027*safeZoneH; sizeEx=0.0145*safeZoneH;};
  class EqPointerLabel: SPORG_Weapons_Text {idc=4034; text="Apontador"; x=safeZoneX+0.804*safeZoneW; y=safeZoneY+0.463*safeZoneH; w=0.048*safeZoneW; h=0.027*safeZoneH; sizeEx=0.0145*safeZoneH;};
  class EqPointerValue: SPORG_Weapons_Text {idc=4035; text="Nenhum"; x=safeZoneX+0.853*safeZoneW; y=safeZoneY+0.463*safeZoneH; w=0.125*safeZoneW; h=0.027*safeZoneH; sizeEx=0.0145*safeZoneH;};
  class EqBipodLabel: SPORG_Weapons_Text {idc=4036; text="Bipé"; x=safeZoneX+0.804*safeZoneW; y=safeZoneY+0.498*safeZoneH; w=0.048*safeZoneW; h=0.027*safeZoneH; sizeEx=0.0145*safeZoneH;};
  class EqBipodValue: SPORG_Weapons_Text {idc=4037; text="Nenhum"; x=safeZoneX+0.853*safeZoneW; y=safeZoneY+0.498*safeZoneH; w=0.125*safeZoneW; h=0.027*safeZoneH; sizeEx=0.0145*safeZoneH;};
  class EqMagazineLabel: SPORG_Weapons_Text {idc=4038; text="Carregador"; x=safeZoneX+0.804*safeZoneW; y=safeZoneY+0.533*safeZoneH; w=0.048*safeZoneW; h=0.027*safeZoneH; sizeEx=0.0145*safeZoneH;};
  class EqMagazineValue: SPORG_Weapons_Text {idc=4039; text="Nenhum"; x=safeZoneX+0.853*safeZoneW; y=safeZoneY+0.533*safeZoneH; w=0.125*safeZoneW; h=0.027*safeZoneH; sizeEx=0.0145*safeZoneH;};
  class EquipmentStatus: SPORG_Weapons_Structured {idc=4040; x=safeZoneX+0.804*safeZoneW; y=safeZoneY+0.657*safeZoneH; w=0.174*safeZoneW; h=0.148*safeZoneH; colorBackground[]={0.01,0.015,0.017,0.20};};
  class EquipmentReadOnly: SPORG_Weapons_Text {idc=4041; style=2; text="SOMENTE LEITURA — APLICAÇÃO EM 0.7"; x=safeZoneX+0.804*safeZoneW; y=safeZoneY+0.812*safeZoneH; w=0.174*safeZoneW; h=0.032*safeZoneH; sizeEx=0.0115*safeZoneH; colorText[]={0.55,0.75,0.71,1};};

  class FooterContext: SPORG_Weapons_FooterContext {idc=5000; x=safeZoneX+0.022*safeZoneW; y=safeZoneY+0.887*safeZoneH; w=0.956*safeZoneW; h=0.023*safeZoneH;};
  class FooterMessage: SPORG_Weapons_FooterMessage {idc=5001; x=safeZoneX+0.022*safeZoneW; y=safeZoneY+0.917*safeZoneH; w=0.956*safeZoneW; h=0.023*safeZoneH;};
  class FooterHistory: SPORG_Weapons_FooterHistory {idc=5002; x=safeZoneX+0.022*safeZoneW; y=safeZoneY+0.947*safeZoneH; w=0.956*safeZoneW; h=0.023*safeZoneH;};
 };
};
