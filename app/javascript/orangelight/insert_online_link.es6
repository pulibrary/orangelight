export const insert_online_header = () => {
  const online_div = $("div[class^='availability--online']");
  if (online_div.length < 1) {
    const physical_div = $(".availability--physical");
    const online_div = '<div class="availability--online"><h3>Available Online</h3><ul></ul></div>';
    return $(online_div).insertBefore(physical_div);
  }
}

export const online_link_content = (link, target) => {
  return `Princeton users: <a href="${link}" target="${target}">View digital content<i class="fa fa-external-link new-tab-icon-padding" aria-hidden="true" role="img"></i></a>`;
}

export const insert_online_link = (link = "#viewer-container", id = "cdl_link", content = online_link_content) => {
  insert_online_header()
  const existing_online_link = $(`#${id}`)
  if (existing_online_link.length > 0)
    return
  let target = "_blank"
  if (link.charAt(0) === "#")
    target = "_self"
  const online_list = $("div[class^='availability--online'] ul");
  const online_link = `<li id='${id}'>${content(link, target)}</li></div>`;
  return $(online_list).append(online_link);
}
