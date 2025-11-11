import RelatedRecordsDisplayer from '../../../app/javascript/orangelight/related_records.es6';
import { promises as fs } from 'fs';

describe('RelatedRecords', function () {
  afterEach(vi.clearAllMocks);

  test('on button press', async () => {
    document.body.innerHTML =
      '<ul id="list"></ul>' +
      '<button aria-expanded="false" aria-controls="list" ' +
      'data-maximum-default-values="3" ' +
      'data-show-more-text="Show 10 more related records" ' +
      'data-show-less-text="Show fewer related records" id="btn">' +
      'Show 10 more linked records</button>';
    const json_response = await fs.readFile(
      'spec/fixtures/files/linked_records.json',
      'utf8'
    );
    const displayer = new RelatedRecordsDisplayer(JSON.parse(json_response));

    const list = document.getElementById('list');
    const button = document.getElementById('btn');

    const mockEvent = { target: button };

    displayer.displayMore(mockEvent);

    expect(list.children.length).toBe(13);
    expect(list.getAttribute('tabindex')).toBe('-1');
    expect(button.innerHTML).toBe(
      '<i class="pe-none toggle"></i> Show fewer related records'
    );
    expect(button.getAttribute('aria-expanded')).toBe('true');
  });
  describe('fetchData()', () => {
    test('it uses the X-CSRF token in the request', async () => {
      document.body.innerHTML = '<meta name="csrf-token" content="my-token" />';
      global.fetch = vi.fn(() => Promise.resolve(new Response('[]')));

      await RelatedRecordsDisplayer.fetchData('my_field', '123');

      expect(global.fetch).toHaveBeenCalledWith(
        '/catalog/123/linked_records/my_field',
        { headers: { 'X-CSRF-Token': 'my-token' }, method: 'POST' }
      );
    });
    test('it does not fail if the meta tag is missing for some reason', async () => {
      document.body.innerHTML =
        '<meta name="some-other-meta" content="some-other-content" />';
      global.fetch = vi.fn(() => Promise.resolve(new Response('[]')));

      expect(
        async () => await RelatedRecordsDisplayer.fetchData('my_field', '123')
      ).not.toThrowError();
    });
  });
});
