import { mount } from '@vue/test-utils';
import { beforeEach, describe, expect, vi } from 'vitest';
import HoldingGroupAvailability from '../../../../app/javascript/orangelight/vue_components/holding_group_availability.vue';

const { JSDOM } = require('jsdom');

let wrapper;
let document;
vi.useFakeTimers();

describe('HoldingGroupAvailability', () => {
  describe('when the group has a single holding and it is available', () => {
    beforeEach(() => {
      document = new JSDOM(`
            <details>
              <div id="vue-mount"></div>
              <table>
                <tr class="holding-block">
                  <span class="availability-icon">Available</span>
                </tr>
              </table>
            </details>`).window.document;
      wrapper = mount(HoldingGroupAvailability, {
        attachTo: document.getElementById('vue-mount'),
      });
    });
    it('Shows available', () => {
      vi.advanceTimersByTime(1000);
      expect(wrapper.text()).toContain('Available');
      expect(wrapper.text()).not.toContain('Some Available');
    });
  });

  describe('when the group has a single holding and it is On-site access', () => {
    beforeEach(() => {
      document = new JSDOM(`
            <details>
              <div id="vue-mount"></div>
              <table>
                <tr class="holding-block">
                  <span class="availability-icon">On-site access</span>
                </tr>
              </table>
            </details>`).window.document;
      wrapper = mount(HoldingGroupAvailability, {
        attachTo: document.getElementById('vue-mount'),
      });
    });
    it('Shows available', () => {
      vi.advanceTimersByTime(1000);
      expect(wrapper.text()).toContain('Available');
      expect(wrapper.text()).not.toContain('Some Available');
    });
  });

  describe('when the group has many holdings that are all unavailable', () => {
    beforeEach(() => {
      document = new JSDOM(`
            <details>
              <div id="vue-mount"></div>
              <table>
                <tr class="holding-block">
                  <span class="availability-icon">Unavailable</span>
                </tr>
                <tr class="holding-block">
                  <span class="availability-icon">Ask Staff</span>
                </tr>
                <tr class="holding-block">
                  <span class="availability-icon">Unavailable</span>
                </tr>
              </table>
            </details>`).window.document;
      wrapper = mount(HoldingGroupAvailability, {
        attachTo: document.getElementById('vue-mount'),
      });
    });
    it('Shows request', () => {
      vi.advanceTimersByTime(1000);
      expect(wrapper.text()).toContain('Request');
    });
  });

  describe('when the group has many a mix of available and unavailable', () => {
    beforeEach(() => {
      document = new JSDOM(`
            <details>
              <div id="vue-mount"></div>
              <table>
                <tr class="holding-block">
                  <span class="availability-icon">Unavailable</span>
                </tr>
                <tr class="holding-block">
                  <span class="availability-icon">Ask Staff</span>
                </tr>
                <tr class="holding-block">
                  <span class="availability-icon">Available</span>
                </tr>
              </table>
            </details>`).window.document;
      wrapper = mount(HoldingGroupAvailability, {
        attachTo: document.getElementById('vue-mount'),
      });
    });
    it('Shows Some Available', () => {
      vi.advanceTimersByTime(1000);
      expect(wrapper.text()).toContain('Some Available');
    });
  });

  describe('when the group has not loaded availability yet', () => {
    beforeEach(() => {
      document = new JSDOM(`
            <details>
              <div id="vue-mount"></div>
              <table>
                <tr class="holding-block">
                  <span class="availability-icon"></span>
                </tr>
              </table>
            </details>`).window.document;
      wrapper = mount(HoldingGroupAvailability, {
        attachTo: document.getElementById('vue-mount'),
      });
    });
    it('Does not display anything', () => {
      vi.advanceTimersByTime(1000);
      expect(wrapper.text().trim()).toEqual('');
    });
  });
});
