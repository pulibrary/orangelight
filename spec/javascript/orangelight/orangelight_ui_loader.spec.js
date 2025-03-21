import loader from '../../../app/javascript/orangelight/orangelight_ui_loader.es6';
import { FiggyManifestManager } from '../../../app/javascript/orangelight/figgy_manifest_manager';

describe('OrangelightUiLoader', function () {
  afterEach(vi.clearAllMocks);

  test('hooked up right', () => {
    expect(loader).not.toBe(undefined);
  });

  test('Focus on First Element', () => {
    document.body.innerHTML =
      '<div id="blacklight-modal">' +
      '<input type="hidden" id="one">' +
      '<input type="tel" id="two">' +
      '<input type="text" id="three"></div>';
    const l = new loader();
    l.setup_modal_focus();
    expect(document.activeElement.id).toEqual('');

    // trigger event
    $('#blacklight-modal').trigger('shown.bs.modal');
    // check for focus
    expect(document.activeElement.id).toEqual('two');
  });

  test('Focus on first textarea', () => {
    document.body.innerHTML =
      '<div id="blacklight-modal">' +
      '<input type="hidden" id="one">' +
      '<textarea id="two-but-textarea"></textarea>' +
      '<input type="text" id="three"></div>';
    const l = new loader();
    l.setup_modal_focus();
    expect(document.activeElement.id).toEqual('');

    // trigger event
    $('#blacklight-modal').trigger('shown.bs.modal');
    // check for focus
    expect(document.activeElement.id).toEqual('two-but-textarea');
  });

  test("Doesn't call Figgy if there's no IDs to call", () => {
    document.body.innerHTML = '';
    const spy = vi.spyOn(FiggyManifestManager, 'buildThumbnailSet');
    const spy2 = vi.spyOn(FiggyManifestManager, 'buildMonogramThumbnails');
    const l = new loader();
    l.setup_viewers();
    expect(spy).toHaveBeenCalledTimes(0);
    expect(spy2).toHaveBeenCalledTimes(0);
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
    const element =
      "<div id='view' class='document-viewers' data-bib-id='9946093213506422'>";
    vi.spyOn(FiggyManifestManager, 'buildViewers');
    await FiggyManifestManager.buildViewers(element);
    const l = new loader();
    l.setup_viewers();
    // It calls Figgy once.
    expect(FiggyManifestManager.buildViewers).toHaveBeenCalledTimes(1);
  });
});
