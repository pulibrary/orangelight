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
});
