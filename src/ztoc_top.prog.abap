*&---------------------------------------------------------------------*
*&  Include           ZTOC_TOP
*&---------------------------------------------------------------------*
TABLES: e070.

SELECT-OPTIONS: so_req FOR e070-trkorr NO INTERVALS OBLIGATORY." OBLIGATORY MATCHCODE OBJECT tr_request_choice."fdt_shlp_trkorr.
PARAMETERS: p_target TYPE tr_targgrp OBLIGATORY.
PARAMETERS: p_func TYPE trfunction OBLIGATORY DEFAULT 'T'.
PARAMETERS: p_text TYPE char20.

PARAMETERS: p_disp TYPE c1 RADIOBUTTON GROUP rg1 DEFAULT 'X'.
PARAMETERS: p_releas TYPE c1 RADIOBUTTON GROUP rg1.



CLASS lcl_create_toc DEFINITION DEFERRED.
CLASS lcl_toc_objects DEFINITION DEFERRED.

DATA ls_requests TYPE trwbo_request_header.
DATA lo_create_toc TYPE REF TO lcl_create_toc.
DATA lo_handle_obj_toc TYPE REF TO lcl_toc_objects.
