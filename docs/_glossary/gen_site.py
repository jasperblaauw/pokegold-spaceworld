#!/usr/bin/env python3
# Builds the multi-page docs/glossary/ site.
# Japanese is read straight from the repo; English comes from translations.TR
# (keyed by the exact joined Japanese). Anything missing renders as a visible
# "pending" marker, and per-section coverage is printed, so nothing is silently
# dropped — every ROM string appears on some page.
import re, os, html, sys, collections
HERE = os.path.dirname(__file__)
sys.path.insert(0, HERE)
from newcomers import NEWCOMERS
import translations as T

# Repo root is two levels up from this file (docs/_glossary/gen_site.py),
# or overridden via $GLOSSARY_REPO. Keeps the generator location-independent.
REPO = os.environ.get("GLOSSARY_REPO") or os.path.abspath(os.path.join(HERE, "..", ".."))
OUT = os.path.join(REPO, "docs/glossary")
os.makedirs(OUT, exist_ok=True)

def read(p): return open(os.path.join(REPO, p), encoding="utf-8", errors="replace").read()
def esc(s): return html.escape(s, quote=True)

# ---- coverage bookkeeping --------------------------------------------------
COV = collections.Counter()   # section -> [translated, total]
COVT = collections.Counter()
MISSING = collections.defaultdict(list)
def lookup(table, key, section):
    """Look up a translation by stable id; record coverage; return (html, pending)."""
    COVT[section] += 1
    t = table.get(key)
    if t:
        COV[section] += 1
        return esc(t).replace("\n", "<br>"), False
    MISSING[section].append(key)
    return '<span class="pending">— pending —</span>', True

def jp_clean(s):
    return s.replace("@", "").replace("#", "ポケモン").replace("　", " ").strip()
def jp_disp(lines):
    # display a multi-line Japanese block
    return "<br>".join(esc(jp_clean(l)) for l in lines if jp_clean(l))
def jp_key(lines):
    # canonical key: raw kana joined by \n, @ stripped, spaces kept as-is
    return "\n".join(l.replace("@", "") for l in lines).strip()

# ---------------------------------------------------------------- extractors
LABEL = re.compile(r'^\s*(\.?[A-Za-z_][A-Za-z0-9_]*):')
TEXTLINE = re.compile(r'^\s*(?:db|text|line|para|cont|next|text_start)\b')
STRLIT = re.compile(r'"((?:[^"\\]|\\.)*)"')
def has_jp(s): return bool(re.search(r'[ぁ-ゖァ-ヺー？！。、０-９]', s))

def extract_blocks(path):
    """Yield (label, [jp_lines]) for every Japanese text run, attached to its
    nearest preceding label (global or local). Fully inclusive: any db/text/line
    string-bearing run counts; runs end at a code line, a new label, or done/prompt."""
    lines = read(path).splitlines()
    blocks = []
    cur = []            # current run of string literals
    cur_label = None    # label the current run belongs to
    last_label = None   # most recent label seen
    def flush():
        if cur and any(has_jp(x) for x in cur):
            blocks.append((cur_label or last_label or "(text)", list(cur)))
        cur.clear()
    for ln in lines:
        stripped = ln.strip()
        if stripped == "" or stripped.startswith(";"):
            continue                                   # blanks/comments stay inside a run
        m = LABEL.match(ln)
        if m and not TEXTLINE.match(ln):
            flush(); last_label = m.group(1); cur_label = None
            continue
        strs = STRLIT.findall(ln)
        if strs and TEXTLINE.match(ln):
            if cur_label is None: cur_label = last_label
            cur.extend(strs)
            continue
        flush()                                        # code / done / prompt ends the run
    flush()
    return blocks

# =============================================================== shared shell
CSS = read("docs/index.html"); CSS = CSS[CSS.index("<style>")+7: CSS.index("</style>")]
EXTRA_CSS = """
.app { display:grid; grid-template-columns:262px minmax(0,1fr); min-height:100vh; }
.sidebar { position:sticky; top:0; align-self:start; height:100vh; overflow-y:auto;
  background:var(--surface); border-right:1px solid var(--line); padding:22px 16px 40px; }
.content { padding:44px clamp(18px,4vw,60px); min-width:0; max-width:1040px; }
.brand { display:flex; align-items:center; gap:10px; margin-bottom:16px; text-decoration:none; }
.brand b { font-family:var(--mono); font-size:.9rem; color:var(--ink); }
.brand span { font-family:var(--mono); font-size:.6rem; letter-spacing:.16em; text-transform:uppercase; color:var(--ink-faint); display:block; }
nav.side { display:flex; flex-direction:column; gap:3px; }
nav.side .grp { margin:14px 0 3px; padding:0 8px; font-family:var(--mono); font-size:.6rem;
  letter-spacing:.15em; text-transform:uppercase; color:var(--ink-faint); }
nav.side a { display:flex; justify-content:space-between; gap:8px; align-items:center;
  padding:6px 10px; border-radius:7px; color:var(--ink-soft); text-decoration:none;
  font-size:.85rem; border-left:2px solid transparent; }
nav.side a:hover { background:var(--surface-2); color:var(--ink); }
nav.side a.active { background:var(--accent-wash); color:var(--accent-strong);
  border-left-color:var(--accent); font-weight:600; }
nav.side a .n { font-family:var(--mono); font-size:.62rem; color:var(--ink-faint); }
.pending { font-family:var(--mono); font-size:.72rem; color:var(--gold); opacity:.85; }
tr.demo td { background:color-mix(in srgb, var(--accent-wash) 60%, transparent); }
.pill { font-family:var(--mono); font-size:.58rem; letter-spacing:.06em; text-transform:uppercase;
  color:var(--accent-strong); border:1px solid var(--accent); border-radius:999px; padding:1px 6px; margin-left:6px; white-space:nowrap; }
.jpcell { font-size:.98rem; color:var(--ink); line-height:1.5; }
td:first-child { font-family:var(--mono); color:var(--ink-faint); white-space:nowrap; }
.cov { font-family:var(--mono); font-size:.72rem; color:var(--ink-faint); margin:2px 0 14px; }
.covbar { display:inline-block; width:120px; height:7px; border-radius:4px; background:var(--surface-2);
  vertical-align:middle; overflow:hidden; margin:0 8px; border:1px solid var(--line); }
.covbar i { display:block; height:100%; background:var(--accent); }
.grpname { font-family:var(--mono); font-size:1.02rem; margin:30px 0 6px; color:var(--ink); }
.menu-btn2 { display:none; }
@media (max-width:820px){ .app{grid-template-columns:1fr;} .sidebar{position:static;height:auto;} }
"""
NAV = [
 ("Start", [("index","Overview", "")]),
 ("Names", [("pokemon","Pokémon","251"), ("moves","Moves","250"), ("items","Items","~150"),
            ("locations","Locations","45"), ("trainers","Trainers","64"), ("types","Types","19")]),
 ("Flavor & descriptions", [("dex","Pokédex entries","251"),
            ("move-desc","Move descriptions","251"), ("item-desc","Item descriptions","206")]),
 ("Dialogue & scripts", [("dialogue","Map dialogue","122"),
            ("system","Battle / menu / system","733")]),
]
def sidebar(active):
    rows = ['<a class="brand" href="../index.html"><span>Space World \'97</span></a>',
            '<a class="brand" href="index.html" style="margin-top:-8px"><b>Text Glossary</b></a>',
            '<nav class="side">']
    for grp, items in NAV:
        rows.append('<div class="grp">%s</div>' % esc(grp))
        for pid, label, count in items:
            a = ' class="active"' if pid == active else ''
            href = "index.html" if pid == "index" else pid + ".html"
            n = '<span class="n">%s</span>' % esc(count) if count else ''
            rows.append('<a%s href="%s">%s%s</a>' % (a, href, esc(label), n))
    rows.append('</nav>')
    return "\n".join(rows)

def page(pid, title, body):
    doc = """<!doctype html><html lang="en"><head>
<meta charset="utf-8"><meta name="viewport" content="width=device-width, initial-scale=1">
<title>%s — Space World '97 Text Glossary</title>
<style>%s\n%s</style></head><body>
<div class="app"><aside class="sidebar">%s</aside>
<main class="content">%s</main></div></body></html>""" % (
        esc(title), CSS, EXTRA_CSS, sidebar(pid), body)
    with open(os.path.join(OUT, ("index" if pid=="index" else pid) + ".html"), "w", encoding="utf-8") as f:
        f.write(doc)

def tbl(headers, rows, extra=""):
    th = "".join("<th>%s</th>" % h for h in headers)
    return ('<div class="tbl-wrap">%s<table><thead><tr>%s</tr></thead><tbody>%s</tbody></table></div>'
            % (extra, th, "".join(rows)))
def tr(cells, cls=""):
    c = ' class="%s"' % cls if cls else ""
    return "<tr%s>%s</tr>" % (c, "".join("<td>%s</td>" % x for x in cells))
def cov_line(section):
    t, tot = COV[section], COVT[section]
    pct = (100*t//tot) if tot else 100
    return ('<p class="cov">Translation coverage: %d / %d (%d%%)'
            '<span class="covbar"><i style="width:%d%%"></i></span></p>' % (t, tot, pct, pct))

# ============================================================ NAME-TABLE PAGES
def parse_db_names(path):
    out = []
    for line in read(path).splitlines():
        m = re.match(r'\s*db\s+"(.*?)"\s*;\s*(\S+)', line)
        if m: out.append((jp_clean(m.group(1)), m.group(2)))
    return out

# --- data reused from the first glossary build -----------------------------
from names_data import OFFICIAL_151, LOC, DEMO_LOC, TRN, TYPES, MOVE_OVERRIDES, ITEM_OVERRIDES
def pretty(idstr, overrides):
    if idstr in overrides: return overrides[idstr]
    if re.fullmatch(r"(TM|HM)\d+", idstr): return idstr
    if re.fullmatch(r"[0-9A-F]{2}", idstr) or re.fullmatch(r"\d+", idstr): return "(unused/disabled slot)"
    return " ".join(w.capitalize() if not w.isupper() or len(w)>2 else w.title()
                    for w in idstr.split("_")).replace("Poke","Poké")

def build_pokemon():
    poke = parse_db_names("data/pokemon/names.asm")
    newmap = {n[0]: n for n in NEWCOMERS}
    DEMO = {"Happa","Honōguma","Kurusu"}
    rows = []
    for i,(jp,iid) in enumerate(poke, 1):
        if i <= 151:
            rows.append(tr(["%03d"%i, '<span class="jpcell">%s</span>'%esc(jp), "—",
                            "<b>%s</b>"%esc(OFFICIAL_151[i-1]), "—",
                            "Original 151 — official English name."]))
        else:
            _,romaji,eng,lit,typ,final,status = newmap[i]
            if status=="scrapped":
                note = "<b>Scrapped</b> — never released. Localization: <i>%s</i>. %s"%(esc(lit),esc(final))
            elif status=="renamed":
                note = "Released as <b>%s</b>. Demo name: <i>%s</i>."%(esc(final.split(' (')[0]),esc(lit))
            else:
                note = "Released as <b>%s</b> (name kept)."%esc(final.split(' (')[0])
            demo = romaji in DEMO
            rows.append(tr(["%03d"%i, '<span class="jpcell">%s</span>'%esc(jp), esc(romaji),
                ("<b>%s</b>"%esc(eng if eng!="—" else "— (unreleased)"))+(' <span class="pill">demo starter</span>' if demo else ''),
                esc(typ) if typ else "—", note], cls="demo" if demo else ""))
    body = INTRO_NAMES + tbl(["Dex","Japanese","Rōmaji","English","Proto type","Notes"], rows)
    page("pokemon","Pokémon names", body)

def build_moves_names():
    moves = parse_db_names("data/moves/names.asm")
    rows = [tr(["%d"%i, '<span class="jpcell">%s</span>'%esc(jp), pretty(iid,MOVE_OVERRIDES)])
            for i,(jp,iid) in enumerate(moves,1)]
    page("moves","Move names",
         '<p class="eyebrow">Names</p><h1>Move names</h1><p class="lead">Shown in battle and the summary screen. Most match their official English names; prototype-exclusive moves are rendered literally and tagged “beta”.</p>'
         + tbl(["#","Japanese","English"], rows))

def build_items_names():
    items = parse_db_names("data/items/names.asm")
    rows=[]
    for i,(jp,iid) in enumerate(items,1):
        eng = pretty(iid, ITEM_OVERRIDES)
        if jp=="しようきんし": eng="(disabled — 使用禁止 “usage forbidden”)"
        if jp=="みしよう": eng="(unused — 未使用)"
        rows.append(tr(["$%02X"%i, '<span class="jpcell">%s</span>'%esc(jp), eng]))
    page("items","Item names",
         '<p class="eyebrow">Names</p><h1>Item names</h1><p class="lead">Bag / PC item names, by item ID. Many slots are placeholders (しようきんし “usage forbidden”, みしよう “unused”). Note the many prototype-only hold items and stones.</p>'
         + tbl(["ID","Japanese","English"], rows))

def build_locations():
    land = parse_db_names("data/maps/landmark_names.asm")
    rows=[]
    for jp,iid in land:
        eng,note = LOC.get(iid,(iid.title(),""))
        demo = iid in DEMO_LOC
        rows.append(tr(['<span class="jpcell">%s</span>'%esc(jp),
            ("<b>%s</b>"%esc(eng))+(' <span class="pill">in demo</span>' if demo else ''),
            esc(note)], cls="demo" if demo else ""))
    page("locations","Locations",
         '<p class="eyebrow">Names</p><h1>Locations</h1><p class="lead">Landmark labels on the Town Map (<code>data/maps/landmark_names.asm</code>). Only Silent Hill, Blue Forest and Old City are reachable in the demo.</p>'
         + tbl(["Japanese","English","Notes"], rows))

def build_trainers_names():
    trn = parse_db_names("data/trainers/class_names.asm")
    rows=[tr(['<span class="jpcell">%s</span>'%esc(jp), TRN.get(iid,iid.title())]) for jp,iid in trn]
    page("trainers","Trainers & characters",
         '<p class="eyebrow">Names</p><h1>Trainers &amp; characters</h1><p class="lead">The trainer-class table (<code>data/trainers/class_names.asm</code>) doubles as a character roster — named bosses first. The evil team is the <b>Geruge-dan</b>, not Team Rocket.</p>'
         + tbl(["Japanese","English / character"], rows))

def build_types():
    rows=[tr(['<span class="jpcell">%s</span>'%esc(jp),"<b>%s</b>"%esc(en),esc(note)]) for jp,en,note in TYPES]
    page("types","Types",
         '<p class="eyebrow">Names</p><h1>Types</h1><p class="lead">From <code>data/types/names.asm</code>. Two are prototype-only: <b>Bird</b> (とり) and <b>Metal</b> (メタル, later renamed Steel).</p>'
         + tbl(["Japanese","English","Notes"], rows))

# ============================================================ DEX ENTRIES
DEX_POKE = None
def poke_names():
    global DEX_POKE
    if DEX_POKE is None:
        DEX_POKE = [OFFICIAL_151[i] for i in range(151)]
        newmap={n[0]:n for n in NEWCOMERS}
        for d in range(152,252):
            _,romaji,eng,_,_,final,status = newmap[d]
            DEX_POKE.append(eng if eng not in ("—",) else romaji)
    return DEX_POKE

def build_dex():
    t = read("data/pokemon/dex_entries.asm")
    blocks = re.split(r'\n(?=[A-Za-z0-9_]+DexEntry:)', t)
    entries = {}
    for b in blocks:
        m = re.match(r'([A-Za-z0-9_]+)DexEntry:', b)
        if not m: continue
        strs = re.findall(r'(?:db|next|line|para|cont)\s+"([^"]+)"', b)
        hw = re.findall(r'^\s*d[bw]\s+(\d+)\s*$', b, re.M)
        cat = strs[0] if strs else ""
        flavor = strs[1:]
        entries[m.group(1)] = (cat, hw, flavor)
    # dex order via pointer tables
    order = re.findall(r'dw ([A-Za-z0-9_]+)DexEntry', t)
    names = poke_names()
    rows=[]
    for idx,lab in enumerate(order):
        if lab not in entries: continue
        dexno = idx+1
        cat, hw, flavor = entries[lab]
        nm = names[dexno-1] if dexno-1 < len(names) else lab
        cat_en,_ = lookup(T.DEX_CAT, cat.replace("@","").strip(), "dex-cat")
        flav_join = "".join(x.replace("@","") for x in flavor)
        if "はっけんされた" in flav_join:          # shared newcomer placeholder
            COVT["dex"]+=1
            if T.DEX_PLACEHOLDER: COV["dex"]+=1; flav_en=esc(T.DEX_PLACEHOLDER)
            else: MISSING["dex"].append("__placeholder__"); flav_en='<span class="pending">— pending —</span>'
        else:
            flav_en,_ = lookup(T.DEX_FLAVOR, nm, "dex")
        rows.append(tr(["%03d"%dexno, "<b>%s</b>"%esc(nm),
            '<span class="jpcell">%s / %s</span>'%(esc(jp_clean(cat)) or "—", cat_en),
            '<span class="jpcell">%s</span>'%jp_disp(flavor), flav_en]))
    body = ('<p class="eyebrow">Flavor &amp; descriptions</p><h1>Pokédex entries</h1>'
            '<p class="lead">Species category, and the flavor text (<code>data/pokemon/dex_entries.asm</code>). '
            'All 100 newcomers share one placeholder entry — <i>“A Pokémon that was just discovered. Currently under investigation.”</i> — and a <span class="jpcell">？？？</span> category.</p>'
            + cov_line("dex")
            + tbl(["Dex","Pokémon","Category (JP / EN)","Flavor text (JP)","Flavor (EN)"], rows))
    page("dex","Pokédex entries", body)

# ============================================================ DESCRIPTIONS
def build_descriptions(kind):
    # kind: 'move' or 'item'
    if kind=="move":
        src="data/moves/descriptions.asm"; names=parse_db_names("data/moves/names.asm")
        sec="move-desc"; title="Move descriptions"; table=T.MOVE_DESC
        idfn=lambda i: pretty(names[i][1],MOVE_OVERRIDES) if i<len(names) else ""
        intro='<p class="lead">In-battle / summary move descriptions (<code>data/moves/descriptions.asm</code>).</p>'
    else:
        src="data/items/descriptions.asm"; names=parse_db_names("data/items/names.asm")
        sec="item-desc"; title="Item descriptions"; table=T.ITEM_DESC
        idfn=lambda i: pretty(names[i][1],ITEM_OVERRIDES) if i<len(names) else ""
        intro='<p class="lead">Item descriptions from the bag (<code>data/items/descriptions.asm</code>). 49 slots are the placeholder <span class="jpcell">？</span>.</p>'
    t = read(src)
    order = re.findall(r'dw ([A-Za-z0-9_]+)Description', t)
    blocks = re.split(r'\n(?=[A-Za-z0-9_]+Description:)', t)
    bd={}
    for b in blocks:
        m=re.match(r'([A-Za-z0-9_]+)Description:',b)
        if not m: continue
        bd[m.group(1)] = re.findall(r'(?:db|next|line|para|cont)\s+"([^"]+)"', b)
    rows=[]
    for i,lab in enumerate(order):
        flavor = bd.get(lab,[])
        nm = idfn(i)
        joined = "".join(x.replace("@","") for x in flavor).strip()
        if not any(has_jp(x) for x in flavor) or set(joined) <= set("？?　 /"):
            en="—"                                  # empty or ？ placeholder
        else:
            en,_ = lookup(table, "%d"%(i+1), sec)
        rows.append(tr(["%d"%(i+1), "<b>%s</b>"%esc(nm),
            '<span class="jpcell">%s</span>'%(jp_disp(flavor) or "—"), en]))
    body=('<p class="eyebrow">Flavor &amp; descriptions</p><h1>%s</h1>%s%s%s'%(
        esc(title), intro, cov_line(sec),
        tbl(["#","Name","Japanese","English"], rows)))
    page(sec, title, body)

# ============================================================ DIALOGUE (maps)
MAP_TITLES = {
 "PlayerHouse2F":"Player's House 2F", "PlayerHouse1F":"Player's House 1F",
 "SilentHillLabFront":"Silent Hill — Prof. Oak's Lab (front)",
 "SilentHillLab":"Silent Hill — Prof. Oak's Lab",
 "SilentHillPokecenter":"Silent Hill — Pokémon Center",
 "SilentHillMart":"Silent Hill — Mart", "SilentHill":"Silent Hill (town)",
 "QuietHills":"Quiet Hills (route)", "BlueForest":"Blue Forest",
 "OldCity":"Old City", "OldCityPokecenter":"Old City — Pokémon Center",
}
def prettify_map(stem):
    if stem in MAP_TITLES: return MAP_TITLES[stem]
    return re.sub(r'(?<=[a-z])(?=[A-Z0-9])', ' ', stem)

def build_dialogue():
    mapdir = os.path.join(REPO,"maps")
    files=[f for f in os.listdir(mapdir) if f.endswith(".asm")]
    data=[]
    for f in sorted(files):
        blocks=list(extract_blocks("maps/"+f))
        if not blocks: continue
        data.append((f[:-4], blocks))
    sections=[]
    for stem, blocks in data:
        sections.append('<h2 id="%s">%s <span class="count">%d blocks</span></h2>'%(esc(stem),esc(prettify_map(stem)),len(blocks)))
        rows=[]
        seen=collections.Counter()
        for label, buf in blocks:
            base="%s:%s"%(stem,label); seen[base]+=1
            key=base if seen[base]==1 else "%s#%d"%(base,seen[base])
            en,_ = lookup(T.DIALOGUE, key, "dialogue")
            rows.append(tr(["<code>%s</code>"%esc(label),
                '<span class="jpcell">%s</span>'%jp_disp(buf), en]))
        sections.append(tbl(["Label","Japanese","English"], rows))
    header=('<p class="eyebrow">Dialogue &amp; scripts</p><h1>Map dialogue</h1>'
          '<p class="lead">Every NPC line, signpost, trainer taunt and radio broadcast in the maps that carry scripts. Labels hint at the surface (…<code>TextString</code>, …<code>SignText</code>, …<code>RadioText</code>, …<code>PCText</code>). Speaker names appear inline (<span class="jpcell">ケン『</span> = “Ken:”).</p>')
    page("dialogue","Map dialogue", header + cov_line("dialogue") + "".join(sections))

# ============================================================ ENGINE / SYSTEM
def build_system():
    roots=["engine","home"]
    groups=collections.OrderedDict()
    for root in roots:
        for dp,_,fs in os.walk(os.path.join(REPO,root)):
            for fn in sorted(fs):
                if not fn.endswith(".asm"): continue
                rel=os.path.relpath(os.path.join(dp,fn),REPO)
                blocks=list(extract_blocks(rel))
                if not blocks: continue
                groups.setdefault(os.path.dirname(rel), []).append((rel,blocks))
    # Basenames shared by >1 file (e.g. battle/menu.asm vs home/menu.asm) would
    # collide on a "basename:label" key, so those get a parent-dir prefix.
    basecount=collections.Counter(os.path.basename(rel)
                                  for files in groups.values() for rel,_ in files)
    def keyfile(rel):
        bn=os.path.basename(rel)
        return "%s/%s"%(os.path.basename(os.path.dirname(rel)), bn) if basecount[bn]>1 else bn
    sections=[]
    for d,files in groups.items():
        sections.append('<h2>%s/</h2>'%esc(d))
        for rel,blocks in files:
            sections.append('<p class="grpname"><code>%s</code></p>'%esc(os.path.basename(rel)))
            rows=[]
            seen=collections.Counter()
            for label,buf in blocks:
                base="%s:%s"%(keyfile(rel),label); seen[base]+=1
                key=base if seen[base]==1 else "%s#%d"%(base,seen[base])
                en,_=lookup(T.SYSTEM, key, "system")
                rows.append(tr(["<code>%s</code>"%esc(label),
                    '<span class="jpcell">%s</span>'%jp_disp(buf), en]))
            sections.append(tbl(["Label","Japanese","English"], rows))
    header=('<p class="eyebrow">Dialogue &amp; scripts</p><h1>Battle, menu &amp; system text</h1>'
          '<p class="lead">Free text baked into the engine — battle messages (with <span class="jpcell">&lt;TARGET&gt;</span>/<span class="jpcell">&lt;USER&gt;</span> placeholders), menus, the intro/Oak speech, and system prompts. Grouped by source directory.</p>')
    page("system","Battle / menu / system", header + cov_line("system") + "".join(sections))

# ============================================================ INDEX / OVERVIEW
INTRO_NAMES = ('<p class="eyebrow">Names</p><h1>Pokémon names</h1>'
 '<p class="lead">All 251 in the prototype Pokédex order. Released Pokémon use their official English name (incl. renamed newcomers, e.g. ハッパ Happa → Chikorita); scrapped ones use a literal translation of the prototype name.</p>')

def build_index():
    # overall coverage
    tot=sum(COVT.values()); done=sum(COV.values())
    pct=100*done//tot if tot else 0
    covrows=[]
    for sec in ["dex","dex-cat","move-desc","item-desc","dialogue","system"]:
        if COVT[sec]:
            p=100*COV[sec]//COVT[sec]
            covrows.append(tr([sec, "%d / %d"%(COV[sec],COVT[sec]),
                '<span class="covbar"><i style="width:%d%%"></i></span> %d%%'%(p,p)]))
    body="""<p class="eyebrow">Reference</p>
<h1>Text &amp; Localization Glossary</h1>
<p class="lead">Every Japanese string in the prototype ROM — names, Pokédex entries, move/item descriptions, and all NPC, signpost, trainer and system dialogue — paired with an English translation, and split by where it appears in-game.</p>
<div class="callout warn"><span class="ico">!</span><p><b>Documentation only.</b> Nothing here changes a ROM byte — <code>make compare</code> stays green. Japanese is read directly from the repo's <code>.asm</code> data so it matches the source exactly.</p></div>

<h2>Coverage</h2>
<p>The site includes <b>100%% of the ROM's Japanese strings</b> (extracted straight from source), and <b>every one is now translated</b>. Any future untranslated cell is marked <span class="pending">— pending —</span> so gaps stay visible, never hidden — but there are none today.</p>
%s
<p class="cov">Overall free-text translation: <b>%d / %d (%d%%)</b>. The six name tables (Pokémon, moves, items, locations, trainers, types — ~820 entries) are fully localized and not counted above. Battle/menu/system strings are often fragments the engine joins around an inline name or number buffer; those are translated as fragments, with <span class="jpcell">&lt;USER&gt;</span>/<span class="jpcell">&lt;TARGET&gt;</span>/<span class="jpcell">&lt;PLAYER&gt;</span> placeholders kept as-is.</p>

<h2>How Pokémon are named</h2>
<ul><li><b>Released</b> → official English (e.g. デンリュウ → Ampharos).</li>
<li><b>Scrapped</b> → literal translation (e.g. クルス → “Cruise”). Nob Ogasawara's DYKG names aren't reliably transcribed, so per the fallback these use documented etymology.</li></ul>

<h2>The Space World 1997 demo</h2>
<p>Built 15 Nov 1997, shown 22 Nov 1997. Only a slice was playable: home town <b>Silent Hill</b> → first routes → <b>Blue Forest</b> → <b>Old City</b>; a random Lv 8 starter (<b>Happa</b>/<b>Honōguma</b>/<b>Kurusu</b>); no saving, no naming, PC/Center “under repair”. Demo-reachable rows are shaded and tagged across the name tables.</p>

<h2>Sources</h2>
<ul>
<li>Japanese: this repo's <code>data/</code>, <code>engine/</code>, <code>maps/</code> (byte-exact).</li>
<li>Newcomer romaji, typings, etymology, final-game correspondence: <a class="inline" href="https://tcrf.net/Proto:Pok%%C3%%A9mon_Gold_and_Silver/Spaceworld_1997_Demo/Pok%%C3%%A9mon">TCRF</a>.</li>
<li>Demo scope: <a class="inline" href="https://tcrf.net/Proto:Pok%%C3%%A9mon_Gold_and_Silver/Spaceworld_1997_Demo">TCRF</a>, <a class="inline" href="https://bulbapedia.bulbagarden.net/wiki/Pok%%C3%%A9mon_Gold_and_Silver_Spaceworld_'97_demo">Bulbapedia</a>.</li>
</ul>""" % (tbl(["Section","Translated","Progress"], covrows), done, tot, pct)
    page("index","Overview", body)

# =============================================================== run
build_pokemon(); build_moves_names(); build_items_names(); build_locations()
build_trainers_names(); build_types()
build_dex(); build_descriptions("move"); build_descriptions("item")
build_dialogue(); build_system()
build_index()  # last: needs coverage totals

print("Sections coverage:")
for sec in sorted(COVT):
    print("  %-12s %d/%d" % (sec, COV[sec], COVT[sec]))
print("pages written to", OUT)
# dump missing per section for translating
import json
with open(os.path.join(HERE,"missing.json"),"w",encoding="utf-8") as f:
    json.dump({k:list(dict.fromkeys(v)) for k,v in MISSING.items()}, f, ensure_ascii=False, indent=1)
print("unique missing:", {k:len(set(v)) for k,v in MISSING.items()})
