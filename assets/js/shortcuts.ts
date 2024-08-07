/**
 * Keyboard shortcuts
 */

import { $ } from './utils/dom';

type ShortcutKeyMap = Record<string, () => void>;

function getHover(): string | null {
  const thumbBoxHover = $<HTMLDivElement>('.media-box:hover');

  return thumbBoxHover && (thumbBoxHover.dataset.imageId || null);
}

function openFullView() {
  const imageHover = $<HTMLDivElement>('[data-uris]:hover');

  if (!imageHover || !imageHover.dataset.uris) return;

  window.location = JSON.parse(imageHover.dataset.uris).full;
}

function openFullViewNewTab() {
  const imageHover = $<HTMLDivElement>('[data-uris]:hover');

  if (!imageHover || !imageHover.dataset.uris) return;

  window.open(JSON.parse(imageHover.dataset.uris).full);
}

function click(selector: string) {
  const el = $<HTMLElement>(selector);

  if (el) {
    el.click();
  }
}

function isOK(event: KeyboardEvent): boolean {
  return (
    !event.altKey &&
    !event.ctrlKey &&
    !event.metaKey &&
    document.activeElement !== null &&
    document.activeElement.tagName !== 'INPUT' &&
    document.activeElement.tagName !== 'TEXTAREA'
  );
}

/* eslint-disable prettier/prettier */

const keyCodes: ShortcutKeyMap = {
  j() { click('.js-prev');             }, // J - go to previous image
  i() { click('.js-up');               }, // I - go to index page
  k() { click('.js-next');             }, // K - go to next image
  r() { click('.js-rand');             }, // R - go to random image
  s() { click('.js-source-link');      }, // S - go to image source
  l() { click('.js-tag-sauce-toggle'); }, // L - edit tags
  o() { openFullView();                }, // O - open original
  v() { openFullViewNewTab();          }, // V - open original in a new tab
  f() {
    // F - favourite image
    click(getHover() ? `a.interaction--fave[data-image-id="${getHover()}"]` : '.block__header a.interaction--fave');
  },
  u() {
    // U - upvote image
    click(getHover() ? `a.interaction--upvote[data-image-id="${getHover()}"]` : '.block__header a.interaction--upvote');
  },
};

/* eslint-enable prettier/prettier */

export function listenForKeys() {
  document.addEventListener('keydown', (event: KeyboardEvent) => {
    if (isOK(event) && keyCodes[event.key]) {
      keyCodes[event.key]();
      event.preventDefault();
    }
  });
}
