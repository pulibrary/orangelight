import RelatedRecordsDisplayer from 'orangelight/related_records';
import { promises as fs } from 'fs';

describe('RelatedRecords', function() {
    afterEach(jest.clearAllMocks);

    test('on button press', async() => {
        document.body.innerHTML = 
        '<ul id="list"></ul>' +
        '<button data-linked-records-container="list" id="btn">' +
        'Show 10 more linked records</button>';
        const json_response = await fs.readFile("spec/fixtures/files/linked_records.json", 'utf8');
        const displayer = new RelatedRecordsDisplayer(JSON.parse(json_response));

        const list = document.getElementById('list');
        const button = document.getElementById('btn');

        const mockEvent = {"target": button};

        displayer.displayMore(mockEvent);

        expect(list.children.length).toBe(13);
        expect(list.getAttribute('tabindex')).toBe('-1');
        expect(button.textContent).toBe('Show fewer related records');
    });
});