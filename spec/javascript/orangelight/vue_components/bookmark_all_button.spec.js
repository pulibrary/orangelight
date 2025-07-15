import { mount } from '@vue/test-utils';
import { beforeEach, describe, it, vi } from 'vitest';
import BookmarkAllButton from '../../../../app/javascript/orangelight/vue_components/bookmark_all_button.vue';

const { JSDOM } = require('jsdom');

let wrapper;

describe('BookmarkAllButton', () => {
  describe('when no documents are bookmarked', () => {
    beforeEach(() => {
      vi.stubGlobal(
        'document',
        new JSDOM(`
            <div id="vue-mount"></div>
            <div class="bookmark-button">
                <button ol-state="not-in-bookmarks">Bookmark</button>
                <button ol-state="not-in-bookmarks">Bookmark</button>
            </div>`).window.document
      );
    });
    it('bookmarks all documents', () => {
      const buttonClicks = Array.from(document.querySelectorAll('button')).map(
        (button) => vi.spyOn(button, 'click')
      );
      wrapper = mount(BookmarkAllButton, {
        attachTo: document.getElementById('vue-mount'),
      });

      wrapper.get('button').trigger('click');

      expect(buttonClicks[0]).toHaveBeenCalled();
      expect(buttonClicks[1]).toHaveBeenCalled();
    });
  });

  describe('when some documents are bookmarked', () => {
    beforeEach(() => {
      vi.stubGlobal(
        'document',
        new JSDOM(`
            <div id="vue-mount"></div>
            <div class="bookmark-button">
                <button ol-state="in-bookmarks">In bookmarks</button>
                <button ol-state="not-in-bookmarks">Bookmark</button>
            </div>`).window.document
      );
    });
    it('bookmarks only documents that are not yet in bookmarks', () => {
      const buttonClicks = Array.from(document.querySelectorAll('button')).map(
        (button) => vi.spyOn(button, 'click')
      );
      wrapper = mount(BookmarkAllButton, {
        attachTo: document.getElementById('vue-mount'),
      });

      wrapper.get('button').trigger('click');

      expect(buttonClicks[0]).not.toHaveBeenCalled();
      expect(buttonClicks[1]).toHaveBeenCalled();
    });
  });
  describe('when all documents are bookmarked', () => {
    beforeEach(() => {
      vi.stubGlobal(
        'document',
        new JSDOM(`
            <div id="vue-mount"></div>
            <div class="bookmark-button">
                <button ol-state="in-bookmarks">In bookmarks</button>
                <button ol-state="in-bookmarks">In bookmarks</button>
            </div>`).window.document
      );
    });
    it('removes all documents from bookmarks', () => {
      const buttonClicks = Array.from(document.querySelectorAll('button')).map(
        (button) => vi.spyOn(button, 'click')
      );
      wrapper = mount(BookmarkAllButton, {
        attachTo: document.getElementById('vue-mount'),
      });

      wrapper.get('button').trigger('click');

      expect(buttonClicks[0]).toHaveBeenCalled();
      expect(buttonClicks[1]).toHaveBeenCalled();
    });
  });
});
