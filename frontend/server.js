import express from "express";
import path from "path";
import { fileURLToPath } from "url";

const app = express();
const PORT = 3000;

// Correction du chemin de base (nécessaire pour les modules ES)
const __filename = fileURLToPath(import.meta.url);
const __dirname = path.dirname(__filename);

// Servir les fichiers statiques du dossier public
app.use(express.static(path.join(__dirname, "public")));

// Route principale
app.get("/", (req, res) => {
  res.sendFile(path.join(__dirname, "public", "index.html"));
});

app.listen(PORT, () => {
  console.log(`Frontend Node.js démarré sur http://localhost:${PORT}`);
});
