import FacetFieldCheckboxesComponent from 'facet_field_checkboxes_component';

describe('DisplayMoreFieldComponent', function() {
    describe('when the select does not have the selectpicker class', () => {
        beforeEach(() => {
            document.body.innerHTML = '<select multiple="true"></select>';
            new FacetFieldCheckboxesComponent();
        })
        it('does not change the select', () => {
            expect(document.body.innerHTML).toEqual('<select multiple="true"></select>');
        })
    });

    describe('when the select has the selectpicker class', () => {
        beforeEach(() => {
            document.body.innerHTML = `
            <label for="my-id">My field</label>
            <select multiple="true" class="selectpicker" id="my-id">
                <option value="Firestone">Firestone</option>
                <option value="Lewis">Lewis</option>
            </select>`;
            new FacetFieldCheckboxesComponent();
        })
        it('creates a new input for the user to interact with', () => {
            const input = document.getElementById('my-id');
            expect(input.tagName).toEqual('INPUT');
            expect(input.getAttribute('aria-activedescendant')).toEqual(null);
            expect(input.getAttribute('aria-autocomplete')).toEqual('list');
            expect(input.getAttribute('role')).toEqual('combobox');
            expect(input.getAttribute('aria-controls')).toEqual('my-id-listbox');
            expect(document.getElementById('my-id').getAttribute('aria-expanded')).toEqual('false');
        });

        it('creates a new listbox to display the options', () => {
            const listbox = document.getElementById('my-id-listbox');
            expect(listbox.tagName).toEqual('UL');
            expect(listbox.getAttribute('role')).toEqual('listbox');
            expect(listbox.classList.contains('d-none')).toBe(true);
            expect(listbox.getAttribute('aria-label')).toEqual('Options');

            expect(listbox.firstChild.tagName).toEqual('LI');
            expect(listbox.firstChild.innerText).toEqual('Firestone');
            expect(listbox.firstChild.getAttribute('role')).toBe('option')
            expect(listbox.firstChild.id).toEqual('my-id-listbox-0');

            expect(listbox.lastChild.tagName).toEqual('LI');
            expect(listbox.lastChild.innerText).toEqual('Lewis');
            expect(listbox.lastChild.getAttribute('role')).toBe('option')
            expect(listbox.lastChild.id).toEqual('my-id-listbox-1');
        })
        it('hides the original select from screens and screenreaders', () => {
            expect(document.querySelector('select[multiple="true"]').classList.contains('d-none')).toBe(true);
        })
        describe('when the user focuses the input and presses DOWN arrow', () => {
            beforeEach(() => {
                const input = document.getElementById('my-id');
                input.focus();
                input.dispatchEvent(new KeyboardEvent('keyup', {code: 'ArrowDown'}));
            });
            it('displays the options', () => {
                const listbox = document.getElementById('my-id-listbox');
                expect(listbox.classList.contains('d-none')).toBe(false);
                expect(document.getElementById('my-id').getAttribute('aria-expanded')).toEqual('true');
            });
            it('focuses the first option in the list', () => {
                const input = document.getElementById('my-id');
                expect(input.getAttribute('aria-activedescendant')).toEqual('my-id-listbox-0');
                expect(document.getElementById('my-id-listbox-0').classList.contains('bg-primary')).toBe(true);
                expect(document.getElementById('my-id-listbox-0').classList.contains('text-white')).toBe(true);
            });
            it('closes when they press ESC', () => {
                document.getElementById('my-id').dispatchEvent(new KeyboardEvent('keyup', {code: 'Escape'}));
                const listbox = document.getElementById('my-id-listbox');
                expect(listbox.classList.contains('d-none')).toBe(true);
                expect(document.getElementById('my-id').getAttribute('aria-expanded')).toEqual('false');
                expect(document.getElementById('my-id').getAttribute('aria-activedescendant')).toEqual('');
            });
        })
        describe('when the user changes the text string', () => {
            beforeEach(() => {
                const input = document.getElementById('my-id');
                input.value = 'Fire';
                input.dispatchEvent(new InputEvent('input'));
            });
            it('displays the matching options', () => {
                const listbox = document.getElementById('my-id-listbox');
                expect(listbox.classList.contains('d-none')).toBe(false);
                expect(document.getElementById('my-id').getAttribute('aria-expanded')).toEqual('true');
                expect(document.getElementById('my-id-listbox-1').classList.contains('d-none')).toBe(true);
            });
            it('focuses the first option in the list', () => {
                const input = document.getElementById('my-id');
                expect(input.getAttribute('aria-activedescendant')).toEqual('my-id-listbox-0');
                expect(document.getElementById('my-id-listbox-0').classList.contains('bg-primary')).toBe(true);
                expect(document.getElementById('my-id-listbox-0').classList.contains('text-white')).toBe(true);
            });
        });
    });

});