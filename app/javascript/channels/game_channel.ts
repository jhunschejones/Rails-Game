import Consumer from "./consumer";
import Turbolinks from "turbolinks";

if (window.location.pathname.match(/^\/games\/(\d+)$/)) {
  Consumer.subscriptions.create(
    {
      channel: "GameChannel",
      game_id: window.location.pathname.match(/^\/games\/(\d+)$/)[1],
    },
    {
      connected() {
        // Called when the subscription is ready for use on the server
        // tslint:disable-next-line:no-console
        console.log("Connected to game_channel");
      },

      disconnected() {
        // Called when the subscription has been terminated by the server
        // tslint:disable-next-line:no-console
        console.log("Disconnected from game_channel");
      },

      received(data) {
        if (Object.keys(data).length === 0) {
          // Reloading page with just Turbolinks to avoid flickering
          // also attempting to maintain scroll position around reload
          const top = document.scrollingElement.scrollTop;
          const scrollToTop = () => {
            document.scrollingElement.scrollTo(0, top);
            document.removeEventListener("turbolinks:load", scrollToTop);
          };

          Turbolinks.visit(window.location.toString(), { action: "replace" });
          document.addEventListener("turbolinks:load", scrollToTop);
        } else {
          const gamePlayContainer = document.querySelector(
            ".game-play-container"
          );
          while (gamePlayContainer.firstChild) {
            gamePlayContainer.removeChild(gamePlayContainer.firstChild);
          }
          gamePlayContainer.insertAdjacentHTML(
            "beforeend",
            data.gamePlaySections
          );
          document.querySelector(
            ".current-player"
          ).textContent = `Current player: ${data.currentPlayer}`;
        }
      },
    }
  );
}
