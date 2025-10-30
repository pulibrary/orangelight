/**
 * Tests for RequestFormHandler
 */

import { describe, it, expect, beforeEach, afterEach, vi } from 'vitest';
import RequestFormHandler from '../../../app/javascript/orangelight/request_form_handler.js';

describe('RequestFormHandler', () => {
  let handler;
  let mockForm;
  let mockSubmitButton;

  beforeEach(() => {
    // Set up DOM structure
    document.body.innerHTML = `
      <div class="flash_messages">
        <div class="container">
        </div>
      </div>
      <form class="simple_form request-form">
        <div>
          <span class="error error-items"></span>
        </div>
        <div>
          <span class="error error-title"></span>
        </div>
        <div id="request-submit-wrapper">
          <button id="request-submit-button" class="btn btn-primary submit--request" type="submit">
            Submit Request
          </button>
        </div>
      </form>
    `;

    mockForm = document.querySelector('.simple_form.request-form');
    mockSubmitButton = document.querySelector('#request-submit-button');
    handler = new RequestFormHandler('.simple_form.request-form');
  });

  afterEach(() => {
    document.body.innerHTML = '';
  });

  describe('initialization', () => {
    it('should initialize with form and submit button', () => {
      expect(handler.form).toBe(mockForm);
      expect(handler.submitButton).toBe(mockSubmitButton);
      expect(handler.isSubmitting).toBe(false);
    });

    it('should not initialize if no form is found', () => {
      document.body.innerHTML = '';
      const handler = new RequestFormHandler();
      expect(handler.form).toBeNull();
    });
  });

  describe('clearAllErrors', () => {
    beforeEach(() => {
      // Set up error state
      const errorElement = document.querySelector('.error-items');
      errorElement.style.display = 'block';
      errorElement.textContent = 'Some error';
      errorElement.parentElement.classList.add('has-error');
    });

    it('should clear all error elements', () => {
      handler.clearAllErrors();

      const errorElements = document.querySelectorAll('.error');
      errorElements.forEach((el) => {
        expect(el.style.display).toBe('none');
        expect(el.textContent).toBe('');
      });
    });

    it('should remove has-error class from parent elements', () => {
      handler.clearAllErrors();

      const errorParents = document.querySelectorAll('.has-error');
      expect(errorParents.length).toBe(0);
    });
  });

  describe('displaySuccess', () => {
    it('should hide submit button and display success message in flash container', () => {
      const mockData = {
        message: 'Request submitted!',
        success: true,
      };

      handler.displaySuccess(mockData);

      // Submit button should be hidden, not removed
      expect(document.querySelector('.submit--request').style.display).toBe(
        'none'
      );

      // Success message should be in the flash messages container
      const flashContainer = document.querySelector(
        '.flash_messages .container'
      );
      console.log(flashContainer.innerHTML);
      console.log(document.body.innerHTML);
      expect(flashContainer.querySelector('.alert-success')).toBeTruthy();
      expect(
        flashContainer.querySelector('.alert-success').textContent
      ).toContain('Request submitted!');
    });
  });

  describe('displayErrors', () => {
    it('should display flash messages in flash container', () => {
      const mockData = {
        success: false,
        message: 'Error occurred',
        errors: {},
      };

      handler.displayErrors(mockData);

      const flashContainer = document.querySelector(
        '.flash_messages .container'
      );
      expect(flashContainer.querySelector('.alert-danger')).toBeTruthy();
      expect(
        flashContainer.querySelector('.alert-danger').textContent
      ).toContain('Error occurred');
    });

    it('should display field-specific errors', () => {
      const mockData = {
        success: false,
        errors: {
          title: ['Please specify title for the selection you want digitized.'],
        },
      };

      handler.displayErrors(mockData);

      const titleError = document.querySelector('.error-title');
      expect(titleError.textContent).toBe(
        'Please specify title for the selection you want digitized.'
      );
      expect(titleError.style.display).toBe('block');
      expect(titleError.parentElement.classList.contains('has-error')).toBe(
        true
      );
    });

    it('should handle items field errors specially', () => {
      const mockData = {
        success: false,
        errors: {
          items: [
            {
              key: 'item123',
              type: 'digitization',
              text: 'Please specify title for the selection you want digitized.',
            },
          ],
        },
      };

      // Add the delivery element that the handler looks for
      document.body.innerHTML += `
        <div id="request_item123">
          <div class="delivery--digitization"></div>
        </div>
      `;

      handler.displayErrors(mockData);

      const itemsError = document.querySelector('.error-items');
      expect(itemsError.textContent).toBe(
        'Please specify title for the selection you want digitized.'
      );
      expect(itemsError.style.display).toBe('block');

      const deliveryElement = document.querySelector(
        '#request_item123 .delivery--digitization'
      );
      expect(deliveryElement.classList.contains('alert')).toBe(true);
      expect(deliveryElement.classList.contains('alert-danger')).toBe(true);
    });
  });

  describe('handleSubmit debouncing', () => {
    it('should prevent rapid submissions', () => {
      const mockEvent = {
        preventDefault: vi.fn(),
        stopPropagation: vi.fn(),
        stopImmediatePropagation: vi.fn(),
      };

      // First submission should go through (but preventDefault is always called now)
      const result1 = handler.handleSubmit(mockEvent);
      expect(result1).toBe(false); // Now always returns false since we handle submission ourselves
      expect(mockEvent.preventDefault).toHaveBeenCalledTimes(1);

      handler.isSubmitting = true;

      // Second rapid submission should be prevented
      const result2 = handler.handleSubmit(mockEvent);
      expect(result2).toBe(false);
      expect(mockEvent.preventDefault).toHaveBeenCalledTimes(2); // Called twice now
    });
  });

  describe('disableSubmitButton', () => {
    it('should disable submit button and change text', () => {
      handler.disableSubmitButton();

      expect(mockSubmitButton.disabled).toBe(true);
      expect(mockSubmitButton.textContent).toBe('Submitting Request...');
    });
  });

  describe('resetSubmissionState', () => {
    beforeEach(() => {
      handler.isSubmitting = true;
      handler.submitTimeout = setTimeout(() => {}, 1000);
      mockSubmitButton.disabled = true;
      mockSubmitButton.textContent = 'Submitting Request...';
    });

    it('should reset submission state', () => {
      handler.resetSubmissionState();

      expect(handler.isSubmitting).toBe(false);
      expect(handler.submitTimeout).toBeNull();
    });

    it('should re-enable submit button', () => {
      mockSubmitButton.dataset.originalText = 'Submit Request';
      handler.resetSubmissionState();

      expect(mockSubmitButton.disabled).toBe(false);
      expect(mockSubmitButton.textContent).toBe('Submit Request');
    });
  });

  describe('form submission', () => {
    let mockFetch;

    beforeEach(() => {
      mockFetch = vi.fn();
      global.fetch = mockFetch;

      const metaTag = document.createElement('meta');
      metaTag.setAttribute('name', 'csrf-token');
      metaTag.setAttribute('content', 'test-csrf-token');
      document.head.appendChild(metaTag);
    });

    afterEach(() => {
      vi.restoreAllMocks();
      document.head.querySelector('meta[name="csrf-token"]')?.remove();
    });

    it('should submit form via fetch API on successful response', async () => {
      const responseData = {
        success: true,
        flash_messages_html: '<div class="alert alert-success">Success!</div>',
      };

      mockFetch.mockResolvedValue({
        ok: true,
        status: 200,
        headers: {
          get: () => 'application/json',
        },
        json: () => Promise.resolve(responseData),
      });

      vi.spyOn(handler, 'displaySuccess');

      const submitEvent = new Event('submit', {
        bubbles: true,
        cancelable: true,
      });
      handler.form.dispatchEvent(submitEvent);

      // Wait for async
      await new Promise((resolve) => setTimeout(resolve, 0));

      expect(mockFetch).toHaveBeenCalledWith(
        handler.form.action,
        expect.objectContaining({
          method: 'POST',
          headers: expect.objectContaining({
            'X-Requested-With': 'XMLHttpRequest',
            Accept: 'application/json',
          }),
        })
      );

      expect(handler.displaySuccess).toHaveBeenCalledWith(responseData);
    });

    it('should handle validation errors (422 response)', async () => {
      const responseData = {
        success: false,
        errors: { title: ['Error message'] },
        flash_messages_html: '<div class="alert alert-danger">Error!</div>',
      };

      mockFetch.mockResolvedValue({
        ok: false,
        status: 422,
        headers: {
          get: () => 'application/json',
        },
        json: () => Promise.resolve(responseData),
      });

      vi.spyOn(handler, 'displayErrors');

      // Trigger form submission
      const submitEvent = new Event('submit', {
        bubbles: true,
        cancelable: true,
      });
      handler.form.dispatchEvent(submitEvent);

      // Wait for async operations
      await new Promise((resolve) => setTimeout(resolve, 0));

      expect(handler.displayErrors).toHaveBeenCalledWith(responseData);
    });

    it('should handle network errors', async () => {
      mockFetch.mockRejectedValue(new Error('Network error'));

      vi.spyOn(handler, 'displayGenericError');

      // Trigger form submission
      const submitEvent = new Event('submit', {
        bubbles: true,
        cancelable: true,
      });
      handler.form.dispatchEvent(submitEvent);

      // Wait for async operations
      await new Promise((resolve) => setTimeout(resolve, 0));

      expect(handler.displayGenericError).toHaveBeenCalledWith(
        'An error occurred while submitting your request. Please try again.'
      );
    });
  });
});
