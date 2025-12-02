import AlertManager from './alert-manager';

/**
 * Handles request form submissions and responses
 */
class RequestFormHandler {
  constructor(formSelector = '.simple_form.request') {
    this.alertManager = new AlertManager();

    this.form = document.querySelector(formSelector);
    this.submitButton = document.querySelector('#request-submit-button');
    this.isSubmitting = false;
    this.submitTimeout = null;

    if (this.form) {
      this.form.addEventListener('submit', this.handleSubmit.bind(this));
    } else {
      console.warn('No form found with selector:', formSelector);
    }
  }

  handleSubmit(event) {
    // Prevent rapid submissions with debouncing
    if (this.isSubmitting) {
      event.preventDefault();
      return false;
    }

    event.preventDefault(); // Prevent the default form submission
    event.stopPropagation(); // Stop other event listeners from firing
    event.stopImmediatePropagation(); // Stop any remaining listeners on this element
    this.isSubmitting = true;

    this.alertManager.clearAllErrors();
    this.disableSubmitButton();

    this.submitForm();

    return false;
  }

  /**
   * Submit the form via Fetch api and handle the response
   * We use the rails form to collect all input values (text fields, checkboxes, select)
   */
  async submitForm() {
    try {
      const formData = new FormData(this.form);
      // Add CSRF token for Rails authenticity
      const csrfToken =
        document
          .querySelector('meta[name="csrf-token"]')
          ?.getAttribute('content') ||
        document.querySelector('input[name="authenticity_token"]')?.value;

      if (csrfToken) {
        if (!formData.has('authenticity_token')) {
          formData.append('authenticity_token', csrfToken);
        }
      } else {
        console.warn('No CSRF token found');
      }

      const response = await fetch(this.form.action, {
        method: 'POST',
        headers: {
          'X-Requested-With': 'XMLHttpRequest',
          Accept: 'application/json',
        },
        body: formData,
      });

      if (response.ok || response.status === 422) {
        // Handle both successful responses (200) and validation errors (422)
        const contentType = response.headers.get('content-type');

        let data;
        if (contentType && contentType.includes('application/json')) {
          data = await response.json();
        } else {
          // Handle non-JSON response (likely HTML/text)
          const text = await response.text();
          throw new Error(`Server returned ${contentType} instead of JSON`);
        }

        if (data.success) {
          this.alertManager.displaySuccess(data);
          this.submitButton.style.display = 'none';
        } else {
          this.alertManager.displayErrors(data);
        }
      } else {
        throw new Error(`HTTP ${response.status}`);
      }
    } catch (error) {
      this.consoleError(
        "There was a problem with this request which Library staff need to investigate. You'll be notified once it's resolved and requested for you."
      );
    } finally {
      this.resetSubmissionState();
    }
  }

  consoleError(message) {
    console.log(message);
  }

  /**
   * Disable submit button during submission
   */
  disableSubmitButton() {
    if (this.submitButton) {
      // Store original text if not already stored
      if (!this.submitButton.dataset.originalText) {
        this.submitButton.dataset.originalText =
          this.submitButton.value || this.submitButton.textContent;
      }
      this.submitButton.disabled = true;
      this.submitButton.textContent = 'Submitting Request...';
    }
  }

  /**
   * Reset submission state
   */
  resetSubmissionState() {
    this.isSubmitting = false;
    if (this.submitTimeout) {
      clearTimeout(this.submitTimeout);
      this.submitTimeout = null;
    }

    if (this.submitButton && !this.submitButton.classList.contains('success')) {
      this.submitButton.disabled = false;
      this.submitButton.textContent =
        this.submitButton.dataset.originalText || 'Submit Request';
    }
  }
}

export default RequestFormHandler;
