@AbapCatalog.viewEnhancementCategory: [#NONE]
@AccessControl.authorizationCheck: #NOT_REQUIRED
@EndUserText.label: 'Document headers BO view'
@Metadata.ignorePropagatedAnnotations: true
define root view entity ZI_ZCG_RAP_mbo_HEAD
  as select from zcg_rap_mbo_head

  composition [0..*] of ZI_ZCG_RAP_mbo_ITEM      as _Items //on $projection.Uuid = _Items.HeaderId

  composition [0..*] of ZI_ZCG_RAP_MBO_HEAD_TEXT as _Text

  association [0..1] to ZI_ZCG_RAP_MBO_HEAD_SUM  as _Totals   on $projection.Uuid = _Totals.HeaderId

  //  association [0..*] to ZI_ZCG_RAP_mbo_ITEM as _Items    on $projection.Uuid = _Items.HeaderId

  association [1..1] to /DMO/I_Customer          as _Customer on $projection.CustomerId = _Customer.CustomerID
{
  key uuid                       as Uuid,
      document_number            as DocumentNumber,
      customer_id                as CustomerId,
      created_by                 as CreatedBy,
      created_at                 as CreatedAt,
      last_changed_by            as LastChangedBy,
      last_changed_at            as LastChangedAt,
      local_lastchanged_at       as LocalLastchangedAt,
      cast( 'EUR' as abap.cuky ) as CurrencyEUR,

      @Semantics.amount.currencyCode: 'CurrencyEUR'
      cast(
        coalesce(
          cast( _Totals.TotalValueEUR as abap.dec(23,2) ),
          cast( 0 as abap.dec(23,2) )
        )
        as abap.curr(23,2)
      )                          as TotalValueEUR,

      coalesce(
        _Totals.TotalCriticality,
        cast( 1 as abap.int1 )
      )                          as TotalCriticality,

      _Items,
      _Customer,
      _Text

}
