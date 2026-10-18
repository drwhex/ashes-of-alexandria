# Converts src/images/boot_splash.bmp into src/images/BootSplash.h (1-bit, Floyd-Steinberg).
# Usage: powershell -File scripts/bmp2header.ps1 -InPath src/images/boot_splash.bmp -OutHeader src/images/BootSplash.h -OutPreview splash_preview.png
param([string]$InPath, [string]$OutHeader, [string]$OutPreview)
Add-Type -AssemblyName System.Drawing
Add-Type -ReferencedAssemblies System.Drawing -TypeDefinition @"
using System;
using System.Drawing;
using System.Text;
public static class Conv {
  // Floyd-Steinberg to 1 bit. Packed row-major, MSB first, bit 1 = black pixel.
  public static byte[] Pack(Bitmap b, out Bitmap preview) {
    int w = b.Width, h = b.Height;
    float[] g = new float[w * h];
    for (int y = 0; y < h; y++) for (int x = 0; x < w; x++) {
      Color c = b.GetPixel(x, y);
      float v = 0.299f * c.R + 0.587f * c.G + 0.114f * c.B;
      // Levels: crush the near-black background noise so it stays solid black.
      v = (v - 32f) * 255f / (255f - 32f);
      g[y * w + x] = v < 0f ? 0f : (v > 255f ? 255f : v);
    }
    byte[] outp = new byte[(w + 7) / 8 * h];
    preview = new Bitmap(w, h);
    for (int y = 0; y < h; y++) for (int x = 0; x < w; x++) {
      float old = g[y * w + x];
      bool black = old < 128f;
      float err = old - (black ? 0f : 255f);
      if (black) outp[y * ((w + 7) / 8) + x / 8] |= (byte)(0x80 >> (x % 8));
      preview.SetPixel(x, y, black ? Color.Black : Color.White);
      if (x + 1 < w) g[y * w + x + 1] += err * 7 / 16f;
      if (y + 1 < h) {
        if (x > 0) g[(y + 1) * w + x - 1] += err * 3 / 16f;
        g[(y + 1) * w + x] += err * 5 / 16f;
        if (x + 1 < w) g[(y + 1) * w + x + 1] += err * 1 / 16f;
      }
    }
    return outp;
  }
  public static string Header(byte[] d, int w, int h) {
    var sb = new StringBuilder();
    sb.Append("#pragma once\n#include <cstdint>\n\n");
    sb.Append("// Ashes of Alexandria boot splash, generated from src/images/boot_splash.bmp by scripts/bmp2header.ps1.\n");
    sb.Append("// " + w + "x" + h + " px, 1 bit per pixel, row-major, MSB first, bit 1 = black pixel.\n");
    sb.Append("constexpr int BootSplashWidth = " + w + ";\nconstexpr int BootSplashHeight = " + h + ";\n");
    sb.Append("static const uint8_t BootSplash[] = {\n");
    for (int i = 0; i < d.Length; i++) {
      if (i % 19 == 0) sb.Append("    ");
      sb.Append("0x" + d[i].ToString("x2") + ",");
      sb.Append(i % 19 == 18 || i == d.Length - 1 ? "\n" : " ");
    }
    sb.Append("};\nstatic_assert(sizeof(BootSplash) == (BootSplashWidth + 7) / 8 * BootSplashHeight, \"BootSplash size mismatch\");\n");
    return sb.ToString();
  }
}
"@
$b = [System.Drawing.Bitmap]::new($InPath)
$prev = $null
$data = [Conv]::Pack($b, [ref]$prev)
[System.IO.File]::WriteAllText($OutHeader, [Conv]::Header($data, $b.Width, $b.Height))
$prev.Save($OutPreview, [System.Drawing.Imaging.ImageFormat]::Png)
"bytes=$($data.Length)"
