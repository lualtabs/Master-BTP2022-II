CLASS lhc_Booking DEFINITION INHERITING FROM cl_abap_behavior_handler.
  PRIVATE SECTION.

    METHODS calculateTotalFlighPrice FOR DETERMINE ON MODIFY
      IMPORTING keys FOR Booking~calculateTotalFlighPrice.

    METHODS validateStatus FOR VALIDATE ON SAVE
      IMPORTING keys FOR Booking~validateStatus.

    "!
    METHODS get_features FOR FEATURES IMPORTING keys REQUEST requested_features FOR booking RESULT result.

ENDCLASS.

CLASS lhc_Booking IMPLEMENTATION.

  METHOD calculateTotalFlighPrice.
    IF keys IS NOT INITIAL.
        zcl_aux_travel_det_latr=>calculate_price( it_travel_id = VALUE #( FOR GROUPS <booking> OF booking_key IN keys
                                                                          GROUP BY booking_key-TravelId WITHOUT MEMBERS ( <booking> ) ) ).
    ENDIF.
  ENDMETHOD.

  METHOD validateStatus.
    READ ENTITY zi_travel_latr\\Booking
        FIELDS ( bookingstatus )
        WITH VALUE #( FOR <row_key> IN keys ( %key = <row_key>-%key ) )
        RESULT DATA(lt_booking_result).
    LOOP AT lt_booking_result INTO DATA(ls_booking_result).
      CASE ls_booking_result-bookingstatus.
        WHEN 'N'. " New
        WHEN 'X'. " Cancelled
        WHEN 'B'. " Booked
        WHEN OTHERS.
          APPEND VALUE #( %key = ls_booking_result-%key ) TO failed-booking.
          APPEND VALUE #( %key = ls_booking_result-%key
                          %msg = new_message( id = 'ZMC_TRAVEL_LATR'
                                              number = '007'
                                              v1 = ls_booking_result-bookingid
                                              severity = if_abap_behv_message=>severity-error )
                          %element-bookingstatus = if_abap_behv=>mk-on ) TO reported-booking.
      ENDCASE.
    ENDLOOP.
  ENDMETHOD.

  METHOD get_features.
    READ ENTITIES OF zi_travel_latr
        ENTITY Booking
        FIELDS ( BookingId BookingDate CustomerId BookingStatus )
        WITH VALUE #( FOR keyval IN keys ( %key = keyval-%key ) )
        RESULT DATA(lt_booking_result).
    result = VALUE #( FOR ls_travel IN lt_booking_result
                                      ( %key = ls_travel-%key
                                        %assoc-_BookingSupplement = if_abap_behv=>fc-o-enabled ) ).
ENDMETHOD.

ENDCLASS.
