import { nextTick } from 'vue';
import { mount } from '@vue/test-utils';
import OnlineOptions from '../../../../app/javascript/orangelight/vue_components/online_options.vue';

describe('OnlineOptions', () => {
  it('shows a link', () => {
    const wrapper = mount(OnlineOptions, {
      props: {
        documentId: '99131181127806421',
        optionsCount: '2',
        linkJson: '[]',
      },
    });
    expect(wrapper.get('span').text()).toContain('2 Online Options');
  });
  it('links to the available online section of the show page', () => {
    const wrapper = mount(OnlineOptions, {
      props: {
        documentId: '99131181127806421',
        optionsCount: '2',
        linkJson: '{"title": "Link 1", "url": "http://example.com/1"}',
      },
    });
    expect(wrapper.get('a').attributes('href')).toEqual(
      '/catalog/99131181127806421#available-online'
    );
  });
  it('renders the provided link', async () => {
    const wrapper = mount(OnlineOptions, {
      props: {
        documentId: '99131181127806421',
        optionsCount: '1',
        linkJson: '{"title": "Link 1", "url": "http://example.com/1"}',
      },
    });
    await nextTick();
    expect(wrapper.get('a').text()).toEqual('Link 1');
    expect(wrapper.get('a').attributes('href')).toEqual('http://example.com/1');
  });
  it('Does not render the link when it is a finding aid', async () => {
    const wrapper = mount(OnlineOptions, {
      props: {
        documentId: '998449623506421',
        optionsCount: '1',
        linkJson:
          '{"title": "Princeton University Library Finding Aids", "url": "http://example.com/1"}',
      },
    });
    await nextTick();
    const link = wrapper.find('icon-external');
    expect(link.exists()).toBe(false);
  });
});
