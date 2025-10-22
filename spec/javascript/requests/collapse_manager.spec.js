// Load the CollapseManager class directly
import '../../../app/assets/javascripts/requests/requests.js';
import { describe, test, expect, beforeEach, afterEach, vi } from 'vitest';

// Access the class from global scope
const { CollapseManager } = globalThis;

describe('CollapseManager', () => {
  let mockElement, mockElement2;

  beforeEach(() => {
    document.body.innerHTML = `
      <div id="test-collapse" class="collapse">Test Content</div>
      <div id="test-collapse2" class="collapse">Test Content 2</div>
      <input type="radio" name="test-group" data-target="#test-collapse" value="option1">
      <input type="radio" name="test-group" data-target="#test-collapse2" value="option2">
    `;

    mockElement = document.getElementById('test-collapse');
    mockElement2 = document.getElementById('test-collapse2');
  });

  afterEach(() => {
    document.body.innerHTML = '';
    vi.clearAllMocks();
  });

  describe('hideAllRelated method', () => {
    test('should hide all collapse elements for radio buttons with same name', () => {
      const hideSpy = vi.spyOn(CollapseManager, 'hide');

      CollapseManager.hideAllRelated('test-group');

      expect(hideSpy).toHaveBeenCalledTimes(2);
      expect(hideSpy).toHaveBeenCalledWith(mockElement);
      expect(hideSpy).toHaveBeenCalledWith(mockElement2);
    });

    test('should handle radios without data-target gracefully', () => {
      document.body.innerHTML = `
        <input type="radio" name="empty-group" value="option1">
        <input type="radio" name="empty-group" data-target="#nonexistent" value="option2">
      `;

      expect(() => CollapseManager.hideAllRelated('empty-group')).not.toThrow();
    });
  });

  describe('showForRadio method', () => {
    test('should show collapse element for radio with data-target', () => {
      const radioButton = document.querySelector(
        'input[data-target="#test-collapse"]'
      );
      const showSpy = vi.spyOn(CollapseManager, 'show');

      CollapseManager.showForRadio(radioButton);

      expect(showSpy).toHaveBeenCalledWith(mockElement);
    });

    test('should handle radio without data-target gracefully', () => {
      const radioButton = document.createElement('input');
      radioButton.type = 'radio';

      expect(() => CollapseManager.showForRadio(radioButton)).not.toThrow();
    });
  });

  describe('handleDeliveryModeChange method', () => {
    test('should hide all related panels and show selected one', () => {
      const radioButton = document.querySelector(
        'input[data-target="#test-collapse"]'
      );
      const hideAllSpy = vi.spyOn(CollapseManager, 'hideAllRelated');
      const showForRadioSpy = vi.spyOn(CollapseManager, 'showForRadio');

      CollapseManager.handleDeliveryModeChange(radioButton);

      expect(hideAllSpy).toHaveBeenCalledWith('test-group');
      expect(showForRadioSpy).toHaveBeenCalledWith(radioButton);
    });
  });
});
