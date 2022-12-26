import { getInstance } from "$lib/surrealdb";
import type { LayoutLoad } from "./$types";

export const ssr = false;

export const load: LayoutLoad = async ({ fetch }) => {
  const s = await getInstance(fetch);
  const result = await s.query("INFO FOR DB;");
  return {
    result,
  };
};
