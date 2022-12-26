import { base } from "$app/paths";

async function config(_fetch = fetch) {
  const response = await _fetch(base + "/config.json");
  const json = await response.json();
  return json;
}

export default config;
