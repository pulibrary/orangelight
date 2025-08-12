import { beforeEach, describe } from 'vitest';
import { mount } from '@vue/test-utils';
import BookmarkButton from '../../../../app/javascript/orangelight/vue_components/bookmark_button.vue';
import { nextTick } from 'vue';

let wrapper;

describe('BookmarkButton', () => {
  beforeEach(() => {
    vi.stubGlobal(
      'fetch',
      vi
        .fn()
        .mockReturnValue(
          Promise.resolve(new Response('{"bookmarks":{"count":8}}'))
        )
    );
  });
  describe('when the item is not in bookmarks', () => {
    beforeEach(() => {
      wrapper = mount(BookmarkButton, {
        props: { inBookmarks: false, documentId: '123' },
      });
    });
    it('has the text Bookmark', () => {
      expect(wrapper.text().trim()).toEqual('Bookmark');
    });
    it('includes its status in the DOM as an attribute', () => {
      expect(wrapper.get('button').attributes('ol-state')).toEqual(
        'not-in-bookmarks'
      );
    });
  });

  describe('when the item is not in bookmarks and user is not logged in', () => {
    beforeEach(async () => {
      wrapper.setProps({ loggedIn: false });
      await nextTick();
    });
    it('records in local storage the time we advised the user they should sign in', () => {
      vi.stubGlobal('localStorage', { getItem: vi.fn(), setItem: vi.fn() });
      vi.setSystemTime(new Date(Date.UTC(2030, 0, 5))); // Midnight UTC on January 5, 2030

      wrapper.get('button').trigger('click');
      expect(window.localStorage.setItem).toHaveBeenCalledWith(
        'catalog.bookmarks.save_account_alert',
        '2030-01-05T00:00:00.000Z'
      );
    });
    it('does not update existing local storage values', () => {
      vi.stubGlobal('localStorage', {
        getItem: vi.fn().mockReturnValue('2025-07-13T00:00:00.000Z'),
        setItem: vi.fn(),
      });
      vi.setSystemTime(new Date(Date.UTC(2030, 0, 5))); // Midnight UTC on January 5, 2030

      wrapper.get('button').trigger('click');
      expect(window.localStorage.setItem).not.toHaveBeenCalled();
    });
  });

  describe('when the item is not in bookmarks and user is logged in', () => {
    beforeEach(async () => {
      wrapper.setProps({ loggedIn: true });
      await nextTick();
    });
    it('does not consult local storage', () => {
      vi.stubGlobal('localStorage', {
        getItem: vi.fn().mockReturnValue('2025-07-13T00:00:00.000Z'),
        setItem: vi.fn(),
      });
      vi.setSystemTime(new Date(Date.UTC(2030, 0, 5))); // Midnight UTC on January 5, 2030

      wrapper.get('button').trigger('click');
      expect(window.localStorage.getItem).not.toHaveBeenCalled();
      expect(window.localStorage.setItem).not.toHaveBeenCalled();
    });
  });

  describe('when the item is in bookmarks', () => {
    beforeEach(async () => {
      wrapper.setProps({ inBookmarks: true });
      await nextTick();
    });
    it('has the text In Bookmarks', () => {
      expect(wrapper.text().trim()).toEqual('In Bookmarks');
    });
    it('does not consult local storage', () => {
      vi.stubGlobal('localStorage', {
        getItem: vi.fn().mockReturnValue('2025-07-13T00:00:00.000Z'),
        setItem: vi.fn(),
      });
      vi.setSystemTime(new Date(Date.UTC(2030, 0, 5))); // Midnight UTC on January 5, 2030

      wrapper.get('button').trigger('click');
      expect(window.localStorage.getItem).not.toHaveBeenCalled();
      expect(window.localStorage.setItem).not.toHaveBeenCalled();
    });
  });
});
