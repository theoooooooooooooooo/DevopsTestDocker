  // import express from "express";
  // import path from "path";
  // import { fileURLToPath } from "url";

  // const app = express();

  // // Récupérer le port depuis Render ou fallback à 3000 pour dev local
  // const PORT = process.env.PORT || 3000;

  // // Correction du chemin de base (nécessaire pour les modules ES)
  // const __filename = fileURLToPath(import.meta.url);
  // const __dirname = path.dirname(__filename);

  // // Servir les fichiers statiques du dossier public
  // app.use(express.static(path.join(__dirname, "public")));

  // // Route principale
  // app.get("/", (req, res) => {
  //   res.sendFile(path.join(__dirname, "public", "index.html"));
  // });

  // // Écouter sur 0.0.0.0 pour que Render puisse forwarder le trafic
  // app.listen(PORT, "0.0.0.0", () => {
  //   console.log(`Frontend Node.js démarré sur http://0.0.0.0:${PORT}`);
  // });

  import express from "express";
import path from "path";
import { fileURLToPath } from "url";
import { createProxyMiddleware } from "http-proxy-middleware";

const app = express();
const PORT = process.env.PORT || 10000;

const __filename = fileURLToPath(import.meta.url);
const __dirname = path.dirname(__filename);

// Proxy des routes API vers le backend interne (Apache)
app.use(
  "/salles",
  createProxyMiddleware({
    target: "http://127.0.0.1:8080",
    changeOrigin: true,
  })
);

// Fichiers statiques frontend
app.use(express.static(path.join(__dirname, "public")));

// Route principale
app.get("/", (req, res) => {
  res.sendFile(path.join(__dirname, "public", "index.html"));
});

app.listen(PORT, "0.0.0.0", () => {
  console.log(`Frontend + proxy backend démarré sur http://0.0.0.0:${PORT}`);
});
