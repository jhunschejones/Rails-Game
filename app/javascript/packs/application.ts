import * as ActiveStorage from "@rails/activestorage";
import Rails from "@rails/ujs";
import Turbolinks from "turbolinks";

Rails.start();
Turbolinks.start();
ActiveStorage.start();
require("trix");
require("@rails/actiontext");
require("channels");

import MenuHamburger from "src/menu_hamburger";
import FlashDelete from "src/flash_delete";

document.addEventListener("turbolinks:load", () => {
  new MenuHamburger(
    document.querySelector(".navbar-burger") as HTMLElement
  ).initHandlers();

  const flashDeleteButton = document.querySelector(
    ".flash .delete"
  ) as HTMLElement;
  if (flashDeleteButton) new FlashDelete(flashDeleteButton).initHandlers();
});
