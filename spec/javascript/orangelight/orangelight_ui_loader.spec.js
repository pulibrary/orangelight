import loader from 'orangelight/orangelight_ui_loader'

describe('OrangelightUILoader', function() {
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
    l.run()
    expect(document.activeElement.id).toEqual('')

    // trigger event
    $("#blacklight-modal").trigger("shown.bs.modal")
    // check for focus
    expect(document.activeElement.id).toEqual('two')
  })
})
