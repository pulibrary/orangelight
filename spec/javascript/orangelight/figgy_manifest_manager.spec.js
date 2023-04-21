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

    test('displays one viewer for ScannedMaps', async() => {
      const graphqlResponse = {
                                "resourcesByOrangelightId": [
                                  {
                                    "id": "26b01ff3-eb40-40b0-821c-42fade1cf349",
                                    "thumbnail": {
                                      "iiifServiceUrl": "https://iiif-cloud.princeton.edu/iiif/2/84%2Fda%2Ff9%2F84daf940542e425a8c97fbfe53858b57%2Fintermediate_file",
                                      "thumbnailUrl": "https://iiif-cloud.princeton.edu/iiif/2/84%2Fda%2Ff9%2F84daf940542e425a8c97fbfe53858b57%2Fintermediate_file/full/!200,150/0/default.jpg",
                                      "__typename": "Thumbnail"
                                    },
                                    "label": "Pennsylvania: Troy Quadrangle.",
                                    "url": "https://figgy.princeton.edu/catalog/26b01ff3-eb40-40b0-821c-42fade1cf349",
                                    "memberIds": [
                                      "85773d63-8a3a-4cea-b1c3-d9d0196bac3f"
                                    ],
                                    "embed": {
                                      "type": "html",
                                      "content": "\u003ciframe allowfullscreen=\"true\" id=\"uv_iframe\" src=\"https://figgy.princeton.edu/viewer#?manifest=https://figgy.princeton.edu/concern/scanned_maps/26b01ff3-eb40-40b0-821c-42fade1cf349/manifest\"\u003e\u003c/iframe\u003e",
                                      "status": "authorized",
                                      "__typename": "Embed"
                                    },
                                    "notice": null,
                                    "manifestUrl": "https://figgy.princeton.edu/concern/scanned_maps/26b01ff3-eb40-40b0-821c-42fade1cf349/manifest",
                                    "__typename": "ScannedMap"
                                  },
                                  {
                                    "id": "a65bd135-5356-4613-8089-d90fc445cfda",
                                    "thumbnail": {
                                      "iiifServiceUrl": "https://iiif-cloud.princeton.edu/iiif/2/0f%2F6a%2F0d%2F0f6a0dcac6054d19987c6048854f505d%2Fintermediate_file",
                                      "thumbnailUrl": "https://iiif-cloud.princeton.edu/iiif/2/0f%2F6a%2F0d%2F0f6a0dcac6054d19987c6048854f505d%2Fintermediate_file/full/!200,150/0/default.jpg",
                                      "__typename": "Thumbnail"
                                    },
                                    "label": "Pennsylvania: (Lycoming) Trout Run Quadrangle",
                                    "url": "https://figgy.princeton.edu/catalog/a65bd135-5356-4613-8089-d90fc445cfda",
                                    "memberIds": [
                                      "595ee476-d247-4339-83e2-bddb90a7d069",
                                      "26b01ff3-eb40-40b0-821c-42fade1cf349"
                                    ],
                                    "embed": {
                                      "type": "html",
                                      "content": "\u003ciframe allowfullscreen=\"true\" id=\"uv_iframe\" src=\"https://figgy.princeton.edu/viewer#?manifest=https://figgy.princeton.edu/concern/scanned_maps/a65bd135-5356-4613-8089-d90fc445cfda/manifest\"\u003e\u003c/iframe\u003e",
                                      "status": "authorized",
                                      "__typename": "Embed"
                                    },
                                    "notice": null,
                                    "manifestUrl": "https://figgy.princeton.edu/concern/scanned_maps/a65bd135-5356-4613-8089-d90fc445cfda/manifest",
                                    "__typename": "ScannedMap"
                                  },
                                  {
                                    "id": "595ee476-d247-4339-83e2-bddb90a7d069",
                                    "thumbnail": {
                                      "iiifServiceUrl": "https://iiif-cloud.princeton.edu/iiif/2/0f%2F6a%2F0d%2F0f6a0dcac6054d19987c6048854f505d%2Fintermediate_file",
                                      "thumbnailUrl": "https://iiif-cloud.princeton.edu/iiif/2/0f%2F6a%2F0d%2F0f6a0dcac6054d19987c6048854f505d%2Fintermediate_file/full/!200,150/0/default.jpg",
                                      "__typename": "Thumbnail"
                                    },
                                    "label": "Pennsylvania: (Lycoming) Trout Run Quadrangle (Lycoming)",
                                    "url": "https://figgy.princeton.edu/catalog/595ee476-d247-4339-83e2-bddb90a7d069",
                                    "memberIds": [
                                      "8fa8bc9b-b0e9-456c-a1ee-a913b2499054"
                                    ],
                                    "embed": {
                                      "type": "html",
                                      "content": "\u003ciframe allowfullscreen=\"true\" id=\"uv_iframe\" src=\"https://figgy.princeton.edu/viewer#?manifest=https://figgy.princeton.edu/concern/scanned_maps/595ee476-d247-4339-83e2-bddb90a7d069/manifest\"\u003e\u003c/iframe\u003e",
                                      "status": "authorized",
                                      "__typename": "Embed"
                                    },
                                    "notice": null,
                                    "manifestUrl": "https://figgy.princeton.edu/concern/scanned_maps/595ee476-d247-4339-83e2-bddb90a7d069/manifest",
                                    "__typename": "ScannedMap"
                                  }
                                ]
                              };

      document.body.innerHTML =
      '<div class="availability--online"><h3>Available Online</h3><ul><li></li></ul></div>' +
      '<div id="view" class="document-viewers" data-bib-id="9968683243506421"></div>';

      const queryFunction = jest.fn((_bibIds) => { return graphqlResponse })
      const availableOnlineElement = document.getElementsByClassName('availability--online');
      const viewerWrapperElement = document.getElementById('view');

      const viewerSet = new FiggyViewerSet(viewerWrapperElement, queryFunction, '9968683243506421', null)
      await viewerSet.render()
      expect(viewerWrapperElement.getElementsByTagName('iframe')).toHaveLength(1);
    })

    test('displays two viewers for objects with multi-spectral imaging', async() => {
      const graphqlResponse = {
                                "resourcesByOrangelightId": [
                                  {
                                    "id": "bbc6f6c4-3b92-4ae9-8461-1a14c113af8c",
                                    "thumbnail": {
                                      "iiifServiceUrl": "https://iiif-cloud.princeton.edu/iiif/2/e4%2F2c%2F68%2Fe42c680b62c44540836cb59164cead42%2Fintermediate_file",
                                      "thumbnailUrl": "https://iiif-cloud.princeton.edu/iiif/2/e4%2F2c%2F68%2Fe42c680b62c44540836cb59164cead42%2Fintermediate_file/full/!200,150/0/default.jpg",
                                      "__typename": "Thumbnail"
                                    },
                                    "label": "At a Council held at Boston March 8. 1679,80. : The governour and Council, upon mature consideration of the many loud calls of Providence ... Do therefore appoint and order, that the fifteenth day of April next, be set apart for a day of humiliation and prayer ...",
                                    "url": "https://figgy.princeton.edu/catalog/bbc6f6c4-3b92-4ae9-8461-1a14c113af8c",
                                    "memberIds": [
                                      "8ecd795b-cd1b-4efc-9f1b-1411574d948c",
                                      "2e6c63af-7e2d-4191-a1b6-b4113394ce33"
                                    ],
                                    "embed": {
                                      "type": "html",
                                      "content": "\u003ciframe allowfullscreen=\"true\" id=\"uv_iframe\" src=\"https://figgy.princeton.edu/viewer#?manifest=https://figgy.princeton.edu/concern/scanned_resources/bbc6f6c4-3b92-4ae9-8461-1a14c113af8c/manifest\"\u003e\u003c/iframe\u003e",
                                      "status": "authorized",
                                      "__typename": "Embed"
                                    },
                                    "notice": null,
                                    "manifestUrl": "https://figgy.princeton.edu/concern/scanned_resources/bbc6f6c4-3b92-4ae9-8461-1a14c113af8c/manifest",
                                    "__typename": "ScannedResource"
                                  },
                                  {
                                    "id": "54b399c7-f28c-46f6-a7b4-c835a60516c4",
                                    "thumbnail": {
                                      "iiifServiceUrl": "https://iiif-cloud.princeton.edu/iiif/2/bb%2Ffa%2F24%2Fbbfa247e175149db8d9151180dfa3896%2Fintermediate_file",
                                      "thumbnailUrl": "https://iiif-cloud.princeton.edu/iiif/2/bb%2Ffa%2F24%2Fbbfa247e175149db8d9151180dfa3896%2Fintermediate_file/full/!200,150/0/default.jpg",
                                      "__typename": "Thumbnail"
                                    },
                                    "label": "At a Council held at Boston March 8. 1679,80. : The governour and Council, upon mature consideration of the many loud calls of Providence ... Do therefore appoint and order, that the fifteenth day of April next, be set apart for a day of humiliation and prayer ...",
                                    "url": "https://figgy.princeton.edu/catalog/54b399c7-f28c-46f6-a7b4-c835a60516c4",
                                    "memberIds": [
                                      "b9ce8d56-2ab7-48e0-8e97-d510b904f920",
                                      "e3e5ba6b-e7c6-4016-8c62-fe6656c020ca"
                                    ],
                                    "embed": {
                                      "type": "html",
                                      "content": "\u003ciframe allowfullscreen=\"true\" id=\"uv_iframe\" src=\"https://figgy.princeton.edu/viewer#?manifest=https://figgy.princeton.edu/concern/scanned_resources/54b399c7-f28c-46f6-a7b4-c835a60516c4/manifest\"\u003e\u003c/iframe\u003e",
                                      "status": "authorized",
                                      "__typename": "Embed"
                                    },
                                    "notice": null,
                                    "manifestUrl": "https://figgy.princeton.edu/concern/scanned_resources/54b399c7-f28c-46f6-a7b4-c835a60516c4/manifest",
                                    "__typename": "ScannedResource"
                                  }
                                ]
                              };
      document.body.innerHTML =
      '<div class="availability--online"><h3>Available Online</h3><ul><li></li></ul></div>' +
      '<div id="view" class="document-viewers" data-bib-id="9950403683506421"></div>';
  
      const queryFunction = jest.fn((_bibIds) => { return graphqlResponse })
      const viewerWrapperElement = document.getElementById('view');
      const viewerSet = new FiggyViewerSet(viewerWrapperElement, queryFunction, '9950403683506421', null)
      await viewerSet.render()
      expect(viewerWrapperElement.getElementsByTagName('iframe')).toHaveLength(2);
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
