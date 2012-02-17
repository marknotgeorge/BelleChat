BelleChat, formerly QMLIrc.

BelleChat is an IRC (Internet Relay Chat) client for Symbian Anna and Belle smartphones.

It offers the following features:

- Conforms to the Belle UI guidelines, using QT Quick Components for Symbian.
- Multiple channels open at once.
- Correctly renders mIRC colours.
- Split-screen keyboard supported.

BelleChat requires Qt 4.7.4 and Qt Quick 1.1.

To compile the source code, you will require Communi, written by JP  Nurmi et al.
You will require Communi 1.0.0, as that is what it is currently linked with, and
it should be built as a static library. The best way of doing this is to open BelleChat
and Communi in the same session and set a dependency to Communi in the BelleChat Build/Run
options screen.

BelleChat uses Communi, which is released under the FSF LGPL.

(c) 2011-12 Mark Johnson.
