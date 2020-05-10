export default class FlashDelete {
  button: HTMLElement;
  flash: HTMLElement;

  constructor(button: HTMLElement) {
    this.button = button;
    this.flash = this.button.parentNode as HTMLElement;
  }

  initHandlers(): void {
    this.button.addEventListener("click", this.closeFlash.bind(this));
  }

  closeFlash(): void {
    this.flash.parentNode.removeChild(this.flash);
  }
}
