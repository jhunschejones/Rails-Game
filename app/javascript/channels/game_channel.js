import consumer from "./consumer"

if (window.location.pathname.match(/^\/games\/(\d+)$/)) {
  consumer.subscriptions.create({
    channel: "GameChannel",
    game_id: window.location.pathname.match(/^\/games\/(\d+)$/)[1]
  }, {
    connected() {
      // Called when the subscription is ready for use on the server
      console.log("Connected to game_channel");
    },

    disconnected() {
      // Called when the subscription has been terminated by the server
      console.log("Disconnected from game_channel");
    },

    received(data) {
      if (Object.keys(data).length === 0) {
        // Reloading page with just Turbolinks to avoid flickering
        // also attempting to maintain scroll position around reload
        var top = document.scrollingElement.scrollTop;
        var scrollToTop = () => {
          document.scrollingElement.scrollTo(0, top);
          document.removeEventListener("turbolinks:load", scrollToTop);
        };

        Turbolinks.visit(window.location.toString(), {action: 'replace'});
        document.addEventListener("turbolinks:load", scrollToTop);

      } else {
        var gamePlayContainer = document.querySelector(".game-play-container");
        while (gamePlayContainer.firstChild) {
          gamePlayContainer.removeChild(gamePlayContainer.firstChild);
        }
        gamePlayContainer.insertAdjacentHTML("beforeend", data["gamePlaySections"]);
        document.querySelector(".current-player").textContent = `Current player: ${data["currentPlayer"]}`;
      }
    }
  });
}
