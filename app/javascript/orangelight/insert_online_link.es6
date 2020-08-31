export const insert_online_header = () => {
  const online_div = $("div[class^='availability--online']:not(.availability--panel_umlaut)");
  if (online_div.length < 1) {
    const physical_div = $(".availability--physical");
    const online_div = '<div class="availability--online"><h3>Available Online</h3><ul></ul></div>';
    return $(online_div).insertBefore(physical_div);
  }
}

export const insert_online_link = (link = "#view", id = "cdl_link") => {
  insert_online_header()
  const existing_online_link = $(`#${id}`)
  if (existing_online_link.length > 0)
    return
  let target = "_blank"
  if (link.charAt(0) === "#")
    target = "_self"
  const online_list = $("div[class^='availability--online']:not(.availability--panel_umlaut) ul");
  const online_link = `<li id='${id}'>Princeton users: <a href="${link}" target="${target}">View digital content</a></li></div>`;
  return $(online_list).append(online_link);
}
