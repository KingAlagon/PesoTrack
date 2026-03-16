// node tool/svg_to_png.js
// Converts app_icon.svg -> app_icon.png (1024x1024) and app_icon_foreground.png
// using @resvg/resvg-js (installed in C:/tmp/node_modules)

const path = require('path');
const fs = require('fs');

const { Resvg } = require('@resvg/resvg-js');

const svgPath = path.join(__dirname, '../assets/images/app_icon.svg');
const svgData = fs.readFileSync(svgPath, 'utf-8');

// ── Full icon (1024x1024) — render the icon rect region only ─────────────────
// The SVG viewBox is 680x680; the icon rect is x=100,y=80 w=480 h=480
// We use a viewBox crop by wrapping in a new SVG that sets viewBox to the icon area.

const iconSvg = svgData.replace(
  /viewBox="[^"]*"/,
  'viewBox="100 80 480 480"'
).replace(/width="[^"]*"/, 'width="1024"').replace(/height="[^"]*"/, 'height="1024"')
  // add height if not present
  || svgData;

const resvgFull = new Resvg(iconSvg, {
  fitTo: { mode: 'width', value: 1024 },
  font: { loadSystemFonts: false },
});
const fullPng = resvgFull.render().asPng();
fs.writeFileSync(path.join(__dirname, '../assets/images/app_icon.png'), fullPng);
console.log('✓ Wrote assets/images/app_icon.png (1024x1024)');

// ── Foreground layer — same but without the background rect and orbs,
//    keeping only the ₱ symbol (safe zone = centre 66%)
//    We render the same cropped icon; adaptive foreground needs a transparent bg.
//    Strategy: render full icon but on transparent background.
//    The adaptive background colour (#0F0C29) is set in pubspec.yaml.
const fgSvg = iconSvg
  // Remove the solid background rect (first rect with fill="url(#bg)")
  .replace(/<rect[^>]*fill="url\(#bg\)"[^>]*\/>/, '')
  // Remove orbs group
  .replace(/<g clip-path="url\(#iconClip\)"[\s\S]*?<\/g>/, '')
  // Remove glass surface overlay rect
  .replace(/<rect[^>]*fill="url\(#cardGlass\)"[^>]*\/>/, '')
  // Remove shine path
  .replace(/<path[^>]*fill="url\(#shine\)"[^>]*\/>/, '')
  // Remove bottom stats bar elements (everything after the ₱ highlight text up to outer border)
  .replace(/<!-- Floating mini stats[\s\S]*?<!-- Outer glow border -->/, '<!-- Outer glow border -->')
  // Remove outer border rects
  .replace(/<rect[^>]*stroke="url\(#pesoGrad\)"[^>]*\/>/, '')
  .replace(/<rect[^>]*stroke="white"[^>]*stroke-opacity="0\.07"[^>]*\/>/, '');

const resvgFg = new Resvg(fgSvg, {
  fitTo: { mode: 'width', value: 1024 },
  font: { loadSystemFonts: false },
  background: 'transparent',
});
const fgPng = resvgFg.render().asPng();
fs.writeFileSync(path.join(__dirname, '../assets/images/app_icon_foreground.png'), fgPng);
console.log('✓ Wrote assets/images/app_icon_foreground.png (1024x1024)');

console.log('\nDone! Run: dart run flutter_launcher_icons');
