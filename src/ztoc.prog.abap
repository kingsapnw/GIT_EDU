*&---------------------------------------------------------------------*
*& Report ZTOC
*&---------------------------------------------------------------------*
*&
*&---------------------------------------------------------------------*
REPORT ztoc.
*komentar
INCLUDE ztoc_top.
INCLUDE ztoc_c01.
"change branch new
INITIALIZATION.
*set target group
  SELECT SINGLE targ_group
    FROM tcetarg
    INTO @p_target.

*search help for requests
AT SELECTION-SCREEN ON VALUE-REQUEST FOR so_req-low.

  CALL FUNCTION 'TR_F4_REQUESTS'
    EXPORTING
      iv_username         = sy-uname
      iv_trstatus         = 'RNDL'
      iv_client           = sy-mandt
    IMPORTING
      ev_selected_request = so_req-low.

START-OF-SELECTION.
*create object and get name for ToC
  CREATE OBJECT lo_create_toc
    EXPORTING
      iv_text     = p_text
      iv_target   = p_target
      iv_func     = p_func
      ir_req_from = so_req[].

  lo_create_toc->create_toc(
    IMPORTING
      ev_tr_number = DATA(lv_new_toc)
  ).

  CREATE OBJECT lo_handle_obj_toc
    EXPORTING
      iv_toc_number = lv_new_toc
      ir_req_from   = so_req[].
*fill with objects from chosen requests
  lo_handle_obj_toc->copy_objects( ).

  IF p_disp = 'X'.
*display for editing objects of toc
    SUBMIT wb_mngr_start_from_tool_access WITH obj_name = lo_create_toc->mv_new_toc
                                          WITH obj_type = 'RQ'
                                          WITH action = 'DISPLAY'
                                          WITH tool = 'CL_CTS_REQUEST'.
  ELSE.
*release now
    lo_create_toc->release_toc( p_releas ).
  ENDIF.
