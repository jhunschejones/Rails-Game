# Rails Game

## Overview
Rails Game is, as you might have guessed, a turn-based web app / game. It uses unique user sessions and shared games to allow players to collaborate on creating and playing together, whether from the same location or from around the world.

## Lessons learned
This app takes advantage of some new technologies I was interested in trying within the context of the Rails ecosystem. All the client-side JavaScript for the app is written as Typescript and transpiled through Rails' asset pipeline. Rails 6 changed how it handles this process for Typescript partway through the process of writing the app, so I completed the migration before there was much documentation on how to do so. The setup process takes a bit of wrangling, but after that it was smooth sailing. I am sure as I maintain the app going forward I will appreciate the extra level of security a more strongly typed JavaScript is providing.

The other new tool I tried out in this app is ActionCable, Rails' WebSockets library. When playing with multiple players on different machines, ActionCable made it possible for me to refresh the content on all players devices at the same time. I have had a hit-and-miss time working with WebSockets in the past, as I'm like building the type of web apps that can be used on mobile devices with spotty internet. Rails made it surprisingly easy to dip my toes in and add _just_ enough WebSocket functionality for the simultaneous play feature without having to go too far into the weeds with this technology. In my testing it failed fairly gracefully on spotty internet as well, so overall it felt like a win!

## Reflections
Every new Rails app I write comes to life faster than the last. The initial, feature-complete version of this game was up and running after a single Saturday coding session, for example, a new personal best. It then only took one more session to flesh out my test suite a little better and polish up any UX tweaks I had noticed in the interim. I am growing more comfortable working with Devise and Bulma as well, which also get some credit for this increased development speed as they enable me to build secure, modern-looking apps without having to re-invent the wheel every time.

Overall, it seems the more time I spend in the Rails universe, the more I want to keep coming back. I find it's simply a pleasure to work in this breadth-first ecosystem where I can bring ideas to life without having to be an expert in every domain I touch, and without having to write a bunch of complex boilerplate code. When it's time for me to dive in and optimize or try a new technology, Rails often leaves me with a nice, clean jumping off place to start from. Suffice it to say, this is definitely not the last Rails project you'll see from me, that's for certain!
