(function(){
  const $ = (s, r=document) => r.querySelector(s);
  const $$ = (s, r=document) => Array.from(r.querySelectorAll(s));

  if (!$('.container')) {
    const container = document.createElement('div');
    container.className = 'container';
    // On met tout le body dedans (sauf scripts)
    const nodes = Array.from(document.body.childNodes);
    container.append(...nodes);
    document.body.appendChild(container);
  }

  if (!$('.topbar')) {
    const topbar = document.createElement('div');
    topbar.className = 'topbar';
    topbar.innerHTML = `
      <div class="container">
        <div class="header">
          <div class="title">
            <h1>${document.title || 'Concordances'}</h1>
            <div class="meta" id="metaLine"></div>
          </div>
          <div class="actions">
            <button class="btn" id="prevBtn" title="Précédent (Shift+N)"><span>◀</span><kbd>⇧N</kbd></button>
            <button class="btn" id="nextBtn" title="Suivant (N)"><span>▶</span><kbd>N</kbd></button>
            <button class="btn" id="toggleCooc" title="Afficher/masquer cooccurrents"><span>Cooc</span></button>
          </div>
        </div>
      </div>
    `;
    document.body.prepend(topbar);
  }

  const marks = $$('mark');
  const toast = document.createElement('div');
  toast.className = 'toast';
  document.body.appendChild(toast);

  function say(msg){
    toast.textContent = msg;
    toast.classList.add('show');
    setTimeout(()=>toast.classList.remove('show'), 1200);
  }

  let pre = $('pre');
  if (!pre) {
    const allText = document.body.innerText;
    pre = document.createElement('pre');
    pre.className = 'kwic';
    pre.textContent = allText;
    document.body.innerHTML = '';
    document.body.appendChild(pre);
  }
  pre.classList.add('kwic');

  if (!$('.card')) {
    const wrap = document.createElement('div');
    wrap.className = 'grid';
    wrap.innerHTML = `
      <div class="card">
        <div class="card-h">
          <div class="badge" id="hitCount"></div>
          <div class="pager">
            <span class="count" id="pos"></span>
          </div>
        </div>
        <div class="card-b">
          <div class="search">
            <input id="q" type="search" placeholder="Rechercher dans la page… (ex: سعيد)" autocomplete="off"/>
            <button class="btn" id="clear">Effacer</button>
          </div>
          <div style="height:12px"></div>
        </div>
      </div>
    `;
    const container = $('.container') || document.body;
    container.appendChild(wrap);

    const cardB = $('.card .card-b');
    cardB.appendChild(pre);

    const urlLine = $$('p').find(p => /URL\s*:/i.test(p.textContent))?.textContent;
    $('#metaLine').textContent = urlLine ? urlLine : '';
  }

  let idx = -1;
  const hitCount = $('#hitCount');
  const pos = $('#pos');

  function updateUI(){
    const total = marks.length;
    hitCount.textContent = total ? `Occurrences surlignées: ${total}` : 'Aucune occurrence surlignée';
    pos.textContent = total && idx>=0 ? `${idx+1}/${total}` : '';
  }

  function focus(i){
    if (!marks.length) return;
    marks.forEach(m => m.classList.remove('hit'));
    idx = (i + marks.length) % marks.length;
    const m = marks[idx];
    m.classList.add('hit');
    m.scrollIntoView({behavior:'smooth', block:'center'});
    updateUI();
  }

  $('#nextBtn')?.addEventListener('click', ()=>focus(idx+1));
  $('#prevBtn')?.addEventListener('click', ()=>focus(idx-1));

  document.addEventListener('keydown', (e)=>{
    if (e.key.toLowerCase() === 'n' && !e.shiftKey) { e.preventDefault(); focus(idx+1); }
    if (e.key.toLowerCase() === 'n' && e.shiftKey) { e.preventDefault(); focus(idx-1); }
    if (e.key === 'Escape') { $('#q').value=''; highlightSearch(''); }
  });

  const input = $('#q');
  let originalHTML = pre.innerHTML;

  function escapeRegExp(s){ return s.replace(/[.*+?^${}()|[\]\\]/g, '\\$&'); }

  function highlightSearch(q){
    pre.innerHTML = originalHTML;
    if (!q) { updateUI(); return; }
    const re = new RegExp(escapeRegExp(q), 'g');
    pre.innerHTML = pre.innerHTML.replace(re, (m)=>`<mark class="cooc">${m}</mark>`);
    say(`Recherche: ${q}`);
  }

  input?.addEventListener('input', ()=>highlightSearch(input.value.trim()));
  $('#clear')?.addEventListener('click', ()=>{ input.value=''; highlightSearch(''); });

  let coocOn = true;
  $('#toggleCooc')?.addEventListener('click', ()=>{
    coocOn = !coocOn;
    $$('mark.cooc').forEach(m => m.style.display = coocOn ? 'inline' : 'inline');
    say(coocOn ? 'Cooc: ON' : 'Cooc: OFF');
  });

  updateUI();
  if (marks.length) focus(0);
})();

