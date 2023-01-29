CLASS lcl_buffer DEFINITION.
  PUBLIC SECTION.
    CONSTANTS: created TYPE c LENGTH 1 VALUE 'C',
               updated TYPE c LENGTH 1 VALUE 'U',
               deleted TYPE c LENGTH 1 VALUE 'D'.

    TYPES: BEGIN OF ty_buffer_master.
             INCLUDE TYPE zhc_master_latr AS data.
    TYPES:   flag TYPE c LENGTH 1,
           END OF ty_buffer_master.

    TYPES: tt_master TYPE SORTED TABLE OF ty_buffer_master WITH UNIQUE KEY e_name.

    CLASS-DATA mt_buffer_master TYPE tt_master.
ENDCLASS.

CLASS lhc_HCMMaster DEFINITION INHERITING FROM cl_abap_behavior_handler.
  PRIVATE SECTION.
    METHODS: create FOR MODIFY IMPORTING entities FOR CREATE HCMMaster,
      update FOR MODIFY IMPORTING entities FOR UPDATE HCMMaster,
      delete FOR MODIFY IMPORTING keys FOR DELETE HCMMaster,
      read FOR READ IMPORTING keys FOR READ HCMMaster RESULT result.
ENDCLASS.

CLASS lhc_HCMMaster IMPLEMENTATION.
  METHOD create.
    GET TIME STAMP FIELD DATA(lv_tsl).
    SELECT MAX( e_number ) AS e_number FROM zhc_master_latr INTO @DATA(lv_e_number).
    LOOP AT entities INTO DATA(ls_entities).
      ls_entities-%data-crea_date_time = lv_tsl. ls_entities-%data-crea_uname = sy-uname.
      ls_entities-%data-e_number = lv_e_number + 1.
      INSERT VALUE #( flag = lcl_buffer=>created data = CORRESPONDING #( ls_entities-%data ) )
        INTO TABLE lcl_buffer=>mt_buffer_master.
      IF ls_entities-%cid IS NOT INITIAL.
        INSERT VALUE #( %cid = ls_entities-%cid e_number = ls_entities-e_number ) INTO TABLE mapped-hcmmaster.
      ENDIF.
    ENDLOOP.
  ENDMETHOD.

  METHOD update.
    LOOP AT entities INTO DATA(ls_entities).
      GET TIME STAMP FIELD ls_entities-%data-lchg_date_time.
      ls_entities-%data-lchg_uname = sy-uname.
* CASE 2 - Only UPDATE the FIELDS posted
      SELECT SINGLE * FROM zhc_master_latr WHERE e_number EQ @ls_entities-e_number INTO @DATA(ls_ddbb).
      IF sy-subrc EQ 0.
        INSERT VALUE #( flag = lcl_buffer=>updated data =
            VALUE #( e_name = COND #( WHEN ls_entities-%control-e_name = if_abap_behv=>mk-on
                THEN ls_entities-e_name
                ELSE ls_ddbb-e_name ) e_department = COND #( WHEN ls_entities-%control-e_department = if_abap_behv=>mk-on
                THEN ls_entities-e_department
                ELSE ls_ddbb-e_department ) status = COND #( WHEN ls_entities-%control-status = if_abap_behv=>mk-on
                THEN ls_entities-status
                ELSE ls_ddbb-status ) job_title = COND #( WHEN ls_entities-%control-job_title = if_abap_behv=>mk-on
                THEN ls_entities-job_title
                ELSE ls_ddbb-job_title ) start_date = COND #( WHEN ls_entities-%control-start_date = if_abap_behv=>mk-on
                THEN ls_entities-start_date
                ELSE ls_ddbb-start_date ) end_date = COND #( WHEN ls_entities-%control-end_date = if_abap_behv=>mk-on
                THEN ls_entities-end_date
                ELSE ls_ddbb-end_date ) email = COND #( WHEN ls_entities-%control-email = if_abap_behv=>mk-on
                THEN ls_entities-email
                ELSE ls_ddbb-email ) m_number = COND #( WHEN ls_entities-%control-m_number = if_abap_behv=>mk-on
                THEN ls_entities-m_number
                ELSE ls_ddbb-m_number ) m_name = COND #( WHEN ls_entities-%control-m_name = if_abap_behv=>mk-on
                THEN ls_entities-m_name
                ELSE ls_ddbb-m_name ) m_department = COND #( WHEN ls_entities-%control-m_department = if_abap_behv=>mk-on
                THEN ls_entities-m_department
                ELSE ls_ddbb-m_department )
                    e_number = ls_entities-e_number crea_date_time = ls_ddbb-crea_date_time crea_uname = ls_ddbb-crea_uname ) )
            INTO TABLE lcl_buffer=>mt_buffer_master.
        IF ls_entities-e_number IS NOT INITIAL.
          INSERT VALUE #( %cid = ls_entities-e_number e_number = ls_entities-e_number )
              INTO TABLE mapped-hcmmaster.
        ENDIF.
      ENDIF.
    ENDLOOP.
  ENDMETHOD.

  METHOD delete.
    LOOP AT keys INTO DATA(ls_entities).
      INSERT VALUE #( flag = lcl_buffer=>deleted data = VALUE #( e_number = ls_entities-e_number ) )
            INTO TABLE lcl_buffer=>mt_buffer_master.
      IF ls_entities-e_number IS NOT INITIAL.
        INSERT VALUE #( %cid = ls_entities-e_number e_number = ls_entities-e_number )
            INTO TABLE mapped-hcmmaster.
      ENDIF.
    ENDLOOP.
  ENDMETHOD.

  METHOD read.
  ENDMETHOD.
ENDCLASS.

CLASS lsc_ZI_HCM_MASTER_LATR DEFINITION INHERITING FROM cl_abap_behavior_saver.
  PROTECTED SECTION.

    METHODS: finalize REDEFINITION,
      check_before_save REDEFINITION,
      save REDEFINITION,
      cleanup REDEFINITION,
      cleanup_finalize REDEFINITION.
ENDCLASS.

CLASS lsc_ZI_HCM_MASTER_LATR IMPLEMENTATION.
  METHOD finalize.
  ENDMETHOD.

  METHOD check_before_save.
  ENDMETHOD.

  METHOD save.
    DATA: lt_data_created TYPE STANDARD TABLE OF zhc_master_latr,
          lt_data_updated TYPE STANDARD TABLE OF zhc_master_latr,
          lt_data_deleted TYPE STANDARD TABLE OF zhc_master_latr.

    lt_data_created = VALUE #( FOR <row> IN lcl_buffer=>mt_buffer_master
                        WHERE ( flag = lcl_buffer=>created ) ( <row>-data ) ).
    IF lt_data_created IS NOT INITIAL.
      INSERT zhc_master_latr FROM TABLE @lt_data_created.
    ENDIF.

    lt_data_updated = VALUE #( FOR <row> IN lcl_buffer=>mt_buffer_master
        WHERE ( flag = lcl_buffer=>updated ) ( <row>-data ) ).
    IF lt_data_updated IS NOT INITIAL.
      UPDATE zhc_master_latr FROM TABLE @lt_data_updated.
    ENDIF.

    lt_data_deleted = VALUE #( FOR <row> IN lcl_buffer=>mt_buffer_master WHERE ( flag = lcl_buffer=>deleted ) ( <row>-data ) ).
    IF lt_data_deleted IS NOT INITIAL.
      DELETE zhc_master_latr FROM TABLE @lt_data_deleted.
    ENDIF.
  ENDMETHOD.

  METHOD cleanup.
  ENDMETHOD.

  METHOD cleanup_finalize.
  ENDMETHOD.
ENDCLASS.
