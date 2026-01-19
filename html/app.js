let fee = 0.0;
let black = 0;
let cops = 0;

const app = document.getElementById('app');
const closeBtn = document.getElementById('closeBtn');
const confirmBtn = document.getElementById('confirmBtn');
const amountInput = document.getElementById('amountInput');

const blackValue = document.getElementById('blackValue');
const feeValue = document.getElementById('feeValue');
const copsValue = document.getElementById('copsValue');

const fromBox = document.getElementById('fromBox');
const toBox = document.getElementById('toBox');
const swapIcon = document.getElementById('swapIcon');

const presetButtons = [
  document.getElementById('p1'),
  document.getElementById('p2'),
  document.getElementById('p3'),
];

function fmtMoney(n){
  n = Math.max(0, Math.floor(Number(n) || 0));
  return n.toLocaleString('de-DE') + '$';
}

function setActivePreset(btn){
  presetButtons.forEach(b => b.classList.remove('active'));
  if (btn) btn.classList.add('active');
}

function compute(){
  const amt = Math.max(0, Math.floor(Number(amountInput.value) || 0));
  fromBox.textContent = fmtMoney(amt);
  const payout = Math.floor(amt * (1.0 - fee));
  toBox.textContent = fmtMoney(payout);
}

function openUI(data){
  app.classList.remove('hidden');

  black = data.black || 0;
  cops = data.cops || 0;
  fee = data.fee || 0.0;

  blackValue.textContent = fmtMoney(black);
  feeValue.textContent = Math.round(fee * 100) + '%';
  copsValue.textContent = String(cops);

  // presets text if server sends custom
  if (data.presets && data.presets.length === 3){
    presetButtons[0].dataset.amt = data.presets[0];
    presetButtons[1].dataset.amt = data.presets[1];
    presetButtons[2].dataset.amt = data.presets[2];
    presetButtons[0].textContent = fmtMoney(data.presets[0]).replace('$','') + '$';
    presetButtons[1].textContent = fmtMoney(data.presets[1]).replace('$','') + '$';
    presetButtons[2].textContent = fmtMoney(data.presets[2]).replace('$','') + '$';
  }

  setActivePreset(null);
  amountInput.value = '';
  fromBox.textContent = '0$';
  toBox.textContent = '0$';
}

function refreshUI(data){
  black = data.black ?? black;
  cops = data.cops ?? cops;
  fee = data.fee ?? fee;

  blackValue.textContent = fmtMoney(black);
  feeValue.textContent = Math.round(fee * 100) + '%';
  copsValue.textContent = String(cops);

  compute();
}

function closeUI(){
  app.classList.add('hidden');
  swapIcon.classList.remove('rotate');
  setActivePreset(null);
  amountInput.value = '';
  fromBox.textContent = '0$';
  toBox.textContent = '0$';
}

window.addEventListener('message', (event) => {
  const data = event.data;
  if (!data || !data.action) return;

  if (data.action === 'open') openUI(data);
  if (data.action === 'close') closeUI();
  if (data.action === 'refresh') refreshUI(data);
});

closeBtn.addEventListener('click', () => {
  fetch(`https://${GetParentResourceName()}/close`, {
    method: 'POST',
    headers: {'Content-Type': 'application/json; charset=UTF-8'},
    body: JSON.stringify({})
  });
});

document.addEventListener('keydown', (e) => {
  if (e.key === 'Escape') {
    fetch(`https://${GetParentResourceName()}/close`, {
      method: 'POST',
      headers: {'Content-Type': 'application/json; charset=UTF-8'},
      body: JSON.stringify({})
    });
  }
});

presetButtons.forEach(btn => {
  btn.addEventListener('click', () => {
    const amt = Number(btn.dataset.amt || 0);
    amountInput.value = Math.floor(amt);
    setActivePreset(btn);
    compute();
  });
});

amountInput.addEventListener('input', () => {
  setActivePreset(null);
  compute();
});

confirmBtn.addEventListener('click', async () => {
  const amt = Math.max(0, Math.floor(Number(amountInput.value) || 0));
  if (amt <= 0) return;

  // simple client-side check
  if (amt > black) {
    // keep UI silent as in the style; server will reject anyway
  }

  swapIcon.classList.add('rotate');

  try{
    const res = await fetch(`https://${GetParentResourceName()}/wash`, {
      method: 'POST',
      headers: {'Content-Type': 'application/json; charset=UTF-8'},
      body: JSON.stringify({ amount: amt })
    });

    const json = await res.json();
    // stop rotation when server answered
    swapIcon.classList.remove('rotate');

    // if ok, keep amount but update numbers will come from refresh
    if (!json.ok){
      // optional: could show toast; intentionally kept minimal
    }
  } catch (e){
    swapIcon.classList.remove('rotate');
  }
});

window.addEventListener('DOMContentLoaded', () => {
  // sicherheitshalber immer unsichtbar starten
  document.body.style.background = 'transparent';
});
