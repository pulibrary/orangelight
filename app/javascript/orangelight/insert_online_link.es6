export const insert_online_header = () => {
  if (!already_has_online_availability()) {
    const physical_div = document.querySelector('.availability--physical');
    if (physical_div) {
      physical_div.parentNode.insertBefore(online_heading(), physical_div);
    }
  }
};

const already_has_online_availability = () => {
  return document.querySelector("div[class^='availability--online']");
};

const online_heading = () => {
  const wrapper = document.createElement('div');
  wrapper.classList.add('availability--online');
  const heading = document.createElement('h3');
  heading.textContent = 'Available Online';
  const list = document.createElement('ul');
  wrapper.appendChild(heading);
  wrapper.appendChild(list);
  return wrapper;
};

export const online_link_content = (link, target) => {
  return `Princeton users: <a href="${link}" target="${target}">View digital content<i class="fa fa-external-link new-tab-icon-padding" aria-label="opens in new tab" role="img"></i></a>`;
};

export const insert_online_link = (
  link = '#viewer-container',
  id = 'cdl_link',
  content = online_link_content
) => {
  insert_online_header();
  if (document.getElementById(id)) {
    return;
  }
  let target = '_blank';
  if (link.charAt(0) === '#') target = '_self';
  const online_list = document.querySelector(
    "div[class^='availability--online'] ul"
  );
  const online_link = `<li id='${id}'>${content(link, target)}</li></div>`;
  online_list.innerHTML = online_list.innerHTML + online_link;
};
