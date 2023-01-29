CLASS zcl_ext_travel_upd_latr DEFINITION
  PUBLIC
  FINAL
  CREATE PUBLIC .

  PUBLIC SECTION.
    INTERFACES if_oo_adt_classrun.
  PROTECTED SECTION.
  PRIVATE SECTION.
ENDCLASS.



CLASS zcl_ext_travel_upd_latr IMPLEMENTATION.
  METHOD if_oo_adt_classrun~main.
    DATA(lv_travel_id) = '00000999'. " Valid travel ID
    DATA(lv_description) = 'Changed Travel Agency'.
    DATA(lv_new_agency_id) = '070017'. " Valid agency ID

    MODIFY ENTITY zi_travel_latr
        UPDATE FIELDS ( AgencyId description )
        WITH VALUE #( ( TravelId = lv_travel_id
                        AgencyId = lv_new_agency_id
                        description = lv_description ) )
        FAILED DATA(ls_failed)
        REPORTED DATA(ls_reported).

    CLEAR: ls_reported, ls_failed.

    READ ENTITY zi_travel_latr
        FIELDS ( AgencyId description )
        WITH VALUE #( ( TravelId = lv_travel_id ) )
        RESULT DATA(lt_received_travel_data)
        FAILED ls_failed.
    out->write( lt_received_travel_data ).

    COMMIT ENTITIES.

    IF sy-subrc = 0.
        out->write( 'Successful COMMIT!' ).
    ELSE.
        out->write( 'COMMIT failed!' ).
    ENDIF.
  ENDMETHOD.

ENDCLASS.
