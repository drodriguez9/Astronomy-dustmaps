PRO overlay, file1, file2

;File1 is the V-Band data gathered by the F606
;File2 is the H-Band data gathered by the F160

;saving/recording input values

;Open F606 header and grab orientation data; load image data
image606 = mrdfits(file1, 1, header606)
orient606 = sxpar(header606, 'orientat')

;Open F160 first header and grab orientation data; load image data
image160 = mrdfits(file2, 0, header160)
orient160 = sxpar(header160, 'orientat')
;IF (STRMATCH(file2, '*mos*', /FOLD_CASE) EQ 1) THEN BEGIN
    image160 = mrdfits(file2, 1)
;ENDIF
    
;determine rotation needed, then rotate
rotate = orient160 - orient606
IF (rotate LT 0) THEN rotate = rotate + 360
hrot, image606, header606, newimage606, header606, rotate, -1, -1, 0, MIS = 0

;Find new dimensions and resize
size = size(image160)
x = size[1]
y = size[2]
hrebin, newimage606, header606, OUT = [x, y] ;figure out how to use total

;Create new array that is the f606 - f160
finalimage = FLTARR(x,y)
finalimage = newimage606 - image160

;Save Results
mwrfits, finalimage, 'final.fits'
END