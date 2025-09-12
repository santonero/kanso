function getTransitionClasses(element, stage) {
  const from = element.dataset[`transition${capitalize(stage)}From`] || '';
  const to = element.dataset[`transition${capitalize(stage)}To`] || '';
  return {
    from: from.split(' ').filter(Boolean),
    to: to.split(' ').filter(Boolean)
  };
}

function capitalize(str) {
  return str.charAt(0).toUpperCase() + str.slice(1);
}

export function enter(element) {
  const classes = getTransitionClasses(element, 'enter');

  return new Promise(resolve => {
    element.classList.remove('hidden');
    element.classList.add(...classes.from);

    requestAnimationFrame(() => {
      element.classList.remove(...classes.from);
      element.classList.add(...classes.to);

      element.addEventListener('transitionend', () => {
        resolve();
      }, { once: true });
    });
  });
}

export function leave(element) {
  const classes = getTransitionClasses(element, 'leave');

  return new Promise(resolve => {
    element.classList.add(...classes.from);

    requestAnimationFrame(() => {
      element.classList.remove(...classes.from);
      element.classList.add(...classes.to);

      element.addEventListener('transitionend', () => {
        element.classList.add('hidden');
        element.classList.remove(...classes.to);
        resolve();
      }, { once: true });
    });
  });
}