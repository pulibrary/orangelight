import { mount } from '@vue/test-utils';
import { describe, expect } from 'vitest';
import BookmarkLoginDialog from '../../../../app/javascript/orangelight/vue_components/bookmark_login_dialog.vue';

describe('BookmarkLoginDialog', () => {
  it('calls the native HTMLDialogElement close() method when the user presses the close button', () => {
    const wrapper = mount(BookmarkLoginDialog);
    // Unfortunately, we need to mock the HTMLDialogElement's methods,
    // since JSDOM has not yet implemented HTMLDialogElement at the
    // time of writing (see https://github.com/jsdom/jsdom/issues/3294)
    //
    // It would be nicer to use the real HTMLDialogElement methods and
    // make assertions about whether or not the modal is visible on the
    // screen.
    wrapper.vm.$refs.dialog.close = vi.fn();

    wrapper.find('button').trigger('click');

    expect(wrapper.vm.$refs.dialog.close).toHaveBeenCalled();
  });
});
