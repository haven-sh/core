const app = document.getElementById('app');
const tabs = document.querySelectorAll('.nav-item');
const contents = document.querySelectorAll('.tab-content');

setInterval(() => {
    const now = new Date();
    document.getElementById('clock').innerText = now.toLocaleTimeString('pt-BR', { hour: '2-digit', minute: '2-digit' });
}, 1000);

tabs.forEach(tab => {
    tab.addEventListener('click', () => {
        tabs.forEach(t => t.classList.remove('active'));
        contents.forEach(c => c.classList.remove('active'));
        tab.classList.add('active');
        document.getElementById(tab.getAttribute('data-tab')).classList.add('active');
    });
});

window.addEventListener('message', function(event) {
    if (event.data.action === "open") {
        app.style.display = 'flex';
    }
});

document.getElementById('close-btn').addEventListener('click', () => {
    app.style.display = 'none';
    fetch(`https://${GetParentResourceName()}/close`, { method: 'POST', body: JSON.stringify({}) });
});

document.getElementById('play-btn').addEventListener('click', () => {
    fetch(`https://${GetParentResourceName()}/playMusic`, {
        method: 'POST',
        body: JSON.stringify({ url: document.getElementById('yt-link').value })
    });
});

document.getElementById('stop-btn').addEventListener('click', () => fetch(`https://${GetParentResourceName()}/stopMusic`, { method: 'POST' }));

document.getElementById('volume-slider').addEventListener('input', (e) => fetch(`https://${GetParentResourceName()}/setVolume`, { method: 'POST', body: JSON.stringify({ volume: e.target.value }) }));

window.setLightMode = (mode) => {
    const r = document.getElementById('color-r').value;
    const g = document.getElementById('color-g').value;
    const b = document.getElementById('color-b').value;
    fetch(`https://${GetParentResourceName()}/updateLights`, {
        method: 'POST',
        body: JSON.stringify({ mode: mode, color: { r: parseInt(r), g: parseInt(g), b: parseInt(b) } })
    });
};
document.querySelectorAll('.color-slider').forEach(s => s.addEventListener('change', () => window.setLightMode('STATIC')));

document.getElementById('screen-toggle').addEventListener('change', (e) => {
    fetch(`https://${GetParentResourceName()}/toggleScreens`, {
        method: 'POST',
        body: JSON.stringify({ state: e.target.checked })
    });
});

document.getElementById('cam-fov').addEventListener('input', (e) => {
    fetch(`https://${GetParentResourceName()}/updateCam`, {
        method: 'POST',
        body: JSON.stringify({ fov: e.target.value })
    });
});

document.getElementById('cam-rot').addEventListener('input', (e) => {
    fetch(`https://${GetParentResourceName()}/updateCam`, {
        method: 'POST',
        body: JSON.stringify({ rot: e.target.value })
    });
});