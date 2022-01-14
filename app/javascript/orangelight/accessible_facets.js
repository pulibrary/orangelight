// Please do not remove this yet. Added role="button" in the app/views/catalog/_facet_layout.html.erb

// const updateFacet = () => {
//   const cardFacets = document.querySelectorAll('#facet-panel-collapse div.card-header.collapse-toggle.facet-field-heading > a')
//   cardFacets.forEach(function(card) {
//     card.setAttribute("role", "button");
//   })
// };

const handleBtnKeyDown = () => {
  const cardFacets = document.querySelectorAll('#facet-panel-collapse div.card-header.collapse-toggle.facet-field-heading > a')
  cardFacets.forEach(function(card) {
    card.addEventListener('keydown', eventKeyCheck)
  })
};
 const eventKeyCheck = (event) => {
  // "Spacebar" for IE11 support
  /*  https://developer.mozilla.org/en-US/docs/Web/API/KeyboardEvent/code
      https://developer.mozilla.org/en-US/docs/Web/API/KeyboardEvent/code/code_values
      KeyboardEvent: key=' ' | code='Space'
      KeyboardEvent: key='Enter' | code='Enter'  */
    if (event.key === " " || event.key === "Space" || event.key === "Enter" || event.key === "Spacebar") {
      // if Space or Enter is keydown then do what click does through toggleAriaExpanded function;
      event.preventDefault();
      event.stopPropagation();
      toggleAriaExpanded(event.target);
    }
  };
  
  // toggleAriaExpanded updates the "aria-expanded" value
  // The "aria-expanded" value initially is set in app/views/catalog/_facet_layout.html.erb
  const toggleAriaExpanded = (element) => {
    let expanded = element.getAttribute("aria-expanded")
    element.click();
    if (expanded == "true") {
      return element.setAttribute("aria-expanded", "false")
    } else{
      return element.setAttribute("aria-expanded", "true")
    }
  };

export { handleBtnKeyDown };
