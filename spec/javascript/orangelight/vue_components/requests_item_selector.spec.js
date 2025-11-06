import { flushPromises, mount } from '@vue/test-utils';
import RequestsItemSelector from '../../../../app/javascript/orangelight/vue_components/requests_item_selector.vue';
import { nextTick } from 'vue';

describe('RequestsItemSelector', () => {
  let wrapper;

  it('can accept a bibliographic record id', () => {
    expect(RequestsItemSelector.props.recordId).toBeDefined();
  });

  it('makes a request to bibdata for the most up-to-date availability data', async () => {
    global.fetch = vi.fn(() => Promise.resolve(new Response('[]')));
    wrapper = mount(RequestsItemSelector, {
      props: {
        items: [],
        recordId: '9933643713506421',
        mfhdId: '22727480400006421',
        bibdataBase: 'https://bibdata.example.com',
      },
    });
    await flushPromises();
    expect(global.fetch).toHaveBeenCalledWith(
      'https://bibdata.example.com/bibliographic/9933643713506421/holdings/22727480400006421/availability.json'
    );
  });

  it('uses item information from the props before the up-to-date availability data is loaded', async () => {
    global.fetch = vi.fn(() => Promise.resolve(new Response('[]')));
    wrapper = mount(RequestsItemSelector, {
      props: {
        items: [
          { id: '123', label: 'vol.1' },
          { id: '456', label: 'vol.2' },
        ],
        recordId: '9933643713506421',
        mfhdId: '22727480400006421',
        bibdataBase: 'https://bibdata.example.com',
      },
    });

    // Focus the input so the dropdown is displayed
    await wrapper.find('input').trigger('focus');
    // Wait for it to find its data and re-render
    await nextTick();

    const dropdownItems = wrapper
      .findAll('.lux-autocomplete-result')
      .map((item) => item.text());

    expect(dropdownItems).toContain('vol.1');
    expect(dropdownItems).toContain('vol.2');
    expect(dropdownItems).not.toContain('vol.3');
  });

  it('uses item information from the up-to-date availability data once it is loaded', async () => {
    global.fetch = vi.fn(() =>
      Promise.resolve(
        new Response(`
[{
  "barcode": "32101071345571",
  "id": "123",
  "status": "Available",
  "description": "vol.1"
}, {
  "barcode": "32101071345572",
  "id": "789",
  "status": "Available",
  "description": "vol.3"
}]
        `)
      )
    );
    wrapper = mount(RequestsItemSelector, {
      props: {
        items: [
          { id: '123', label: 'vol.1' },
          { id: '456', label: 'vol.2' },
        ],
        recordId: '9933643713506421',
        mfhdId: '22727480400006421',
        bibdataBase: 'https://bibdata.example.com',
      },
    });

    await flushPromises();

    // Focus the input so the dropdown is displayed
    await wrapper.find('input').trigger('focus');

    const dropdownItems = wrapper
      .findAll('.lux-autocomplete-result')
      .map((item) => item.text());

    expect(dropdownItems).toContain('vol.1');
    expect(dropdownItems).toContain('vol.3');
    expect(dropdownItems).not.toContain('vol.2');
  });
});
