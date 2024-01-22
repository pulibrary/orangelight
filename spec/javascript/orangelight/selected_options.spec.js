import SelectedOptions from "../../../app/javascript/orangelight/selected_options.es6";

it('can return the selected options as a concatenated string', () => {
    const options = new SelectedOptions();
    options.add('Architecture Library (2)')
    options.add('Engineering Library (4)')
    expect(options.toString()).toEqual('Architecture Library (2); Engineering Library (4)')
})

it('does not store unnecessary whitespace when adding a string', () => {
    const options = new SelectedOptions();
    options.add("  \n  Architecture Library (2)\t ")
    expect(options.toString()).toEqual('Architecture Library (2)')
})

it('disregards duplicates', () => {
    const options = new SelectedOptions();
    options.add('Architecture Library (2)')
    options.add('Architecture Library (2)')
    expect(options.toString()).toEqual('Architecture Library (2)')
})

it('can remove items', () => {
    const options = new SelectedOptions();
    options.add('Architecture Library (2)')
    options.add('Engineering Library (4)')
    options.remove('Engineering Library (4)')
    expect(options.toString()).toEqual('Architecture Library (2)')
})

describe('contains()', () => {
    it('is true if the item has been added', () => {
        const options = new SelectedOptions();
        options.add('Architecture Library (2)')
        expect(options.contains('Architecture Library (2)')).toBe(true)
    })
    it('is false if the item has not been added', () => {
        const options = new SelectedOptions();
        options.add('Architecture Library (2)')
        expect(options.contains('Engineering Library (4)')).toBe(false)
    })
    it('is false if the item has been removed', () => {
        const options = new SelectedOptions();
        options.add('Architecture Library (2)')
        options.remove('Architecture Library (2)')
        expect(options.contains('Architecture Library (2)')).toBe(false)
    })
})
