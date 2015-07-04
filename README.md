<div align="center">
  <h3 valign="middle">
    <img src="https://f.cloud.github.com/assets/436043/2303465/90386194-a1bf-11e3-98d9-b5f9c951be95.png" width="124">
    for Atom
  </h3>
  <h5>Adds Rdio controls to Atom and displays the currently playing song in the status bar.</h5>
  <br>
  <p><img src="https://f.cloud.github.com/assets/436043/2303457/70953200-a1be-11e3-8216-5e26b4f88369.gif"></p>
  <p><img src="https://f.cloud.github.com/assets/436043/2303448/3d0476ea-a1bd-11e3-8398-7086c2bb13f4.png"></p>
</div>

## Requirements
- [Atom](https://atom.io/)
- [Rdio](https://rd.io)
- Mac OS X (applescript)

## Features
- Opens current track directly inside `Rdio.app` when clicking the title;
- Sound bars animation pauses when Rdio is paused.

## Code Mood™
What if I told you that every bits of code that you write has a mood? Introducing the `Rdio: Play Code Mood` command, where your code actually tells Rdio what to play.

Madness! How is that possible? It’s actually quite simple. It will convert your current pane’s code (or selection if you have an active selection) into an MD5 digest and keeps only the first 6 digits. It will then ask Rdio.app to play the track number. [Rdio does a pretty good job](https://gist.github.com/EtienneLem/9339045) at always playing something. You will always get the same song from an unchanged file.

Every variable, every constant, every method, every single line of code has it’s own mood. Add a new feature, get a new song! Hopefully your code sounds as good as it looks :heart:

Do note that no API calls are made, so if your code wants to play an unavailable track, there’s nothing I can do to stop it. Rdio will fallback to auto play or do nothing. Check your `Developer Tools` to get more information about each track chosen.

## Commands
```rb
# Playstate
Play
Pause
Toggle

# Track
Next
Previous
Play Code Mood
Open Current Track

# Collection
Add
Remove

# Mobile
Sync
Unsync
```

## Credits
- Inspired by [atom-spotify](https://atom.io/packages/atom-spotify)
- Sound bars based on [CSS3 Pseudo Sound Bars](http://codepen.io/jackrugile/pen/CkAbG)
