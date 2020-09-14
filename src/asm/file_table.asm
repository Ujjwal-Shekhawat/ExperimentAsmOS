;;;
;;;    Basic filetable mase using db (declae byte), strings comstistion of '{filename-sector#, filename2-sector#, ...filenamen-sector#}'
;;;

;;; New file table organization structure
;;;
;;;    0-9 file name
;;;    10-12 file extension
;;;    13 Directory entry
;;;    14 Staring sector
;;;    15 File size in hex
;;;    

db 'bootSect  ', 'bin', 0h, 1h, 1h, \
   'filesystem', 'fts', 0h, 2h, 1h, \
   'kernel    ', 'bin', 0h, 3h, 3h, \
   'calculator', 'bin', 0h, 6h, 1h

times 512-($-$$) db 0