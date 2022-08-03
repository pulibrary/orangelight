export default class RelatedRecordsDisplayer {
    constructor(json) {
        this.relatedRecords = json;
        this.expanded = false;
    }

    static fetchData(fieldName, recordId) {
        let url = '/catalog/' + recordId + '/linked_records/' + fieldName;
        return fetch(url, {
            headers: {'X-CSRF-Token': $('meta[name="csrf-token"]').attr('content')},
            method: 'POST'})
        .then(response => response.json())
        .then(data => new RelatedRecordsDisplayer(data));
    }

    displayMore(event) {
        const listElement = this.listElement(event.target);
        // Remove duplicate <li>s
        this.popListItems(listElement);

        // Add the new <li>s
        for (let i in this.relatedRecords) {
            const listItem = document.createElement("li");
            listItem.innerHTML = '<a href="/catalog/' + this.relatedRecords[i].document.id + '">' + this.relatedRecords[i].document.title_display + '</a>';
            listElement.appendChild(listItem);
        }
        listElement.setAttribute('tabindex', '-1');
        event.target.innerHTML = '<i class="pe-none toggle"></i> Show fewer related records'
        event.target.setAttribute('aria-expanded', 'true');
        setTimeout(() => listElement.focus(), 500);
    }

    displayFewer(event) {
        const listElement = this.listElement(event.target);
        this.popListItems(listElement, event.target.getAttribute('data-initial-linked-records'));
        event.target.innerHTML = '<i class="pe-none toggle collapsed"></i> Show ' + event.target.getAttribute('data-additional-linked-records') + ' more related records';
        event.target.setAttribute('aria-expanded', 'false');
        setTimeout(() => listElement.focus(), 500);
    }

    toggle(event) {
        event.preventDefault();
        const listElement = this.listElement(event.target);
        const expanded = listElement.children.length > event.target.getAttribute('data-initial-linked-records');
        expanded ? this.displayFewer(event) : this.displayMore(event);
    }

    listElement(buttonElement) {
        return document.getElementById(buttonElement.getAttribute('aria-controls'));
    }

    popListItems(listElement, numberToLeave=0) {
        while (listElement.children.length > numberToLeave) {
            listElement.removeChild(listElement.lastChild);
        }
    }
}