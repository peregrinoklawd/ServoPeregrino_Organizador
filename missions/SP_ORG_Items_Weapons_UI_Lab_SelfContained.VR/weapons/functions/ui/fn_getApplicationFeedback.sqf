params [["_result",createHashMap,[createHashMap]]];
private _code = _result getOrDefault ["code",""];
private _message = "Não foi possível equipar este rascunho. Revise a arma, os acessórios e o carregador e tente novamente.";
private _kind = "ERROR";
if (_result getOrDefault ["success",false]) then {
 _kind = "SUCCESS";
 _message = if (_code isEqualTo "WEAPONS_APPLICATION_ALREADY_APPLIED") then {"O equipamento já corresponde ao rascunho. Nada foi alterado."} else {"Rascunho equipado. Suas alterações continuam no rascunho; use SALVAR para atualizar o kit."};
} else {
 if (_code isEqualTo "WEAPONS_APPLICATION_DRAFT_INVALID") then {_message="Escolha uma arma para o rascunho antes de equipar."};
 if (_code isEqualTo "WEAPONS_APPLICATION_APPLY_STALE_SNAPSHOT") then {_message="Seu equipamento mudou durante a operação. Nenhuma alteração foi aplicada; tente novamente."};
 if (_code isEqualTo "WEAPONS_APPLICATION_APPLY_VERIFY_FAILED") then {_message="Não foi possível concluir a aplicação. Seu equipamento anterior foi restaurado; o rascunho continua intacto."};
 if (_code isEqualTo "WEAPONS_APPLICATION_ROLLBACK_FAILED") then {_message="A aplicação falhou e não foi possível confirmar a restauração completa. Confira seu equipamento antes de continuar. O rascunho continua intacto."};
 if ((toUpperANSI _code) find "INCOMPATIBLE" >= 0 || {(toUpperANSI _code) find "SEMANTIC" >= 0}) then {_message="A configuração do rascunho não é compatível com esta arma. Revise acessórios e carregador."};
};
if (((_result getOrDefault ["data",createHashMap]) getOrDefault ["sourceKind",""]) isEqualTo "CATALOG_SELECTION") then {
 if (_result getOrDefault ["success",false]) then {
  _message=if (_code isEqualTo "WEAPONS_APPLICATION_ALREADY_APPLIED") then {"O item já está equipado. Nada foi alterado."} else {"Item equipado diretamente. O rascunho e o kit salvo continuam intactos."};
 } else {
  if (_code in ["WEAPONS_UI_CATALOG_SELECTION_REQUIRED","WEAPONS_UI_CATALOG_EMPTY_DESTINATION","WEAPONS_UI_CATALOG_KIND_UNSUPPORTED","WEAPONS_UI_CATALOG_SELECTION_INCOMPATIBLE","WEAPONS_UI_CATALOG_DESTINATION_INVALID"]) then {_message=_result getOrDefault ["message",_message]};
  if (_code find "INCOMPATIBLE" >= 0) then {_message="Esse item não é compatível com a arma física visualizada."};
 };
};
createHashMapFromArray [["message",_message],["kind",_kind],["code",_code]]
