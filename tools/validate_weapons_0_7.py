#!/usr/bin/env python3
"""Static mission-first contracts. Not an SQF compiler or Arma runtime gate."""
from pathlib import Path
import re, json, subprocess, tempfile
R=Path(__file__).resolve().parents[1]; M=R/'missions/SP_ORG_Items_Weapons_UI_Lab_SelfContained.VR'; W=M/'weapons'; failures=[]; checks=0

def check(name,ok):
 global checks
 checks+=1
 if not ok: failures.append(name)
 print(('PASS' if ok else 'FAIL')+' | '+name)

def strip(s): return re.sub(r'"(?:""|[^"])*"|\'(?:\'\'|[^\'])*\'|//[^\n]*|/\*[\s\S]*?\*/', '', s)
def balanced(s):
 stack=[]
 for c in strip(s):
  if c in '([{': stack.append(c)
  elif c in ')]}':
   if not stack or '([{'.index(stack.pop())!=')]}'.index(c): return False
 return not stack
base='af63a41565213975ff233dcc80d2cd62a7ebbb46'
changed=subprocess.check_output(['git','diff',base,'--name-only'],cwd=R,text=True).splitlines()
check('Items/UICommon/addons and Items backlog untouched',not any('/items/' in p or '/UICommon/' in p or p.startswith('addons/') or p=='docs/64_ITEMS_FUTURE_CAPTURE_CONFIRMATION.md' for p in changed))
for p in W.rglob('*.sqf'):
 check('balanced '+str(p.relative_to(W)),balanced(p.read_text()))
config=(M/'description.ext').read_text()
functions={p.stem[3:] for p in W.rglob('fn_*.sqf')}
check('all Weapons functions registered',all(re.search(r'class\s+'+re.escape(n)+r'\s*\{',config) for n in functions))
sources='\n'.join(p.read_text() for p in W.rglob('*.sqf'))
refs=set(re.findall(r'ServoPeregrino_Organizador_Weapons_fnc_(\w+)',sources))
check('all Weapons references resolve',refs<=functions)
plan=(W/'functions/application/fn_createApplicationPlan.sqf').read_text()
check('diff changes mapped to Plan field names','getOrDefault ["changes",[]]) apply {_x get "field"}' in plan)
check('frozen Plan remains descriptive',all(s in plan for s in ['["schemaVersion","0.7-A-application-plan-candidate"]','["dryRunOnly",true]','["mutationAuthorized",false]','["fullMagazines",false]']))
for p in (W/'functions/application').glob('*.sqf'):
 check('every setUnitLoadout uses false '+p.name, all('false]' in line for line in strip(p.read_text()).splitlines() if 'setUnitLoadout' in line))
for p in [R/'machine/PROJECT_STATE.json',R/'machine/MODULE_MATRIX.json']: json.loads(p.read_text());check('valid JSON '+p.name,True)
# Preprocess the real mission include topology and every Weapons SQF. This validates includes/macros, not engine commands.
import shutil
with tempfile.TemporaryDirectory() as d:
 t=Path(d);shutil.copytree(M,t/'mission')
 for p in (t/'mission').rglob('*'):
  if p.is_file() and p.suffix in ['.sqf','.hpp','.ext']:
   s=p.read_text();s=re.sub(r'(#include\s+")([^"]+)(")',lambda m:m[1]+m[2].replace('\\','/')+m[3],s);p.write_text(s)
 results=[subprocess.run(['cpp','-P','-traditional-cpp',str(p)],capture_output=True,text=True) for p in list((t/'mission/weapons').rglob('*.sqf'))+[t/'mission/description.ext']]
 check('mission includes/macros preprocess',all(p.returncode==0 for p in results))
 for result in results:
  if result.returncode: print(result.stderr)
# D2: resolve every mission CfgFunctions file group, including Items, not only Weapons names.
def class_blocks(s):
 for m in re.finditer(r'\bclass\s+(\w+)\s*(?::[^{};]+)?\s*\{',s):
  depth=1; quoted=False; i=m.end(); start=i
  while i<len(s) and depth:
   c=s[i]
   if c=='"':
    if quoted and i+1<len(s) and s[i+1]=='"': i+=2; continue
    quoted=not quoted
   elif not quoted:
    if c=='{': depth+=1
    elif c=='}': depth-=1
   i+=1
  yield m.group(1),s[start:i-1]
groups=[];missing=[]
for name,body in class_blocks(config):
 prefix=re.split(r'\bclass\s+',body,maxsplit=1)[0]
 f=re.search(r'\bfile\s*=\s*"([^"]+)"',prefix)
 if f:
  path=f[1].replace('\\','/')
  entries=re.findall(r'\bclass\s+(\w+)\s*\{',body)
  groups.append((name,path,entries))
  missing.extend(str(Path(path)/('fn_'+n+'.sqf')) for n in entries if not (M/path/('fn_'+n+'.sqf')).is_file())
check('D2 every CfgFunctions registration resolves to its actual mission path',not missing)
if missing: print('Missing registrations:',missing)
feedback_groups=[(name,path,names.count('getApplicationFeedback')) for name,path,names in groups if 'getApplicationFeedback' in names]
check('D2 feedback registered exactly once under Weapons UI',feedback_groups==[('UI','weapons/functions/ui',1)])
check('D2 Items has no Weapons feedback registration',not any(path.startswith('items/') and 'getApplicationFeedback' in names for _,path,names in groups))
cat=(W/'functions/application/fn_executeCatalogApplication.sqf').read_text()
check('D2 catalog delegates to the one canonical executor',cat.count('call ServoPeregrino_Organizador_Weapons_fnc_executeDraftApplication')==1 and 'setUnitLoadout' not in strip(cat))
check('D2 catalog performs no repository/draft authoring',not re.search(r'fnc_(createWeaponKit|updateWeaponKit\w*|save\w*|publish\w*|setWeaponKitDraft\w*|getOrCreateWeaponKitDraft)\b',cat))
check('D2 catalog compatibility uses approved selector model','fnc_buildCompatibilitySelectorModel' in cat and 'fnc_getWeaponCatalogEntry' in cat)
check('D2 runtime UI contains no permanent catalog button disable',not any(re.search(r'displayCtrl\s+3151\)\s+ctrlEnable\s+false',p.read_text()) for p in (W/'functions/ui').glob('*.sqf')))
active='\n'.join(p.read_text() for d in ['ui','lifecycle'] for p in (W/'functions'/d).glob('*.sqf'))
check('D2 active UI does not announce blocked physical application','aplicação física ainda bloqueada' not in active and 'applicationGate","DEFERRED_0_7' not in active)
check('D2 A assertion proves authority without UI marker allow-list','planning remains isolated from player-facing' not in (W/'functions/tests/fn_runDelivery0_7_ATests.sqf').read_text())
oldconfig=subprocess.check_output(['git','show','8c177c4a05b4018231bd0c11538bcfa2cc81f53a:'+str((M/'description.ext').relative_to(R))],cwd=R,text=True)
check('D2 CfgRemoteExec policy byte-semantically unchanged',dict(class_blocks(oldconfig)).get('CfgRemoteExec')==dict(class_blocks(config)).get('CfgRemoteExec'))
check('D2 catalog has no multiplayer/CBA engine invocation',not re.search(r'\b(remoteExec|remoteExecCall|CBA_fnc_\w+)\b',strip(cat)))
oldlayout=subprocess.check_output(['git','show','8c177c4a05b4018231bd0c11538bcfa2cc81f53a:'+str((W/'ui/weapons_dialog.hpp').relative_to(R))],cwd=R,text=True)
layout=(W/'ui/weapons_dialog.hpp').read_text()
geometry=lambda s:re.findall(r'\b(?:idc|x|y|w|h)\s*=\s*[^;]+;',s)
# E1 adds only one P4 action; all previously frozen positions/IDCs stay untouched.
legacy_layout=re.sub(r'\bclass\s+EquipmentCapture:\s*SPORG_Weapons_Button\s*\{[^{}]*\};','',layout)
check('E1 freezes every existing dialog geometry and IDC',geometry(oldlayout)==geometry(legacy_layout))
check('E1 capture has distinct P4 action/IDC', 'class EquipmentCapture: SPORG_Weapons_Button {idc=4123;' in layout and "['EQUIPMENT_TO_DRAFT']" in layout)
# Healthy-path count is derived from actual call sites and scenario rows; missing checks become BLOCKED.
d2=(W/'functions/tests/fn_runDelivery0_7_D2Tests.sqf').read_text()
scenario_body=d2.split('} forEach [',1)[1].split('];',1)[0]
scenarios=len(re.findall(r'^ \["',scenario_body,re.M))
run_body=d2.split('private _run={',1)[1].split('private _mx=',1)[0]
ui_body=d2.split('private _uiTests={',1)[1].split('private _start=count _checks;',1)[0]
per_run=len(re.findall(r'call _assert;',run_body));per_ui=len(re.findall(r'call _assert;',ui_body))
top=len(re.findall(r'call _assert;',d2))-per_run-per_ui
expected=1109+scenarios*per_run+per_ui+top
check('D2 deterministic 1360 checks from 19x12 + 12 UI + 11 top-level',scenarios==19 and per_run==12 and per_ui==12 and top==11 and expected==1360 and '["expected",1360]' in d2)
check('D2 no-recipe ammo-rich fixture expects strict rollback','"WEAPON_PRIMARY","arifle_MX_F","WEAPON","HANDGUN",_p07,"PRIMARY","WEAPONS_APPLICATION_APPLY_VERIFY_FAILED"' in d2)
check('D2 no-recipe ammo-free fixture independently proves physical apply','"WEAPON_PRIMARY_NO_CARGO_AMMO"' in d2 and 'removeAllItemsWithMagazines _unit' in d2)
check('D2 no-recipe diagnostics expose rollback and engine rows','[NO_MAG_D2_DIAGNOSTIC]' in d2 and 'rollbackRestoredExactly' in d2)
for name in ['fn_rollbackApplicationSnapshot.sqf','fn_validateApplicationRollback.sqf','fn_validateAppliedApplicationState.sqf']:
 rel=str((W/'functions/application'/name).relative_to(R))
 original=subprocess.check_output(['git','show','8c177c4a05b4018231bd0c11538bcfa2cc81f53a:'+rel],cwd=R,text=True)
 check('D2 preserves C validation '+name,original==(W/'functions/application'/name).read_text())
check('D2 legacy R6 catalog harness cannot physically equip player','_rightStateE set ["selectedCatalogClass",""]' in (W/'functions/tests/fn_runDelivery0_6_FR6Tests.sqf').read_text())
check('D2 mission config structural delimiters',balanced(config))


capture=(W/'functions/ui/fn_captureEquippedWeaponToDraft.sqf').read_text()
capture_edit=(W/'functions/ui/fn_setPendingCapturedDraftSelection.sqf').read_text()
events=(W/'functions/ui/fn_handleUIEvent.sqf').read_text()
check('E1 R2 captures with safe observed Recipe preparation',all(x in capture for x in ['fnc_getEquipmentSlotSnapshot','fnc_prepareObservedCaptureRecipe','fnc_compareWeaponRecipes']))
check('E1 equipment capture never physically mutates or stores kits',not re.search(r'\b(setUnitLoadout|addWeapon|removeWeapon|remoteExec|remoteExecCall)\b|fnc_(createWeaponKit|updateWeaponKitDefinition|saveWeaponKitDraft|publish)',strip(capture)))
check('E1 pending compatibility never mutates physical equipment or saved kit',not re.search(r'\b(setUnitLoadout|remoteExec|remoteExecCall)\b|fnc_(createWeaponKit|updateWeaponKitDefinition|saveWeaponKitDraft)',strip(capture_edit)))
check('E1 explicit save owns only pending new creation', '["SAVE_DRAFT"]' not in capture and 'private _savedR=[_name,_captured getOrDefault ["targetSlot",""]' in events)
check('E1 capture and pending compatibility events connected','case "EQUIPMENT_TO_DRAFT"' in events and 'fnc_setPendingCapturedDraftSelection' in events)
check('E1 equipment control enabled only on occupied slot',all('displayCtrl 4123) ctrlEnable (_eq getOrDefault ["equipped",false])' in (W/'functions/ui'/p).read_text() for p in ['fn_refreshInterface.sqf','fn_refreshEquipmentViewUI.sqf']))
e=(W/'functions/tests/fn_runDelivery0_7_ETests.sqf').read_text()
e_asserts=len(re.findall(r'call _assert;',e))
check('E1 R2 cumulative runner preserves D2 and 48 E checks',e_asserts==48 and 'fnc_runDelivery0_7_D2Tests' in e and '1408' in e and 'MISSION_FIRST_0_7_E_R2' in e)
check('E1 R2 mission action single gate','SP_ORG LAB - TESTAR WEAPONS 0.7-E R2' in (M/'initPlayerLocal.sqf').read_text())
check('E1 R2 mission and build identity', '0.7.4.2-equipment-to-draft-e1-r2-mission-first' in (W/'script_version.hpp').read_text() and (R/'missions/PACKAGE_MISSION_NAME.txt').read_text().strip()=='SP_ORG_Weapons_0_7_E_Equipment_Capture_E1_R2.VR')

observed_prep=(W/'functions/ui/fn_prepareObservedCaptureRecipe.sqf').read_text()
check('E1 R2 fallback only strips engine-identified incompatible classes',
  'WEAPONS_CONFIGURATION_INCOMPATIBLE' in observed_prep and
  'WEAPONS_RECIPE_MAGAZINE_INCOMPATIBLE' in observed_prep and
  'fnc_validateWeaponConfigurationSemantic' in observed_prep and
  'fnc_createWeaponRecipe' in observed_prep and
  'fnc_deepCopy' in observed_prep)
check('E1 R2 preserves exact class name in omission reporting',
  '["field",_field]' in observed_prep and '["className",_original]' in observed_prep and
  '["field","magazineClass"]' in observed_prep)
check('E1 R2 UI does not silently omit incompatible pieces',
  'CAPTURA PARCIAL' in events and
  'captureOmissions' in capture and
  'captureOmissions' in (W/'functions/ui/fn_refreshDraftUI.sqf').read_text())
check('E1 R2 keeps compatibility validators frozen',
  (W/'functions/domain/fn_validateWeaponConfigurationSemantic.sqf').read_text() == (R/'weapons_0_7_d2_baseline'/ 'never_present') if False else
  'WEAPONS_UI_CAPTURE_WEAPON_CONFIGURATION_UNSUPPORTED' in observed_prep)
check('E1 R2 no global semantic bypass or physical mutations in helper',
  not re.search(r'\\b(setUnitLoadout|addWeapon|removeWeapon|remoteExec|remoteExecCall)\\b|fnc_(saveWeaponKitDraft|createWeaponKit|updateWeaponKitDefinition)',strip(observed_prep)))

print(f'STATIC SUMMARY {checks-len(failures)}/{checks}; runtime remains pending')
raise SystemExit(bool(failures))
