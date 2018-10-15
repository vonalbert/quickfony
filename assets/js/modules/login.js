const $ = require('jquery');


class LoginModalManager {
  static getContainer() {
    let $container = $('#login-modal-container');
    if ($container.length === 0) {
      $container = $('<div id="login-modal-container">').appendTo('body');
    }

    return $container;
  }

  static load(href) {
    const $container = LoginModalManager.getContainer();
    $container.load(href, function() {
      $container.find('> .modal').modal('show').on('hidden.bs.modal', () => {
        $container.html('');
      });
    });
  }

  static hide() {
    LoginModalManager.getContainer().find('> .modal').modal('hide');
  }
}



document.arrive('[data-login]', {existing: true}, function() {
  const $toggle = $(this);
  const href = $toggle.attr('href');

  if (href && href !== window.location.pathname) {
    $toggle.on('click', (e) => {
      e.preventDefault();
      LoginModalManager.load(href);
    });
  }
});
