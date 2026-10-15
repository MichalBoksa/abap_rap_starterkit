CLASS zcl_rap_mbo_head_ve DEFINITION
  PUBLIC
  FINAL
  CREATE PUBLIC .

  PUBLIC SECTION.

  INTERFACES if_sadl_exit_calc_element_read.
  PROTECTED SECTION.
  PRIVATE SECTION.
ENDCLASS.



CLASS zcl_rap_mbo_head_ve IMPLEMENTATION.

method if_sadl_exit_calc_element_read~get_calculation_info.

 IF iv_entity = 'ZC_ZCG_RAP_MBO_HEAD'
       AND line_exists(
         it_requested_calc_elements[
           table_line = 'TOTALVALUEVIRTUALEUR'
         ]
       ).

      INSERT `UUID` INTO TABLE et_requested_orig_elements.

    ENDIF.

ENDMETHOD.

method if_sadl_exit_calc_element_read~calculate.

 CHECK it_original_data IS NOT INITIAL.

    CHECK line_exists(
      it_requested_calc_elements[
        table_line = 'TOTALVALUEVIRTUALEUR'
      ]
    ).

    DATA lt_headers TYPE STANDARD TABLE OF
      zc_zcg_rap_mbo_head WITH EMPTY KEY.

    lt_headers = CORRESPONDING #( it_original_data ).

    DATA lr_header_ids TYPE RANGE OF sysuuid_x16.

    lr_header_ids = VALUE #(
      FOR ls_header IN lt_headers
      (
        sign   = 'I'
        option = 'EQ'
        low    = ls_header-Uuid
      )
    ).

    CHECK lr_header_ids IS NOT INITIAL.

    DATA(lv_date) =
      cl_abap_context_info=>get_system_date( ).

    SELECT
      FROM zcg_rap_mbo_item AS item
      INNER JOIN zcg_rap_mbo_comp AS component
        ON item~component_id = component~uuid
      FIELDS
        item~uuid AS ItemUuid,
        item~header_id AS HeaderId,

        currency_conversion(
          amount             = item~value,
          source_currency    = component~currency_code,
          target_currency    = 'EUR',
          exchange_rate_date = @lv_date
        ) AS ValueEUR

      WHERE item~header_id IN @lr_header_ids

      INTO TABLE @DATA(lt_items).

    TYPES:
      BEGIN OF ty_total,
        HeaderId TYPE sysuuid_x16,
        Amount   TYPE
          zc_zcg_rap_mbo_head-TotalValueVirtualEUR,
      END OF ty_total.

    DATA lt_totals TYPE HASHED TABLE OF ty_total
      WITH UNIQUE KEY HeaderId.

    DATA ls_total TYPE ty_total.

    LOOP AT lt_items INTO DATA(ls_item).

      ls_total = VALUE #(
        HeaderId = ls_item-HeaderId
        Amount   = ls_item-ValueEUR
      ).

      COLLECT ls_total INTO lt_totals.

    ENDLOOP.

    LOOP AT lt_headers ASSIGNING FIELD-SYMBOL(<ls_header>).

      <ls_header>-TotalValueVirtualEUR = 0.

      READ TABLE lt_totals
        INTO ls_total
        WITH TABLE KEY HeaderId = <ls_header>-Uuid.

      IF sy-subrc = 0.
        <ls_header>-TotalValueVirtualEUR = ls_total-Amount.
      ENDIF.

    ENDLOOP.

    ct_calculated_data = CORRESPONDING #( lt_headers ).

ENDMETHOD.
ENDCLASS.
