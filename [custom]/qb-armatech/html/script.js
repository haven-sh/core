window.addEventListener("message", function (event) {
  if (event.data.action === "open") {
    $("#container").fadeIn(200);
    renderWeapons(event.data.recipes, event.data.station);
  }
});

function renderWeapons(recipes, currentStation) {
  let html = "";
  let hasItems = false;

  for (let key in recipes) {
    let weapon = recipes[key];

    if (weapon.station === currentStation) {
      hasItems = true;

      let materialsHtml = "";
      weapon.items.forEach((mat) => {
        materialsHtml += `<div>- ${mat.amount}x ${mat.label}</div>`;
      });

      html += `
                <div class="weapon-card">
                    <h3>${weapon.label}</h3>
                    <div class="recipe-list">
                        <strong>REQUISITOS:</strong>
                        ${materialsHtml}
                    </div>
                    <div style="text-align: right; font-size: 10px; margin-bottom:5px;">
                        <i class="fas fa-clock"></i> ${weapon.craftTime / 1000}s
                    </div>
                    <button class="craft-btn" onclick="startCraft('${key}')">PRODUZIR</button>
                </div>
            `;
    }
  }

  if (!hasItems) {
    $("#weapon-list").html(
      "<h3 style='color:#888; text-align:center; width:100%;'>Esta bancada não processa estes itens.</h3>"
    );
  } else {
    $("#weapon-list").html(html);
  }
}

function startCraft(name) {
  $.post(`https://qb-armatech/startCrafting`, JSON.stringify({ weapon: name }));
  closeUI();
}

function closeUI() {
  $("#container").fadeOut(200);
  $.post(`https://qb-armatech/close`);
}

document.onkeyup = function (data) {
  if (data.which == 27) {
    closeUI();
  }
};
