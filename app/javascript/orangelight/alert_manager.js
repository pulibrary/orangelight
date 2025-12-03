class AlertManager {
  constructor() {}

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
    const flashContainer = this.getFlashContainer();
    if (flashContainer && data.message) {
      const successElement = document.createElement('div');
      successElement.classList.add('alert', 'alert-success');
      successElement.textContent = data.message;
      const closeBtn = document.createElement('button');
      closeBtn.className = 'close';
      closeBtn.setAttribute('data-bs-dismiss', 'alert');
      closeBtn.innerHTML = '&times;';
      successElement.appendChild(closeBtn);
      flashContainer.appendChild(successElement);
    }
  }

  /**
   * Display validation errors
   */
  displayErrors(data) {
    const flashContainer = this.getFlashContainer();
    if (flashContainer && data.message) {
      const errorElement = document.createElement('div');
      errorElement.classList.add('alert', 'alert-danger');
      errorElement.textContent = data.message;
      const closeBtn = document.createElement('button');
      closeBtn.className = 'close';
      closeBtn.setAttribute('data-bs-dismiss', 'alert');
      closeBtn.innerHTML = '&times;';
      errorElement.appendChild(closeBtn);
      flashContainer.appendChild(errorElement);
    }

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
}

export default AlertManager;
