/**
 * Functions to execute when the DOM is ready
 */

import { whenReady } from './utils/dom';

import { setupTables } from './tables';
import { listenAutocomplete } from './autocomplete';
import { loadBooruData } from './booru';
import { registerEvents } from './boorujs';
import { setupBurgerMenu } from './burger';
import { bindCaptchaLinks } from './captcha';
import { setupComments } from './comment';
import { setupDupeReports } from './duplicate_reports';
import { setSesCookie } from './fp';
import { setupGalleryEditing } from './galleries';
import { bindImageTarget } from './image_expansion';
import { initImagesClientside } from './imagesclientside';
import { setupToolbar } from './markdowntoolbar';
import { setupEvents } from './misc';
import { setupNotifications } from './notifications';
import { warnAboutPMs } from './pmwarning';
import { pollOptionCreator } from './poll';
import { setupPreviews } from './preview';
import { setupQuickTag } from './quick-tag';
import { initializeListener } from './resizablemedia';
import { setupSearch } from './search';
import { setupSettings } from './settings';
import { listenForKeys } from './shortcuts';
import { imageSourcesCreator } from './sources';
import { hideStaffTools } from './staffhider';
import { initTagDropdown } from './tags';
import { setupTagListener } from './tagsinput';
import { setupTagEvents } from './tagsmisc';
import { setupTimestamps } from './timeago';
import { setupImageUpload } from './upload';

const functions = [
  loadBooruData,
  listenAutocomplete,
  registerEvents,
  setupBurgerMenu,
  bindCaptchaLinks,
  initImagesClientside,
  setupComments,
  setupDupeReports,
  setSesCookie,
  setupGalleryEditing,
  bindImageTarget,
  setupEvents,
  setupNotifications,
  setupPreviews,
  setupQuickTag,
  initializeListener,
  setupSettings,
  listenForKeys,
  initTagDropdown,
  setupTagListener,
  setupTagEvents,
  setupTimestamps,
  setupImageUpload,
  setupSearch,
  setupToolbar,
  hideStaffTools,
  pollOptionCreator,
  warnAboutPMs,
  imageSourcesCreator,
  setupTables,
];

whenReady(() => {
  functions.forEach(fn => {
    try {
      fn();
    } catch (err: unknown) {
      console.log(`${fn.name} ran with errors.`);

      if (err instanceof Error) {
        console.log(`The error was:\n\n${err.message}`);
      }
    }
  });
});
