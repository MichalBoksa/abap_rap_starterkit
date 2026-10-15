CLASS lhc_DocumentHeader DEFINITION INHERITING FROM cl_abap_behavior_handler.
  PRIVATE SECTION.

    METHODS get_instance_features FOR INSTANCE FEATURES
      keys REQUEST requested_features FOR DocumentHeader RESULT result.

*    METHODS get_global_authorizations FOR GLOBAL AUTHORIZATION
*      REQUEST requested_authorizations FOR DocumentHeader RESULT result.

    METHODS determineDocumentNumber FOR DETERMINE ON SAVE
       keys FOR DocumentHeader~determineDocumentNumber.

    METHODS validateCustomerId FOR VALIDATE ON SAVE
       keys FOR DocumentHeader~validateCustomerId.
    METHODS createItems FOR MODIFY
      keys FOR ACTION DocumentHeader~createItems RESULT result.

ENDCLASS.

CLASS lhc_DocumentHeader IMPLEMENTATION.

  METHOD get_instance_features.
  ENDMETHOD.

*  METHOD get_global_authorizations.
*  ENDMETHOD.

  METHOD determineDocumentNumber.
  ENDMETHOD.

  METHOD validateCustomerId.
  ENDMETHOD.

  METHOD createItems.

  DATA lt_success TYPE TABLE FOR READ IMPORT
    ZI_ZCG_RAP_MBO_HEAD.

  DATA lv_number TYPE zcg_rap_mbo_item-item_number.

  LOOP AT keys INTO DATA(ls_key).

    "Required input
    IF ls_key-%param-ComponentId IS INITIAL
       OR ls_key-%param-Quantity <= 0.

      APPEND VALUE #(
        %tky = ls_key-%tky
      ) TO failed-documentheader.

      APPEND VALUE #(
        %tky = ls_key-%tky
        %msg = new_message_with_text(
          severity = if_abap_behv_message=>severity-error
          text = 'Select a component and enter quantity greater than zero.'
        )
      ) TO reported-documentheader.

      CONTINUE.
    ENDIF.

    "Check component
    SELECT SINGLE uuid
      FROM zcg_rap_mbo_comp
      WHERE uuid = @ls_key-%param-ComponentId
      INTO @DATA(lv_component_uuid).

    IF sy-subrc <> 0.

      APPEND VALUE #(
        %tky = ls_key-%tky
      ) TO failed-documentheader.

      APPEND VALUE #(
        %tky = ls_key-%tky
        %msg = new_message_with_text(
          severity = if_abap_behv_message=>severity-error
          text = 'Selected component does not exist.'
        )
      ) TO reported-documentheader.

      CONTINUE.
    ENDIF.

    "Read existing items of this document
    READ ENTITIES OF ZI_ZCG_RAP_MBO_HEAD IN LOCAL MODE
      ENTITY DocumentHeader
        BY \_Items
        FIELDS ( ItemNumber )
        WITH VALUE #( ( %tky = ls_key-%tky ) )
        RESULT DATA(lt_items).

    CLEAR lv_number.

    LOOP AT lt_items INTO DATA(ls_item).
      IF ls_item-ItemNumber > lv_number.
        lv_number = ls_item-ItemNumber.
      ENDIF.
    ENDLOOP.

    lv_number = lv_number + 10.

    "Create one item for the selected document
    MODIFY ENTITIES OF ZI_ZCG_RAP_MBO_HEAD IN LOCAL MODE
      ENTITY DocumentHeader
        CREATE BY \_Items AUTO FILL CID
        FIELDS ( ComponentId Quantity ItemNumber )
        WITH VALUE #(
          (
            %tky = ls_key-%tky
            %target = VALUE #(
              (
                ComponentId = ls_key-%param-ComponentId
                Quantity    = ls_key-%param-Quantity
                ItemNumber  = lv_number
              )
            )
          )
        )
      FAILED DATA(ls_failed)
      REPORTED DATA(ls_reported).

    APPEND LINES OF ls_reported-documentheader
      TO reported-documentheader.

    APPEND LINES OF ls_reported-documentitem
      TO reported-documentitem.

    IF ls_failed-documentheader IS NOT INITIAL
       OR ls_failed-documentitem IS NOT INITIAL.

      APPEND VALUE #(
        %tky = ls_key-%tky
      ) TO failed-documentheader.

      APPEND VALUE #(
        %tky = ls_key-%tky
        %msg = new_message_with_text(
          severity = if_abap_behv_message=>severity-error
          text = 'Item could not be created.'
        )
      ) TO reported-documentheader.

      CONTINUE.
    ENDIF.

    APPEND VALUE #(
      %tky = ls_key-%tky
    ) TO lt_success.

  ENDLOOP.

  IF lt_success IS NOT INITIAL.

    READ ENTITIES OF ZI_ZCG_RAP_MBO_HEAD IN LOCAL MODE
      ENTITY DocumentHeader
        ALL FIELDS WITH lt_success
        RESULT DATA(lt_headers).

    result = VALUE #(
      FOR ls_header IN lt_headers
      (
        %tky   = ls_header-%tky
        %param = ls_header
      )
    ).

  ENDIF.

  ENDMETHOD.

ENDCLASS.

CLASS lhc_DocumentItem DEFINITION INHERITING FROM cl_abap_behavior_handler.
  PRIVATE SECTION.

    METHODS calculateItemValue FOR DETERMINE ON MODIFY
       keys FOR DocumentItem~calculateItemValue.

    METHODS validateComponentId FOR VALIDATE ON SAVE
       keys FOR DocumentItem~validateComponentId.

    METHODS validateQuantity FOR VALIDATE ON SAVE
       keys FOR DocumentItem~validateQuantity.

ENDCLASS.

CLASS lhc_DocumentItem IMPLEMENTATION.

  METHOD calculateItemValue.
    DATA lt_update TYPE TABLE FOR UPDATE
        zi_zcg_rap_mbo_head\\DocumentItem.

    DATA item_value TYPE zcg_rap_mbo_item-value.

    READ ENTITIES OF zi_zcg_rap_mbo_head IN LOCAL MODE
    ENTITY DocumentItem
    FIELDS ( ComponentId Quantity )
    WITH CORRESPONDING #( keys )
    RESULT DATA(items).

    IF items IS INITIAL.
      RETURN.
    ENDIF.


    SELECT uuid, price
    FROM zcg_rap_mbo_comp
    FOR ALL ENTRIES IN @items
    WHERE uuid = @items-ComponentId
    INTO TABLE @DATA(components).

    LOOP AT items INTO DATA(item).

      CLEAR item_value.

      READ TABLE components INTO DATA(component)
      WITH KEY uuid = item-ComponentId.

      IF sy-subrc = 0.
        item_value = item-Quantity * component-price.
      ENDIF.

      APPEND VALUE #(
      %tky = item-%tky
      Value = item_value
      ) TO lt_update.

    ENDLOOP.


    MODIFY ENTITIES OF zi_zcg_rap_mbo_head IN LOCAL MODE
    ENTITY DocumentItem
    UPDATE FIELDS ( Value )
    WITH lt_update
    FAILED DATA(failed_update)
    REPORTED DATA(reported_update).

    reported = CORRESPONDING #( DEEP reported_update ).

  ENDMETHOD.

  METHOD validateComponentId.
  ENDMETHOD.

  METHOD validateQuantity.
  ENDMETHOD.

ENDCLASS.
