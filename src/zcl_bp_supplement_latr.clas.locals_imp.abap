CLASS lhc_Supplement DEFINITION INHERITING FROM cl_abap_behavior_handler.
  PRIVATE SECTION.

    METHODS calculateTotaSupplimPrice FOR DETERMINE ON MODIFY
      IMPORTING keys FOR Supplement~calculateTotaSupplimPrice.

ENDCLASS.

CLASS lhc_Supplement IMPLEMENTATION.

  METHOD calculateTotaSupplimPrice.
    IF keys IS NOT INITIAL.
      zcl_aux_travel_det_latr=>calculate_price( it_travel_id = VALUE #( FOR GROUPS <booking_suppl> OF booksuppl_key IN keys
                                                                        GROUP BY booksuppl_key-TravelId WITHOUT MEMBERS ( <booking_suppl> ) ) ).
    ENDIF.
  ENDMETHOD.

ENDCLASS.


CLASS lcl_supplement DEFINITION INHERITING FROM cl_abap_behavior_saver.
  PUBLIC SECTION.
    CONSTANTS: create TYPE string VALUE 'C',
               update TYPE string VALUE 'U',
               delete TYPE string VALUE 'D'.
  PROTECTED SECTION.
    METHODS save_modified REDEFINITION.
ENDCLASS.

CLASS lcl_supplement IMPLEMENTATION.
  METHOD save_modified.
    DATA: lt_supplements TYPE STANDARD TABLE OF ztb_booksup_latr,
          lr_supplements TYPE ztb_booksup_latr,
          lv_op_type     TYPE zde_flag_latr,
          lv_updated     TYPE zde_flag_latr.

    IF NOT create-supplement IS INITIAL.
      lt_supplements = CORRESPONDING #( create-supplement ).
      lv_op_type = lcl_supplement=>create.
    ENDIF.

    IF NOT update-supplement IS INITIAL.
      lt_supplements = CORRESPONDING #( update-supplement ). "No tienen los mismos nombres
      "Mover campo por campo porque el alías molesta y no sirvió el maping.
      lr_supplements-travel_id             = update-supplement[ 1 ]-TravelId.
      lr_supplements-booking_id            = update-supplement[ 1 ]-BookingId.
      lr_supplements-booking_supplement_id = update-supplement[ 1 ]-BookingSupplementId.
      lr_supplements-price                 = update-supplement[ 1 ]-Price.
      append lr_supplements to lt_supplements.
      lv_op_type = lcl_supplement=>update.
    ENDIF.

    IF NOT delete-supplement IS INITIAL.
      lt_supplements = CORRESPONDING #( delete-supplement ).
      lv_op_type = lcl_supplement=>delete.
    ENDIF.

    IF NOT lt_supplements IS INITIAL.
      CALL FUNCTION 'ZFM_SUPPL_LATR'
        EXPORTING
          it_suplements = lt_supplements
          iv_op_type    = lv_op_type
        IMPORTING
          ev_updated    = lv_updated.
      IF lv_updated EQ abap_true.
      ENDIF.
    ENDIF.
  ENDMETHOD.
ENDCLASS.
