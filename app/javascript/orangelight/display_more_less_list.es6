// Extend this class to implement a list that can
// expand and contract when a user presses a button
export default class DisplayMoreLessList {
    constructor () {}

    displayMore(event) {
        this.addItemsToDisplay(event.target);
        event.target.innerHTML = '<i class="pe-none toggle"></i> ' + event.target.getAttribute('data-show-less-text');
        event.target.setAttribute('aria-expanded', true);
        this.setFocusOnList(this.listElement(event.target));
    }

    displayFewer(event) {
        this.removeItemsFromDisplay(event.target);
        event.target.innerHTML = '<i class="pe-none toggle collapsed"></i> ' + event.target.getAttribute('data-show-more-text');
        event.target.setAttribute('aria-expanded', false);
        this.setFocusOnList(this.listElement(event.target));
    }

    toggle(event) {
        event.preventDefault();
        this.isExpanded(event) ? this.displayFewer(event) : this.displayMore(event);
    }

    isExpanded(event) {
        const listElement = this.listElement(event.target);
        // If no elements are visually hidden, we consider
        // the list to be expanded
        return listElement.querySelector('.d-none') == null;
    }

    setFocusOnList(listElement) {
        listElement.setAttribute('tabindex', '-1');
        setTimeout(() => listElement.focus(), 500);
    }

    listElement(buttonElement) {
        return document.getElementById(buttonElement.getAttribute('aria-controls'));
    }

    initialMaximumValuesCount(button) {
        return Number(button.getAttribute('data-maximum-default-values'));
    }
}