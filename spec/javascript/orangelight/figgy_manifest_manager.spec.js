import { FiggyViewer, FiggyManifestManager, FiggyViewerSet } from 'orangelight/figgy_manifest_manager';
import * as Queries from 'orangelight/load-resources-by-orangelight-id'

describe('RelatedRecords', function() {
    afterEach(jest.clearAllMocks);

    test('viewer iframe has a title', async() => {
        document.body.innerHTML = '<div id="container"></div>';
        const element = document.getElementById('container');
        const viewer = new FiggyViewer(0, element, 'https://example.com');
        viewer.render().then(() => {
            const element = document.getElementById('iframe-1');
            expect(element.getAttribute('title')).toBe('Digital content viewer');
        });
    });

    test('adds request link when graphql notice returns unauthorized for a PUL thesis', async() => {
      const graphqlResponse = {
                                "resourcesByOrangelightId": [
                                  {
                                    "id": "9e42a4eb-42dc-43b6-b476-660d7e489c62",
                                    "__typename": "ScannedResource",
                                    "label": "Qadhafi's thesis",
                                    "embed": {
                                      "type": "",
                                      "content": "",
                                      "status": "unauthorized"
                                    },
                                    "notice": {
                                      "heading": "Terms and Conditions for Using Princeton University Senior Theses",
                                      "textHtml": "<p>The Princeton University Senior Theses DataSpace community is a catalog of theses written by seniors at Princeton University from 1926 to the present. Senior theses submitted from 2014 forward contain a full-text PDF that is accessible only on the Princeton University network. Theses written prior to 2014 are available by visiting the Princeton University Archives at the Mudd Manuscript Library. Email <a href=\"mailto:mudd@princeton.edu\">mudd@princeton.edu</a> with any questions.</p> <p>Most theses are protected by copyright. The copyright law of the United States governs the making of photocopies or other reproductions of material under copyright. Under certain conditions specified in the law, libraries and archives are authorized to furnish a photocopy or other reproduction. These reproductions of copyrighted material must be for educational and/or research purposes consistent with “fair use” as defined by 17 U.S.C. 107. A photocopy or other reproduction provided by a library is not to be “used for any purpose other than private study, scholarship or research.” If a user makes a request for, or later uses, a photocopy or other reproduction for purposes in excess of “fair use,” that individual may be liable for copyright infringement.</p>"
                                    }
                                  }]
                              };

      document.body.innerHTML =
      '<div class="availability--online"><h3>Available Online</h3><ul><li></li></ul></div>' +
      '<div id="view" class="document-viewers" data-bib-id="dsp01wd3760321"></div>';

      const queryFunction = jest.fn((_bibIds) => { return graphqlResponse })

      const availableOnlineElement = document.getElementsByClassName('availability--online');
      const viewerWrapperElement = document.getElementById('view');
      const viewerSet = new FiggyViewerSet(viewerWrapperElement, queryFunction, 'dsp01wd3760321', null)
      await viewerSet.render()
      expect(queryFunction).toHaveBeenCalledTimes(1);
      expect(availableOnlineElement[0].getElementsByTagName('li')).toHaveLength(2);
      expect(viewerWrapperElement.getElementsByTagName('iframe')).toHaveLength(0);
    })

    test('does not error when graphql notice is null', async() => {
      const graphqlResponseNullNotice = {
                                "resourcesByOrangelightId": [
                                  {
                                    "id": "9e42a4eb-42dc-43b6-b476-660d7e489c62",
                                    "__typename": "ScannedResource",
                                    "label": "Qadhafi's thesis",
                                    "embed": {
                                      "type": "",
                                      "content": "",
                                      "status": "unauthorized"
                                    },
                                    "notice": null
                                  }]
                              };

      document.body.innerHTML =
      '<div class="availability--online"><h3>Available Online</h3><ul><li></li></ul></div>' +
      '<div id="view" class="document-viewers" data-bib-id="dsp01wd3760321"></div>';

      const queryFunction2 = jest.fn((_bibIds) => { return graphqlResponseNullNotice })

      const availableOnlineElement = document.getElementsByClassName('availability--online');
      const viewerWrapperElement = document.getElementById('view');
      const viewerSet = new FiggyViewerSet(viewerWrapperElement, queryFunction2, 'dsp01wd3760321', null)
      await viewerSet.render()
      expect(queryFunction2).toHaveBeenCalledTimes(1);
      expect(availableOnlineElement[0].getElementsByTagName('li')).toHaveLength(1);
      expect(viewerWrapperElement.getElementsByTagName('iframe')).toHaveLength(1);
    })
});
