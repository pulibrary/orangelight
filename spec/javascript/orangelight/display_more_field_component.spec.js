import DisplayMoreFieldComponent from 'display_more_field_component';

let component, list, button, mockEvent;

describe('DisplayMoreFieldComponent', function() {
    afterEach(jest.clearAllMocks);

    beforeEach(() => {
        document.body.innerHTML = 
        '<ul id="list"><li>1</li><li>2</li><li>3</li>' +
        '<li class="d-none">4</li><li class="d-none">5</li></ul>' +
        '<button aria-expanded="false" aria-controls="list" id="btn" ' +
        'data-maximum-default-values="3" ' +
        'data-show-more-text="Show 3 more" ' +
        'data-show-less-text="Show less">' +
        'Show 3 more</button>';
        component = new DisplayMoreFieldComponent();

        list = document.getElementById('list');
        button = document.getElementById('btn');
        mockEvent = {'target': button, 'preventDefault': () => {}};
    });

    describe('when the button is pressed initially', () => {
        beforeEach(() => {
            component.toggle(mockEvent);
        });
        test('the d-none attributes are removed', () => {
            expect(list.childNodes.item(3).getAttribute('class')).not.toMatch(/d-none/);
            expect(list.childNodes.item(4).getAttribute('class')).not.toMatch(/d-none/);
        });

        test('tab index is set', () => {
            expect(list.getAttribute('tabindex')).toBe('-1');
        });
        test('aria-expanded is true', () => {
            expect(button.getAttribute('aria-expanded')).toBe('true');
        });
        test('button text is changed', () => {
            expect(button.innerHTML).toBe('<i class="pe-none toggle"></i> Show less');
        });
    });

    describe('when the button is pressed a second time', () => {
        beforeEach(() => {
            component.toggle(mockEvent);
            component.toggle(mockEvent);
        });
        test('the d-none attributes are added back', () => {
            expect(list.childNodes.item(3).getAttribute('class')).toMatch(/d-none/);
            expect(list.childNodes.item(4).getAttribute('class')).toMatch(/d-none/);
        });

        test('aria-expanded is false', () => {
            expect(button.getAttribute('aria-expanded')).toBe('false');
        });

        test('button text is changed', () => {
            expect(button.innerHTML).toBe('<i class="pe-none toggle collapsed"></i> Show 3 more');
        });
    });
});