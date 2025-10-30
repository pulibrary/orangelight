/**
 * Integration test to verify JavaScript handler works with JSON responses
 */

import RequestFormHandler from '../../../app/javascript/orangelight/request_form_handler.js';

describe('RequestFormHandler with JSON Response', () => {
  let handler;

  beforeEach(() => {
    document.body.innerHTML = `
      <div class="flash_messages">
        <div class="container">
        </div>
      </div>
      <form class="simple_form request-form">
        <div>
          <span class="error error-email"></span>
        </div>
        <div>
          <span class="error error-user_name"></span>
        </div>
        <div>
          <span class="error error-items"></span>
        </div>
        <div id="request-submit-wrapper">
          <button id="request-submit-button" class="btn btn-primary submit--request" type="submit">
            Submit Request
          </button>
        </div>
      </form>
    `;

    handler = new RequestFormHandler('.simple_form.request-form');
  });

  afterEach(() => {
    document.body.innerHTML = '';
  });

  describe('handling a validation error response', () => {
    it('should display errors from actual JSON response structure', () => {
      const realJsonResponse = {
        success: false,
        message:
          'We were unable to process your request. Correct the highlighted errors.',
        errors: {
          email: [
            "can't be blank",
            'is invalid',
            'is too short (minimum is 5 characters)',
          ],
          user_name: [
            "can't be blank",
            'is too short (minimum is 1 character)',
          ],
          items: [
            {
              key: null,
              type: 'pick_up',
              text: 'Please choose a Request Method for your selected item.',
            },
          ],
        },
      };

      handler.displayErrors(realJsonResponse);

      // Check that flash messages were inserted into the flash messages container
      const flashContainer = document.querySelector(
        '.flash_messages .container'
      );
      expect(flashContainer.querySelector('.alert-danger')).toBeTruthy();
      const alertDanger = flashContainer.querySelector('.alert-danger');
      expect(alertDanger.textContent).toContain(realJsonResponse.message);

      // Check that field-specific errors are displayed
      const emailError = document.querySelector('.error-email');
      expect(emailError.textContent).toBe("can't be blank");
      expect(emailError.style.display).toBe('block');
      expect(emailError.parentElement.classList.contains('has-error')).toBe(
        true
      );

      const userNameError = document.querySelector('.error-user_name');
      expect(userNameError.textContent).toBe("can't be blank");
      expect(userNameError.style.display).toBe('block');

      const itemsError = document.querySelector('.error-items');
      expect(itemsError.textContent).toBe(
        'Please choose a Request Method for your selected item.'
      );
      expect(itemsError.style.display).toBe('block');
    });

    it('should handle items errors with complex structure', () => {
      const itemsErrorResponse = {
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
        flash_messages_html: "<div class='alert alert-danger'>Error</div>",
      };

      // Add a delivery element that should get the alert class
      document.body.innerHTML += `
        <div id="request_item123">
          <div class="delivery--digitization"></div>
        </div>
      `;

      handler.displayErrors(itemsErrorResponse);

      // Check items error text
      const itemsError = document.querySelector('.error-items');
      expect(itemsError.textContent).toBe(
        'Please specify title for the selection you want digitized.'
      );

      // Check that delivery element got the alert classes
      const deliveryElement = document.querySelector(
        '#request_item123 .delivery--digitization'
      );
      expect(deliveryElement.classList.contains('alert')).toBe(true);
      expect(deliveryElement.classList.contains('alert-danger')).toBe(true);
    });
  });

  describe('error clearing', () => {
    it('should clear errors when form is resubmitted', () => {
      // First, add some errors
      const errorElement = document.querySelector('.error-email');
      errorElement.textContent = 'Some error';
      errorElement.style.display = 'block';
      errorElement.parentElement.classList.add('has-error');

      // Clear errors
      handler.clearAllErrors();

      // Confirm they're cleared
      expect(errorElement.textContent).toBe('');
      expect(errorElement.style.display).toBe('none');
      expect(errorElement.parentElement.classList.contains('has-error')).toBe(
        false
      );
    });
  });
});
