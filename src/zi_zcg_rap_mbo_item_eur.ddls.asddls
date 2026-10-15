@AccessControl.authorizationCheck: #NOT_REQUIRED
@EndUserText.label: 'Document item values in EUR'
define view entity ZI_ZCG_RAP_MBO_ITEM_EUR
  as select from zcg_rap_mbo_item as Item
    inner join zcg_rap_mbo_comp as Component
      on Item.component_id = Component.uuid
{
  key Item.uuid      as Uuid,
      Item.header_id as HeaderId,

      cast( 'EUR' as abap.cuky ) as CurrencyEUR,

      @Semantics.amount.currencyCode: 'CurrencyEUR'
      cast(
        currency_conversion(
          amount             => cast( Item.value as abap.decfloat34 ),
          source_currency    => Component.currency_code,
          target_currency    => cast( 'EUR' as abap.cuky ),
          exchange_rate_date => $session.system_date,
          exchange_rate_type => 'M',
          error_handling     => 'FAIL_ON_ERROR'
        )
        as abap.dec(23,2)
      ) as ValueEUR
}
