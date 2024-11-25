# libastal setup

## Quick words on the code layout (note to self)

The UI itself is split into self standing modules, which are supposed to at best rely on
their children, for example "osds.notifications" can rely on functionality in
"osds.notifications.sounds", but not the other way around. Any cross-functionality has to
be handled by a parent, with each module exposing public functions that provide this
functionality. Each module should expose an `unload` function, so that for example
windows can be deconstructed when a reload is issued. ANY state that needs to be preserved
has to be a global variable. We do NOT use global variables, so there should be no state.

Anything that should be reused/made reusable does NOT belong in the `ui` folder. This
folder is only for the code that directly adds windows and cool stuff to the screen, if
you can see the same thing in two places it does not belong there

Reactivity should be achieved with explicit callbacks and shall not rely on magic.

Gears are copied from awesome and do not need to be tampered with.

I try to not use as many external lua libraries, i already have lgi with the gtk libs
available.
