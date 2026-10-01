#!/usr/bin/env python3
"""Refresh only Weapons rows; preserve baseline records from other modules."""
import csv
import json
import re
from pathlib import Path
ROOT=Path(__file__).resolve().parents[1]
a=ROOT/'addons/ServoPeregrino_Organizador_Weapons'
index_path=ROOT/'machine/FUNCTION_INDEX.json'
rows=[x for x in json.loads(index_path.read_text()) if x['addon']!='Weapons']
new=[]
new_edges=set()
for p in sorted(a.rglob('fn_*.sqf')):
 s=p.read_text(); name=p.stem[3:]; symbol='ServoPeregrino_Organizador_Weapons_fnc_'+name
 refs=sorted(set(re.findall(r'ServoPeregrino_Organizador_\w+_fnc_\w+',s)))
 params=re.search(r'^params \[(.*)\];$',s,re.M)
 new.append(dict(addon='Weapons',category=p.parent.name,function=name,symbol=symbol,path=p.relative_to(a).as_posix(),params_detected=params[1] if params else '',bytes=p.stat().st_size,references=';'.join(refs)))
 new_edges.update((symbol,ref) for ref in refs)
rows+=new
index_path.write_text(json.dumps(rows,ensure_ascii=False,indent=2)+'\n')
with (ROOT/'machine/FUNCTION_INDEX.csv').open('w',newline='') as f:
 w=csv.DictWriter(f,fieldnames=list(rows[0]),lineterminator="\n");w.writeheader();w.writerows(rows)
ep=ROOT/'machine/CALL_GRAPH_EDGES.csv'
with ep.open() as f: edges=[r for r in csv.DictReader(f) if not r['caller'].startswith('ServoPeregrino_Organizador_Weapons_fnc_')]
edges.extend(dict(caller=a,callee=b) for a,b in sorted(new_edges))
with ep.open('w',newline='') as f:
 w=csv.DictWriter(f,fieldnames=['caller','callee'],lineterminator='\n');w.writeheader();w.writerows(edges)
print(f'Weapons inventory: {len(new)} functions, {len(new_edges)} detected references (includes function-name strings, not proof of executed calls).')
