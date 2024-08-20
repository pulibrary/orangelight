import { mount } from '@vue/test-utils';
import OrangelightHeader from '../../../../app/javascript/orangelight/vue_components/orangelight_header.vue';
import { nextTick } from 'vue';

describe('OrangelightHeader', () => {
  let wrapper;

  describe('when not logged in yet', () => {
    jest.useFakeTimers();
    beforeEach(() => {
      wrapper = mount(OrangelightHeader, {
        props: {
          loggedIn: false,
          bookmarks: 2,
        },
      });
    });

    it('includes the name of the application', () => {
      expect(wrapper.text()).toContain('Catalog');
    });

    it('has Help and Feedback top-level menu items', () => {
      const helpLink = wrapper.get('a[href="/help/"]');
      expect(helpLink.text()).toEqual('Help');
      const feedbackLink = wrapper.get('a[href="/feedback/"]');
      expect(feedbackLink.text()).toEqual('Feedback');
    });

    it('has Library Account, Bookmarks, and Search History under the Library Account', () => {
      wrapper.get('button.lux-submenu-toggle').trigger('click');
      const accountLink = wrapper.get(
        'a[href="/users/sign_in?origin=%2Fredirect-to-alma"]'
      );
      expect(accountLink.text()).toEqual('Library Account');

      const bookmarksLink = wrapper.get('a[href="/bookmarks/"]');
      expect(bookmarksLink.text()).toEqual('Bookmarks (2)');

      const searchHistoryLink = wrapper.get('a[href="/search_history/"]');
      expect(searchHistoryLink.text()).toEqual('Search History');
    });

    describe('when a user tries to sign in', () => {
      it('takes the net id from a fetch request after 2 seconds', () => {
        // Open the submenu
        wrapper.get('button.lux-submenu-toggle').trigger('click');

        // Click the Sign In link
        wrapper
          .get('a[href="/users/sign_in?origin=%2Fredirect-to-alma"]')
          .trigger('click');

        // Mock fetch
        global.fetch = jest.fn(() =>
          Promise.resolve({
            json: () => Promise.resolve({ user_id: 'cd5678' }),
          })
        );

        expect(fetch).not.toHaveBeenCalled();

        // Advance the timer by 2 seconds
        jest.advanceTimersByTime(2000);

        // Expect the netId to have been set from the fetch response
        expect(fetch).toHaveBeenCalledTimes(1);
      });
    });
  });

  describe('when you have already logged in', () => {
    beforeEach(() => {
      wrapper = mount(OrangelightHeader, {
        props: {
          loggedIn: true,
          bookmarks: 2,
        },
      });
    });
    it('has Library Account, ILL, Bookmarks, Search History, and Log out under the Library Account', () => {
      wrapper.get('button.lux-submenu-toggle').trigger('click');
      const accountLink = wrapper.get(
        'a[href="/users/sign_in?origin=%2Fredirect-to-alma"]'
      );
      expect(accountLink.text()).toEqual('Library Account');

      const digitizationLink = wrapper.get(
        'a[href="/account/digitization_requests/"]'
      );
      expect(digitizationLink.text()).toEqual('ILL & Digitization Requests');

      const bookmarksLink = wrapper.get('a[href="/bookmarks/"]');
      expect(bookmarksLink.text()).toEqual('Bookmarks (2)');

      const searchHistoryLink = wrapper.get('a[href="/search_history/"]');
      expect(searchHistoryLink.text()).toEqual('Search History');

      const logOutLink = wrapper.get('a[href="/sign_out/"]');
      expect(logOutLink.text()).toEqual('Log Out');
    });
    describe('when netId prop is passed', () => {
      beforeEach(() => {
        wrapper = mount(OrangelightHeader, {
          props: {
            loggedIn: true,
            bookmarks: 2,
            netId: 'ab1234',
          },
        });
      });
      it('displays the netId', () => {
        expect(wrapper.get('button.lux-submenu-toggle').text()).toEqual(
          'ab1234'
        );
      });
    });
  });
});
