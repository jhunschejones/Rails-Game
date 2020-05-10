export default class MenuHamburger {
  hamburger: HTMLElement;
  menu: HTMLElement;

  constructor(hamburger: HTMLElement) {
    this.hamburger = hamburger;
    this.menu = document.querySelector(".main-nav-menu") as HTMLElement;
  }

  initHandlers(): void {
    document.addEventListener("click", this.closeMenu.bind(this));
    this.hamburger.addEventListener("click", this.toggle.bind(this));
  }

  closeMenu(e: Event): void {
    if (!this.hasClass(e.target as HTMLElement, "navbar")) {
      this.menu.classList.remove("is-active");
      this.hamburger.classList.remove("is-active");
    }
  }

  toggle(): void {
    this.menu.classList.toggle("is-active");
    this.hamburger.classList.toggle("is-active");
  }

  hasClass(element: HTMLElement, className: string): boolean {
    let stillParsing = true;
    do {
      if (element.classList && element.classList.contains(className)) {
        return true;
      }
      if (element.parentElement) {
        stillParsing = true;
        element = element.parentElement;
      } else {
        stillParsing = false;
      }
    } while (stillParsing);
    return false;
  }
}
