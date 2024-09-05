FlowMap Painter
(c)2012 Teck Lee Tan
www.teckArtist.com

== Description ==

This here is a flowmap painter. It serves to make artist-authored (or -tweaked) flowmaps a viable option, where current methods tend to favor simulations via Houdini, for example.
(https://developer.valvesoftware.com/wiki/Water_(shader)#Authoring_a_flow_map)

The tool allows the artist to paint areas of flow, and uses a basic flow shader to immediately preview the results.
It also provides a couple of additional visualisations, such as the actual colors that are being painted, as well as a visualisation of the resulting flow lines.

It's currently a little rough around the edges; for example, needing to type in the path to your output or custom texture, as opposed to having a proper file browser.

Currently PNG is the image format of choice for saving, though JPEGs can be loaded (as your overlay texture, for example). TGA is unsupported.


== Installation ==

Currently there's no installer. Just unzip to the location of your choice and run FlowMapPainter.exe.


== Changelog ==

= 0.9.2 =
* 4 October 2012
* Tweaked pan/zoom behavior
* Added:
  - Spacebar as an alternative to Alt for pan/zoom
  - Zoom level indicator
  - option to flip red/green channels on bake
  - swizzle option (red/green --> red/blue)
  - ability to save/load session **superceded by next point
  - ability to load flowmap texture
  - slider to alter flow preview line length
  - optional wrapping (with tiling preview)
  - defaults.ini to remember your last-used paths between sessions
* Fixed overlay texture rotated 180 degrees
* Fixed custom tiling texture reverting to default when toggling vertex color preview
* Fixed version check
* Optimised performance somewhat
* Known Issue: Flowmap preview doesn't tile correctly (shader problem?)
* Known Issue: Flow line preview mode is slowww

= 0.9.1 =
* 20 September 2012
* Added new brush modes (Pinch/Inflate, and Vortex)
  -Currently, only way to switch modes is keyboard shortcuts (1, 2, 3)
* Added pan and zoom functionality (and reset view)
* Added rudimentary version checker and update notification
* Fixed broken overlay functionality from initial release.
  -also defaults overlay to 50% opacity (instead of invisible)

= 0.9 =
* 17 September 2012
* Initial test release


== ToDo ==

* Proper file browser
* Store some defaults (eg. Output directory, last session's custom texture path, etc)
* Redo functionality (currently only undo)
* Proper brush selector


== Further Reading ==

https://developer.valvesoftware.com/wiki/Water_(shader)
http://mtnphil.wordpress.com/2012/08/25/water-flow-shader/
http://twvideo01.ubm-us.net/o1/vault/gdc2012/slides/Missing%20Presentations/Added%20March%2026/Keith_Guerrette_VisualArts_TheTricksUp.pdf (from P57 - Creating Motion in Particles, Technique 2: Flow Technique)