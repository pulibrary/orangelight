import { insert_online_link, insert_online_header } from 'orangelight/insert_online_link'

describe('insert_online_link', function() {
  test('insert_online_header() when there was no header', () => {
    document.body.innerHTML =
      '<div class="wrapper"><div class="availability--physical"></div></div>'
    insert_online_header()

    const onlineDiv = document.getElementsByClassName('availability--online')
    expect(onlineDiv.length).toEqual(1)
  })

  test("insert_online_header() doesn't add a new one when there was already a header", () => {
    document.body.innerHTML =
      '<div class="wrapper"><div class="availability--online"></div><div class="availability--physical"></div></div>'
    insert_online_header()

    const onlineDiv = document.getElementsByClassName('availability--online')
    expect(onlineDiv.length).toEqual(1)
  })

  test("insert_online_link() adds a new link to the list", () => {
    document.body.innerHTML =
      '<div class="wrapper"><div class="availability--online"><ul></ul></div><div class="availability--physical"></div></div>'
    insert_online_link()
    insert_online_link()

    const li_elements = document.getElementsByTagName('li')
    expect(li_elements.length).toEqual(1)
    let list_item = li_elements.item(0)
    expect(list_item.textContent).toEqual("Princeton users: View digital content")
    const anchor = list_item.getElementsByTagName('a').item(0)
    expect(anchor.getAttribute("href")).toEqual("#view")
    expect(anchor.getAttribute("target")).toEqual("_self")
  })

  test("insert_online_link() can accept a content builder", () => {
    document.body.innerHTML =
      '<div class="wrapper"><div class="availability--online"><ul></ul></div><div class="availability--physical"></div></div>'
    insert_online_link("#view", "id", (link, target) => `${link}${target}`)

    const li_elements = document.getElementsByTagName('li')
    expect(li_elements.length).toEqual(1)
    let list_item = li_elements.item(0)
    expect(list_item.textContent).toEqual("#view_self")
  })
})
