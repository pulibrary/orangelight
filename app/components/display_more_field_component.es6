export default class DisplayMoreFieldComponent {
    displayMore(event) {
        const listElement = this.listElement(event.target);
        listElement.childNodes.forEach((listItem) => {
            listItem.classList.remove('d-none');
        });
        listElement.setAttribute('tabindex', '-1');
        event.target.innerHTML = '<i class="pe-none toggle"></i> ' + event.target.getAttribute('data-show-less-text');
        event.target.setAttribute('aria-expanded', 'true');
        setTimeout(() => listElement.focus(), 500);
    }

    displayFewer(event) {
        const listElement = this.listElement(event.target);
        const numberToLeave = Number(event.target.getAttribute('data-maximum-default-values'));
        const elementsToHide = Array.from(listElement.childNodes).slice(numberToLeave);
                
        elementsToHide.forEach(listItem => {
            listItem.classList.add('d-none');
        });
        event.target.innerHTML = '<i class="pe-none toggle collapsed"></i> ' + event.target.getAttribute('data-show-more-text');
        event.target.setAttribute('aria-expanded', 'false');
        setTimeout(() => listElement.focus(), 500);
    }

    toggle(event) {
        event.preventDefault();
        const listElement = this.listElement(event.target);
        const expanded = listElement.querySelector('.d-none') == null;
        console.log(listElement);
        console.log(expanded);
        expanded ? this.displayFewer(event) : this.displayMore(event);
    }

    listElement(buttonElement) {
        console.log(buttonElement.getAttribute('aria-controls'));

        return document.getElementById(buttonElement.getAttribute('aria-controls'));
    }
}