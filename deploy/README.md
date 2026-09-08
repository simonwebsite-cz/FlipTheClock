# Server deployment

Files here are for the copy of the site hosted at
[www.tichysimon.cz/FlipTheClock](https://www.tichysimon.cz/FlipTheClock/).
They are not part of the app and GitHub Pages does not serve them.

## Layout on the server

```
FlipTheClock/      contents of ../docs  (index.html + img/)
fliptheclock/      contents of ./fliptheclock  (a redirect to the above)
```

Upload the *contents* of each folder, not the folder itself.

## Why the lowercase copy exists

The server is Linux, so `/fliptheclock/` and `/FlipTheClock/` are
different paths and the lowercase one would otherwise 404. This is easy to
miss on a desktop, where the address bar autocompletes to a URL already in
history and quietly restores the capitals; on a phone there is no such
history, so what was typed is what gets sent.

A `return 301` in nginx would be the better fix, but it means editing the
configuration of a live server. This is the equivalent that only needs an
upload.

If other spellings ever come up in practice, copy the same folder again
under that name — the file redirects to `/FlipTheClock/` regardless of
what it is served as.
