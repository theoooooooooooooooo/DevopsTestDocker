async function chargerSalles() {
  const container = document.getElementById("sallesContainer");
  container.innerHTML = '<p class="text-center">Chargement des salles...</p>';

  try {
    const response = await fetch("http://localhost:8080/salles");
    if (!response.ok) throw new Error("Erreur HTTP " + response.status);
    const salles = await response.json();

    container.innerHTML = ""; // On vide avant d'ajouter les cartes

    salles.forEach((salle) => {
      const col = document.createElement("div");
      col.className = "col-12 col-md-6 col-lg-4";

      const dispoClass = salle.disponible ? "success" : "danger";
      const dispoText = salle.disponible ? "Disponible" : "Occupée";

      col.innerHTML = `
        <div class="card h-100">
          <div class="card-body">
            <h5 class="card-title text-primary">${salle.nom}</h5>
            <p class="card-text">
              <strong>Capacité :</strong> ${salle.capacite} personnes<br/>
              <strong>Équipements :</strong> ${salle.equipement || "Aucun"}<br/>
            </p>
            <span class="badge bg-${dispoClass}">${dispoText}</span>
          </div>
          <div class="card-footer text-muted small">
            Créée le ${new Date(salle.created_at).toLocaleDateString("fr-FR")}
          </div>
        </div>
      `;

      container.appendChild(col);
    });
  } catch (error) {
    console.error(error);
    container.innerHTML = `<div class="alert alert-danger text-center">
      Impossible de charger les salles (${error.message})
    </div>`;
  }
}

document.addEventListener("DOMContentLoaded", chargerSalles);


// Charger les salles au démarrage
chargerSalles();

// async function chargerSalles() {
//   const container = document.getElementById("sallesContainer");
//   container.innerHTML = '<p class="text-center">Chargement des salles...</p>';

//   try {
//     // 👉 Appel relatif (plus de localhost, ni de port)
//     const response = await fetch("/salles");
//     if (!response.ok) throw new Error("Erreur HTTP " + response.status);

//     const salles = await response.json();
//     container.innerHTML = "";

//     salles.forEach((salle) => {
//       const col = document.createElement("div");
//       col.className = "col-12 col-md-6 col-lg-4";

//       const dispoClass = salle.disponible ? "success" : "danger";
//       const dispoText = salle.disponible ? "Disponible" : "Occupée";

//       col.innerHTML = `
//         <div class="card h-100">
//           <div class="card-body">
//             <h5 class="card-title text-primary">${salle.nom}</h5>
//             <p class="card-text">
//               <strong>Capacité :</strong> ${salle.capacite} personnes<br/>
//               <strong>Équipements :</strong> ${salle.equipement || "Aucun"}<br/>
//             </p>
//             <span class="badge bg-${dispoClass}">${dispoText}</span>
//           </div>
//           <div class="card-footer text-muted small">
//             Créée le ${new Date(salle.created_at).toLocaleDateString("fr-FR")}
//           </div>
//         </div>
//       `;
//       container.appendChild(col);
//     });
//   } catch (error) {
//     console.error(error);
//     container.innerHTML = `<div class="alert alert-danger text-center">
//       Impossible de charger les salles (${error.message})
//     </div>`;
//   }
// }

// document.addEventListener("DOMContentLoaded", chargerSalles);
