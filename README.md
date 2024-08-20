# Technical Difficulties No Internet (aka The Dino Crisis)
Warsaw, Miami 2024

A very small entry to [SV2K24SE](https://sillyventure.eu/en/).

Code: [Pecus](https://github.com/Pecusx) and [pirx](https://github.com/pkali)

Msx: Alex and Jochen Hippel

Used portions of LZSS player by [DMSC](https://github.com/dmsc/lzss-sap)

Assembly:
```
mads dino.asm -o:dino_.xex -d:ALONE=0
mads intro/tech_diff.asm -o:tech_diff.xex
cat intro/tech_diff.xex dino_.xex > tdc.xex; rm dino_.xex
```

Stand-alone game (no intro):
```
mads dino.asm -o:dino.xex -d:ALONE=1```
