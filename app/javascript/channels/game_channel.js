import consumer from "./consumer"

// To only match the game/show page, add a `$` end-of string character to the
// end of these regexes
if (window.location.pathname.match(/^\/games\/(\d+)/)) {
  consumer.subscriptions.create({
    channel: "GameChannel",
    game_id: window.location.pathname.match(/^\/games\/(\d+)/)[1]
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
      // Called when there's incoming data on the websocket for this channel

      // Same action as /app/views/games/play.js.erb
      // var gamePlayContainer = document.querySelector(".game-play-container");
      // while (gamePlayContainer.firstChild) {
      //   gamePlayContainer.removeChild(gamePlayContainer.firstChild);
      // }
      // gamePlayContainer.insertAdjacentHTML("beforeend", data);

      // simplest solution
      // location.reload();

      // Reloading with just Turbolinks to avoid flickering
      Turbolinks.visit(window.location.toString(), {action: 'replace'})
    }
  });
}
