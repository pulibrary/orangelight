<template>
  <div class="mb-3 advanced-search-facet row dropdown">
    <label class="col-sm-4 control-label advanced-facet-label" :for="domId">{{
      label
    }}</label>
    <input
      @focus="focus"
      @blur.stop="blurInput"
      @click.stop="focus"
      @keyup.up.down="upOrDown"
      @keyup="search"
      v-model="inputModel"
      ref="input"
      :id="domId"
      data-bs-toggle="dropdown"
      autocomplete="off"
      :class="['col-sm-8', 'combobox-multiselect']"
      role="combobox"
      aria-expanded="false"
      :aria-controls="listboxId"
    />
    <span
      class="fa fa-caret-down"
      aria-hidden="true"
      data-bs-toggle="dropdown"
    ></span>
    <ul
      @focus="focus"
      ref="dropdown"
      :class="['dropdown-menu']"
      role="listbox"
      aria-label="Options"
      :id="listboxId"
    >
      <li
        v-for="value in filteredValues.filter((v) => v.selected)"
        @blur.stop="blur"
        @click.stop="toggleItem(value)"
        @keyup.enter="toggleItem(value)"
        @keydown.tab.shift.prevent="tabToPrevious"
        :class="['dropdown-item', 'selected-item', { active: value.selected }]"
        :aria-selected="value.selected"
        tabindex="-1"
        role="option"
      >
        {{ value.label
        }}<span
          v-if="value.selected"
          class="fa fa-check"
          aria-hidden="true"
        ></span>
      </li>
      <li v-if="filteredValues.filter((v) => v.selected).length > 0">
        <hr class="dropdown-divider" />
      </li>
      <li
        v-for="value in filteredValues"
        :key="value.value"
        @blur.stop="blur"
        @click.stop="toggleItem(value)"
        @keyup.enter="toggleItem(value)"
        @keydown.tab.shift.prevent="tabToPrevious"
        :class="['dropdown-item', { active: value.selected }]"
        :aria-selected="value.selected"
        tabindex="-1"
        role="option"
      >
        {{ value.label
        }}<span
          v-if="value.selected"
          class="fa fa-check"
          aria-hidden="true"
        ></span>
      </li>
    </ul>
    <select
      multiple="multiple"
      aria-hidden="true"
      hidden="hidden"
      :name="`f_inclusive[${fieldName}][]`"
      :id="hiddenSelectId"
    >
      <option
        v-for="value in values"
        :value="value.value"
        :selected="value.selected"
      >
        {{ value.value }}
      </option>
    </select>
    <div
      class="visually-hidden number-of-results"
      aria-live="polite"
      aria-atomic="false"
    >
      {{ pluralize(filteredValues.length, 'option') }}. Press down arrow for
      options.
    </div>
  </div>
</template>
<script setup>
import { computed, ref } from 'vue';

const props = defineProps({
  fieldName: { type: String, required: true },
  label: { type: String, required: true },
  domId: { type: String, required: true },
  valuesJson: { type: String, required: true },
});

const listboxId = ref(`${props.domId}-list`);
const hiddenSelectId = ref(`${props.domId}-select`);
const values = ref(buildValues());
const input = ref(null);
const dropdown = ref(null);
const inputModel = defineModel('inputModel');
const query = ref('');

const inputValue = computed(() =>
  values.value
    .filter((v) => v.selected)
    .map((v) => v.label)
    .join(';')
);

const filteredValues = computed(() => {
  if (query.value === undefined) {
    return values.value;
  }
  return values.value.filter((value) => {
    const normalizedQuery = query.value.trim().toLowerCase();
    if (inputModel.value === inputValue.value) {
      return values.value;
    }
    return (
      value.label.toLowerCase().includes(normalizedQuery) || value.selected
    );
  });
});

function focus(event) {
  const instance = bootstrap.Dropdown.getOrCreateInstance(event.target);
  if (event.target === input.value || event.target === dropdown.value) {
    instance.show();
  } else {
    instance.hide();
  }
  if (inputModel.value === inputValue.value) {
    inputModel.value = query.value;
  }
}

function blur(event) {
  hideDropdown(event);
}

function blurInput(event) {
  const listElements = Array.from(dropdown.value.children);
  if (listElements.includes(event.relatedTarget)) {
    return;
  }
  inputModel.value = inputValue.value;
  if (event.relatedTarget && event.relatedTarget.localName !== 'input') {
    return;
  }
  hideDropdown(event);
}

function hideDropdown(event) {
  const instance = bootstrap.Dropdown.getOrCreateInstance(input.value);
  if (
    (!Array.from(event.target.parentNode.childNodes).includes(
      event.relatedTarget
    ) ||
      event.target.parentNode === event.relatedTarget) &&
    event.relatedTarget !== null
  ) {
    instance.hide();
  }
}

function tabToPrevious(event) {
  const previousElement = event.target.closest(
    '.multiselect-combobox'
  ).previousElementSibling;
  if (previousElement) {
    previousElement.querySelector('input').focus();
  } else {
    const tabbableElements = Array.from(
      document.querySelectorAll(
        'a[href], button:not([disabled]), input:not([disabled]):not([type=hidden]), select:not([disabled]), textarea:not([disabled]), [tabindex]:not([tabindex="-1"])'
      )
    );
    const currentFocus = document.activeElement
      .closest('.multiselect-combobox')
      .querySelector('input');
    const currentIndex = tabbableElements.indexOf(currentFocus);
    tabbableElements[currentIndex - 1].focus();
  }
}

function upOrDown(event) {
  const instance = bootstrap.Dropdown.getOrCreateInstance(event.target);
  if (event.key === 'ArrowDown') {
    instance._selectMenuItem({ key: 'ArrowDown' });
  }
}

function search(event) {
  if (['ArrowUp', 'ArrowDown', 'Enter'].includes(event.key)) {
    return;
  }
  query.value = inputModel.value;
}

function buildValues() {
  const baseValues = JSON.parse(props.valuesJson);
  const pul = [
    {
      value: 'pul',
      selected: pulSelected(),
      label: 'All Princeton Holdings',
    },
  ];
  return props.fieldName === 'advanced_location_s'
    ? pul.concat(baseValues)
    : baseValues;
}

function pulSelected() {
  const urlString = window.location.search;
  const urlParams = new URLSearchParams(urlString);
  return urlParams.get('f_inclusive[advanced_location_s][]') === 'pul';
}

function toggleItem(option) {
  if (document.activeElement.classList.contains('selected-item')) {
    const instance = bootstrap.Dropdown.getOrCreateInstance(input.value);
    const parent = document.activeElement.parentElement;
    option.selected = !option.selected;
    let nextLi = null;
    const listElements = Array.from(parent.querySelectorAll('li'));
    const index = listElements.indexOf(document.activeElement);
    if (listElements[index + 2].classList.length === 0) {
      nextLi = listElements[index + 4];
    } else if (listElements[index + 1].classList.contains('dropdown-item')) {
      nextLi = listElements[index + 2];
    } else {
      nextLi = listElements[index + 3];
    }
    instance._selectMenuItem({
      target: nextLi,
    });
  } else {
    option.selected = !option.selected;
  }
  inputModel.value = inputValue.value;
}

function pluralize(number, string) {
  return number === 1 ? `${number} ${string}` : `${number} ${string}s`;
}

inputModel.value = inputValue.value;
</script>
<style scoped>
.dropdown-menu.show {
  position: absolute;
  inset: 0px 0px auto auto;
  margin: 0px;
  transform: translate(0px, 42px);
}
</style>
