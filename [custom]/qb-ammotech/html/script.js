window.addEventListener("message", function (event) {
  if (event.data.action === "open") {
    $("#container").fadeIn(200);
    renderRecipes(event.data.recipes, event.data.station);
  }
});

function renderRecipes(recipes, currentStation) {
  let html = "";
  let hasItems = false;

  for (let key in recipes) {
    let item = recipes[key];

    if (item.station === currentStation) {
      hasItems = true;

      let materialsHtml = "";
      item.items.forEach((mat) => {
        materialsHtml += `<div>• ${mat.amount}x ${mat.label}</div>`;
      });

      html += `
        <div class="ammo-card">
          <h3>${item.label}</h3>
          <div class="recipe-requirements">
            ${materialsHtml}
          </div>
          <button class="craft-btn" onclick="startCraft('${key}')">FABRICAR</button>
        </div>
      `;
    }
  }

  if (!hasItems) {
    $("#recipe-list").html(
      "<h3 style='color:#666; width:100%; text-align:center;'>Nenhuma receita disponível nesta máquina.</h3>"
    );
  } else {
    $("#recipe-list").html(html);
  }
}

function startCraft(name) {
  $.post(`https://qb-ammotech/startCrafting`, JSON.stringify({ weapon: name }));
  closeUI();
}

function closeUI() {
  $("#container").fadeOut(200);
  $.post(`https://qb-ammotech/close`);
}

document.onkeyup = function (data) {
  if (data.which == 27) {
    closeUI();
  }
};
