CLASS zcl_rap_mbo_class_01 DEFINITION
  PUBLIC
  FINAL
  CREATE PUBLIC .

  PUBLIC SECTION.

    INTERFACES if_oo_adt_classrun .
  PROTECTED SECTION.
  PRIVATE SECTION.
ENDCLASS.



CLASS zcl_rap_mbo_class_01 IMPLEMENTATION.


  METHOD if_oo_adt_classrun~main.

    out->write( 'Our first ABAP program on SAP Cloud' ).
    out->write( cl_abap_context_info=>get_system_date( ) ).
    out->write( cl_abap_context_info=>get_system_url(  ) ).
    endmethod.
ENDCLASS.
