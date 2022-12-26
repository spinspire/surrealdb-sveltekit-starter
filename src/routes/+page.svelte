<script lang="ts">
  import config from "$lib/config";
  import { getInstance } from "$lib/surrealdb";

  // export let data: any;
  let user = {
    email: "",
    pass: "",
  };
  let token = "";
  async function sign(up: boolean) {
    const { surrealdb } = await config();
    const s = await getInstance();
    // const auth = { NS: "test", DB: "test", SC: "user", ...user };
    const auth = { ...surrealdb, user: user.email, pass: user.pass };
    token = up ? await s.signup(auth) : await s.signin(auth);
  }
  const signIn = () => sign(false);
  const signUp = () => sign(true);
  const signOut = async () => {
    const s = await getInstance();
    await s.invalidate();
    token = "";
  };

  let todo: any = {
    title: "",
    completed: false,
  };
  let counter = 0;
  const table = "todo";
  async function submit() {
    save(todo);
  }
  async function save(item: any) {
    const s = await getInstance();
    const result = item.id ? await s.update(item.id, item) : await s.create(table, item);
    ++counter; // to cause getItems to be re-invoked
    return result;
  }
  async function remove(id: string) {
    const s = await getInstance();
    const result = await s.delete(id);
    ++counter;
    return result;
  }
  async function getItems(c = 0) {
    const s = await getInstance();
    const result: any[] = await s.select("todo");
    return result;
  }
</script>

<h1>Hello SurrealDB</h1>
{#if token}
  <button on:click={signOut}>Sign Out</button>
  <form on:submit|preventDefault={submit}>
    <label
      ><span>title</span>
      <input placeholder="todo title" bind:value={todo.title} />
    </label>
    <button type="submit">Submit</button>
  </form>
  <table>
    <thead>
      <tr>
        <th>title</th>
        <th>completed</th>
        <th>actions</th>
      </tr>
    </thead>
    <tbody>
      {#await getItems(counter) then items}
        {#each items as i (i.id)}
          <tr>
            <td>
              <input
                type="text"
                value={i.title}
                on:blur={(e) => i.title !== e.target.value && save({ ...i, title: e.target.value })}
              />
            </td>
            <td
              ><input
                type="checkbox"
                checked={i.completed}
                on:change={(e) => save({ ...i, completed: e.target.checked })}
              /></td
            >
            <td><button on:click={() => remove(i.id)}>&times;</button></td>
          </tr>
        {:else}
          <tr>
            <td colspan="999">No data found. Please create some.</td>
          </tr>
        {/each}
      {/await}
    </tbody>
  </table>
{:else}
  <form on:submit|preventDefault={signIn}>
    <label
      ><span>Email</span>
      <input type="text" bind:value={user.email} />
    </label>
    <label
      ><span>Password</span>
      <input type="password" bind:value={user.pass} />
    </label>
    <button type="submit">Sign In</button>
    <button type="button" on:click={signUp}>Sign Up</button>
  </form>
{/if}
