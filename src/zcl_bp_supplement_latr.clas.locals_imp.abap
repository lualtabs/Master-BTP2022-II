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
