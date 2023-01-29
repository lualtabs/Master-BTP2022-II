CLASS lhc_Travel DEFINITION INHERITING FROM cl_abap_behavior_handler.
  PRIVATE SECTION.

    METHODS get_instance_features FOR INSTANCE FEATURES
      IMPORTING keys REQUEST requested_features FOR Travel RESULT result.

    METHODS get_instance_authorizations FOR INSTANCE AUTHORIZATION
      IMPORTING keys REQUEST requested_authorizations FOR Travel RESULT result.

    METHODS acceptTravel FOR MODIFY
      IMPORTING keys FOR ACTION Travel~acceptTravel RESULT result.

    METHODS createTravelByTemplate FOR MODIFY
      IMPORTING keys FOR ACTION Travel~createTravelByTemplate RESULT result.

    METHODS rejectTravel FOR MODIFY
      IMPORTING keys FOR ACTION Travel~rejectTravel RESULT result.

    METHODS validateCustomer FOR VALIDATE ON SAVE
      IMPORTING keys FOR Travel~validateCustomer.

    METHODS validateDates FOR VALIDATE ON SAVE
      IMPORTING keys FOR Travel~validateDates.

    METHODS validateStatus FOR VALIDATE ON SAVE
      IMPORTING keys FOR Travel~validateStatus.

ENDCLASS.

CLASS lhc_Travel IMPLEMENTATION.
  METHOD get_instance_features.
    READ ENTITIES OF zi_travel_latr
        ENTITY travel
        FIELDS ( TravelId OverallStatus )
        WITH VALUE #( FOR keyval IN keys ( %key = keyval-%key ) )
            RESULT DATA(lt_travel_result).

    result = VALUE #( FOR ls_travel IN lt_travel_result (
                            %key = ls_travel-%key
                            %field-TravelId = if_abap_behv=>fc-f-read_only
                            %field-OverallStatus = if_abap_behv=>fc-f-read_only
                            %assoc-_Booking = if_abap_behv=>fc-o-enabled
                            %features-%action-rejectTravel = COND #( WHEN ls_travel-OverallStatus = 'X'
                                THEN if_abap_behv=>fc-o-disabled
                                ELSE if_abap_behv=>fc-o-enabled )
                            %features-%action-acceptTravel = COND #( WHEN ls_travel-OverallStatus = 'A'
                                THEN if_abap_behv=>fc-o-disabled
                                ELSE if_abap_behv=>fc-o-enabled ) ) ).
  ENDMETHOD.

  METHOD get_instance_authorizations.
    DATA(lv_auth) = COND #( WHEN cl_abap_context_info=>get_user_technical_name( ) EQ 'CB9980002318'
                    THEN if_abap_behv=>auth-allowed
                    ELSE if_abap_behv=>auth-unauthorized ).
    LOOP AT keys ASSIGNING FIELD-SYMBOL(<ls_keys>).
      APPEND INITIAL LINE TO result ASSIGNING FIELD-SYMBOL(<ls_result>).
      <ls_result> = VALUE #( %key = <ls_keys>-%key
      %op-%update = lv_auth
      %delete = lv_auth
      %action-acceptTravel = lv_auth
      %action-rejectTravel = lv_auth
      %action-createTravelByTemplate = lv_auth
      %assoc-_Booking = lv_auth ).
    ENDLOOP.
  ENDMETHOD.

  METHOD acceptTravel.
    MODIFY ENTITIES OF zi_travel_latr IN LOCAL MODE
        ENTITY travel
        UPDATE FIELDS ( OverallStatus )
        WITH VALUE #( FOR key IN keys ( TravelId      = key-TravelId
                                        OverallStatus = 'A' ) ) " Accepted
        FAILED failed
        REPORTED reported.

    READ ENTITIES OF zi_travel_latr IN LOCAL MODE
    ENTITY travel
    FIELDS ( AgencyId
             CustomerId
             BeginDate
             EndDate
             BookingFee
             TotalPrice
             CurrencyCode
             OverallStatus
             Description
             CreatedBy
             CreatedAt
             LastChangedAt
             LastChangedBy )
    WITH VALUE #( FOR key IN keys ( TravelId = key-TravelId ) )
        RESULT DATA(lt_travel).

    result = VALUE #( FOR travel IN lt_travel ( TravelId = travel-TravelId
                                                  %param = travel ) ).

    LOOP AT lt_travel ASSIGNING FIELD-SYMBOL(<ls_travel>).
      DATA(lv_travel_msg) = <ls_travel>-TravelId.
      SHIFT lv_travel_msg LEFT DELETING LEADING '0'.
      APPEND VALUE #( travelid = <ls_travel>-TravelId
                      %msg = new_message( id = 'ZMC_TRAVEL_LATR'
                                          number = '005'
                                          v1 = lv_travel_msg
                                          severity = if_abap_behv_message=>severity-success )
                      %element-customerid = if_abap_behv=>mk-on ) TO reported-travel.
    ENDLOOP.
  ENDMETHOD.

*
  METHOD rejectTravel.
    MODIFY ENTITIES OF zi_travel_latr IN LOCAL MODE
      ENTITY travel
      UPDATE FIELDS ( OverallStatus )
      WITH VALUE #( FOR key IN keys ( TravelId      = key-TravelId
                                      OverallStatus = 'X' ) ) " Rejected
      FAILED failed
      REPORTED reported.

    READ ENTITIES OF zi_travel_latr IN LOCAL MODE
    ENTITY travel
    FIELDS ( AgencyId
             CustomerId
             BeginDate
             EndDate
             BookingFee
             TotalPrice
             CurrencyCode
             OverallStatus
             Description
             CreatedBy
             CreatedAt
             LastChangedAt
             LastChangedBy )
    WITH VALUE #( FOR key IN keys ( TravelId = key-TravelId ) )
        RESULT DATA(lt_travel).

    result = VALUE #( FOR travel IN lt_travel ( TravelId = travel-TravelId
                                                  %param = travel ) ).

    LOOP AT lt_travel ASSIGNING FIELD-SYMBOL(<ls_travel>).
      DATA(lv_travel_msg) = <ls_travel>-TravelId.
      SHIFT lv_travel_msg LEFT DELETING LEADING '0'.
      APPEND VALUE #( travelid = <ls_travel>-TravelId
                      %msg = new_message( id = 'ZMC_TRAVEL_LATR'
                                          number = '006'
                                          v1 = lv_travel_msg
                                          severity = if_abap_behv_message=>severity-success )
                      %element-customerid = if_abap_behv=>mk-on ) TO reported-travel.
    ENDLOOP.
  ENDMETHOD.

*
  METHOD createTravelByTemplate.
    "Read Entidad raíz del Behavior Definitios hacia entidad
    READ ENTITIES OF zi_travel_latr
      ENTITY Travel
      FIELDS ( TravelId AgencyId CustomerId BookingFee TotalPrice CurrencyCode )
      WITH VALUE #( FOR row_key IN keys ( %key =  row_key-%key ) )
      RESULT DATA(lt_read_result)
      FAILED failed
      REPORTED reported.
    "Máxima cantidad de registros de la tabla de persistencia
    SELECT MAX( travel_id ) FROM ztb_travel_latr INTO @DATA(lv_travel_id).

    DATA(lv_today) = cl_abap_context_info=>get_system_date( ).
    DATA lt_create TYPE TABLE FOR CREATE zi_travel_latr\\travel. "Vista raíz del Behavior definitions
    "Obtiene filas
    lt_create = VALUE #( FOR row IN lt_read_result INDEX INTO idx
       ( TravelId = lv_travel_id + idx
         AgencyId = row-AgencyId
         CustomerId = row-CustomerId
         BeginDate = lv_today
         EndDate = lv_today + 30
         BookingFee = row-BookingFee
         TotalPrice = row-TotalPrice
         CurrencyCode = row-CurrencyCode
         Description = 'Comments here'
         OverallStatus = 'O') ).
    "Modifica la entidad que lleva a tabla de persistencia con filas de lt_crete
    MODIFY ENTITIES OF zi_travel_latr
    IN LOCAL MODE ENTITY travel
    CREATE FIELDS ( TravelId
                    AgencyId
                    CustomerId
                    BeginDate
                    EndDate
                    BookingFee
                    TotalPrice
                    CurrencyCode
                    Description
                    OverallStatus )
                    WITH lt_create
                    MAPPED mapped
                    FAILED failed
                    REPORTED reported.

    "Devuelve resultados
    result = VALUE #( FOR create IN lt_create INDEX INTO idx
        ( %cid_ref = keys[ idx ]-%cid_ref
          %key = keys[ idx ]-TravelId
          %param = CORRESPONDING #( create ) ) ).
  ENDMETHOD.

  METHOD validateCustomer.
    "Lectura de la entidad
    READ ENTITIES OF zi_travel_latr IN LOCAL MODE
        ENTITY Travel
        FIELDS ( CustomerId )
        WITH CORRESPONDING #( keys )
        RESULT DATA(lt_travel).

    "Lectura de la tabla de persistencia
    DATA lt_customer TYPE SORTED TABLE OF /dmo/customer WITH UNIQUE KEY customer_id.

    "Descartar duplicados
    lt_customer = CORRESPONDING #( lt_travel DISCARDING DUPLICATES MAPPING customer_id = CustomerId EXCEPT * ).
    "Borrar blancos
    DELETE lt_customer WHERE customer_id IS INITIAL.
    IF lt_customer IS NOT INITIAL.
      "Lectura tabla persistencia ya depurada-
      SELECT FROM /dmo/customer FIELDS customer_id
      FOR ALL ENTRIES IN @lt_customer
      WHERE customer_id = @lt_customer-customer_id
      INTO TABLE @DATA(lt_customer_db).
    ENDIF.

    LOOP AT lt_travel INTO DATA(ls_travel).
      "Validar data digitada vs data de la tabla de persistencia
      IF ls_travel-CustomerId IS INITIAL OR NOT line_exists( lt_customer_db[ customer_id = ls_travel-CustomerId ] ).
        APPEND VALUE #( travelid = ls_travel-TravelId ) TO failed-travel.
        APPEND VALUE #( travelid = ls_travel-TravelId
                        %msg = new_message( id = 'ZMC_TRAVEL_LATR'
                                            number = '001'
                                            v1 = ls_travel-CustomerId
                                            severity = if_abap_behv_message=>severity-error )
                        %element-customerid = if_abap_behv=>mk-on ) TO reported-travel.
      ENDIF.
    ENDLOOP.

  ENDMETHOD.

  METHOD validateDates.
    READ ENTITY zi_travel_latr\\Travel
        FIELDS ( BeginDate EndDate )
        WITH VALUE #( FOR <row_key> IN keys ( %key = <row_key>-%key ) )
        RESULT DATA(lt_travel_result).

    LOOP AT lt_travel_result INTO DATA(ls_travel_result).
      IF ls_travel_result-EndDate LT ls_travel_result-BeginDate. "end_date before begin_date
        APPEND VALUE #( %key = ls_travel_result-%key
                        travelid = ls_travel_result-TravelId ) TO failed-travel.
        APPEND VALUE #( %key = ls_travel_result-%key
                        %msg = new_message( id = 'ZMC_TRAVEL_LATR'
                                            number = '002'
                                            v1 = ls_travel_result-BeginDate
                                            v2 = ls_travel_result-EndDate
                                            v3 = ls_travel_result-TravelId
                                            severity = if_abap_behv_message=>severity-error )
                        %element-begindate  = if_abap_behv=>mk-on
                        %element-enddate = if_abap_behv=>mk-on ) TO reported-travel.
      ELSEIF ls_travel_result-begindate < cl_abap_context_info=>get_system_date( ). "begin_date must be in the future
        APPEND VALUE #( %key = ls_travel_result-%key
                        travelid = ls_travel_result-TravelId ) TO failed-travel.
        APPEND VALUE #( %key = ls_travel_result-%key
                        %msg = new_message( id = 'ZMC_TRAVEL_LATR'
                                            number = '003'
                                            v1 = ls_travel_result-BeginDate
                                            severity = if_abap_behv_message=>severity-error )
                        %element-begindate = if_abap_behv=>mk-on
                        %element-enddate = if_abap_behv=>mk-on ) TO reported-travel.
      ENDIF.
    ENDLOOP.
  ENDMETHOD.

  METHOD validateStatus.
    READ ENTITY zi_travel_latr\\Travel FIELDS ( OverallStatus )
        WITH VALUE #( FOR <root_key> IN keys ( %key = <root_key> ) )
        RESULT DATA(lt_travel_result).

    LOOP AT lt_travel_result INTO DATA(ls_travel_result).
      CASE ls_travel_result-OverallStatus.
        WHEN 'O'. " Open
        WHEN 'X'. " Cancelled
        WHEN 'A'. " Accepted
        WHEN OTHERS.
          APPEND VALUE #( %key = ls_travel_result-%key ) TO failed-travel.
          APPEND VALUE #( %key = ls_travel_result-%key
                          %msg = new_message( id = 'ZMC_TRAVEL_LATR'
                                              number = '004'
                                              v1 = ls_travel_result-OverallStatus
                                              severity = if_abap_behv_message=>severity-error )
                          %element-overallstatus = if_abap_behv=>mk-on ) TO reported-travel.
      ENDCASE.
    ENDLOOP.
  ENDMETHOD.

ENDCLASS.

CLASS lsc_ZI_TRAVEL_LATR DEFINITION INHERITING FROM cl_abap_behavior_saver.
  PUBLIC SECTION.
    CONSTANTS: create TYPE string VALUE 'CREATE',
               update TYPE string VALUE 'UPDATE',
               delete TYPE string VALUE 'DELETE'.

  PROTECTED SECTION.

    METHODS save_modified REDEFINITION.

    METHODS cleanup_finalize REDEFINITION.

ENDCLASS.

CLASS lsc_ZI_TRAVEL_LATR IMPLEMENTATION.

  METHOD save_modified.
    DATA: lt_travel_log   TYPE TABLE OF ztb_log_latr,
          lt_travel_log_u TYPE TABLE OF ztb_log_latr.
    DATA(lv_flag) = cl_abap_behv=>flag_changed.
    DATA(lv_mk_on) = if_abap_behv=>mk-on. DATA(lv_user_mod) = cl_abap_context_info=>get_user_technical_name( ).
    DATA(lv_user) = cl_abap_context_info=>get_user_technical_name( ).

    IF create-travel IS NOT INITIAL.
"      lt_travel_log-travel_id = create-travel-.
      lt_travel_log = CORRESPONDING #( create-travel ).

      LOOP AT lt_travel_log ASSIGNING FIELD-SYMBOL(<fs_travel_log_c>).
        GET TIME STAMP FIELD <fs_travel_log_c>-created_at.
        <fs_travel_log_c>-changing_operation = lsc_ZI_TRAVEL_LATR=>create.
        READ TABLE create-travel
            WITH TABLE KEY entity COMPONENTS TravelId = <fs_travel_log_c>-travelid INTO DATA(ls_travel).
        IF sy-subrc = 0.
          IF ls_travel-%control-BookingFee = lv_flag.
            <fs_travel_log_c>-changed_field_name = 'booking_fee'.
            <fs_travel_log_c>-changed_value = ls_travel-BookingFee.
            <fs_travel_log_c>-user_mod = lv_user_mod.
            TRY.
                <fs_travel_log_c>-change_id = cl_system_uuid=>create_uuid_x16_static( ) .
              CATCH cx_uuid_error.
            ENDTRY.
            APPEND <fs_travel_log_c> TO lt_travel_log_u.
          ENDIF.
        ENDIF.
      ENDLOOP.
    ENDIF.

    IF NOT update-travel IS INITIAL.
      lt_travel_log = CORRESPONDING #( update-travel ).
      LOOP AT update-travel INTO DATA(ls_update_travel).
        ASSIGN lt_travel_log[ travelid = ls_update_travel-TravelId ] TO FIELD-SYMBOL(<ls_travel_log_bd>).
        GET TIME STAMP FIELD <ls_travel_log_bd>-created_at.
        <ls_travel_log_bd>-changing_operation = lsc_zi_travel_latr=>update.
        IF ls_update_travel-%control-CustomerId EQ cl_abap_behv=>flag_changed.
          <ls_travel_log_bd>-changed_field_name = 'customer_id'.
          <ls_travel_log_bd>-changed_value = ls_update_travel-CustomerId.
          <ls_travel_log_bd>-user_mod = lv_user.
          TRY.
              <ls_travel_log_bd>-change_id = cl_system_uuid=>create_uuid_x16_static( ).
            CATCH cx_uuid_error.
          ENDTRY.
          APPEND <ls_travel_log_bd> TO lt_travel_log_u.
        ENDIF.
      ENDLOOP.
    ENDIF.

    IF NOT delete-travel IS INITIAL.
      lt_travel_log = CORRESPONDING #( delete-travel ).
      LOOP AT lt_travel_log ASSIGNING FIELD-SYMBOL(<ls_travel_log_del>).
        GET TIME STAMP FIELD <ls_travel_log_del>-created_at.
        <ls_travel_log_del>-changing_operation = lsc_zi_travel_latr=>delete.
        <ls_travel_log_del>-user_mod = lv_user.
        TRY.
            <ls_travel_log_del>-change_id = cl_system_uuid=>create_uuid_x16_static( ).
          CATCH cx_uuid_error.
        ENDTRY.
        APPEND <ls_travel_log_del> TO lt_travel_log_u.
      ENDLOOP.
    ENDIF.

    IF NOT lt_travel_log_u IS INITIAL.
      INSERT ztb_log_latr FROM TABLE @lt_travel_log_u.
    ENDIF.

  ENDMETHOD.

  METHOD cleanup_finalize.
  ENDMETHOD.

ENDCLASS.
