import { invoke } from '@tauri-apps/api/core';
import { listen } from '@tauri-apps/api/event';
import { Ok, Error } from "../../build/dev/javascript/splot/gleam.mjs"; // FIXME: Is this the right way to do this?

export async function greet(name) {
  try {
    return new Ok(await invoke('greet', { name: name }));
  } catch (error) {
    return new Error(error.toString());
  }
}

export async function listenForTick(handler) {
  await listen('tick', (event) => {
    handler(event.payload);
  });
}
