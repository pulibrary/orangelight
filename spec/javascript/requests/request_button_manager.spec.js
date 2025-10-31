import '../../../app/assets/javascripts/requests/requests.js';
import { describe, test, expect, beforeEach, afterEach } from 'vitest';

// Access the class from global scope
const { RequestManager } = globalThis;

describe('RequestManager - Button Management', () => {
  let requestManager, submitButton;

  beforeEach(() => {
    document.body.innerHTML = `
      <button id="request-submit-button" disabled>Submit Request</button>
    `;

    submitButton = document.getElementById('request-submit-button');
    requestManager = new RequestManager();
  });

  afterEach(() => {
    document.body.innerHTML = '';
  });

  describe('constructor', () => {
    test('should find the submit button element', () => {
      expect(requestManager.submitButton).toBe(submitButton);
    });
  });

  describe('_activateRequestButton', () => {
    test('should enable the submit button when it exists', () => {
      // Initially disabled
      expect(submitButton.disabled).toBe(true);

      requestManager._activateRequestButton();

      expect(submitButton.disabled).toBe(false);
    });
  });

  describe('_deactivateRequestButton', () => {
    test('should disable the submit button when it exists', () => {
      // First enable it
      submitButton.disabled = false;
      expect(submitButton.disabled).toBe(false);

      requestManager._deactivateRequestButton();

      expect(submitButton.disabled).toBe(true);
    });
  });

  describe('toggle functionality', () => {
    test('should toggle button state correctly', () => {
      // Start disabled
      expect(submitButton.disabled).toBe(true);

      // Activate
      requestManager._activateRequestButton();
      expect(submitButton.disabled).toBe(false);

      // Deactivate
      requestManager._deactivateRequestButton();
      expect(submitButton.disabled).toBe(true);

      // Activate again
      requestManager._activateRequestButton();
      expect(submitButton.disabled).toBe(false);
    });
  });
});
