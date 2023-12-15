// This class is responsible for creating a type-ahead
// multi-select comboboxes based on a <select> elements that exists
// in the DOM.
//
// It does this by hiding the <select> from all users,
// and presenting a more usable <input>/listbox.  When users choose
// values in the visible combobox, the changes are also reflected
// in the hidden <select>, and that value is ultimately sent
// to the server when the user submits the form.
//
// It uses patterns from the aria practices guide "Editable combobox
// with list autocomplete" (https://www.w3.org/WAI/ARIA/apg/patterns/combobox/examples/combobox-autocomplete-list/)
// and Sarah Higley's "<select> your poision" article
// (https://www.24a11y.com/2019/select-your-poison-part-2)

export default class Combobox {
  constructor(select) {
    this.#calculateIds(select.id)

    const newInput = document.createElement('input')
    newInput.setAttribute('id', this.inputId)
    newInput.setAttribute('aria-autocomplete', 'list')
    newInput.setAttribute('aria-controls', this.listboxId)
    newInput.setAttribute('aria-expanded', 'false')
    newInput.setAttribute('role', 'combobox')
    newInput.addEventListener('keyup', (event) => {
      switch (event.code) {
        case 'ArrowDown':
          this.#open()
          break
        case 'Escape':
          this.#close()
          break
      }
    })
    newInput.addEventListener('input', () => {
      document
        .getElementById(this.listboxId)
        .childNodes.forEach((listEntry) => {
          if (
            listEntry.innerText.includes(
              document.getElementById(this.inputId).value
            )
          ) {
            listEntry.classList.remove('d-none')
          } else {
            listEntry.classList.add('d-none')
          }
        })
      this.#open()
    })
    select.parentElement.append(newInput)

    const newListbox = document.createElement('ul')
    newListbox.id = this.listboxId
    newListbox.setAttribute('role', 'listbox')
    newListbox.setAttribute('aria-label', 'Options')
    // Don't display the listbox initially
    newListbox.classList.add('d-none')
    select.parentElement.append(newListbox)

    select.querySelectorAll('option').forEach((option, index) => {
      const newEntry = document.createElement('li')
      newEntry.innerText = option.text
      newEntry.setAttribute('role', 'option')
      newEntry.id = this.listboxId + '-' + index
      document.getElementById(this.listboxId).appendChild(newEntry)
    })

    this.#hideSelect(select)
  }

  #calculateIds(originalId) {
    this.inputId = originalId
    this.selectId = originalId + '-select'
    this.listboxId = originalId + '-listbox'
  }

  #hideSelect(select) {
    this.selectId = this.inputId + '-select'
    select.id = this.selectId
    select.classList.add('d-none')
  }

  #open() {
    document.getElementById(this.listboxId).classList.remove('d-none')
    document.getElementById(this.inputId).setAttribute('aria-expanded', 'true')
    const input = document.getElementById(this.inputId)
    input.setAttribute('aria-expanded', 'true')
    // Set focus to the first item that matches
    document
      .getElementById(this.listboxId)
      .childNodes.forEach((listEntry, index) => {
        if (!listEntry.classList.contains('d-none')) {
          this.#setFocusToIndex(index)
          return
        }
      })
    this.#setFocusToIndex(0)
  }

  #close() {
    document.getElementById(this.listboxId).classList.add('d-none')
    document.getElementById(this.inputId).setAttribute('aria-expanded', 'false')
    document
      .getElementById(this.inputId)
      .setAttribute('aria-activedescendant', '')
  }

  #setFocusToIndex(index) {
    const idToSelect = this.listboxId + '-' + index
    const input = document.getElementById(this.inputId)
    input.setAttribute('aria-activedescendant', idToSelect)
    document
      .getElementById(idToSelect)
      .classList.add('bg-primary', 'text-white')
  }
}
