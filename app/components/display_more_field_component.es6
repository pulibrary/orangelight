import DisplayMoreLessList from "../javascript/orangelight/display_more_less_list.es6";

export default class DisplayMoreFieldComponent extends DisplayMoreLessList {
    addItemsToDisplay(button) {
        const listElement = this.listElement(button);
        listElement.childNodes.forEach((listItem) => {
            listItem.classList.remove('d-none');
        });
    }

    removeItemsFromDisplay(button) {
        const listElement = this.listElement(button);
        const elementsToHide = Array.from(listElement.childNodes).slice(this.initialMaximumValuesCount(button));
        elementsToHide.forEach(listItem => {
            listItem.classList.add('d-none');
        });
    }
}