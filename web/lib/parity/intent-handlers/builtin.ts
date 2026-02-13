export type IntentHandler = () => void;

const DARK_MODE_STORAGE_KEY = 'settings_dark_mode';

function emit(eventName: string, detail: Record<string, unknown>) {
  window.dispatchEvent(new CustomEvent(eventName, { detail }));
}

function toggleDarkModeIntent() {
  const current = localStorage.getItem(DARK_MODE_STORAGE_KEY) === '1';
  const next = !current;
  localStorage.setItem(DARK_MODE_STORAGE_KEY, next ? '1' : '0');
  document.body.dataset.parityDarkMode = next ? '1' : '0';
  emit('parity:intent', { intentId: 'dark_mode_switch', value: next });
}

export const BUILTIN_INTENT_HANDLERS: Record<string, IntentHandler> = {
  dark_mode_switch: toggleDarkModeIntent,
  close_dialog: () => emit('parity:close_dialog', { intentId: 'close_dialog' }),
  home_button: () => emit('parity:navigate', { intentId: 'home_button', view: 'home' }),
  game_center_button: () => emit('parity:navigate', { intentId: 'game_center_button', view: 'game_center' }),
  history_button: () => emit('parity:navigate', { intentId: 'history_button', view: 'history' }),
  settings_button: () => emit('parity:navigate', { intentId: 'settings_button', view: 'settings' }),
  center_team_button: () => emit('parity:team_selector', { intentId: 'center_team_button' }),
};
