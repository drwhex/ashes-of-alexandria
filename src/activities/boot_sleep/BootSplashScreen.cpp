#include "BootSplashScreen.h"

#include <GfxRenderer.h>
#include <I18n.h>

#include <cstdint>

#include "fontIds.h"
#include "images/BootSplash.h"

// drawPixel() goes through the renderer's orientation transform, so the
// portrait image stays upright; the raw drawImage() blit does not rotate bits.
// Pixels outside a smaller screen are clipped.
void drawBootSplash(const GfxRenderer& renderer) {
  const auto pageWidth = renderer.getScreenWidth();
  const auto pageHeight = renderer.getScreenHeight();
  const int originX = (pageWidth - BootSplashWidth) / 2;
  const int originY = (pageHeight - BootSplashHeight) / 2;
  constexpr int rowBytes = (BootSplashWidth + 7) / 8;

  renderer.clearScreen(0x00);
  for (int y = 0; y < BootSplashHeight; ++y) {
    const int screenY = originY + y;
    if (screenY < 0 || screenY >= pageHeight) continue;
    const uint8_t* row = BootSplash + y * rowBytes;
    for (int x = 0; x < BootSplashWidth; ++x) {
      const int screenX = originX + x;
      if (screenX < 0 || screenX >= pageWidth) continue;
      // The screen starts black; only white pixels need drawing.
      if ((row[x >> 3] & (0x80 >> (x & 7))) == 0) renderer.drawPixel(screenX, screenY, false);
    }
  }
  // Firmware name on the dark top band, fixed motto on the dark bottom band.
  renderer.drawCenteredText(UI_12_FONT_ID, 32, tr(STR_CROSSINK), false, EpdFontFamily::BOLD);
  renderer.drawCenteredText(UI_12_FONT_ID, pageHeight - 48, "Valhøl ver komum!", false, EpdFontFamily::BOLD);
}
