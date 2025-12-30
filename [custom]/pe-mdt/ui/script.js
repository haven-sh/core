window.addEventListener('message', function(event) {
    if (event.data.action === "abrir") {
        document.body.style.display = "flex";
        document.getElementById('nome-policia').innerText = event.data.nomeOficial;
        document.getElementById('cargo-policia').innerText = event.data.cargoOficial || "OFICIAL";
        voltarPesquisa();
    }
});

// ==========================================
// SISTEMA DE MULTAS (NOVO)
// ==========================================

function prepararMulta() {
    document.getElementById('modal-multa').style.display = "block";
    
    // Puxa a lista de crimes do servidor para o Select
    fetch(`https://${GetParentResourceName()}/getListaCrimes`, {
        method: 'POST',
        headers: { 'Content-Type': 'application/json' },
        body: JSON.stringify({})
    }).then(resp => resp.json()).then(crimes => {
        let select = document.getElementById('select-crimes');
        select.innerHTML = '<option value="" selected disabled>Escolher Infração...</option>';
        crimes.forEach(c => {
            select.innerHTML += `<option value="${c.multa}" data-label="${c.label}">${c.label}</option>`;
        });
    });
}

function atualizarValorMulta() {
    let select = document.getElementById('select-crimes');
    if (!select.value) return;
    
    // Preenche o valor e o motivo automaticamente com base na seleção
    document.getElementById('valor-multa').value = select.value;
    document.getElementById('motivo-multa').value = select.options[select.selectedIndex].getAttribute('data-label');
}

function confirmarMulta() {
    const cid = document.getElementById('ficha-cid').innerText;
    const valor = document.getElementById('valor-multa').value;
    const motivo = document.getElementById('motivo-multa').value;

    if (valor === "" || motivo === "") return;

    fetch(`https://${GetParentResourceName()}/aplicarMulta`, {
        method: 'POST',
        headers: { 'Content-Type': 'application/json' },
        body: JSON.stringify({ cid: cid, valor: valor, motivo: motivo })
    }).then(() => {
        document.getElementById('modal-multa').style.display = "none";
        // Limpa os campos para a próxima
        document.getElementById('valor-multa').value = "";
        document.getElementById('motivo-multa').value = "";
        // Atualiza a ficha para a multa aparecer no histórico criminal
        verFicha(cid, document.getElementById('ficha-nome').innerText);
    });
}

// ==========================================
// LISTA DE UNIDADES
// ==========================================

function abrirUnidades() {
    document.getElementById('tab-pesquisa').style.display = "none";
    document.getElementById('ficha-detalhes').style.display = "none";
    document.getElementById('tab-mandados').style.display = "none";
    
    const abaUnidades = document.getElementById('tab-unidades');
    if (abaUnidades) abaUnidades.style.display = "block";

    let container = document.getElementById('lista-unidades-corpo');
    container.innerHTML = '<p style="text-align:center; color:#888;">A atualizar unidades...</p>';

    fetch(`https://${GetParentResourceName()}/getUnidades`, {
        method: 'POST',
        headers: { 'Content-Type': 'application/json' },
        body: JSON.stringify({})
    }).then(resp => resp.json()).then(data => {
        container.innerHTML = "";
        if (data && data.length > 0) {
            data.forEach(u => {
                container.innerHTML += `
                    <div class="pessoa-card" style="display:flex; justify-content:space-between; align-items:center; border-left: 3px solid #00f2ff; margin-bottom: 10px; background: rgba(255,255,255,0.02); padding: 15px;">
                        <div>
                            <strong style="color:#00f2ff; font-size: 16px;">${u.nome}</strong><br>
                            <small style="color: #eee;">${u.cargo} | Rádio: ${u.callsign}</small>
                        </div>
                        <div style="width:10px; height:10px; background:#2ecc71; border-radius:50%; box-shadow:0 0 8px #2ecc71;"></div>
                    </div>`;
            });
        } else {
            container.innerHTML = '<p style="text-align:center; color:#888;">Nenhuma unidade em serviço.</p>';
        }
    });
}

// ==========================================
// PESQUISA E FICHA CRIMINAL
// ==========================================

function buscarPessoa() {
    let valor = document.getElementById('input-busca').value;
    if (valor === "") return;
    fetch(`https://${GetParentResourceName()}/pesquisarPessoa`, {
        method: 'POST',
        headers: { 'Content-Type': 'application/json' },
        body: JSON.stringify({ busca: valor })
    }).then(resp => resp.json()).then(resultados => {
        let container = document.getElementById('resultados-pesquisa');
        container.innerHTML = "";
        resultados.forEach(pessoa => {
            let info = JSON.parse(pessoa.charinfo);
            container.innerHTML += `
                <div class="pessoa-card">
                    <div style="display:inline-block;">
                        <strong style="color:#00f2ff;">${info.firstname} ${info.lastname}</strong><br>
                        <small>CID: ${pessoa.citizenid}</small>
                    </div>
                    <button class="btn-ver-ficha" onclick="verFicha('${pessoa.citizenid}', '${info.firstname} ${info.lastname}')">VER FICHA</button>
                </div>`;
        });
    });
}

function verFicha(citizenid, nomeCompleto) {
    document.getElementById('tab-pesquisa').style.display = "none";
    document.getElementById('tab-mandados').style.display = "none";
    document.getElementById('tab-unidades').style.display = "none";
    document.getElementById('ficha-detalhes').style.display = "block";
   
    document.getElementById('ficha-nome').innerText = nomeCompleto.toUpperCase();
    document.getElementById('ficha-cid').innerText = citizenid;

    fetch(`https://${GetParentResourceName()}/getFicha`, {
        method: 'POST',
        headers: { 'Content-Type': 'application/json' },
        body: JSON.stringify({ cid: citizenid })
    }).then(resp => resp.json()).then(data => {
        if (data.exist) {
            document.getElementById('ficha-nasc').innerText = data.charinfo.birthdate;
            document.getElementById('ficha-phone').innerText = data.charinfo.phone;
            document.getElementById('ficha-nacionalidade').innerText = data.charinfo.nationality;
            document.getElementById('ficha-genero').innerText = (data.charinfo.gender == 0) ? "Masculino" : "Feminino";
            document.getElementById('ficha-banco').innerText = "$" + data.money.toLocaleString();
            document.getElementById('ficha-emprego').innerText = data.jobLabel;
            
            document.getElementById('ficha-mandado').innerText = data.isWarranted ? "PROCURADO" : "LIMPO";
            document.getElementById('ficha-mandado').style.color = data.isWarranted ? "#ff4b2b" : "#2ecc71";
            document.getElementById('ficha-foto').src = data.profile?.image_url || "https://i.imgur.com/83pL77K.png";
            document.getElementById('ficha-notas').value = data.profile?.notes || "";

            let container = document.getElementById('lista-reports');
            container.innerHTML = data.reports?.length > 0 ? "" : "<p style='color:gray; font-size:12px;'>Sem antecedentes.</p>";
            data.reports?.forEach(r => {
                // Se o report tiver multa (fine > 0), mostramos com o valor
                let detalheFicha = r.fine > 0 ? `$${r.fine} - ${r.officer_name}` : r.officer_name;
                container.innerHTML += `
                    <div style="background:rgba(255,0,0,0.1); padding:8px; margin-bottom:5px; border-radius:5px; border-left:3px solid red;">
                        <strong style="color:#ff4b2b; font-size:12px;">${r.title}</strong><br>
                        <small>${detalheFicha}</small>
                    </div>`;
            });
        }
    });
}

// ==========================================
// MANDADOS
// ==========================================

function abrirMandados() {
    document.getElementById('tab-pesquisa').style.display = "none";
    document.getElementById('ficha-detalhes').style.display = "none";
    document.getElementById('tab-unidades').style.display = "none";
    document.getElementById('tab-mandados').style.display = "block";

    fetch(`https://${GetParentResourceName()}/getMandados`, {
        method: 'POST',
        headers: { 'Content-Type': 'application/json' },
        body: JSON.stringify({})
    }).then(resp => resp.json()).then(data => {
        let container = document.getElementById('lista-mandados-corpo');
        container.innerHTML = "";
        if (data && data.length > 0) {
            data.forEach(m => {
                container.innerHTML += `
                    <div class="mandado-item">
                        <div class="mandado-info">
                            <strong>${m.nome}</strong> <small>(CID: ${m.citizenid})</small><br>
                            <span>Motivo: ${m.motivo}</span><br>
                            <small style="opacity:0.7;">Oficial: ${m.oficial}</small>
                        </div>
                        <button class="btn-apagar" onclick="removerMandado(${m.id})">REMOVER</button>
                    </div>`;
            });
        } else {
            container.innerHTML = '<p style="text-align:center; color:#888; margin-top:20px;">Não existem mandados ativos.</p>';
        }
    });
}

function prepararMandado() { document.getElementById('modal-mandado').style.display = "block"; }

function confirmarMandado() {
    let cid = document.getElementById('ficha-cid').innerText;
    let nome = document.getElementById('ficha-nome').innerText;
    let motivo = document.getElementById('motivo-mandado').value;
    if (motivo.trim() === "") return;

    fetch(`https://${GetParentResourceName()}/adicionarMandado`, {
        method: 'POST',
        headers: { 'Content-Type': 'application/json' },
        body: JSON.stringify({ cid: cid, nome: nome, motivo: motivo })
    }).then(() => {
        document.getElementById('modal-mandado').style.display = "none";
        document.getElementById('motivo-mandado').value = "";
        setTimeout(() => { abrirMandados(); }, 300);
    });
}

function removerMandado(id) {
    fetch(`https://${GetParentResourceName()}/removerMandado`, {
        method: 'POST',
        headers: { 'Content-Type': 'application/json' },
        body: JSON.stringify({ id: id })
    }).then(() => { abrirMandados(); });
}

// ==========================================
// NAVEGAÇÃO GERAL
// ==========================================

function voltarPesquisa() {
    document.getElementById('tab-pesquisa').style.display = "block";
    document.getElementById('ficha-detalhes').style.display = "none";
    document.getElementById('tab-mandados').style.display = "none";
    document.getElementById('tab-unidades').style.display = "none";
}

function fecharTablet() {
    document.body.style.display = "none";
    fetch(`https://${GetParentResourceName()}/fechar`, { method: 'POST', body: JSON.stringify({}) });
}