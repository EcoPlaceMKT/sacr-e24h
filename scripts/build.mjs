// Copie public/ vers dist/ et écrit dist/config.js à partir des variables d'environnement.
// Vercel lance ce script à chaque déploiement (voir vercel.json).
import { cpSync, mkdirSync, rmSync, writeFileSync } from "node:fs";

const url = (process.env.SUPABASE_URL || "").trim();
const anonKey = (process.env.SUPABASE_ANON_KEY || "").trim();

if (!url || !anonKey) {
  console.warn("Il manque SUPABASE_URL et/ou SUPABASE_ANON_KEY : le site affichera « Configuration manquante ».");
  console.warn("Ajoute-les dans Vercel (Settings > Environment Variables), puis redéploie.");
}
if (url && !/^https:\/\/[a-z0-9-]+\.supabase\.co\/?$/i.test(url)) {
  console.warn("Attention : SUPABASE_URL ne ressemble pas à une adresse de projet Supabase (https://xxxx.supabase.co).");
}

rmSync("dist", { recursive: true, force: true });
mkdirSync("dist", { recursive: true });
cpSync("public", "dist", { recursive: true });
writeFileSync(
  "dist/config.js",
  "window.SACREES_CONFIG = " + JSON.stringify({ url: url.replace(/\/$/, ""), anonKey }) + ";\n"
);
console.log("Build terminé : dist/ prêt à être servi.");
