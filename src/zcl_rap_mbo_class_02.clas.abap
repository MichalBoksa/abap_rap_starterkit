CLASS zcl_rap_mbo_class_02 DEFINITION
  PUBLIC
  FINAL
  CREATE PUBLIC .

  PUBLIC SECTION.

    INTERFACES if_oo_adt_classrun .
  PROTECTED SECTION.
  PRIVATE SECTION.
ENDCLASS.



CLASS zcl_rap_mbo_class_02 IMPLEMENTATION.


  METHOD if_oo_adt_classrun~main.
    DATA:
      lt_comp     TYPE STANDARD TABLE OF zcg_rap_mbo_comp,
      lt_head     TYPE STANDARD TABLE OF zcg_rap_mbo_head,
      lt_item     TYPE STANDARD TABLE OF zcg_rap_mbo_item,
      lt_customer TYPE STANDARD TABLE OF /dmo/customer.

    DATA:
      ls_comp LIKE LINE OF lt_comp,
      ls_head LIKE LINE OF lt_head,
      ls_item LIKE LINE OF lt_item.


    DATA:
      lv_uuid          TYPE sysuuid_x16,
      lv_timestamp     TYPE timestampl,
      lv_price         TYPE /dmo/total_price,
      lv_quantity      TYPE zcg_rap_mbo_quant,
      lv_items         TYPE i,
      lv_customer      TYPE /dmo/customer_id,
      lv_matnr_length  TYPE i,
      LV_docnum_LENGTH TYPE i,
      LV_item_LENGTH   TYPE i.

    GET TIME STAMP FIELD lv_timestamp.

    TRY.

        SELECT * FROM /dmo/customer
        INTO TABLE @lt_customer
        UP TO 1000 ROWS.

        out->write( |Customers selected: { lines( lt_customer ) }| ).

        IF lt_customer IS INITIAL.
          out->write( 'There is no data in /DMO/CUSTOMER' ).
          RETURN.
        ENDIF.

        lv_matnr_length = CAST cl_abap_elemdescr( cl_abap_typedescr=>describe_by_data( ls_comp-matnr ) )->output_length.
        LV_docnum_LENGTH = CAST cl_abap_elemdescr( cl_abap_typedescr=>describe_by_data( ls_head-document_number ) )->output_length.
        LV_item_LENGTH = CAST cl_abap_elemdescr( cl_abap_typedescr=>describe_by_data( ls_item-item_number ) )->output_length.

        DATA(lv_rand_price) = cl_abap_random_int=>create(
                                     seed = cl_abap_random=>seed( )
                                     min  = 10
                                     max  = 1000 ).

        DATA(lv_rand_CUSTID) = cl_abap_random_int=>create(
       seed = cl_abap_random=>seed( )
       min  = 1
       max  = lines( lt_customer ) ).



        GET TIME STAMP FIELD lv_timestamp.


* COMPONENTS
        DO 100 TIMES.


          lS_COMP = VALUE #( uuid = cl_system_uuid=>create_uuid_x16_static(  )
                             matnr = |{ sy-index WIDTH = lv_matnr_length PAD = '0' }|
                             maktx = |Component { sy-index }|
                             price = lv_rand_price->get_next(  ) / 10
                             currency_code = 'EUR'
                             unit_of_measure = 'ST'
                             created_by = sy-uname
                             created_at = lv_timestamp
                             last_changed_by = sy-uname
                             last_changed_at = lv_timestamp
                             local_lastchanged_at = lv_timestamp
                              ).

          APPEND ls_comp TO lt_comp.
        ENDDO.
        out->write( |Components prepared: { lines( lt_comp ) }| ).

* HEADERS
        DO 200 TIMES.

          ls_head = VALUE #( uuid = cl_system_uuid=>create_uuid_x16_static( )
                             document_number = |{ 90000 + sy-index
                                                           WIDTH = lv_docnum_length
                                                           ALIGN = RIGHT
                                                           PAD = '0' }|
                               customer_id = lt_customer[ lv_rand_custid->get_next( ) ]-customer_id
                               created_by = sy-uname
                               created_at = lv_timestamp
                               last_changed_by = sy-uname
                               last_changed_at = lv_timestamp
                               local_lastchanged_at = lv_timestamp
           ).

          APPEND ls_head TO lt_head.
        ENDDO.

        out->write( |Headers prepared: { lines( lt_head ) }| ).


        LOOP AT lt_head INTO ls_head.

          DATA(lv_rand_item) = cl_abap_random_int=>create(
                                                  seed = cl_abap_random=>seed( )
                                                  min  = 2
                                                  max  = 15 )->get_next( ).

          DO lv_rand_item TIMES.

            DATA(lv_item_num) = sy-index * 10.

            DATA(lv_compindex_rand) =
               cl_abap_random_int=>create(
                           seed = cl_abap_random=>seed( )
                           min = 1
                           max = lines( lt_comp ) )->get_next( ).

            ls_comp = lt_comp[ lv_compindex_rand ].

            DATA(lv_rand_quant) =
                cl_abap_random_int=>create(
                            seed = cl_abap_random=>seed( )
                            min = 1
                            max = 5 )->get_next( ).

            APPEND VALUE #(
                    client = sy-mandt
                    uuid = cl_system_uuid=>create_uuid_x16_static( )
                    header_id = ls_head-uuid
                    item_number = lv_item_num  " |{ lv_item_num WIDTH = lv_item_length PAD = '0' }|
                    component_id = ls_comp-uuid
                    quantity = lv_rand_quant
                    value = lv_rand_quant * ls_comp-price
                    created_by = sy-uname
                    created_at = lv_timestamp
                    last_changed_by = sy-uname
                    last_changed_at = lv_timestamp
                    local_lastchanged_at = lv_timestamp
                    ) TO lt_item.
          ENDDO.

        ENDLOOP.

        out->write( |Items prepared: { lines( lt_item ) }| ).


        DELETE FROM zcg_rap_mbo_comp.
        DELETE FROM zcg_rap_mbo_ITEM.
        DELETE FROM zcg_rap_mbo_HEAD.

        INSERT zcg_rap_mbo_comp FROM TABLE @lt_comp.

        IF sy-subrc <> 0.
          ROLLBACK WORK.
          out->write( 'Components insert failed. Changes rolled back' ).
          RETURN.
        ENDIF.

        INSERT zcg_rap_mbo_head FROM TABLE @lt_head.

        IF sy-subrc <> 0.
          ROLLBACK WORK.
          out->write( 'Headers insert failed. Changes rolled back' ).
          RETURN.
        ENDIF.

        INSERT zcg_rap_mbo_item FROM TABLE @lt_item.

        IF sy-subrc <> 0.
          ROLLBACK WORK.
          out->write( 'Items insert failed. Changes rolled back' ).
          RETURN.
        ENDIF.

        COMMIT WORK.

      CATCH cx_root INTO DATA(lo_error).

        ROLLBACK WORK.
        out->write( lo_error->get_text(  ) ).
        RETURN.

    ENDTRY.

  ENDMETHOD.
ENDCLASS.
