#!/usr/bin/env python3
"""Static checks only. Does not execute SQF, load PBOs or close an Arma gate."""
import csv
import json
from pathlib import Path
import re
import subprocess
import tempfile

ROOT = Path(__file__).resolve().parents[1]
ADDON = ROOT / 'addons/ServoPeregrino_Organizador_Weapons'
LAB = ROOT / 'missions/SP_ORG_Weapons_0_1_A_Identity_Lab_4Slots.VR'
BASE = 'fad4186ef878e00bdd4de3656e94bd1327fe08a2'
PREFIX = 'ServoPeregrino_Organizador_Weapons_fnc_'
checks = []

def check(name, value):
    checks.append((name, bool(value)))
    print(('PASS' if value else 'FAIL') + ' | ' + name)

def strip_literals_comments(source):
    # SQF/config strings escape quotes by doubling them; no backslash escapes.
    pattern = r'"(?:""|[^"])*"|\'(?:\'\'|[^\'])*\'|//[^\n]*|/\*[\s\S]*?\*/'
    return re.sub(pattern, lambda m: ' ' * len(m[0]), source)

def balanced(source):
    stack = []
    for c in strip_literals_comments(source):
        if c in '([{': stack.append(c)
        elif c in ')]}':
            if not stack or '([{'.index(stack.pop()) != ')]}'.index(c): return False
    return not stack

files = sorted(ADDON.rglob('*.sqf'))
config = (ADDON / 'config.cpp').read_text()
functions = {PREFIX + p.stem[3:]: p for p in files}
registered = set(re.findall(r'class\s+(\w+)\s*\{\s*(?:preInit=1; postInit=1;)?\s*\};', config))
check('CfgFunctions exact coverage', registered == {p.stem[3:] for p in files})
check('PBO prefix matches absolute paths', (ADDON/'$PBOPREFIX$').read_text().strip() == 'ServoPeregrino_Organizador_Weapons')
check('requiredAddons only A3 and Nexus', re.search(r'requiredAddons\[\]\s*=\s*\{"A3_Functions_F","ServoPeregrino_Organizador_Nexus"\}', config))
all_sources = '\n'.join(p.read_text() for p in files)
check('no dependency on another domain private state/functions', not re.search(r'ServoPeregrino_Organizador_(?:Items|Armorer|WeaponCondition|Hub|Equipment|Sets)_', all_sources))
check('only weapons.runtime is registered', len(re.findall(r'call ServoPeregrino_Organizador_Nexus_fnc_registerCapability', all_sources)) == 1 and '["weapons.runtime",1,' in all_sources)
check('no stable domain contract publication', 'call ServoPeregrino_Organizador_Nexus_fnc_registerContractDefinition' not in all_sources)
check('no inventory mutation in product domain', not re.search(r'\b(?:setUnitLoadout|removeWeapon|addWeapon|addWeaponCargoGlobal|clearWeaponCargoGlobal)\b', all_sources))
check('no continuous domain polling or DB persistence', not re.search(r'\b(?:onEachFrame|while|saveProfileNamespace|callExtension)\b', strip_literals_comments(all_sources)))
known = set(functions)
for addon in ['Nexus', 'Items']:
    known.update('ServoPeregrino_Organizador_'+addon+'_fnc_'+p.stem[3:] for p in (ROOT/'addons'/('ServoPeregrino_Organizador_'+addon)).rglob('fn_*.sqf'))
references = set(re.findall(r'ServoPeregrino_Organizador_\w+_fnc_\w+', all_sources))
check('all referenced SP_ORG functions resolve', references <= known)
for p in files + [ADDON/'config.cpp', ADDON/'script_version.hpp'] + list(LAB.glob('*.sqf')) + [LAB/'mission.sqm', LAB/'description.ext']:
    check('balanced delimiters '+str(p.relative_to(ROOT)), balanced(p.read_text()))
with tempfile.TemporaryDirectory() as td:
    tmp = Path(td)
    for p in ADDON.rglob('*'):
        if p.is_file():
            dst = tmp/p.relative_to(ADDON); dst.parent.mkdir(parents=True, exist_ok=True)
            s = p.read_text()
            s = re.sub(r'(#include\s+")([^"]+)(")', lambda m:m[1]+m[2].replace('\\','/')+m[3],s)
            dst.write_text(s)
    results = [subprocess.run(['cpp','-P','-traditional-cpp',str(tmp/p.relative_to(ADDON))],capture_output=True,text=True) for p in files+[ADDON/'config.cpp']]
    check('C preprocessor includes/macros (not SQF compiler)', all(r.returncode==0 for r in results))
    for r in results:
        if r.returncode: print(r.stderr)
check('exactly four playable slots', (LAB/'mission.sqm').read_text().count('isPlayable=1;') == 4)
check('mission contains no copied addon implementation', all('createHashMapFromArray' not in p.read_text() for p in LAB.glob('*.sqf')))
check('manual gates remain OPEN', '"identityGate","OPEN"' in all_sources and '["physicalIdentityProven",false]' in all_sources)
check('only two RemoteExec endpoints', set(re.findall(r'class (ServoPeregrino_Organizador_Weapons_fnc_\w+) \{allowedTargets=',config)) == {PREFIX+'serverHandleLabRequest',PREFIX+'clientReceiveLabResult'})
endpoint = (ADDON/'functions/tests/fn_serverHandleLabRequest.sqf').read_text()
check('lab endpoint validates enable flag and ownership', 'SP_ORG_Weapons_LabEnabled' in endpoint and 'owner _unit != _sender' in endpoint and 'remoteExecutedOwner' in endpoint)
check('server identity allocator guard', 'if (!isServer)' in (ADDON/'functions/identity/fn_createWeaponInstance.sqf').read_text())
check('server allocator atomic allocation', 'isNil {' in (ADDON/'functions/identity/fn_createWeaponInstance.sqf').read_text())
check('serial is not classname/config/location-derived', '"SPW-" + _suffix' in all_sources and '_state get "session"' in all_sources)
check('immutable fields not updated', not re.search(r'_instance set \["(?:instanceId|serial|weaponClass|createdAt)"', (ADDON/'functions/identity/fn_updateWeaponInstanceConfiguration.sqf').read_text()))
for name in ['Items','Nexus','Armorer']:
    out=subprocess.run(['git','diff',BASE,'--','addons/ServoPeregrino_Organizador_'+name],cwd=ROOT,capture_output=True,text=True,check=True).stdout
    check(name+' runtime unchanged from baseline',not out)
state = json.loads((ROOT/'machine/PROJECT_STATE.json').read_text())
matrix = json.loads((ROOT/'machine/MODULE_MATRIX.json').read_text())
w = next(m for m in state['modules'] if m['id']=='Weapons')
wm = next(m for m in matrix['modules'] if m['id']=='Weapons')
check('Weapons machine state describes candidate',w['status']=='FOUNDATION_IDENTITY_SPIKE_PENDING_RUNTIME_VALIDATION' and wm['status']==w['status'])
check('machine capabilities match runtime',w['capabilities_provided']['implemented']==['weapons.runtime'] and wm['capabilities_provided']==w['capabilities_provided'])
check('no stable domain contracts',w['contracts_provided']['implemented']==[])
base_state=json.loads(subprocess.run(['git','show',BASE+':machine/PROJECT_STATE.json'],cwd=ROOT,capture_output=True,text=True,check=True).stdout)
check('Items gate preserved byte-equivalent data',next(m for m in state['modules'] if m['id']=='Items')==next(m for m in base_state['modules'] if m['id']=='Items'))
index=json.loads((ROOT/'machine/FUNCTION_INDEX.json').read_text())
check('function index covers all Weapons functions', {r['symbol'] for r in index if r['addon']=='Weapons'} == set(functions))
with (ROOT/'machine/CALL_GRAPH_EDGES.csv').open() as f: edges={(r['caller'],r['callee']) for r in csv.DictReader(f)}
expected={(symbol,ref) for symbol,p in functions.items() for ref in re.findall(r'ServoPeregrino_Organizador_\w+_fnc_\w+',p.read_text())}
check('call graph contains every detected Weapons reference',expected <= edges)
failed=sum(not ok for _,ok in checks)
print(f'STATIC_SUMMARY passed={len(checks)-failed} failed={failed} total={len(checks)}')
print('SQF_EXECUTION=NOT_RUN; PBO_LOAD=NOT_RUN; SP=NOT_RUN; MP=NOT_RUN; IDENTITY_GATE=OPEN')
raise SystemExit(bool(failed))
