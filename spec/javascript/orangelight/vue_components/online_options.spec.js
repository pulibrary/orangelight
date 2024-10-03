import { mount } from '@vue/test-utils';
import OnlineOptions from '../../../../app/javascript/orangelight/vue_components/online_options.vue';

describe('OnlineOptions', () => {
  it('shows a link', () => {
    const wrapper = mount(OnlineOptions, {
      props: {
        documentId: '99131181127806421',
      },
    });
    expect(wrapper.get('a').text()).toContain('Online options');
  });
  it('links to the available online section of the show page', () => {
    const wrapper = mount(OnlineOptions, {
      props: {
        documentId: '99131181127806421',
      },
    });
    expect(wrapper.get('a').attributes('href')).toEqual(
      '/catalog/99131181127806421#available-online'
    );
  });
});
