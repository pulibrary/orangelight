import loader from 'orangelight/orangelight_ui_loader'
import FiggyManifestManager from 'orangelight/figgy_manifest_manager'

describe('OrangelightUiLoader', function() {
  test('hooked up right', () => {
    expect(loader).not.toBe(undefined)
  })

  test('Focus on First Element', () => {
    document.body.innerHTML =
      '<div id="blacklight-modal">'+
      '<input type="hidden" id="one">'+
      '<input type="tel" id="two">'+
      '<input type="text" id="three"></div>'
    let l = new loader
    l.setup_modal_focus()
    expect(document.activeElement.id).toEqual('')

    // trigger event
    $("#blacklight-modal").trigger("shown.bs.modal")
    // check for focus
    expect(document.activeElement.id).toEqual('two')
  })

  test("Doesn't call Figgy if there's no IDs to call", () => {
    document.body.innerHTML = ''
    const spy = jest.spyOn(FiggyManifestManager, 'buildThumbnailSet')
    const spy2 = jest.spyOn(FiggyManifestManager, 'buildMonogramThumbnails')
    let l = new loader
    l.setup_viewers()
    expect(spy).not.toHaveBeenCalled()
    expect(spy2).not.toHaveBeenCalled()
  })
})
