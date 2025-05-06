import { mount } from '@vue/test-utils';
import { expect } from 'vitest';
import MultiselectCombobox from '../../../../app/javascript/orangelight/vue_components/multiselect_combobox.vue';

describe('MultiselectCombobox', () => {
  const wrapper = mount(MultiselectCombobox, {
    props: {
      fieldName: 'format',
      label: 'Format',
      domId: 'format',
      valuesJson: JSON.stringify([
        { value: 'Book', label: 'Book (12)', selected: false },
        { value: 'Map', label: 'Map (8)', selected: true },
      ]),
    },
  });
  it('renders a label with the given label and domId', () => {
    expect(wrapper.get('label').text()).toEqual('Format');
    expect(wrapper.get('label').attributes('for')).toEqual('format');
  });
  describe('input', () => {
    it('uses the given domId as its id', () => {
      expect(wrapper.get('input').attributes('id')).toEqual('format');
    });
    it('controls the listbox', () => {
      expect(wrapper.get('input').attributes('aria-controls')).toEqual(
        'format-list'
      );
    });
  });
  describe('listbox', () => {
    it('contains an option for each value provided', () => {
      const listbox = wrapper.get('ul');
      expect(listbox.findAll('li').length).toEqual(4);
      expect(listbox.findAll('li').at(2).element.textContent).toEqual(
        'Book (12)'
      );
      expect(listbox.findAll('li').at(3).element.textContent).toEqual(
        'Map (8)'
      );
    });
  });
  describe('aria-live region', () => {
    const aria_live_region = wrapper.get(
      '.number-of-results[aria-live="polite"]'
    );
    it('includes the number of results', () => {
      expect(aria_live_region.element.textContent).toContain('2 options.');
    });
    it('includes instructions for the user', () => {
      expect(aria_live_region.element.textContent).toContain(
        'Press down arrow for options.'
      );
    });
  });
});
