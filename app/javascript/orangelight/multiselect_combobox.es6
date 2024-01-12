import SelectedOptions from "./selected_options.es6"

// This class is responsible for providing a multi-select combobox
// to the user and recording their selections in a hidden <select>
// element.  Loosely based on the Multiselect with comma-separated
// values from this article: https://www.24a11y.com/2019/select-your-poison-part-2/
export default class MultiselectCombobox {
    constructor(inputElement) {
        this.selectedOptions = new SelectedOptions();
        this.inputElement = inputElement;
        this.hiddenSelect = inputElement.closest('.dropdown').querySelector('select')
        this.listElement = inputElement.closest('.dropdown').querySelector('ul')
        this.#addEventListeners();
        this.#applySelections();
    }

    toggleItem(item) {
        this.#toggleListItem(item)
        this.selectedOptions.toggle(item.firstChild.nodeValue)
        this.inputElement.value = this.selectedOptions.toString();
        this.#updateHiddenSelect();
    }

    updateOptionVisibility() {
        const queries = this.inputElement.value.split(';');
        this.listElement.querySelectorAll('li').forEach(item => {
            if(queries.some(query => {
                const normalizedQuery = query.trim().toLowerCase();
                return item.textContent.toLowerCase().includes(normalizedQuery);
            })) {
                item.classList.remove('d-none')
            } else {
                item.classList.add('d-none')
            }
        })
    }

    #addEventListeners() {
        this.listElement.querySelectorAll('li').forEach((item) => {
            item.addEventListener('keyup', (event) => {
                if (event.code == 'Enter') {
                    this.toggleItem(item)
                } else {
                    // Send all other events to the input, so that
                    // anything the user types ends up there
                    this.inputElement.dispatchEvent(new KeyboardEvent('keyup', {key: event.key, code: event.code}))
                }
            })
            item.addEventListener('click', (event) => {
                this.toggleItem(item)

                // Don't propagate the event to the bootstrap event
                // listener.  Otherwise, the dropdown closes every
                // time the user clicks on an item
                event.stopPropagation();
            })
        })
        this.inputElement.addEventListener('input', (event) => {
            this.updateOptionVisibility();
            this.#openDropdownIfClosed();
        })
    }

    #applySelections() {
        this.hiddenSelect.querySelectorAll('option:checked').forEach(selectedOption => {
            this.toggleItem(this.#getListItemByText(selectedOption.text))
        })
    }

    #toggleListItem(item) {
        const icon = `<span class="fa fa-check" aria-hidden="true"></span>`

        if(this.selectedOptions.contains(item.firstChild.nodeValue)) {
            item.querySelectorAll('span').forEach(span => span.remove())
            item.classList.remove('active')
            item.setAttribute('aria-selected', 'false')
        } else {
            item.innerHTML += icon
            item.classList.add('active')
            item.setAttribute('aria-selected', 'true')
        }
    }

    #updateHiddenSelect() {
        this.hiddenSelect.querySelectorAll('option').forEach((option) => {
            if (this.selectedOptions.contains(option.textContent.trim())) {
                option.setAttribute('selected', 'selected')
            } else {
                option.removeAttribute('selected')
            }
        })
    }

    #getListItemByText(text) {
        return Array.from(this.listElement.children).find((item) => {
            return item.textContent.trim() === text.trim()
        })
    }

    // Note: Bootstrap 4 requires jquery to open a dropdown.
    // When we move to Bootstrap 5, we should use vanilla js
    // here instead
    #openDropdownIfClosed() {
        if (!this.listElement.classList.contains('show')) {
            $(`#${this.inputElement.id}`).dropdown('toggle')
        }
    }
}
