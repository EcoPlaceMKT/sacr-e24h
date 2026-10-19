// Copie public/ vers dist/. Si SUPABASE_URL et SUPABASE_ANON_KEY sont définies, elles remplacent public/config.js.
// Vercel lance ce script à chaque déploiement (voir vercel.json).
import { cpSync, mkdirSync, rmSync, writeFileSync } from "node:fs";

const url = (process.env.SUPABASE_URL || "").trim();
const anonKey = (process.env.SUPABASE_ANON_KEY || "").trim();

if (url && !/^https:\/\/[a-z0-9-]+\.supabase\.co\/?$/i.test(url)) {
  console.warn("Attention : SUPABASE_URL ne ressemble pas à une adresse de projet Supabase (https://xxxx.supabase.co).");
}

rmSync("dist", { recursive: true, force: true });
mkdirSync("dist", { recursive: true });
cpSync("public", "dist", { recursive: true });
if (url && anonKey) {
  writeFileSync("dist/config.js", "window.SACREES_CONFIG = " + JSON.stringify({ url: url.replace(/\/$/, ""), anonKey }) + ";\n");
  console.log("config.js écrit depuis les variables d'environnement.");
} else {
  console.log("config.js repris du dépôt (public/config.js).");
}
console.log("Build terminé : dist/ prêt à être servi.");
