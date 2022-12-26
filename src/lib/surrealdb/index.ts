import Surreal from "surrealdb.js";
import config from "$lib/config";

let s: Surreal;

export async function getInstance(_fetch = fetch) {
  if (s) return s;
  const c = await config(_fetch);
  const { protocol, host } = window.location;
  // url defaults to "/rpc" (full URL string required)
  const { url = `${protocol}//${host}/rpc`, ns, db, user, pass } = c.surrealdb;
  s = Surreal.Instance;
  await s.connect(url);
  await s.use(ns, db);
  // await s.signin({ user, pass });
  return s;
}
