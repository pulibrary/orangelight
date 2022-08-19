import { exportedForTesting } from 'orangelight/figgy_manifest_manager';
const { FiggyViewer } = exportedForTesting;

describe('RelatedRecords', function() {
    afterEach(jest.clearAllMocks);

    test('viewer iframe has a title', async() => {
        document.body.innerHTML = '<div id="container"></div>';
        const element = document.getElementById('container');
        const viewer = new FiggyViewer(0, element, 'https://example.com', []);
        viewer.render().then(() => {
            const element = document.getElementById('iframe-1');
            expect(element.getAttribute('title')).toBe('Digital content viewer');
        });
    });
});