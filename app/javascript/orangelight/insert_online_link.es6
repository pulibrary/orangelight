export const insert_online_header = () => {
  const online_div = $("div[class^='availability--online']:not(.availability--panel_umlaut)");
  if (online_div.length < 1) {
    const physical_div = $(".availability--physical");
    const online_div = '<div class="availability--online"><h3>Available Online</h3><ul></ul></div>';
    return $(online_div).insertBefore(physical_div);
  }
}

export const insert_online_link = (link = "#view") => {
  insert_online_header()
  const online_list = $("div[class^='availability--online']:not(.availability--panel_umlaut) ul");
  const online_link = `<li>Princeton users: <a href="${link}">View digital content</a></li></div>`;
  return $(online_list).append(online_link);
}
