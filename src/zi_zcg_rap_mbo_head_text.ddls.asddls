@AccessControl.authorizationCheck: #NOT_REQUIRED
@EndUserText.label: 'Document headers BO  texts view'
@ObjectModel.dataCategory: #TEXT
define view entity ZI_ZCG_RAP_MBO_HEAD_TEXT
  as select from zcg_rap_mbo_htex as HeadText
  association to parent ZI_ZCG_RAP_mbo_HEAD as _Header on $projection.HeaderId = _Header.Uuid
{
  key HeadText.header_id   as HeaderId,
      @Semantics.language: true
  key HeadText.language    as Language,
      @Semantics.text: true
      HeadText.description as Description,
      _Header
}
