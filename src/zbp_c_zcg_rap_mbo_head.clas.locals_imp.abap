CLASS lhc_DocumentHeader DEFINITION INHERITING FROM cl_abap_behavior_handler.
  PRIVATE SECTION.

METHODS augment FOR MODIFY
  IMPORTING entities_create FOR CREATE DocumentHeader
            entities_update FOR UPDATE DocumentHeader.

ENDCLASS.

CLASS lhc_DocumentHeader IMPLEMENTATION.

METHOD augment.

  DATA:
    lt_new_texts     TYPE TABLE FOR CREATE
      zi_zcg_rap_mbo_head\_Text,

    lt_missing_texts TYPE TABLE FOR CREATE
      zi_zcg_rap_mbo_head\_Text,

    lt_text_updates  TYPE TABLE FOR UPDATE
      zi_zcg_rap_mbo_head_text,

    lt_rel_create    TYPE abp_behv_relating_tab,
    lt_rel_update    TYPE abp_behv_relating_tab,
    lt_rel_cba       TYPE abp_behv_relating_tab.

  "Text for a newly created header
  LOOP AT entities_create INTO DATA(ls_create).

    DATA(lv_create_index) = sy-tabix.
    APPEND lv_create_index TO lt_rel_create.

    APPEND VALUE #(
      %cid_ref  = ls_create-%cid
      %is_draft = ls_create-%is_draft
      %target   = VALUE #(
        (
          %cid        = |NEW_TEXT_{ lv_create_index }|
          %is_draft   = ls_create-%is_draft
          Language    = sy-langu
          Description = ls_create-Description
          %control    = VALUE #(
            Language    = if_abap_behv=>mk-on
            Description = ls_create-%control-Description
          )
        )
      )
    ) TO lt_new_texts.

  ENDLOOP.

  IF lt_new_texts IS NOT INITIAL.

    MODIFY AUGMENTING ENTITIES OF zi_zcg_rap_mbo_head
      ENTITY DocumentHeader
        CREATE BY \_Text
        FROM lt_new_texts
        RELATING TO entities_create BY lt_rel_create.

  ENDIF.

  IF entities_update IS INITIAL.
    RETURN.
  ENDIF.


  READ ENTITIES OF zi_zcg_rap_mbo_head
    ENTITY DocumentHeader
      BY \_Text
      FROM CORRESPONDING #( entities_update )
      LINK DATA(lt_links)
    FAILED DATA(ls_read_failed).

  LOOP AT entities_update INTO DATA(ls_update)
    WHERE %control-Description = if_abap_behv=>mk-on.

    DATA(lv_update_index) = sy-tabix.

    IF line_exists(
         ls_read_failed-documentheader[
           %tky = ls_update-%tky
         ]
       )
       AND NOT line_exists(
         lt_new_texts[
           %cid_ref  = ls_update-%cid_ref
           %is_draft = ls_update-%is_draft
         ]
       ).
      CONTINUE.
    ENDIF.

    READ TABLE lt_links INTO DATA(ls_link)
      WITH KEY
        source-%tky   = ls_update-%tky
        target-Language = sy-langu.

    IF sy-subrc = 0.

      APPEND lv_update_index TO lt_rel_update.

      APPEND VALUE #(
        %tky        = ls_link-target-%tky
        Description = ls_update-Description
        %control    = VALUE #(
          Description = if_abap_behv=>mk-on
        )
      ) TO lt_text_updates.

    ELSE.

      READ TABLE lt_new_texts INTO DATA(ls_new_text)
        WITH KEY
          %cid_ref  = ls_update-%cid_ref
          %is_draft = ls_update-%is_draft.

      IF sy-subrc = 0.

        "Update a text created in this same request
        APPEND lv_update_index TO lt_rel_update.

        APPEND VALUE #(
          %cid_ref    = ls_new_text-%target[ 1 ]-%cid
          %is_draft   = ls_update-%is_draft
          Description = ls_update-Description
          %control    = VALUE #(
            Description = if_abap_behv=>mk-on
          )
        ) TO lt_text_updates.

      ELSE.

        "Create the first text for this header and language
        APPEND lv_update_index TO lt_rel_cba.

        APPEND VALUE #(
          %tky      = ls_update-%tky
          %cid_ref  = ls_update-%cid_ref
          %target   = VALUE #(
            (
              %cid        = |FIRST_TEXT_{ lv_update_index }|
              %is_draft   = ls_update-%is_draft
              Language    = sy-langu
              Description = ls_update-Description
              %control    = VALUE #(
                Language    = if_abap_behv=>mk-on
                Description = if_abap_behv=>mk-on
              )
            )
          )
        ) TO lt_missing_texts.

      ENDIF.

    ENDIF.

  ENDLOOP.

  IF lt_text_updates IS NOT INITIAL
     OR lt_missing_texts IS NOT INITIAL.

    MODIFY AUGMENTING ENTITIES OF zi_zcg_rap_mbo_head
      ENTITY DocumentText
        UPDATE FROM lt_text_updates
        RELATING TO entities_update BY lt_rel_update

      ENTITY DocumentHeader
        CREATE BY \_Text
        FROM lt_missing_texts
        RELATING TO entities_update BY lt_rel_cba.

  ENDIF.

ENDMETHOD.

ENDCLASS.
