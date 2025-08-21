/**
 * Add listener for theme mode toggle
 */

import Theme from '../../theme.js';

const $toggle = document.getElementById('mode-toggle');

export function modeWatcher() {
  if (!$toggle) {
    return;
  }

  $toggle.addEventListener('click', () => {
    Theme.flip();
  });
}
