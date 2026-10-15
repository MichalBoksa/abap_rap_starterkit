@AbapCatalog.sqlViewName: 'ZMBOCOMPV'
@AccessControl.authorizationCheck: #NOT_REQUIRED
@EndUserText.label: 'Components BO view'
@Metadata.ignorePropagatedAnnotations: true
define root view ZI_ZCG_RAP_mbo_COMP
  as select from zcg_rap_mbo_comp
  
  association [0..1] to I_Currency as _Currency
    on $projection.CurrencyCode = _Currency.Currency
    
    association [0..1] to I_UnitOfMeasure as _UOM
        on $projection.UnitOfMeasure = _UOM.UnitOfMeasure
{
  key uuid                 as Uuid,
      matnr                as Matnr,
      maktx                as Maktx,
      price                as Price,
      currency_code        as CurrencyCode,
      unit_of_measure      as UnitOfMeasure,
      @Semantics.user.createdBy: true
      created_by           as CreatedBy,
      @Semantics.systemDateTime.createdAt: true
      created_at           as CreatedAt,
      @Semantics.user.lastChangedBy: true
      last_changed_by      as LastChangedBy,
      @Semantics.systemDateTime.lastChangedAt: true
      last_changed_at      as LastChangedAt,
      @Semantics.systemDateTime.localInstanceLastChangedAt: true
      local_lastchanged_at as LocalLastchangedAt,
      
      _Currency,
      _UOM
      
}
