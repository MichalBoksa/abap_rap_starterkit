@AccessControl.authorizationCheck: #NOT_REQUIRED
@EndUserText.label: 'Document items BO view'
@Metadata.ignorePropagatedAnnotations: true
define view entity ZI_ZCG_RAP_mbo_ITEM
  as select from zcg_rap_mbo_item as Items

  association to parent ZI_ZCG_RAP_mbo_HEAD as _Header    on $projection.HeaderId = _Header.Uuid

  association [1..1] to ZI_ZCG_RAP_mbo_COMP as _Component on $projection.ComponentId = _Component.Uuid

  association [0..1] to I_UnitOfMeasure     as _UOM       on $projection.UnitOfMeasure = _UOM.UnitOfMeasure
{
  key Items.uuid                 as Uuid,
      Items.header_id            as HeaderId,

      _Header.DocumentNumber     as DocumentNumber,

      Items.item_number          as ItemNumber,
      Items.component_id         as ComponentId,

      @Semantics.quantity.unitOfMeasure: 'UnitOfMeasure'
      Items.quantity             as Quantity,
      
      _Component.UnitOfMeasure   as UnitOfMeasure,
      
      @Semantics.amount.currencyCode: 'CurrencyCode'
      Items.value                as Value,

      _Component.CurrencyCode    as CurrencyCode,

      Items.created_by           as CreatedBy,
      Items.created_at           as CreatedAt,
      Items.last_changed_by      as LastChangedBy,
      Items.last_changed_at      as LastChangedAt,
      Items.local_lastchanged_at as LocalLastChangedAt,

      _Header,
      _Component,
      _UOM
}
