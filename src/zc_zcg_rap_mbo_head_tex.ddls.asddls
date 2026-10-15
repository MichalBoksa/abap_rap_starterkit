@AccessControl.authorizationCheck: #NOT_REQUIRED
@EndUserText.label: 'Projection CDS view for HEAD texts entity'
@Metadata.ignorePropagatedAnnotations: true
define view entity ZC_ZCG_RAP_MBO_HEAD_TEX
  as projection on ZI_ZCG_RAP_MBO_HEAD_TEXT
{
  key HeaderId,
  key Language,
      Description,

      @EndUserText.label: 'Description'
      _Header : redirected to parent ZC_ZCG_RAP_MBO_HEAD
}
