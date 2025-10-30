/**
 * Initializes Lux and the RequestFormHandler.
 */
import { luxImport } from '../orangelight/lux_import';
import RequestFormHandler from '../orangelight/request_form_handler';

luxImport();

// Initialize request form handler for request pages
document.addEventListener('DOMContentLoaded', () => {
  new RequestFormHandler('.simple_form.request');
});
