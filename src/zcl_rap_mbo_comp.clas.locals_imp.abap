CLASS lhc_Component DEFINITION INHERITING FROM cl_abap_behavior_handler.
  PRIVATE SECTION.

    METHODS get_global_authorizations FOR GLOBAL AUTHORIZATION
      REQUEST requested_authorizations FOR Component RESULT result.

    METHODS setMatnr FOR DETERMINE ON SAVE
       keys FOR Component~setMatnr.
    METHODS get_instance_features FOR INSTANCE FEATURES
      keys REQUEST requested_features FOR Component RESULT result.

ENDCLASS.

CLASS lhc_Component IMPLEMENTATION.

  METHOD get_global_authorizations.
  ENDMETHOD.

  METHOD setMatnr.
  ENDMETHOD.

  METHOD get_instance_features.
  ENDMETHOD.

ENDCLASS.
