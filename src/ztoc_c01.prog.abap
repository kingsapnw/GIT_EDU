*&---------------------------------------------------------------------*
*&  Include           ZTOC_C01
*&---------------------------------------------------------------------*
CLASS lcl_create_toc DEFINITION.
  PUBLIC SECTION.
    TYPES: tyr_req_from TYPE RANGE OF e070-trkorr.


    DATA: mv_name_toc TYPE as4text.
    DATA: mv_new_toc TYPE e070-strkorr.
    DATA: mr_req_from TYPE tyr_req_from.
    DATA mv_target_group TYPE tr_target.
    DATA mv_type_of_req TYPE trfunction.

    METHODS: constructor IMPORTING iv_text     TYPE char20
                                   ir_req_from TYPE tyr_req_from
                                   iv_target TYPE tr_target
                                   iv_func TYPE trfunction,
      create_toc EXPORTING ev_tr_number TYPE e070-strkorr,
      release_toc IMPORTING iv_flag_release TYPE c1.
  PRIVATE SECTION.
    METHODS: get_req_string RETURNING VALUE(rv_req_str) TYPE string.

ENDCLASS.
CLASS lcl_toc_objects DEFINITION.
  PUBLIC SECTION.
    TYPES: tyr_req_from TYPE RANGE OF e070-trkorr.

    DATA: mr_tasks TYPE RANGE OF e070-trkorr.
    DATA: mv_toc_num TYPE e070-trkorr.

    METHODS: get_tasks IMPORTING ir_req_from TYPE tyr_req_from,
             prepare_tasks_requests IMPORTING ir_req_from TYPE tyr_req_from,
      constructor IMPORTING iv_toc_number TYPE e070-trkorr
                            ir_req_from   TYPE tyr_req_from,
      copy_objects.
ENDCLASS.
CLASS lcl_create_toc IMPLEMENTATION.
  METHOD constructor.
    mv_type_of_req = iv_func.
    mv_target_group = iv_target.
*keep range in object
    mr_req_from = ir_req_from.
*name of ToC
    mv_name_toc =  COND as4text( WHEN iv_text IS INITIAL THEN |{ sy-datum } ToC { get_req_string( ) } { sy-uname }|
                                 ELSE |{ sy-datum } ToC { iv_text } { sy-uname }| ).
  ENDMETHOD.
  METHOD create_toc.

    DATA ls_req_header TYPE trwbo_request_header.
    DATA lt_task_header TYPE trwbo_request_headers.
*toc create
    CALL FUNCTION 'TR_INSERT_REQUEST_WITH_TASKS'
      EXPORTING
        iv_type           = mv_type_of_req
        iv_text           = mv_name_toc
        iv_owner          = sy-uname
        iv_target         = mv_target_group
      IMPORTING
        es_request_header = ls_req_header
        et_task_headers   = lt_task_header
      EXCEPTIONS
        insert_failed     = 1
        enqueue_failed    = 2
        OTHERS            = 3.
*save number of new ToC
    ev_tr_number = mv_new_toc = ls_req_header-trkorr.

  ENDMETHOD.
  METHOD release_toc.

    IF iv_flag_release = 'X'.
      CALL FUNCTION 'TR_RELEASE_REQUEST'
        EXPORTING
          iv_trkorr          = mv_new_toc
          iv_success_message = 'X'.

      IF sy-subrc <> 0.
* Implement suitable error handling here
      ENDIF.
    ENDIF.

  ENDMETHOD.
  METHOD get_req_string.

    LOOP AT mr_req_from ASSIGNING FIELD-SYMBOL(<fs_req>).
      IF sy-tabix = 1.
        rv_req_str = |{ <fs_req>-low }|.
      ELSE.
        rv_req_str = |{ <fs_req>-low }, { rv_req_str }|.
      ENDIF.
    ENDLOOP.

  ENDMETHOD.
ENDCLASS.
**********************************************************************
**********************************************************************
CLASS lcl_toc_objects IMPLEMENTATION.
  METHOD constructor.
    mv_toc_num = iv_toc_number.

    get_tasks( ir_req_from = ir_req_from ).
    prepare_tasks_requests( ir_req_from = ir_req_from ).
  ENDMETHOD.
  METHOD prepare_tasks_requests.
    APPEND LINES OF ir_req_from TO mr_tasks.
  ENDMETHOD.
  METHOD get_tasks.
    SELECT trkorr AS low, 'I' AS sign, 'EQ' AS option
      FROM e070
      WHERE strkorr IN @ir_req_from
      INTO CORRESPONDING FIELDS OF TABLE @mr_tasks.
  ENDMETHOD.
  METHOD copy_objects.
    LOOP AT mr_tasks ASSIGNING FIELD-SYMBOL(<fs_task>).

      CALL FUNCTION 'TR_COPY_COMM'
        EXPORTING
*         WI_DIALOG                = 'X'
          wi_trkorr_from           = <fs_task>-low
          wi_trkorr_to             = mv_toc_num
          wi_without_documentation = 'X'
        EXCEPTIONS
          db_access_error          = 1
          trkorr_from_not_exist    = 2
          trkorr_to_is_repair      = 3
          trkorr_to_locked         = 4
          trkorr_to_not_exist      = 5
          trkorr_to_released       = 6
          user_not_owner           = 7
          no_authorization         = 8
          wrong_client             = 9
          wrong_category           = 10
          object_not_patchable     = 11
          OTHERS                   = 12.
    ENDLOOP.
  ENDMETHOD.
ENDCLASS.
