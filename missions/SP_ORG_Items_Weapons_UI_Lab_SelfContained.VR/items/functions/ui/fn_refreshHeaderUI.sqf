#include "..\..\script_version.hpp"
disableSerialization;
params [["_unit",player,[objNull]]];
private _display=uiNamespace getVariable [SERVO_PEREGRINO_ORGANIZADOR_ITEMS_UI_DISPLAY_VAR,displayNull];
if (isNull _display || {isNull _unit}) exitWith {false};

private _operator=name _unit;
if (_operator isEqualTo "") then {_operator=profileName;};
private _unitName=groupId (group _unit);
if (_unitName isEqualTo "") then {_unitName=str (group _unit);};

private _current=(loadAbs _unit) max 0;
private _engineRatio=(load _unit) max 0;
private _maxLoad=(getNumber (configFile >> "CfgInventoryGlobalVariable" >> "maxSoldierLoad")) max 0;

// D.7.4 — semântica de carga do jogador:
// loadAbs do UNIT inclui armas, itens vinculados e o conteúdo de todos os containers do soldado.
// maxSoldierLoad é o limite GLOBAL do inventário/stamina, não a soma de maximumLoad de U/C/M.
// Alguns comandos de script/mods podem ultrapassar esse limite; por isso preservamos o ratio bruto para diagnóstico
// e limitamos somente a largura visual da barra. A capacidade de cada U/C/M continua em fn_getContainerCapacityMetrics.
private _rawFraction=if (_maxLoad>0) then {(_current/_maxLoad) max 0} else {_engineRatio};
private _visualFraction=(_rawFraction min 1) max 0;
private _rawPercent=round (_rawFraction*100);
private _overloaded=(_rawFraction>1.0005);
private _excessLoad=if (_maxLoad>0) then {(_current-_maxLoad) max 0} else {0};

(_display displayCtrl 103) ctrlSetText format ["Operador: %1",_operator];
(_display displayCtrl 108) ctrlSetText format ["Unidade: %1",_unitName];
private _currentKg=(_current/22.0462262185) toFixed 2;
private _maxKg=(_maxLoad/22.0462262185) toFixed 2;
private _currentPlayerMass=[_current,false,2] call ServoPeregrino_Organizador_Items_fnc_formatUIMass;
private _maxPlayerMass=[_maxLoad,false,2] call ServoPeregrino_Organizador_Items_fnc_formatUIMass;
private _excessPlayerMass=[_excessLoad,false,2] call ServoPeregrino_Organizador_Items_fnc_formatUIMass;
private _loadText=if (_maxLoad>0) then {
    if (_overloaded) then {
        format ["Carga: %1 / %2 kg - 100%%+ · SOBRECARGA",_currentKg,_maxKg]
    } else {
        format ["Carga: %1 / %2 kg - %3%%",_currentKg,_maxKg,_rawPercent]
    }
} else {
    format ["Carga: %1 kg - %2%%",_currentKg,_rawPercent]
};
(_display displayCtrl 104) ctrlSetText _loadText;
private _bg=_display displayCtrl 105;
private _fill=_display displayCtrl 106;
private _p=ctrlPosition _bg;
_fill ctrlSetPosition [_p#0,_p#1,(_p#2)*_visualFraction,_p#3];
_fill ctrlCommit 0;
private _scopeText="Inclui armas, itens vinculados e conteúdo de Uniforme/Colete/Mochila.";
private _loadTip=if (_maxLoad>0) then {
    if (_overloaded) then {
        format ["Carga total do jogador: %1. Limite global configurado: %2. Excesso: %3 (%4%% do limite). %5 O Arma pode exceder o limite quando scripts/mods inserem carga diretamente.",_currentPlayerMass,_maxPlayerMass,_excessPlayerMass,_rawPercent,_scopeText]
    } else {
        format ["Carga total do jogador: %1 de %2 (%3%%). %4",_currentPlayerMass,_maxPlayerMass,_rawPercent,_scopeText]
    }
} else {
    format ["Carga total atual: %1 (%2%%). Limite global não disponível. %3",_currentPlayerMass,_rawPercent,_scopeText]
};
(_display displayCtrl 104) ctrlSetTooltip _loadTip;
_bg ctrlSetTooltip _loadTip;
_fill ctrlSetTooltip _loadTip;
true
