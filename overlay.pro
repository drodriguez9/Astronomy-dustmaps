PRO overlay, vband, hband

;vband is the V-Band data gathered by the F606
;hband is the H-Band data gathered by the F160

;saving/recording input values

;Open F606 header and grab orientation data; load image data
image606 = mrdfits(vband, 0, header6061)
image606 = mrdfits(vband, 1, header6062)
orient606 = sxpar(header6062, 'orientat')
combinedheader606 = header6061 + header6062
writefits, 'hband.fits', image606, combinedheader606

;Open F160 first header and grab orientation data; load image data
image160 = mrdfits(hband, 0, header1601)
orient160 = sxpar(header1601, 'orientat')
image160 = mrdfits(hband, 1, header1602)
combinedheader160 = header1601 + header1602
writefits, 'vband.fits', image160, combinedheader160
la_cosmic, 'vband.fits', outsuff='-cr', masksuffix='-mask', gain=1.0

;determine rotation needed, then rotate
rotate = orient160 - orient606
IF (rotate LT 0) THEN rotate = rotate + 360
hrot, image606, combinedheader606, newimage606, combinedheader606, rotate, -1, -1, 0, MIS = 0

;Find new dimensions and resize
size = size(image160)
x = size[1]
y = size[2]
hrebin, newimage606, combinedheader606, OUT = [x, y] ;figure out how to use total
writefits, 'hband.fits', newimage606, combinedheader606

finalimage = FLTARR(x,y)
finalimage = newimage606 - image160

;Save Results
writefits, 'vsubh.fits', finalimage

v = readfits('vband.fits',hv)
h = readfits('hband.fits',hh)
vh = readfits('vsubh.fits',hvh)

photflam = fxpar(hv, 'PHOTFLAM')
photzpt = fxpar(hv, 'PHOTZPT')

v_zeropt = -2.5*ALOG10(photflam)+photzpt
v_mag = -2.5*ALOG10(v)+v_zeropt

h_photfnu = 1.49585D-6
h_fnuvega = 1086.9
zpvega = 0.0
h_mag = zpvega-2.5*ALOG10((h_photfnu)*h*(h_fnuvega)^(-1))

vh_mag = v_mag-h_mag
vhr_mag = v_mag/h_mag

writefits, 'finalvsubh.fits', vh_mag
writefits, 'finalvdivh.fits', vhr_mag
END