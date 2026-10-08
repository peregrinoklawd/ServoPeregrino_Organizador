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
print(f'STATIC SUMMARY {checks-len(failures)}/{checks}; runtime remains pending')
raise SystemExit(bool(failures))
