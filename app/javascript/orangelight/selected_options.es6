// This class is responsible for getting and
// setting a list of options that a user has
// selected
export default class SelectedOptions {
    selectedOptions = new Set()

    add(option) {
        this.selectedOptions.add(option.trim());
    }

    remove(option) {
        this.selectedOptions.delete(option.trim())
    }

    toggle(option) {
        if (this.contains(option)) {
            this.remove(option)
        } else {
            this.add(option)
        }
    }

    toString() {
        return Array.from(this.selectedOptions).join('; ')
    }

    contains(option) {
        return Array.from(this.selectedOptions).some((element) => element === option.trim())
    }
}
