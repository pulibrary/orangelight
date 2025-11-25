import loader from '../../../app/javascript/orangelight/orangelight_ui_loader.es6';
import { FiggyManifestManager } from '../../../app/javascript/orangelight/figgy_manifest_manager';

describe('OrangelightUiLoader', function () {
  afterEach(vi.clearAllMocks);

  test('hooked up right', () => {
    expect(loader).not.toBe(undefined);
  });

  test("Doesn't call Figgy if there's no IDs to call", () => {
    document.body.innerHTML = '';
    const spy = vi.spyOn(FiggyManifestManager, 'buildThumbnailSet');
    const l = new loader();
    l.setup_viewers();
    expect(spy).toHaveBeenCalledTimes(0);
  });

  test('If there is an ID, It calls Figgy to build a thumbnailSet', async () => {
    const element =
      "<div class='document-thumbnail has-viewer-link' data-bib-id='coin-11362'>";
    vi.spyOn(FiggyManifestManager, 'buildThumbnailSet');
    await FiggyManifestManager.buildThumbnailSet(element);
    const l = new loader();
    l.setup_viewers();
    expect(FiggyManifestManager.buildThumbnailSet).toHaveBeenCalledTimes(1);
  });

  test('if there is an ID, it calls figgy to build a viewer', async () => {
    const element = document.createElement('div');
    element.setAttribute('id', 'view');
    element.setAttribute('class', 'document-viewers');
    element.setAttribute('data-bib-id', '9946093213506422');
    vi.spyOn(FiggyManifestManager, 'buildViewers');
    await FiggyManifestManager.buildViewers(element);
    const l = new loader();
    l.setup_viewers();
    // It calls Figgy once.
    expect(FiggyManifestManager.buildViewers).toHaveBeenCalledTimes(1);
  });

  test('it makes the fadeout() function available globally', () => {
    expect(window.fadeout).toBeUndefined();
    new loader().run();
    expect(window.fadeout).toBeDefined();
  });
});
