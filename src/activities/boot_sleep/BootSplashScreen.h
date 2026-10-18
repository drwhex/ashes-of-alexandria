#pragma once

class GfxRenderer;

// Ashes of Alexandria default boot and sleep screen: a full-screen 1-bit
// engraving (src/images/BootSplash.h) with the firmware name in white on its
// dark bottom band. Draws into the frame buffer only; the caller refreshes.
void drawBootSplash(const GfxRenderer& renderer);
