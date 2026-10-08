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
check('D2 frozen dialog geometry and IDC map preserved',geometry(oldlayout)==geometry(layout))
# Healthy-path count is derived from actual call sites and scenario rows; missing checks become BLOCKED.
d2=(W/'functions/tests/fn_runDelivery0_7_D2Tests.sqf').read_text()
scenario_body=d2.split('} forEach [',1)[1].split('];',1)[0]
scenarios=len(re.findall(r'^ \["',scenario_body,re.M))
run_body=d2.split('private _run={',1)[1].split('private _mx=',1)[0]
ui_body=d2.split('private _uiTests={',1)[1].split('private _start=count _checks;',1)[0]
per_run=len(re.findall(r'call _assert;',run_body));per_ui=len(re.findall(r'call _assert;',ui_body))
top=len(re.findall(r'call _assert;',d2))-per_run-per_ui
expected=1109+scenarios*per_run+per_ui+top
check('D2 deterministic 1348 checks from 18x12 + 12 UI + 11 top-level',scenarios==18 and per_run==12 and per_ui==12 and top==11 and expected==1348 and '["expected",1348]' in d2)
for name in ['fn_rollbackApplicationSnapshot.sqf','fn_validateApplicationRollback.sqf','fn_validateAppliedApplicationState.sqf']:
 rel=str((W/'functions/application'/name).relative_to(R))
 original=subprocess.check_output(['git','show','8c177c4a05b4018231bd0c11538bcfa2cc81f53a:'+rel],cwd=R,text=True)
 check('D2 preserves C validation '+name,original==(W/'functions/application'/name).read_text())
check('D2 legacy R6 catalog harness cannot physically equip player','_rightStateE set ["selectedCatalogClass",""]' in (W/'functions/tests/fn_runDelivery0_6_FR6Tests.sqf').read_text())
check('D2 mission config structural delimiters',balanced(config))

print(f'STATIC SUMMARY {checks-len(failures)}/{checks}; runtime remains pending')
raise SystemExit(bool(failures))
