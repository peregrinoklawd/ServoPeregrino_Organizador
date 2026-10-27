#!/usr/bin/env python3
"""Gera PBOs SP_ORG P1-C nao binarizados, nao assinados, apenas para teste SP.
As fontes SQF/config.cpp sao copiadas sem modificacao. Exige checkout do GitHub.
"""
import argparse, hashlib, json, re, struct
from pathlib import Path
NEXUS="ServoPeregrino_Organizador_Nexus"
POLICY="ServoPeregrino_Organizador_Policy"

def unpack_pbo(blob):
    i=0
    def cstring():
        nonlocal i
        stop=blob.index(b"\0",i)
        value=blob[i:stop].decode("utf-8")
        i=stop+1
        return value
    props={}; headers=[]; first=True
    while True:
        name=cstring()
        mime,original,reserved,stamp,size=struct.unpack_from("<5I",blob,i)
        i+=20
        if not name:
            if first and mime==0x56657273:
                while True:
                    key=cstring()
                    if not key:break
                    props[key]=cstring()
                first=False
                continue
            assert (mime,original,reserved,stamp,size)==(0,0,0,0,0), "PBO terminator"
            break
        assert mime==0 and original in (0,size), (name,mime,original)
        headers.append((name,size))
        first=False
    records={}
    for name,size in headers:
        assert name not in records
        records[name]=blob[i:i+size]
        assert len(records[name])==size
        i+=size
    assert len(blob)==i+21, "Trailer size"
    assert blob[i:i+1]==b"\0"
    assert hashlib.sha1(blob[:i]).digest()==blob[i+1:], "SHA1 trailer"
    return props,records

def pack(source,out,name):
    assert (source/"config.cpp").is_file(), source
    p=(source/"$PBOPREFIX$").read_text(encoding="utf-8-sig").strip().strip("\\/")
    assert p==name, ("prefix",p,name)
    cfg=(source/"config.cpp").read_text(encoding="utf-8-sig")
    cfgclean=re.sub(r"/\*.*?\*/|//[^\n]*","",cfg,flags=re.S)
    assert "class CfgFunctions" in cfg and "preInit = 1" in cfgclean
    assert "CfgRemoteExec" not in cfgclean
    if name==POLICY:
        assert '"ServoPeregrino_Organizador_Nexus"' in cfgclean
    records={}
    for entry in source.rglob("*"):
        if entry.is_file() and entry.name!="$PBOPREFIX$":
            key=entry.relative_to(source).as_posix().replace("/","\\")
            assert key not in records
            records[key]=entry.read_bytes()
    count=sum(n.lower().endswith(".sqf") for n in records)
    assert count==(21 if name==NEXUS else 6), ("SQF file count",name,count)
    assert "config.cpp" in records
    if name==NEXUS:
        assert "script_version.hpp" in records
    header=bytearray(b"\0sreV"+bytes(16))
    header+=b"prefix\0"+p.encode("ascii")+b"\0\0"
    sorted_files=sorted(records.items(),key=lambda item:item[0].casefold())
    for fname,data in sorted_files:
        header+=fname.encode("utf-8")+b"\0"+struct.pack("<5I",0,0,0,0,len(data))
    header+=bytes(21)
    base=bytes(header)+b"".join(data for _,data in sorted_files)
    blob=base+b"\0"+hashlib.sha1(base).digest()
    out.parent.mkdir(parents=True,exist_ok=True)
    out.write_bytes(blob)
    checkprops,checkfiles=unpack_pbo(out.read_bytes())
    assert checkprops["prefix"]==p and checkfiles==records, "PBO roundtrip"
    return {"addon":name,"prefix":p,"pbo_bytes":len(blob),
            "file_count":len(records),"sqf_count":count,"sha256":hashlib.sha256(blob).hexdigest(),
            "sources_sha256":{key:hashlib.sha256(data).hexdigest() for key,data in sorted_files}}

if __name__=="__main__":
    parser=argparse.ArgumentParser()
    parser.add_argument("--repo",type=Path,default=Path("."))
    parser.add_argument("--out",type=Path,default=Path("dist/policy-p1c"))
    a=parser.parse_args()
    directory=a.repo.resolve()/"addons"
    output=a.out.resolve()
    manifest={"build":"P1-C addon trial","kind":"unbinarized unsigned PBO","engine_test":"NOT_RUN",
              "branch":"feature/policy-0.1-b-nexus-integration","artifacts":[]}
    for name,modfolder in ((NEXUS,"@SPORG_Nexus_P1C"),(POLICY,"@SPORG_Policy_P1C")):
        dest=output/modfolder/"addons"/(name+".pbo")
        result=pack(directory/name,dest,name)
        manifest["artifacts"].append(result)
        print(f"OK {name} sqf={result['sqf_count']} bytes={result['pbo_bytes']} sha256={result['sha256']}")
    (output/"manifest.json").write_text(json.dumps(manifest,ensure_ascii=False,indent=2)+"\n",encoding="utf-8")
    print("PASS: PBO header/prefix/files/SHA1 roundtrip; PENDING: game startup and RPT")
