export const insert_online_header = () => {
  const online_div = $("div[class^='availability--online']");
  if (online_div.length < 1) {
    const physical_div = $(".availability--physical");
    const online_div = '<div class="availability--online:visible"><h3>Available Online</h3><ul></ul></div>';
    return $(online_div).insertBefore(physical_div);
  }
}

export const insert_online_link = () => {
  insert_online_header()
  const online_list = $("div[class^='availability--online'] ul");
  const online_link = '<li>Princeton users: <a href="#view">View digital content</a></li></div>';
  return $(online_list).append(online_link);
}
