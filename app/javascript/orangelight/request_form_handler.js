/**
 * Handles request form submissions and responses
 */
class RequestFormHandler {
  constructor(formSelector = '.simple_form.request') {
    this.form = document.querySelector(formSelector);
    this.submitButton = document.querySelector('#request-submit-button');
    this.isSubmitting = false;
    this.submitTimeout = null;

    if (this.form) {
      this.init();
    } else {
      console.warn('No form found with selector:', formSelector);
    }
  }

  init() {
    // Bind form submission handler
    this.form.addEventListener('submit', this.handleSubmit.bind(this));
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

    this.clearAllErrors();
    this.disableSubmitButton();

    this.submitForm();

    return false;
  }

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
        // Check if the form already has an authenticity_token field
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
          this.displaySuccess(data);
        } else {
          this.displayErrors(data);
        }
      } else {
        throw new Error(`HTTP ${response.status}`);
      }
    } catch (error) {
      this.displayGenericError(
        'An error occurred while submitting your request. Please try again.'
      );
    } finally {
      this.resetSubmissionState();
    }
  }

  /**
   * Clear all existing error states
   */
  clearAllErrors() {
    // Hide all error elements
    document.querySelectorAll('.error').forEach((errorEl) => {
      errorEl.style.display = 'none';
      errorEl.textContent = '';
    });

    // Remove error classes from parent elements
    document.querySelectorAll('.has-error').forEach((el) => {
      el.classList.remove('has-error');
    });

    // Remove flash messages from flash messages container
    const flashContainer = document.querySelector('.flash_messages .container');
    if (flashContainer) {
      flashContainer.querySelectorAll('.alert').forEach((el) => {
        el.remove();
      });
    }

    // Remove any flash messages that might have been inserted before submit button (fallback)
    if (this.submitButton) {
      let prevSibling = this.submitButton.previousElementSibling;
      while (prevSibling) {
        if (prevSibling.classList.contains('alert')) {
          const toRemove = prevSibling;
          prevSibling = prevSibling.previousElementSibling;
          toRemove.remove();
        } else {
          prevSibling = prevSibling.previousElementSibling;
        }
      }
    }

    // Remove alert-danger classes from tbody elements
    document.querySelectorAll('tbody .alert-danger').forEach((el) => {
      el.classList.remove('alert-danger');
    });
  }

  /**
   * Get or create flash messages container
   */
  getFlashContainer() {
    let flashContainer = document.querySelector('.flash_messages .container');

    // If no flash container exists, create one
    if (!flashContainer) {
      const existingFlashMessages = document.querySelector('.flash_messages');
      if (existingFlashMessages) {
        // Add container div to existing flash_messages
        existingFlashMessages.innerHTML = '<div class="container"></div>';
        flashContainer = existingFlashMessages.querySelector('.container');
      } else {
        // Create the entire flash messages structure
        const flashWrapper = document.createElement('div');
        flashWrapper.className = 'flash_messages';
        flashWrapper.innerHTML = '<div class="container"></div>';

        // Insert at the beginning of the form or before submit button
        if (this.form) {
          this.form.insertBefore(flashWrapper, this.form.firstChild);
        } else if (this.submitButton) {
          this.submitButton.parentNode.insertBefore(
            flashWrapper,
            this.submitButton
          );
        }
        flashContainer = flashWrapper.querySelector('.container');
      }
    }

    return flashContainer;
  }

  /**
   * Display success message and update UI
   */
  displaySuccess(data) {
    // Show success flash message in the flash messages container
    if (data.flash_messages_html) {
      const flashContainer = this.getFlashContainer();
      if (flashContainer) {
        flashContainer.insertAdjacentHTML(
          'beforeend',
          data.flash_messages_html
        );
      }
    }

    // Hide or replace the submit button
    if (this.submitButton) {
      this.submitButton.style.display = 'none';
    }
  }

  /**
   * Display validation errors
   */
  displayErrors(data) {
    // Show flash messages in the flash messages container
    if (data.flash_messages_html) {
      const flashContainer = this.getFlashContainer();
      if (flashContainer) {
        flashContainer.insertAdjacentHTML(
          'beforeend',
          data.flash_messages_html
        );
      } else {
        console.error('Could not create or find flash container!');
        if (this.submitButton) {
          this.submitButton.insertAdjacentHTML(
            'beforebegin',
            data.flash_messages_html
          );
        }
      }
    }

    // Display field-specific errors
    if (data.errors) {
      Object.entries(data.errors).forEach(([field, messages]) => {
        this.displayFieldError(field, messages);
      });
    }
  }

  /**
   * Display error for specific field
   */
  displayFieldError(field, messages) {
    const errorElement = document.querySelector(`.error-${field}`);

    // Handle special case for items field
    if (field === 'items' && messages.length > 0) {
      const firstMessage = messages[0];
      if (typeof firstMessage === 'object' && firstMessage.text) {
        errorElement.textContent = firstMessage.text;
      } else {
        errorElement.textContent = firstMessage;
      }

      // Add alert classes to delivery elements
      messages.forEach((error) => {
        if (typeof error === 'object' && error.key && error.type) {
          const deliveryElement = document.querySelector(
            `#request_${error.key} .delivery--${error.type}`
          );
          if (deliveryElement) {
            deliveryElement.classList.add('alert', 'alert-danger');
          }
        }
      });
    } else {
      // Handle regular field errors
      const message = Array.isArray(messages) ? messages[0] : messages;
      errorElement.textContent = message;
    }

    // Show error and add error class to parent
    errorElement.style.display = 'block';
    const parent = errorElement.parentElement;
    if (parent) {
      parent.classList.add('has-error');
    }
  }

  displayGenericError(message) {
    if (this.submitButton) {
      const errorHtml = `<div class="alert alert-danger">${message}</div>`;
      this.submitButton.insertAdjacentHTML('beforebegin', errorHtml);
    }
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
