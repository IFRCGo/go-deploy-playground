/* GO IA Map 2026 — rendering and interaction. Reads SECTIONS, N, SM and the access constants from data.js. */
(function(){
// ---------- Icons ----------
const P={
  page:'<rect x="3" y="4" width="18" height="16" rx="2"/><path d="M3 9h18M8 13h6"/>',
  tab:'<rect x="3" y="5" width="18" height="15" rx="2"/><path d="M3 9h7V5"/>',
  subtab:'<rect x="5" y="7" width="16" height="13" rx="2"/><path d="M5 11h6V7M3 4v12"/>',
  menu:'<path d="M4 6h16M4 12h16M4 18h10"/>',
  form:'<path d="M14 3H6a2 2 0 0 0-2 2v14a2 2 0 0 0 2 2h12a2 2 0 0 0 2-2V9z"/><path d="M14 3v6h6M9 14l2 2 4-4"/>',
  list:'<path d="M8 6h13M8 12h13M8 18h13M3 6h.01M3 12h.01M3 18h.01"/>',
  dropdown:'<rect x="3" y="4" width="18" height="16" rx="2"/><path d="m8 10 4 4 4-4"/>',
  overlay:'<rect x="3" y="3" width="14" height="14" rx="2"/><rect x="7" y="7" width="14" height="14" rx="2"/>',
  external:'<path d="M14 4h6v6M10 14 20 4M18 14v5a1 1 0 0 1-1 1H5a1 1 0 0 1-1-1V7a1 1 0 0 1 1-1h5"/>',
  shortcut:'<path d="M17 2l4 4-4 4"/><path d="M3 11V9a3 3 0 0 1 3-3h15M7 22l-4-4 4-4"/><path d="M21 13v2a3 3 0 0 1-3 3H3"/>',
  user:'<circle cx="12" cy="8" r="4"/><path d="M4 21c0-4 4-6 8-6s8 2 8 6"/>',
  lock:'<rect x="5" y="11" width="14" height="10" rx="2"/><path d="M8 11V7a4 4 0 0 1 8 0v4"/>',
  key:'<circle cx="8" cy="15" r="4"/><path d="m10.8 12.2 9.2-9.2M17 6l3 3M14 9l2 2"/>',
  arrow:'<path d="M5 12h14M13 6l6 6-6 6"/>',
  back:'<path d="M19 12H5M11 6l-6 6 6 6"/>',
  home:'<path d="M3 11 12 4l9 7v9a1 1 0 0 1-1 1h-5v-6H9v6H4a1 1 0 0 1-1-1z"/>',
  globe:'<circle cx="12" cy="12" r="9"/><path d="M3 12h18M12 3c2.5 3 2.5 15 0 18M12 3c-2.5 3-2.5 15 0 18"/>',
  shield:'<path d="M12 3 4 6v6c0 5 3.5 8 8 9 4.5-1 8-4 8-9V6z"/><path d="m9 12 2 2 4-4"/>',
  alert:'<path d="M12 4v16M4 12h16M6.3 6.3l11.4 11.4M17.7 6.3 6.3 17.7"/>',
  book:'<path d="M2 7l10-4 10 4-10 4z"/><path d="M6 9v5c0 1.5 3 3 6 3s6-1.5 6-3V9"/>',
  gear:'<circle cx="9" cy="8" r="4"/><path d="M2 21c0-4 3-6 7-6M17 13v2M17 21v-2M13.5 17h2M20.5 17h-2"/><circle cx="17" cy="17" r="2"/>',
  pen:'<path d="M14 3H6a2 2 0 0 0-2 2v14a2 2 0 0 0 2 2h12a2 2 0 0 0 2-2V9z"/><path d="M14 3v6h6M9 17l1-3 5-5 2 2-5 5z"/>',
  plus:'<circle cx="12" cy="12" r="9"/><path d="M12 8v8M8 12h8"/>',
  search:'<circle cx="11" cy="11" r="7"/><path d="m20 20-4-4"/>',
  lang:'<path d="M4 5h10M9 3v2M6 5c1 4 4 7 8 8M12 5c-1 4-4 7-8 8M13 21l4-9 4 9M14.5 18h5"/>',
  login:'<path d="M15 3h4a2 2 0 0 1 2 2v14a2 2 0 0 1-2 2h-4M10 17l5-5-5-5M15 12H3"/>',
  doc:'<rect x="5" y="3" width="14" height="18" rx="2"/><path d="M9 8h6M9 12h6M9 16h4"/>'
};
const ic=(n,s=14,w=2.2)=>'<svg width="'+s+'" height="'+s+'" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="'+w+'" stroke-linecap="round" stroke-linejoin="round" aria-hidden="true">'+P[n]+'</svg>';
const esc=s=>String(s).replace(/[&<>"]/g,c=>({'&':'&amp;','<':'&lt;','>':'&gt;','"':'&quot;'}[c]));

// ---------- Index & links ----------
const byId={}; N.forEach(n=>{byId[n.id]=n; n.kids=[]; n.acts=n.acts||[]});
N.forEach(n=>{ if(n.p&&byId[n.p]) byId[n.p].kids.push(n) });
N.filter(n=>n.k==='shortcut').forEach(n=>{ const t=byId[n.to]; n.acts=[['Open '+t.t,n.to]]; n.d='Shortcut. Opens the same page that lives under '+SECTIONS.find(s=>s.id===t.s).name+' › '+pathOf(t).map(x=>x.t).join(' › ')+'.'; n.sc=1 });
function pathOf(n){const a=[];let x=n;while(x){a.unshift(x);x=byId[x.p]}return a}
const inbound={}; N.forEach(n=>inbound[n.id]=[]);
N.forEach(n=>n.acts.forEach(([label,to,f={}])=>{ if(!f.self&&inbound[to]&&to!==n.id) inbound[to].push({from:n.id,label,f}) }));
N.forEach(n=>{ if(n.k==='shortcut') inbound[n.to].push({from:n.id,label:'Shortcut',f:{sec:1}}) });
const menuIn={}; N.forEach(n=>menuIn[n.id]=[]);
SM.forEach(z=>z.cols.forEach(c=>c.groups.forEach(([h,links])=>links.forEach(([l,to])=>{ if(to&&menuIn[to]) menuIn[to].push(z.zone+' › '+c.t+(h&&h!==l?' › '+h:'')+' › '+l) }))));

// ---------- Render helpers ----------
const kindLabel={page:'Page',tab:'Tab',subtab:'Sub-tab',menu:'Menu section',form:'Form',list:'List',dropdown:'Dropdown',overlay:'Overlay',external:'External',shortcut:'Shortcut'};
function accChip(a){
  if(a===LOGIN) return '<span class="chipacc">'+ic('user',11,2.6)+'Logged in</span>';
  if(a===IFRC) return '<span class="chipacc ifrc">'+ic('lock',11,2.6)+'IFRC only</span>';
  if(a===PERM) return '<span class="chipacc perm">'+ic('key',11,2.6)+'Specific permissions</span>';
  return '';
}
function metaChips(n){
  let h='<span class="kind">'+ic(n.k,12,2.4)+kindLabel[n.k]+'</span>';
  if(n.rep) h+='<span class="chipacc rp">'+esc(n.rep)+'</span>';
  (n.tags||[]).forEach(t=>h+='<span class="chipacc note">'+esc(t)+'</span>');
  if(n.retire) h+='<span class="chipacc retire">'+esc(n.retire)+'</span>';
  h+=accChip(n.a);
  if(n.c) h+='<span class="chipacc cs">Coming</span>';
  return h;
}
function actBtn([label,to,f={}]){
  const cls='act'+(f.sec?' sec':'')+(f.c?' c':'')+(f.inert?' inert':'');
  const icn=f.a===IFRC?ic('lock',11,2.6):f.a===LOGIN?ic('user',11,2.6):f.a===PERM?ic('key',11,2.6):'';
  const go=(f.self||f.inert)?'':to;
  const tgt=byId[to];
  const title=go?' title="Go to '+esc(tgt?tgt.t:to)+'"':'';
  return '<button type="button" class="'+cls+'" data-go="'+go+'"'+title+(f.inert?' tabindex="-1"':'')+'>'+esc(label)+(icn?' '+icn:'')+(f.ext?ic('external',11,2.4):'')+'</button>';
}
function card(n,extra=''){
  let h='<article class="node k-'+n.k+(n.c?' coming':'')+(n.rep?' rep':'')+(n.big?' big':'')+extra+'" id="'+n.id+'" data-id="'+n.id+'">';
  h+='<div class="n-top">'+metaChips(n)+'</div>';
  if(n.eb&&n.eb!==n.t) h+='<p class="eyebrow">'+esc(n.eb)+'</p>';
  h+='<h3><button type="button" data-sel="'+n.id+'">'+esc(n.t)+'</button></h3>';
  if(n.sc){ const t=byId[n.to]; h+='<div class="sc-to">'+ic('shortcut',13,2.2)+'<span>Same page as <b>'+esc(SECTIONS.find(s=>s.id===t.s).name+' › '+pathOf(t).map(x=>x.t).join(' › '))+'</b></span></div>' }
  else if(n.d) h+='<p class="d">'+esc(n.d)+'</p>';
  if(n.chips) h+='<div class="chips">'+n.chips.map(c=>'<span class="chip">'+esc(c)+'</span>').join('')+'</div>';
  if(n.steps) h+='<ol class="steps">'+n.steps.map(s=>'<li>'+esc(s)+'</li>').join('')+'</ol>';
  const acts=n.acts.filter(a=>!(a[2]&&a[2].self&&!a[2].inert&&a[0]!=='Export'));
  if(acts.length) h+='<div class="acts">'+acts.map(actBtn).join('')+'</div>';
  return h+'</article>';
}
const isGroup=n=>n.kids.length&&n.kids.every(k=>k.k==='subtab');
function tabgroup(n){
  return '<div class="tabgroup'+(n.c?' coming':'')+'" style="--n:'+Math.max(1,Math.min(n.kids.length,3))+'">'+card(n)+'<div class="tg-rail"><span class="tg-label">Sub-tabs</span></div><div class="tg-kids">'+n.kids.map(k=>card(k)).join('')+'</div></div>';
}
function renderList(list){
  let h='',row='';
  const flush=()=>{ if(row){ h+='<div class="row">'+row+'</div>'; row='' } };
  list.forEach(n=>{
    if(!n.kids.length) row+=card(n);
    else if(isGroup(n)) row+=tabgroup(n);
    else { flush(); h+='<div class="branch">'+card(n)+'<div class="kids">'+renderList(n.kids)+'</div></div>' }
  });
  flush(); return h;
}

// ---------- Render sections ----------
const main=document.getElementById('main');
main.innerHTML=SECTIONS.map(s=>'<section class="section" id="sec-'+s.id+'" aria-labelledby="h-'+s.id+'"><div class="sec-head"><span class="sec-ic">'+ic(s.icon,26,2)+'</span><div><div class="eb">'+esc(s.eb)+'</div><h2 id="h-'+s.id+'">'+esc(s.name)+'</h2></div><p>'+esc(s.d)+'</p></div><div class="tree">'+renderList(N.filter(n=>n.s===s.id&&!n.p))+'</div></section>').join('');
document.getElementById('secnav').innerHTML=SECTIONS.map(s=>'<a href="#sec-'+s.id+'" data-sec="'+s.id+'">'+esc(s.name)+'</a>').join('');

// ---------- Stats ----------
const real=N.filter(n=>n.k!=='shortcut'&&n.k!=='menu');
const live=real.filter(n=>!n.c), up=real.filter(n=>n.c);
const links=N.reduce((a,n)=>a+n.acts.filter(x=>!(x[2]&&(x[2].self||x[2].inert))).length,0);
document.getElementById('stats').innerHTML=
 '<div class="stat"><strong>'+live.filter(n=>n.k!=='form').length+'</strong><span>Live pages, tabs & views</span></div>'+
 '<div class="stat"><strong>'+live.filter(n=>n.k==='form').length+'</strong><span>Live forms</span></div>'+
 '<div class="stat"><strong>'+links+'</strong><span>Links traced</span></div>'+
 '<div class="stat up"><strong>'+up.length+'</strong><span>Upcoming</span></div>';

// ---------- Sitemap ----------
function smCol(c,i){
  let h='<div class="sm-col'+(i===0?' first':'')+'" style="grid-column:span '+(c.sp||1)+'"><button type="button" class="sm-top" data-go="'+c.go+'"><span class="ic">'+ic(c.icon,14,2.2)+'</span>'+esc(c.t)+(c.lock?'<span class="lock">'+accChip(LOGIN)+'</span>':'')+'</button>';
  if(c.note) h+='<div class="sm-note">'+esc(c.note)+'</div>';
  c.groups.forEach(([sub,links])=>{
    if(sub) h+='<div class="sm-sub">'+esc(sub)+'</div>';
    links.forEach(([label,to,f={}])=>{
      const cls='sm-link'+(f.dd?' dd':'')+(f.act?' sm-act':'')+(f.plain||!to?' plain':'');
      const tag=(f.tag?'<span class="tag">'+esc(f.tag)+'</span>':'')+(f.rep?'<span class="tag rep">↺ '+esc(f.rep)+'</span>':'')+(f.ifrc?'<span class="tag ifrc">IFRC only</span>':'')+(f.ext?'<span class="tag">↗ External</span>':'');
      h+=to&&!f.plain?'<button type="button" class="'+cls+'" data-go="'+to+'">'+esc(label)+tag+'</button>':'<span class="'+cls+'">'+esc(label)+'</span>';
    });
  });
  return h+'</div>';
}
document.getElementById('sitemap').innerHTML=
 '<div class="sm-zlabel" style="--span:11">'+ic('menu',12,2.4)+'Main menu</div>'+SM[0].cols.map(smCol).join('')+
 '<div class="sm-zlabel" style="--span:9">'+ic('menu',12,2.4)+'Top bar</div><div class="sm-zlabel foot" style="--span:2">'+ic('doc',12,2.4)+'Footer</div>'+
 SM[1].cols.map(smCol).join('')+SM[2].cols.map(c=>smCol(c,1)).join('');

// ---------- Selection / tracing ----------
const panel=document.getElementById('panel');
let current=null;
function clearMarks(){ document.querySelectorAll('.node.sel,.node.lin,.node.lout').forEach(e=>e.classList.remove('sel','lin','lout')) }
function secName(n){ return SECTIONS.find(s=>s.id===n.s).name }
function lk(n,label,dir,c){
  return '<button type="button" class="lk '+dir+(c||n.c?' c':'')+'" data-go="'+n.id+'"><span class="dir">'+ic(dir==='in'?'back':'arrow',14,2.4)+'</span><span><b>'+esc(n.t)+'</b><small>'+esc(label)+' · '+esc(secName(n))+'</small></span></button>';
}
function goUrl(n){
  if(n.ext===true) return '<div class="p-url"><small>Opens outside GO'+(n.extLabel?' · '+esc(n.extLabel):'')+'</small></div>';
  if(n.ext) return '<div class="p-url"><small>Opens outside GO'+(n.extLabel?' · '+esc(n.extLabel):'')+'</small><a href="'+esc(n.ext)+'" target="_blank" rel="noopener">'+esc(n.ext.replace('https://',''))+' ↗</a></div>';
  if(n.links) return '<div class="p-url"><small>Opens outside GO</small>'+n.links.map(([l,u])=>'<a href="'+esc(u)+'" target="_blank" rel="noopener">'+esc(l)+' ↗</a>').join('')+'</div>';
  if(n.urlNote) return '<div class="p-url"><small>Addresses on GO</small><code>'+esc(n.urlNote)+'</code></div>';
  if(!n.url) return n.c?'<div class="p-url"><small>Not live yet. No address on GO.</small></div>':'';
  if(n.url.includes(':')) return '<div class="p-url"><small>Address pattern on GO (one per '+esc(n.url.match(/:(\w+)/)[1].replace(/Id$/,''))+')</small><code>go.ifrc.org'+esc(n.url)+'</code></div>';
  return '<div class="p-url"><small>Open on GO</small><a href="'+GO+esc(n.url)+'" target="_blank" rel="noopener">go.ifrc.org'+esc(n.url)+' ↗</a></div>';
}
function select(id,{scroll=true}={}){
  const n=byId[id]; if(!n) return;
  current=id; clearMarks();
  const el=document.getElementById(id);
  const outs=n.acts.filter(a=>!(a[2]&&(a[2].self||a[2].inert))).map(a=>({n:byId[a[1]],label:a[0],f:a[2]||{}})).filter(x=>x.n&&x.n.id!==id);
  const ins=inbound[id].map(x=>({n:byId[x.from],label:x.label,f:x.f}));
  const mins=menuIn[id]||[];
  el&&el.classList.add('sel');
  outs.forEach(o=>{const e=document.getElementById(o.n.id); e&&e.classList.add('lout')});
  ins.forEach(o=>{const e=document.getElementById(o.n.id); e&&e.classList.add('lin')});
  document.body.classList.add('tracing');
  const path=pathOf(n), sec=SECTIONS.find(s=>s.id===n.s);
  document.getElementById('pc').innerHTML='<span>'+esc(sec.eb)+' › '+esc(sec.name)+'</span>'+path.slice(0,-1).map(p=>' › <button type="button" data-go="'+p.id+'">'+esc(p.t)+'</button>').join('');
  document.getElementById('pt').textContent=n.t;
  document.getElementById('pm').innerHTML=metaChips(n);
  let b='';
  if(n.d) b+='<p>'+esc(n.d)+'</p>';
  b+=goUrl(n);
  if(n.chips) b+='<div class="p-sec"><h3>'+(n.k==='list'?'Lists':n.k==='dropdown'?'Options':'Includes')+' <b>'+n.chips.length+'</b></h3><div class="chips" style="margin:0">'+n.chips.map(c=>'<span class="chip">'+esc(c)+'</span>').join('')+'</div></div>';
  const inerts=n.acts.filter(a=>a[2]&&a[2].inert);
  if(inerts.length) b+='<div class="p-sec"><h3>Actions on this page <b>'+inerts.length+'</b></h3><div class="acts" style="margin:0">'+inerts.map(actBtn).join('')+'</div></div>';
  b+='<div class="p-sec"><h3>Leads to <b>'+outs.length+'</b></h3>'+(outs.length?'<div class="lks">'+outs.map(o=>lk(o.n,o.label,'out',o.f.c)).join('')+'</div>':'<div class="p-empty">No onward links from this '+kindLabel[n.k].toLowerCase()+'.</div>')+'</div>';
  const inAll=ins.length+mins.length;
  b+='<div class="p-sec"><h3>Reached from <b>'+inAll+'</b></h3>'+(inAll?'<div class="lks">'+mins.map(m=>'<div class="lk in menu" style="cursor:default"><span class="dir">'+ic('menu',14,2.4)+'</span><span><b>Navigation menu</b><small>'+esc(m)+'</small></span></div>').join('')+ins.map(o=>lk(o.n,o.label,'in',o.f.c)).join('')+'</div>':'<div class="p-empty">'+(n.p?'Reached through its parent: '+esc(byId[n.p].t)+'.':'No other links point here.')+'</div>')+'</div>';
  if(n.kids.length) b+='<div class="p-sec"><h3>'+(isGroup(n)?'Sub-tabs':'Tabs & child pages')+' <b>'+n.kids.length+'</b></h3><div class="lks">'+n.kids.map(k=>lk(k,kindLabel[k.k],'out',k.c)).join('')+'</div></div>';
  if(n.steps) b+='<div class="p-sec"><h3>Steps <b>'+n.steps.length+'</b></h3><ol class="steps">'+n.steps.map(s=>'<li>'+esc(s)+'</li>').join('')+'</ol></div>';
  document.getElementById('pb').innerHTML=b;
  document.getElementById('pb').scrollTop=0;
  document.getElementById('plink').value=location.href.split('#')[0]+'#'+id;
  panel.classList.add('open'); panel.setAttribute('aria-hidden','false');
  try{ history.replaceState(null,'','#'+id) }catch(e){}
  if(scroll&&el){ el.scrollIntoView({behavior:matchMedia('(prefers-reduced-motion: reduce)').matches?'auto':'smooth',block:'center'}); el.classList.remove('flash'); void el.offsetWidth; el.classList.add('flash') }
}
function closePanel(){ current=null; clearMarks(); document.body.classList.remove('tracing'); panel.classList.remove('open'); panel.setAttribute('aria-hidden','true'); try{ history.replaceState(null,'',location.pathname+location.search) }catch(e){} }
document.getElementById('px').addEventListener('click',closePanel);

// Legend
const lgbtn=document.getElementById('lgbtn'), legend=document.getElementById('legend');
function setLegend(open){ legend.hidden=!open; lgbtn.setAttribute('aria-expanded',String(open)) }
lgbtn.addEventListener('click',e=>{ e.stopPropagation(); setLegend(legend.hidden) });
document.addEventListener('keydown',e=>{ if(e.key==='Escape'){ if(!legend.hidden) setLegend(false); else if(current) closePanel() } });

document.addEventListener('click',e=>{
  if(!legend.hidden&&!e.target.closest('#legend')) setLegend(false);
  const go=e.target.closest('[data-go]');
  if(go&&go.dataset.go){ e.stopPropagation(); select(go.dataset.go); return }
  const sel=e.target.closest('[data-sel]');
  if(sel){ select(sel.dataset.sel,{scroll:false}); return }
  const c=e.target.closest('.node');
  if(c&&!e.target.closest('button')){ select(c.dataset.id,{scroll:false}); return }
  if(current&&!e.target.closest('.panel')&&!e.target.closest('.bar')&&!e.target.closest('.sitemap')) closePanel();
});

// Copy link
document.getElementById('pcopy').addEventListener('click',function(){
  const inp=document.getElementById('plink'), btn=this;
  const done=()=>{btn.textContent='Copied';setTimeout(()=>btn.textContent='Copy link',1400)};
  const fallback=()=>{ inp.focus(); inp.select() };
  try{ navigator.clipboard.writeText(inp.value).then(done,fallback) }catch(e){ fallback() }
});

// View toggle
let VIEW='all';
try{ const v=localStorage.getItem('go-ia-view'); if(v) VIEW=v }catch(e){}
function setView(v){
  VIEW=v;
  document.body.classList.toggle('live-only',v==='live');
  document.body.classList.toggle('upcoming-only',v==='upcoming');
  document.querySelectorAll('.seg button').forEach(b=>b.setAttribute('aria-pressed',String(b.dataset.view===v)));
  try{ localStorage.setItem('go-ia-view',v) }catch(e){}
}
document.querySelectorAll('.seg button').forEach(b=>b.addEventListener('click',()=>setView(b.dataset.view)));
setView(VIEW);

// Search
const q=document.getElementById('q'), qn=document.getElementById('qn');
const hay={}; N.forEach(n=>hay[n.id]=[n.t,n.d,n.eb,(n.chips||[]).join(' '),(n.steps||[]).join(' '),(n.tags||[]).join(' '),n.acts.map(a=>a[0]).join(' ')].join(' ').toLowerCase());
let hits=[];
q.addEventListener('input',()=>{
  const v=q.value.trim().toLowerCase();
  document.querySelectorAll('.node.hit').forEach(e=>e.classList.remove('hit'));
  if(!v){ document.body.classList.remove('searching'); qn.textContent=''; hits=[]; return }
  hits=N.filter(n=>hay[n.id].includes(v)).map(n=>n.id);
  hits.forEach(id=>document.getElementById(id).classList.add('hit'));
  document.body.classList.add('searching'); qn.textContent=hits.length;
});
q.addEventListener('keydown',e=>{ if(e.key==='Enter'&&hits.length){ e.preventDefault(); const id=hits.shift(); hits.push(id); select(id) } if(e.key==='Escape'){ q.value=''; q.dispatchEvent(new Event('input')) } });

// Section nav highlight
const navLinks=[...document.querySelectorAll('.secnav a')];
if('IntersectionObserver' in window){
  const io=new IntersectionObserver(es=>es.forEach(en=>{ if(en.isIntersecting){ const id=en.target.id.slice(4); navLinks.forEach(a=>a.classList.toggle('on',a.dataset.sec===id)) } }),{rootMargin:'-40% 0px -55% 0px'});
  document.querySelectorAll('.section').forEach(s=>io.observe(s));
}

// Deep link
const h=location.hash.slice(1);
if(h&&byId[h]) setTimeout(()=>select(h),150);
})();
