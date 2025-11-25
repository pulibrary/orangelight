const fadeout = (element, callback = () => {}) => {
  if (!element) {
    return;
  }
  if (!element.style.opacity) {
    element.style.opacity = '1';
  }
  const interval = (600 * element.style.opacity) / 10;
  const fadeEffect = setInterval(() => {
    if (element.style.opacity > 0) {
      const current = +element.style.opacity;
      element.style.opacity = roundToNearestTenth(current - 0.1);
    } else {
      callback();
      clearInterval(fadeEffect);
    }
  }, interval);
};

const roundToNearestTenth = (number) => {
  return Math.round(number * 10) / 10.0;
};

export { fadeout };
