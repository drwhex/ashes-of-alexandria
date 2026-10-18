# Ashes of Alexandria

> **Note:** this is an amateur hobby project, developed with the help of AI tools.
> It is provided as is, without any warranty. Use it at your own risk.

Ashes of Alexandria is custom firmware for the Xteink X4 Pro e-reader (also builds for X3, X4 and X4 Classic).

**Source code origin.** This project is based on [CrossInk](https://github.com/uxjulia/CrossInk) by Julia Nguyen
(imported at commit `9914146`, v1.6.1), which is itself a fork of
[CrossPoint Reader](https://github.com/crosspoint-reader/crosspoint-reader) by Dave Allie.
The [FreeInk SDK](https://github.com/Free-Ink/freeink-sdk) is used as a submodule.
All of them are distributed under the MIT License; the original copyright notice is kept in [LICENSE](LICENSE).

Changes in Ashes of Alexandria compared to CrossInk:

- Bitter is the only built-in reading font (Lexend Deca is removed); saved Lexend Deca settings switch to Bitter.
- The online font download screen is removed; custom TTF fonts can still be copied to `/fonts/` or uploaded through the web portal.
- Emergency firmware flash from the SD card: put a firmware image at `/force_update.bin` and restart the device.
  The image is validated and flashed before settings, display or UI start, then the file is removed
  and the device reboots into the new firmware (mechanism ported from [Papyrix](https://github.com/bigbag/papyrix-reader)).

Internal identifiers (`CROSSINK_*` build flags, cache formats, file paths on the SD card) keep their upstream names
to stay compatible with CrossInk data and tools.

---

## Notice on Contributions

For feature ideas and discussion, please use the original CrossInk [discussions](https://github.com/uxjulia/CrossInk/discussions).
If you enjoy this firmware, consider supporting the CrossInk author, uxjulia, on [Ko-fi](https://ko-fi.com/uxjulia).
