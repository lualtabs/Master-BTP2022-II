FUNCTION zfm_suppl_latr.
*"----------------------------------------------------------------------
*"*"Local Interface:
*"  IMPORTING
*"     REFERENCE(IT_SUPLEMENTS) TYPE  ZTT_SUPPL_LATR
*"     REFERENCE(IV_OP_TYPE) TYPE  ZDE_FLAG_LATR
*"  EXPORTING
*"     REFERENCE(EV_UPDATED) TYPE  ZDE_FLAG_LATR
*"----------------------------------------------------------------------
  CHECK NOT it_suplements IS INITIAL.
  CASE iv_op_type.
    WHEN 'C'. INSERT ztb_booksup_latr FROM TABLE @it_suplements.
    WHEN 'U'. UPDATE ztb_booksup_latr FROM TABLE @it_suplements.
    WHEN 'D'.
      DELETE ztb_booksup_latr FROM TABLE @it_suplements.
  ENDCASE.

  IF sy-subrc EQ 0.
    ev_updated = abap_true.
  ENDIF.
ENDFUNCTION.
