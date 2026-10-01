#include "..\..\script_version.hpp"
disableSerialization;
private _refreshStartedAt=diag_tickTime;
private _display = uiNamespace getVariable [SERVO_PEREGRINO_ORGANIZADOR_ITEMS_UI_DISPLAY_VAR, displayNull];
if (isNull _display) exitWith {false};
private _guardState = missionNamespace getVariable [SERVO_PEREGRINO_ORGANIZADOR_ITEMS_UI_STATE_VAR, createHashMap];
_guardState set ["refreshing", true]; missionNamespace setVariable [SERVO_PEREGRINO_ORGANIZADOR_ITEMS_UI_STATE_VAR, _guardState];
private _vmStartedAt=diag_tickTime;
private _vmR = [player] call ServoPeregrino_Organizador_Items_fnc_buildUIViewModel;
private _vmDurationMs=round ((diag_tickTime-_vmStartedAt)*1000);
if !(_vmR getOrDefault ["success",false]) exitWith {_guardState set ["refreshing",false]; missionNamespace setVariable [SERVO_PEREGRINO_ORGANIZADOR_ITEMS_UI_STATE_VAR,_guardState]; false};
private _vm = _vmR getOrDefault ["data",createHashMap];
private _uiR=[] call ServoPeregrino_Organizador_Items_fnc_getUIState; private _ui=((_uiR getOrDefault ["data",createHashMap]) getOrDefault ["state",createHashMap]);
private _setEditIfDifferent={params ["_idc","_value"]; private _c=_display displayCtrl _idc; if ((ctrlText _c) isNotEqualTo _value) then {_c ctrlSetText _value;};};

// Kits — biblioteca Privados/Públicos.
private _kitsCtrl=_display displayCtrl 1102; lbClear _kitsCtrl;
private _kitLibraryMode=toUpper (_vm getOrDefault ["kitLibraryMode",_ui getOrDefault ["kitLibraryMode","PRIVATE"]]);
private _selectedKit=if (_kitLibraryMode isEqualTo "PUBLIC") then {_ui getOrDefault ["selectedPublicKitId",""]} else {_ui getOrDefault ["selectedKitId",""]};
{
    private _massTotal=_x getOrDefault ["totalMass",0];
    private _massLabel=if (_x getOrDefault ["massKnown",false]) then {[_massTotal,false,2] call ServoPeregrino_Organizador_Items_fnc_formatUIMass} else {if (_massTotal>0) then {format ["%1 + ?",[_massTotal,false,2] call ServoPeregrino_Organizador_Items_fnc_formatUIMass]} else {"n/d"}};
    private _scope=_x getOrDefault ["scope",_kitLibraryMode];
    private _author=_x getOrDefault ["authorName","-"];
    private _sourceKind=toUpper (_x getOrDefault ["sourceKind",""]);
    private _originLabel=if (_sourceKind isEqualTo "SERVER") then {"Servidor"} else {_author};
    private _rowText=if (_scope isEqualTo "PUBLIC") then {format ["%1  ·  %2 items  ·  %3  ·  %4",_x getOrDefault ["name","Sem nome"],_x getOrDefault ["entryCount",0],_massLabel,_originLabel]} else {format ["%1  ·  %2 items  ·  %3",_x getOrDefault ["name","Sem nome"],_x getOrDefault ["entryCount",0],_massLabel]};
    private _idx=_kitsCtrl lbAdd _rowText;
    _kitsCtrl lbSetData [_idx,_x getOrDefault ["id",""]];
    _kitsCtrl lbSetTooltip [_idx,if (_scope isEqualTo "PUBLIC") then {format ["%1\n%2 items · peso %3\nOrigem: %4\nSnapshot somente leitura. Selecione e use SALVAR NO PRIVADO para criar uma cópia editável.",_x getOrDefault ["name","Sem nome"],_x getOrDefault ["entryCount",0],_massLabel,_originLabel]} else {format ["%1\n%2 items · peso %3\nClique para abrir em edição; arraste para combinar no Rascunho atual. PUBLICAR cria um snapshot independente.",_x getOrDefault ["name","Sem nome"],_x getOrDefault ["entryCount",0],_massLabel]}];
    if ((_x getOrDefault ["id",""]) isEqualTo _selectedKit) then {_kitsCtrl lbSetCurSel _idx;};
} forEach (_vm getOrDefault ["kits",[]]);
private _privateMode=_kitLibraryMode isEqualTo "PRIVATE";
{(_display displayCtrl _x) ctrlShow _privateMode;} forEach [1110,1111,1112,1113];
{(_display displayCtrl _x) ctrlShow (!_privateMode);} forEach [1114,1115];
(_display displayCtrl 1113) ctrlEnable (_privateMode && {(_ui getOrDefault ["selectedKitId",""]) isNotEqualTo ""});
(_display displayCtrl 1114) ctrlEnable ((!_privateMode) && {(_ui getOrDefault ["selectedPublicKitId",""]) isNotEqualTo ""});
(_display displayCtrl 1104) ctrlSetBackgroundColor (if (_privateMode) then {[0.08,0.38,0.30,0.76]} else {[0.08,0.11,0.12,0.58]});
(_display displayCtrl 1105) ctrlSetBackgroundColor (if (!_privateMode) then {[0.08,0.38,0.30,0.76]} else {[0.08,0.11,0.12,0.58]});
private _kitCount=count (_vm getOrDefault ["kits",[]]);
private _libraryActionStatus=toUpper (_ui getOrDefault ["kitLibraryActionStatus",""]);
private _libraryActionCtrl=_display displayCtrl 1001;
_libraryActionCtrl ctrlSetText _libraryActionStatus;
_libraryActionCtrl ctrlSetTextColor (switch _libraryActionStatus do {case "COPIADO": {[0.45,0.85,0.68,1]}; case "PUBLICADO": {[0.38,0.80,0.88,1]}; case "ENVIADO": {[0.96,0.72,0.25,1]}; case "FALHA": {[0.92,0.34,0.34,1]}; default {[0.55,0.60,0.60,1]};});
private _publicAuthorityLabel=if (_vm getOrDefault ["publicLibraryAuthoritative",false]) then {"servidor"} else {if (_vm getOrDefault ["publicLibraryAuthorityPending",false]) then {"aguardando servidor"} else {"réplica"}};
private _kitStatus=if (_privateMode) then {format ["<t color='#8FB7B0'>PRIVADOS · %1 kit(s)</t><br/><t color='#8A9696'>Clique abre EDIT. Arraste combina no Rascunho. PUBLICAR envia um snapshot ao servidor.</t>",_kitCount]} else {format ["<t color='#8FB7B0'>PÚBLICOS · %1 kit(s) · %2 · sessão rev. %3</t><br/><t color='#8A9696'>Somente leitura. O servidor é a autoridade das publicações; SALVAR NO PRIVADO cria uma cópia local independente.</t>",_kitCount,_publicAuthorityLabel,_vm getOrDefault ["publicLibraryRevision",0]]};
(_display displayCtrl 1103) ctrlSetStructuredText parseText _kitStatus;
[1100,_ui getOrDefault ["kitQuery",""]] call _setEditIfDifferent;
_ui set ["kitLibraryMode",_kitLibraryMode]; _ui set ["publicLibraryRevision",_vm getOrDefault ["publicLibraryRevision",0]];
missionNamespace setVariable [SERVO_PEREGRINO_ORGANIZADOR_ITEMS_UI_STATE_VAR,_ui];

// Draft header + true per-row controls
private _draft=_vm getOrDefault ["draft",createHashMap]; private _hasDraft=_draft getOrDefault ["hasDraft",false]; private _dirty=_draft getOrDefault ["dirty",false];
private _nameCtrl=_display displayCtrl 2100; _nameCtrl ctrlEnable _hasDraft; if ((ctrlText _nameCtrl) isNotEqualTo (_draft getOrDefault ["name",""])) then {_nameCtrl ctrlSetText (_draft getOrDefault ["name",""]);};
(_display displayCtrl 2001) ctrlSetText (if !_hasDraft then {"SEM KIT"} else {if (_dirty) then {"ALTERADO"} else {"SALVO"}});
(_display displayCtrl 2001) ctrlSetTextColor (if !_hasDraft then {[0.55,0.60,0.60,1]} else {if (_dirty) then {[0.96,0.72,0.25,1]} else {[0.45,0.85,0.68,1]}});
[2101,_ui getOrDefault ["draftQuery",""]] call _setEditIfDifferent;
private _draftCtrl=_display displayCtrl 2104; private _oldScroll=ctrlScrollValues _draftCtrl; ["HIDE",controlNull,_display] call ServoPeregrino_Organizador_Items_fnc_updateUIItemTooltip; ctClear _draftCtrl;
private _selectedKey=_ui getOrDefault ["selectedDraftRowKey",[]]; private _selectedIndex=-1;
{
    private _row=_x; private _key=[_row getOrDefault ["type","ITEM"],_row getOrDefault ["className",""],_row getOrDefault ["stateMode","NONE"]];
    ctAddRow _draftCtrl params ["_rowIndex","_controls"];
    if ((count _controls)>=7) then {
        _controls params ["_bg","_pic","_name","_minus","_qty","_plus","_del"];
        { _x setVariable ["SPORG_Items_rowKey",+_key]; } forEach _controls;
        private _dragEntry=+(_row getOrDefault ["entry",[]]);
        if ((count _dragEntry) isNotEqualTo 6) then {private _er=[_row getOrDefault ["type","ITEM"],_row getOrDefault ["className",""],_row getOrDefault ["quantity",0],_row getOrDefault ["stateMode","NONE"],+(_row getOrDefault ["stateData",[]])] call ServoPeregrino_Organizador_Items_fnc_createItemEntry; if (_er getOrDefault ["success",false]) then {_dragEntry=+(((_er getOrDefault ["data",createHashMap]) getOrDefault ["entry",[]]));};};
        private _dragDisplayName=_row getOrDefault ["displayName",_row getOrDefault ["className",""]];
        {_x setVariable ["SPORG_Items_draftEntry",+_dragEntry]; _x setVariable ["SPORG_Items_draftDisplayName",_dragDisplayName];} forEach [_pic,_name];
        _bg ctrlSetBackgroundColor [0.01,0.015,0.017,if ((_rowIndex mod 2) isEqualTo 0) then {0.12}else{0.20}];
        _pic ctrlSetText (_row getOrDefault ["picture",""]); _pic ctrlSetTextColor [1,1,1,1]; _pic ctrlSetTooltip format ["%1\n%2",_row getOrDefault ["displayName",_row getOrDefault ["className",""]],_row getOrDefault ["className",""]];
        private _suffix=if ((_row getOrDefault ["stateMode",""]) isEqualTo "EXACT") then {format [" · EXACT %1",_row getOrDefault ["stateData",[]]]} else {if ((_row getOrDefault ["stateMode",""]) isEqualTo "DEFAULT_FULL") then {" · CHEIO"} else {""}};
        private _massSuffix=if (_row getOrDefault ["massKnown",false]) then {format [" · %1",[(_row getOrDefault ["totalMass",0]),false,2] call ServoPeregrino_Organizador_Items_fnc_formatUIMass]} else {" · peso ?"};
        _name ctrlSetText format ["%1%2%3",_row getOrDefault ["displayName",_row getOrDefault ["className",""]],_suffix,_massSuffix]; _name ctrlSetTooltip format ["%1\nClasse: %2\nTipo: %3 · Estado: %4 · Quantidade: %5\nPeso unitário: %6 · Peso da linha: %7",_row getOrDefault ["displayName",_row getOrDefault ["className",""]],_row getOrDefault ["className",""],_row getOrDefault ["type","ITEM"],_row getOrDefault ["stateMode","NONE"],_row getOrDefault ["quantity",0],[(_row getOrDefault ["unitMass",0]),true,2] call ServoPeregrino_Organizador_Items_fnc_formatUIMass,[(_row getOrDefault ["totalMass",0]),true,2] call ServoPeregrino_Organizador_Items_fnc_formatUIMass];
        private _draftStateMode=_row getOrDefault ["stateMode","NONE"];
        private _draftStateText=if (_draftStateMode isEqualTo "EXACT") then {format [" · Munição: %1",(_row getOrDefault ["stateData",[]]) joinString "/"]} else {if (_draftStateMode isEqualTo "DEFAULT_FULL") then {" · Estado: cheio"} else {""}};
        private _draftMassText=if (_row getOrDefault ["massKnown",false]) then {format ["Peso: %1 por unidade · %2 nesta linha",[(_row getOrDefault ["unitMass",0]),true,2] call ServoPeregrino_Organizador_Items_fnc_formatUIMass,[(_row getOrDefault ["totalMass",0]),true,2] call ServoPeregrino_Organizador_Items_fnc_formatUIMass]} else {"Peso: não disponível"};
        private _draftTipLines=[format ["Quantidade no kit: %1%2",_row getOrDefault ["quantity",0],_draftStateText],_draftMassText,"Arraste para o equipamento ou use - / quantidade / + / X para editar o kit."];
        {
            _x setVariable ["SPORG_Items_tooltipTitle",_dragDisplayName];
            _x setVariable ["SPORG_Items_tooltipLines",+_draftTipLines];
            _x setVariable ["SPORG_Items_tooltipPicture",_row getOrDefault ["picture",""]];
            _x ctrlAddEventHandler ["MouseEnter",{["SHOW",_this#0] call ServoPeregrino_Organizador_Items_fnc_updateUIItemTooltip;}];
            _x ctrlAddEventHandler ["MouseExit",{["HIDE",_this#0] call ServoPeregrino_Organizador_Items_fnc_updateUIItemTooltip;}];
        } forEach [_pic,_name];
        _minus ctrlSetText "-"; _plus ctrlSetText "+"; _del ctrlSetText "X"; _qty ctrlSetText str (_row getOrDefault ["quantity",0]);
        _minus ctrlSetTooltip "Reduzir uma unidade"; _plus ctrlSetTooltip (if ((_row getOrDefault ["stateMode",""]) isEqualTo "EXACT") then {"EXACT permanece; + cria/incrementa DEFAULT_FULL separado"} else {"Adicionar uma unidade"}); _del ctrlSetTooltip "Remover esta linha do Rascunho"; _qty ctrlSetTooltip "Quantidade direta; 0 remove; EXACT não pode crescer por digitação";
        _minus ctrlAddEventHandler ["ButtonClick",{private _r=["MINUS",_this#0] call ServoPeregrino_Organizador_Items_fnc_handleDraftRowAction; [_r,"REMOVE",true] call ServoPeregrino_Organizador_Items_fnc_presentLogicalMutationResult; ["ROW_MINUS"] call ServoPeregrino_Organizador_Items_fnc_refreshDraftMutationUI;}];
        _plus ctrlAddEventHandler ["ButtonClick",{private _r=["PLUS",_this#0] call ServoPeregrino_Organizador_Items_fnc_handleDraftRowAction; [_r,"ADD",true] call ServoPeregrino_Organizador_Items_fnc_presentLogicalMutationResult; ["ROW_PLUS"] call ServoPeregrino_Organizador_Items_fnc_refreshDraftMutationUI;}];
        _del ctrlAddEventHandler ["ButtonClick",{private _r=["DELETE",_this#0] call ServoPeregrino_Organizador_Items_fnc_handleDraftRowAction; [_r,"REMOVE",true] call ServoPeregrino_Organizador_Items_fnc_presentLogicalMutationResult; ["ROW_DELETE"] call ServoPeregrino_Organizador_Items_fnc_refreshDraftMutationUI;}];
        _qty ctrlAddEventHandler ["KillFocus",{[_this#0] call ServoPeregrino_Organizador_Items_fnc_commitDraftQuantityFromControl;}];
        _qty ctrlAddEventHandler ["KeyDown",{_this call ServoPeregrino_Organizador_Items_fnc_handleDraftQuantityKeyDown}];
        _pic ctrlAddEventHandler ["MouseButtonDown",{["DRAFT_ROW_DRAG_START",_this] call ServoPeregrino_Organizador_Items_fnc_handleUIDragEvent;}];
        _name ctrlAddEventHandler ["MouseButtonDown",{["DRAFT_ROW_DRAG_START",_this] call ServoPeregrino_Organizador_Items_fnc_handleUIDragEvent;}];
        if (_key isEqualTo _selectedKey) then {_selectedIndex=_rowIndex;};
    };
} forEach (_draft getOrDefault ["rows",[]]);
if (_selectedIndex>=0) then {_draftCtrl ctSetCurSel _selectedIndex;};
if ((count _oldScroll)>=2) then {_draftCtrl ctrlSetScrollValues [_oldScroll#0,-1];};
(_display displayCtrl 2120) ctrlSetStructuredText parseText format ["<t color='#8FB7B0'>%1 · %2 linha(s) · peso %3%4</t><br/><t color='#8A9696'>- / qtd / + / X / LIMPAR = Kit/Rascunho lógico. APLICAR/REMOVER/SUBSTITUIR = físico.</t>",_draft getOrDefault ["mode","NONE"],count (_draft getOrDefault ["rows",[]]),[_draft getOrDefault ["totalMass",0],false,2] call ServoPeregrino_Organizador_Items_fnc_formatUIMass,if ((_draft getOrDefault ["unknownMassCount",0])>0) then {format [" + %1 peso(s) n/d",_draft getOrDefault ["unknownMassCount",0]]} else {""}];

// Catalog — superfície visível em CT_CONTROLS_TABLE com botões reais; ListBox 3120 fica legado/invisível.
private _catalog=_vm getOrDefault ["catalog",createHashMap];
private _catVisible=_display displayCtrl SERVO_PEREGRINO_ORGANIZADOR_ITEMS_UI_CATALOG_TABLE_IDC;
private _catalogWidthPx=if (pixelW>0 && {!isNull _catVisible}) then {((ctrlPosition _catVisible)#2)/pixelW} else {0};
private _responsiveLabels=[_catalogWidthPx] call ServoPeregrino_Organizador_Items_fnc_getResponsiveCatalogLabels;
{(_display displayCtrl (3110+_forEachIndex)) ctrlSetText _x;} forEach _responsiveLabels;
private _categoryLabel={params ["_id"]; switch (toUpper _id) do {case "MAGAZINES":{"Munição"}; case "GRENADES":{"Granada"}; case "EXPLOSIVES":{"Explosivo"}; case "TOOLS":{"Ferramenta"}; case "FOOD":{"Alimento"}; case "MEDICAL":{"Médico"}; default {"Outro"};};};
[_catalog getOrDefault ["rows",[]],_ui getOrDefault ["selectedCatalogClass",""],"FULL_REFRESH"] call ServoPeregrino_Organizador_Items_fnc_renderCatalogRowsUI;
private _total=_catalog getOrDefault ["totalFiltered",0]; private _offset=_catalog getOrDefault ["offset",0]; private _window=_catalog getOrDefault ["windowSize",SERVO_PEREGRINO_ORGANIZADOR_ITEMS_UI_CATALOG_WINDOW_SIZE]; private _last=(_offset+count (_catalog getOrDefault ["rows",[]])) min _total;
private _maxOffset=(_total-_window) max 0; private _scrollRatio=if (_maxOffset>0) then {(_offset/_maxOffset) max 0 min 1} else {0};
private _catalogPageText=if !(_catalog getOrDefault ["cacheBuilt",false]) then {if (_catalog getOrDefault ["buildInProgress",false]) then {private _root=_catalog getOrDefault ["buildCurrentRoot",""]; format ["Catalogando %1... %2 configs · %3 itens",if (_root isEqualTo "") then {"CONFIG_ALL"} else {_root},_catalog getOrDefault ["buildVisitedCount",0],_catalog getOrDefault ["buildPartialItemCount",0]]} else {"Preparando catálogo CONFIG_ALL..."}} else {if (_total isEqualTo 0) then {"Nenhum item encontrado"} else {if (_total isEqualTo 1) then {"Mostrando 1 item"} else {format ["Mostrando %1 a %2 de %3 itens",_offset+1,_last,_total]}}};
(_display displayCtrl 3122) ctrlSetText _catalogPageText;
private _catalogSlider=_display displayCtrl 3124; if (!isNull _catalogSlider) then {
    _catalogSlider sliderSetRange [0,(_maxOffset max 1)];
    _catalogSlider sliderSetSpeed [6,(_window max 12)];
    _catalogSlider sliderSetPosition _offset;
    _catalogSlider ctrlEnable (_maxOffset>0);
    _catalogSlider ctrlShow true;
};
private _scrollUp=_display displayCtrl 3121; if (!isNull _scrollUp) then {_scrollUp ctrlShow true; _scrollUp ctrlEnable (_offset>0);};
private _scrollDown=_display displayCtrl 3123; if (!isNull _scrollDown) then {_scrollDown ctrlShow true; _scrollDown ctrlEnable (_offset<_maxOffset);};
private _sel=_catalog getOrDefault ["selected",createHashMap];
private _details=if ((count _sel)>0) then {
    private _displayNameSafe=[_sel getOrDefault ["displayName",""]] call ServoPeregrino_Organizador_Items_fnc_escapeStructuredText;
    private _category=[_sel getOrDefault ["categoryId","OTHER"]] call _categoryLabel; private _categorySafe=[_category] call ServoPeregrino_Organizador_Items_fnc_escapeStructuredText;
    private _massValue=_sel getOrDefault ["massEstimate",0]; private _massLabel=if (_massValue>0) then {[_massValue,true,2] call ServoPeregrino_Organizador_Items_fnc_formatUIMass} else {"n/d"};
    private _magCapacity=_sel getOrDefault ["magazineCapacity",0]; private _capacityLine=if (_magCapacity>0) then {format [" · Capacidade: %1",_magCapacity]} else {""};
    format ["<t size='1.05' color='#CDE7E1'>%1</t><br/>%2 · Peso: %3%4<br/><t color='#8FB7B0'>Botão da esquerda: adicionar ao Kit Selecionado · Botão da direita: adicionar ao equipamento exibido em Mostrar</t>",_displayNameSafe,_categorySafe,_massLabel,_capacityLine]
} else {if (_catalog getOrDefault ["cacheBuilt",false]) then {"Selecione um item. Use o botão da esquerda para adicionar ao Kit Selecionado ou o botão da direita para adicionar ao equipamento exibido em Mostrar."} else {"A UI abriu antes do scan. O catálogo será preenchido quando o cache terminar."}};
(_display displayCtrl 3130) ctrlSetStructuredText parseText _details; [3100,_ui getOrDefault ["catalogQuery",""]] call _setEditIfDifferent;
_ui set ["catalogOffset",_offset]; _ui set ["catalogTotalFiltered",_total]; _ui set ["catalogMaxOffset",_maxOffset]; _ui set ["catalogScrollRatio",_scrollRatio];
missionNamespace setVariable [SERVO_PEREGRINO_ORGANIZADOR_ITEMS_UI_STATE_VAR,_ui];

// Equipment capture/read path: CT_CONTROLS_TABLE visual com o mesmo executor físico homologado.
private _eq=_vm getOrDefault ["equipment",createHashMap];
[_eq getOrDefault ["rows",[]],_ui getOrDefault ["equipmentView","U"],_eq getOrDefault ["capacity",createHashMap],_eq getOrDefault ["totalMass",0],_eq getOrDefault ["unknownMassCount",0],_eq getOrDefault ["status","SEM DADOS"],"FULL_REFRESH"] call ServoPeregrino_Organizador_Items_fnc_renderEquipmentRowsUI;
[4100,_ui getOrDefault ["equipmentQuery",""]] call _setEditIfDifferent;

// Physical UI readiness — drop físico bloqueia quando necessário; botões continuam clicáveis para explicar bloqueios.
private _physical = _vm getOrDefault ["physical",createHashMap];
private _physicalEnabled = _vm getOrDefault ["physicalCommandEnabled",false];
private _physicalTarget = _physical getOrDefault ["resolvedTarget","-"];
private _physicalCapacity=_physical getOrDefault ["capacity",createHashMap];
private _equipmentPhysical=_vm getOrDefault ["equipmentPhysical",createHashMap];
private _equipmentPhysicalEnabled=_vm getOrDefault ["equipmentViewCommandEnabled",false];
private _equipmentPhysicalTarget=_equipmentPhysical getOrDefault ["resolvedTarget",_ui getOrDefault ["equipmentView","U"]];
private _physicalDrop = _display displayCtrl 4113;
_physicalDrop ctrlEnable _equipmentPhysicalEnabled;
private _equipmentPhysicalTargetLabel=[_equipmentPhysicalTarget] call ServoPeregrino_Organizador_Items_fnc_getUITargetLabel;
_physicalDrop ctrlSetText (if (_equipmentPhysicalEnabled) then {format ["ARRASTE ITENS PARA ADICIONAR A %1",_equipmentPhysicalTargetLabel]} else {"NÃO É POSSÍVEL ADICIONAR ITENS AQUI"});
_physicalDrop ctrlSetTooltip format ["Itens soltos neste painel são adicionados a %1, que é o equipamento selecionado em Mostrar.",_equipmentPhysicalTargetLabel];
_physicalDrop ctrlSetBackgroundColor (if (_equipmentPhysicalEnabled) then {[0.24,0.13,0.03,0.42]} else {[0.10,0.08,0.07,0.25]});
_physicalDrop ctrlSetTextColor (if (_equipmentPhysicalEnabled) then {[1,0.84,0.55,1]} else {[0.58,0.58,0.56,0.85]});
{(_display displayCtrl _x) ctrlEnable true;} forEach [2150,2151,2152,2153,4124];
(_display displayCtrl 2153) ctrlSetTooltip "Limpar somente o Kit Selecionado/Rascunho. Não altera o equipamento físico.";
(_display displayCtrl 4124) ctrlSetTooltip format ["Remover os itens gerenciáveis do equipamento mostrado (%1). Armas e conteúdos reservados serão preservados.",[_ui getOrDefault ["equipmentView","U"]] call ServoPeregrino_Organizador_Items_fnc_getUITargetLabel];
(_display displayCtrl 4123) ctrlEnable ((_eq getOrDefault ["status",""]) isEqualTo "OK");
[_display,_physicalEnabled,_physicalTarget,_ui getOrDefault ["equipmentView","U"],_physicalCapacity] call ServoPeregrino_Organizador_Items_fnc_refreshHeaderStatusUI;

// highlights: application target != draft preferred target != equipment view.
{private _ctrl=_display displayCtrl (_x#0); _ctrl ctrlSetBackgroundColor (if ((_x#1) isEqualTo (_ui getOrDefault ["applicationTarget","ANY"])) then {[0.08,0.38,0.30,0.76]} else {[0.08,0.11,0.12,0.58]});} forEach [[2110,"ANY"],[2111,"U"],[2112,"C"],[2113,"M"]];
private _pref=toUpper (_draft getOrDefault ["preferredTarget","ANY"]); if (_pref isEqualTo "UNIFORM") then {_pref="U"}; if (_pref isEqualTo "VEST") then {_pref="C"}; if (_pref isEqualTo "BACKPACK") then {_pref="M"};
{private _ctrl=_display displayCtrl (_x#0); _ctrl ctrlSetBackgroundColor (if ((_x#1) isEqualTo _pref) then {[0.28,0.28,0.10,0.72]} else {[0.08,0.11,0.12,0.58]}); _ctrl ctrlEnable _hasDraft;} forEach [[2130,"ANY"],[2131,"U"],[2132,"C"],[2133,"M"]];
{private _ctrl=_display displayCtrl (_x#0); _ctrl ctrlSetBackgroundColor (if ((_x#1) isEqualTo (_ui getOrDefault ["equipmentView","U"])) then {[0.08,0.38,0.30,0.76]} else {[0.08,0.11,0.12,0.58]});} forEach [[4110,"U"],[4111,"C"],[4112,"M"]];
private _catMap=[[3110,"ALL"],[3111,"MAGAZINES"],[3112,"GRENADES"],[3113,"EXPLOSIVES"],[3114,"TOOLS"],[3115,"FOOD"],[3116,"MEDICAL"],[3117,"OTHER"]]; {private _ctrl=_display displayCtrl (_x#0); _ctrl ctrlSetBackgroundColor (if ((_x#1) isEqualTo (_ui getOrDefault ["catalogCategory","ALL"])) then {[0.08,0.38,0.30,0.76]} else {[0.08,0.11,0.12,0.58]});} forEach _catMap;
{(_display displayCtrl _x) ctrlEnable _hasDraft;} forEach [2140,2141,2142];

private _contextSafe=[_vm getOrDefault ["context",""]] call ServoPeregrino_Organizador_Items_fnc_escapeStructuredText;
private _messageSafe=[_vm getOrDefault ["message",""]] call ServoPeregrino_Organizador_Items_fnc_escapeStructuredText;
private _feedbackPalette=[_ui getOrDefault ["lastFeedbackKind","INFO"]] call ServoPeregrino_Organizador_Items_fnc_getUIFeedbackPalette;
(_display displayCtrl 5000) ctrlSetStructuredText parseText format ["<t color='#6FCBB8'>CONTEXTO</t><t color='#A8C9C2'>  •  %1</t>",_contextSafe];
(_display displayCtrl 5001) ctrlSetStructuredText parseText format ["<t color='%1'>RESULTADO</t><t color='%2'>  •  %3</t>",_feedbackPalette getOrDefault ["labelColor","#7EC8FF"],_feedbackPalette getOrDefault ["messageColor","#D7EEFF"],_messageSafe];
private _hist=_vm getOrDefault ["history",[]]; private _histText=""; {private _entry=_x; _histText=_histText + (if (_histText isEqualTo "") then {""} else {"  |  "}) + format ["%1: %2",_entry#0,_entry#1];} forEach (_hist select [((count _hist)-3) max 0,(3 min (count _hist))]);
private _histSafe=[_histText] call ServoPeregrino_Organizador_Items_fnc_escapeStructuredText;
(_display displayCtrl 5002) ctrlSetStructuredText parseText format ["<t color='#81918E'>HISTÓRICO  •  %1</t>",_histSafe];
[player] call ServoPeregrino_Organizador_Items_fnc_refreshHeaderUI;
private _totalDurationMs=round ((diag_tickTime-_refreshStartedAt)*1000);
private _renderDurationMs=(_totalDurationMs-_vmDurationMs) max 0;
private _state=missionNamespace getVariable [SERVO_PEREGRINO_ORGANIZADOR_ITEMS_UI_STATE_VAR,createHashMap];
_state set ["physicalMutationEnabled",false];
_state set ["physicalCommandEnabled",_physicalEnabled];
_state set ["resolvedPhysicalTarget",_physicalTarget];
_state set ["equipmentViewCommandEnabled",_equipmentPhysicalEnabled];
_state set ["resolvedEquipmentViewTarget",_equipmentPhysicalTarget];
_state set ["lastDraftTotalMass",_draft getOrDefault ["totalMass",0]];
_state set ["lastDraftUnknownMassCount",_draft getOrDefault ["unknownMassCount",0]];
_state set ["lastEquipmentContentMass",_eq getOrDefault ["totalMass",0]];
_state set ["lastEquipmentUnknownMassCount",_eq getOrDefault ["unknownMassCount",0]];
_state set ["lastEquipmentCapacity",_eq getOrDefault ["capacity",createHashMap]];
_state set ["lastPhysicalCapacity",_physical getOrDefault ["capacity",createHashMap]];
_state set ["lastRefreshTick",diag_tickTime];
_state set ["lastRefreshMode","FULL"];
_state set ["fullRefreshCount",(_state getOrDefault ["fullRefreshCount",0])+1];
_state set ["lastFullRefreshDurationMs",_totalDurationMs];
private _perf=+(_state getOrDefault ["uiPerfHistory",[]]);
_perf pushBack ["FULL","FULL_REFRESH",_totalDurationMs,count (_draft getOrDefault ["rows",[]]),diag_tickTime];
while {(count _perf)>24} do {_perf deleteAt 0;};
_state set ["uiPerfHistory",_perf];
_state set ["refreshing",false];
missionNamespace setVariable [SERVO_PEREGRINO_ORGANIZADOR_ITEMS_UI_STATE_VAR,_state];
if (_state getOrDefault ["uiPerfTracing",true]) then {
    diag_log format ["[SP_ORG] [ITEMS] [UI_PERF] mode=FULL totalMs=%1 vmMs=%2 renderMs=%3 kits=%4 draftRows=%5 catalogWindowRows=%6 catalogBase=%7 equipmentRows=%8",_totalDurationMs,_vmDurationMs,_renderDurationMs,count (_vm getOrDefault ["kits",[]]),count (_draft getOrDefault ["rows",[]]),count (_catalog getOrDefault ["rows",[]]),_catalog getOrDefault ["baseCount",0],count (_eq getOrDefault ["rows",[]])];
};
true
