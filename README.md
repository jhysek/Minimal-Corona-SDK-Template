Minimal Corona SDK empty app template
=====================================

Minimal Corona SDK template. It contains only what I'm using almost in all Corona apps/games:

- directory structure
- preconfigured build.settings
- preconfigured config.lua with zoomEven scale
- main.lua with
  - composer initialization (new replacement of storyboard),
  - useful constants for responsive layout,
  - hiding the status bar
  - and transition to a menu scene
- empty menu scene
- lib/inspect.lua - useful library by http://github.com/kikito/inspect.lua for debugging purposes
- scripts/makeicons - script for converting icon.png into all icon sizes for iOS (including iPhone 6 plus icons) and Android

This content is released under the MIT License.
