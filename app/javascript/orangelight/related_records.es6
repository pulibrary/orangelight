import DisplayMoreLessList from "./display_more_less_list.es6";

export default class RelatedRecordsDisplayer extends DisplayMoreLessList {
    constructor(json) {
        super();
        this.relatedRecords = json;
    }

    static fetchData(fieldName, recordId) {
        let url = '/catalog/' + recordId + '/linked_records/' + fieldName;
        return fetch(url, {
            headers: {'X-CSRF-Token': $('meta[name="csrf-token"]').attr('content')},
            method: 'POST'})
        .then(response => response.json())
        .then(data => new RelatedRecordsDisplayer(data));
    }

    addItemsToDisplay(button) {
        const listElement = this.listElement(button);
        // Remove duplicate <li>s
        this.popListItems(listElement);

        // Add the new <li>s
        for (let i in this.relatedRecords) {
            const listItem = document.createElement("li");
            listItem.innerHTML = '<a href="/catalog/' + this.relatedRecords[i].document.id + '">' + this.relatedRecords[i].document.title_display + '</a>';
            listElement.appendChild(listItem);
        }
    }

    removeItemsFromDisplay(button) {
        const listElement = this.listElement(button);
        this.popListItems(listElement, this.initialMaximumValuesCount(button));
    }

    isExpanded(event) {
        const listElement = this.listElement(event.target);
        return listElement.children.length > this.initialMaximumValuesCount(event.target);
    }

    popListItems(listElement, numberToLeave=0) {
        while (listElement.children.length > numberToLeave) {
            listElement.removeChild(listElement.lastChild);
        }
    }
}

