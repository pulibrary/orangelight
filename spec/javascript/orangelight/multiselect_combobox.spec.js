import MultiselectCombobox from "../../../app/javascript/orangelight/multiselect_combobox.es6";
describe('MultiselectCombobox', () => {
    let combobox;
    beforeEach(() => {
        document.body.innerHTML = `
        <div class="dropdown">
            <label for="my-id">My field</label>
            <input id="my-id">
            <ul>
                <li>Firestone</li>
                <li>Lewis</li>
            </ul>
            <select multiple="true" class="selectpicker">
                <option value="Firestone">Firestone</option>
                <option value="Lewis">Lewis</option>
            </select>
        </div>`;
        combobox = new MultiselectCombobox(document.querySelector('input'));
    })
    describe('toggleItem()', () => {
        describe('when item is selected for the first time', () => {
            beforeEach(() => {
                const firestoneItem = document.querySelector('li') // Firestone is the first <li>
                combobox.toggleItem(firestoneItem)
            })
            it('Selects the relevant option in the <select>', () => {
                const firestoneOption = document.querySelector('option')
                expect(firestoneOption.value).toBe('Firestone')
                expect(firestoneOption.selected).toBe(true)
            })
            it('Adds a checkmark icon to the <li>', () => {
                expect(document.querySelector('li').querySelector('.fa.fa-check')).not.toBeNull()
            })
            it('Adds the active class to the li', () => {
                expect(document.querySelector('li').classList.contains('active')).toBe(true)
            })
            it('Sets the li aria-selected to true', () => {
                expect(document.querySelector('li').getAttribute('aria-selected')).toEqual('true')
            })
            it('Adds the text to the <input>', () => {
                expect(document.querySelector('input').value).toEqual('Firestone')
            })
        });
        describe('when item has already been selected', () => {
            beforeEach(() => {
                const firestoneItem = document.querySelector('li') // Firestone is the first <li>
                combobox.toggleItem(firestoneItem)
                combobox.toggleItem(firestoneItem)
            })
            it('De-selects the relevant option in the <select>', () => {
                const firestoneOption = document.querySelector('option')
                expect(firestoneOption.value).toBe('Firestone')
                expect(firestoneOption.selected).toBe(false)
            })
            it('Removes the checkmark icon from the <li>', () => {
                expect(document.querySelector('li').querySelector('.fa.fa-check')).toBeNull()
            })
            it('Removes the active class from the li', () => {
                expect(document.querySelector('li').classList.contains('active')).toBe(false)
            })
            it('Sets the li aria-selected to false', () => {
                expect(document.querySelector('li').getAttribute('aria-selected')).toEqual('false')
            })
            it('Removes the text from the <input>', () => {
                expect(document.querySelector('input').value).toEqual('')
            })
        });
    })
    describe('updateOptionVisibility()', () => {
        it("hides options that don't match the query in the input", () => {
            document.querySelector('input').value = 'fir'
            combobox.updateOptionVisibility()
            expect(document.querySelectorAll('li')[0].classList.contains('d-none')).toBe(false)
            expect(document.querySelectorAll('li')[1].classList.contains('d-none')).toBe(true)
        })
        it("allows multiple queries separated by semicolon", () => {
            document.querySelector('input').value = 'fir; lew'
            combobox.updateOptionVisibility()
            expect(document.querySelectorAll('li')[0].classList.contains('d-none')).toBe(false)
            expect(document.querySelectorAll('li')[1].classList.contains('d-none')).toBe(false)
        })
    })
    describe('when one of the options is already selected', () => {
        beforeEach(() => {
            document.body.innerHTML = `
                <div class="dropdown">
                    <label for="my-id">My field</label>
                    <input id="my-id">
                    <ul>
                        <li>Firestone</li>
                        <li>Lewis</li>
                    </ul>
                    <select multiple="true" class="selectpicker">
                        <option value="Firestone">Firestone</option>
                        <option value="Lewis" selected>Lewis</option>
                    </select>
                </div>`;
                combobox = new MultiselectCombobox(document.querySelector('input'));
        })
        it('Adds a checkmark icon to the <li>', () => {
            expect(document.querySelectorAll('li')[1].querySelector('.fa.fa-check')).not.toBeNull()
        })
        it('Adds the active class to the li', () => {
            expect(document.querySelectorAll('li')[1].classList.contains('active')).toBe(true)
        })
        it('Sets the li aria-selected to true', () => {
            expect(document.querySelectorAll('li')[1].getAttribute('aria-selected')).toEqual('true')
        })
        it('Adds the text to the <input>', () => {
            expect(document.querySelector('input').value).toEqual('Lewis')
        })    })
});
