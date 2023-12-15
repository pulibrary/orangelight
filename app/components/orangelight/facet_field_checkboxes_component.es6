import Combobox from "./combobox.es6"

// This class is responsible for adding multi-select comboboxes
// to any relevant <select> elements that exists
// in the DOM.
export default class FacetFieldCheckboxesComponent {
    constructor() {
        document.querySelectorAll('.selectpicker').forEach((select) => {
            new Combobox(select);
        })
    }
    
}